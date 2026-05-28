import { prisma } from '../../config/database'
import { AppError } from '../../utils/app-error'
import { CreatePaymentDto } from '../orders/order.validation'
import { NotificationService } from '../notifications/notification.service'

const notificationService = new NotificationService()

export class PaymentService {
  async createPayment(orderId: string, customerId: string, body: CreatePaymentDto) {
    const order = await prisma.preOrder.findUnique({
      where: { id: orderId },
      include: { payment: true, customer: { select: { name: true } } },
    })

    if (!order) throw new AppError('Pesanan tidak ditemukan.', 404)
    if (order.customerId !== customerId) throw new AppError('Anda tidak memiliki akses ke pesanan ini.', 403)
    if (order.status !== 'waiting_payment') throw new AppError('Pesanan tidak dalam status menunggu pembayaran.', 400)
    if (order.payment) throw new AppError('Pembayaran sudah dibuat untuk pesanan ini.', 409)

    // Simulasi: langsung buat payment dan set status paid + escrow held
    const result = await prisma.$transaction(async (tx) => {
      const payment = await tx.payment.create({
        data: {
          orderId,
          amount: order.totalPrice,
          method: body.method,
          status: 'paid',
          escrowStatus: 'held',
          paidAt: new Date(),
          paymentReference: `PAY-${Date.now()}`,
        },
      })

      await tx.preOrder.update({
        where: { id: orderId },
        data: { status: 'paid_escrow' },
      })

      await tx.orderStatusHistory.create({
        data: { orderId, status: 'paid_escrow', notes: 'Pembayaran diterima (simulasi).', updatedById: customerId },
      })

      return payment
    })

    // Notify farmer
    await notificationService.create({
      userId: order.farmerId,
      type: 'order_paid',
      title: 'Pesanan Baru Dibayar',
      message: `Pesanan dari ${order.customer.name} telah dibayar.`,
      data: { orderId },
      event: 'order.paid',
    })

    return result
  }

  async getStatus(orderId: string, customerId: string) {
    const order = await prisma.preOrder.findUnique({
      where: { id: orderId },
      include: { payment: true },
    })

    if (!order) throw new AppError('Pesanan tidak ditemukan.', 404)
    if (order.customerId !== customerId) throw new AppError('Anda tidak memiliki akses ke pesanan ini.', 403)

    if (!order.payment) {
      return { status: 'unpaid', escrowStatus: 'unpaid', amount: order.totalPrice }
    }

    return {
      id: order.payment.id,
      status: order.payment.status,
      escrowStatus: order.payment.escrowStatus,
      amount: order.payment.amount,
      method: order.payment.method,
      paymentReference: order.payment.paymentReference,
      paidAt: order.payment.paidAt,
      releasedAt: order.payment.releasedAt,
    }
  }
}
