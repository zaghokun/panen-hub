import { prisma } from '../../config/database'
import { AppError } from '../../utils/app-error'
import { getFileUrl } from '../../utils/file-url'
import { NotificationService } from '../notifications/notification.service'
import { CreateDisputeDto } from './dispute.validation'

const notificationService = new NotificationService()

export class DisputeService {
  async create(orderId: string, customerId: string, body: CreateDisputeDto, files?: Express.Multer.File[]) {
    const order = await prisma.preOrder.findUnique({
      where: { id: orderId },
      include: { dispute: true, commodity: { select: { name: true } } },
    })

    if (!order) throw new AppError('Pesanan tidak ditemukan.', 404)
    if (order.customerId !== customerId) throw new AppError('Anda tidak memiliki akses ke pesanan ini.', 403)
    if (order.status !== 'delivered' && order.status !== 'completed') {
      throw new AppError('Sengketa hanya bisa diajukan untuk pesanan yang sudah diterima.', 400)
    }
    if (order.dispute) throw new AppError('Sengketa sudah pernah diajukan untuk pesanan ini.', 409)

    const result = await prisma.$transaction(async (tx) => {
      // Update order status ke disputed
      await tx.preOrder.update({ where: { id: orderId }, data: { status: 'disputed' } })

      await tx.orderStatusHistory.create({
        data: { orderId, status: 'disputed', notes: `Sengketa: ${body.reason}`, updatedById: customerId },
      })

      // Buat dispute
      const dispute = await tx.dispute.create({
        data: {
          orderId,
          customerId,
          farmerId: order.farmerId,
          reason: body.reason,
          description: body.description,
          quantityProblematic: body.quantityProblematic,
        },
      })

      // Upload evidence
      if (files && files.length > 0) {
        await tx.disputeEvidence.createMany({
          data: files.map((file) => ({
            disputeId: dispute.id,
            fileUrl: getFileUrl('disputes', file.filename),
            fileType: file.mimetype,
          })),
        })
      }

      return dispute
    })

    // Notifikasi ke admin (semua admin)
    const admins = await prisma.user.findMany({ where: { role: 'admin' }, select: { id: true } })
    for (const admin of admins) {
      await notificationService.create({
        userId: admin.id,
        type: 'dispute_submitted',
        title: 'Sengketa Baru',
        message: `Sengketa diajukan untuk pesanan ${order.commodity.name}.`,
        data: { disputeId: result.id, orderId },
        event: 'dispute.submitted',
      })
    }

    return result
  }

  async getDetail(disputeId: string, userId: string) {
    const dispute = await prisma.dispute.findUnique({
      where: { id: disputeId },
      include: {
        order: { select: { id: true, status: true, totalPrice: true, commodity: { select: { name: true } } } },
        customer: { select: { id: true, name: true } },
        farmer: { select: { id: true, name: true } },
        evidences: true,
      },
    })

    if (!dispute) throw new AppError('Sengketa tidak ditemukan.', 404)
    if (dispute.customerId !== userId && dispute.farmerId !== userId) {
      throw new AppError('Anda tidak memiliki akses ke sengketa ini.', 403)
    }

    return dispute
  }
}
