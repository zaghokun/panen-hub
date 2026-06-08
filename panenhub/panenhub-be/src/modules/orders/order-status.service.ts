import { OrderStatus } from '@prisma/client'
import { prisma } from '../../config/database'
import { AppError } from '../../utils/app-error'
import { NotificationService } from '../notifications/notification.service'

// Transisi yang diizinkan untuk farmer
const FARMER_TRANSITIONS: Record<string, OrderStatus[]> = {
  paid_escrow: ['pre_order_confirmed', 'harvesting'],
  pre_order_confirmed: ['harvesting'],
  harvesting: ['sorting_qc'],
  sorting_qc: ['shipped'],
}

interface UpdateStatusDto {
  status: OrderStatus
  notes?: string
  courierName?: string
  trackingNumber?: string
}

const notificationService = new NotificationService()

export class OrderStatusService {
  async updateStatus(orderId: string, farmerId: string, body: UpdateStatusDto) {
    const order = await prisma.preOrder.findUnique({
      where: { id: orderId },
      include: { customer: { select: { name: true } }, commodity: { select: { name: true } } },
    })

    if (!order) throw new AppError('Pesanan tidak ditemukan.', 404)
    if (order.farmerId !== farmerId) throw new AppError('Anda tidak memiliki akses ke pesanan ini.', 403)

    // Validasi transisi
    const allowed = FARMER_TRANSITIONS[order.status]
    if (!allowed || !allowed.includes(body.status)) {
      throw new AppError(`Transisi dari "${order.status}" ke "${body.status}" tidak diizinkan.`, 400)
    }

    // Validasi shipped wajib courierName + trackingNumber
    if (body.status === 'shipped') {
      if (!body.courierName || !body.trackingNumber) {
        throw new AppError('courierName dan trackingNumber wajib diisi untuk status shipped.', 400)
      }
    }

    const updated = await prisma.$transaction(async (tx) => {
      const updatedOrder = await tx.preOrder.update({
        where: { id: orderId },
        data: { status: body.status },
      })

      await tx.orderStatusHistory.create({
        data: {
          orderId,
          status: body.status,
          notes: body.notes,
          updatedById: farmerId,
          courierName: body.courierName,
          trackingNumber: body.trackingNumber,
        },
      })

      return updatedOrder
    })

    // Kirim notifikasi ke customer
    const statusLabels: Record<string, string> = {
      pre_order_confirmed: 'Pre-order Dikonfirmasi',
      harvesting: 'Sedang Dipanen',
      sorting_qc: 'Sortir & Quality Control',
      shipped: 'Dikirim',
    }

    const title = statusLabels[body.status] || 'Status Diperbarui'
    const message = body.status === 'shipped'
      ? `Pesanan ${order.commodity.name} telah dikirim via ${body.courierName} (${body.trackingNumber}).`
      : `Pesanan ${order.commodity.name} diperbarui ke status: ${title}.`

    await notificationService.create({
      userId: order.customerId,
      type: body.status === 'shipped' ? 'order_shipped' : 'order_status_updated',
      title,
      message,
      data: { orderId, status: body.status },
      event: body.status === 'shipped' ? 'order.shipped' : 'order.status_updated',
    })

    return updated
  }
}
