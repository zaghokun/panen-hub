import { prisma } from '../../config/database'
import { AppError } from '../../utils/app-error'
import { getFileUrl } from '../../utils/file-url'
import { NotificationService } from '../notifications/notification.service'

const notificationService = new NotificationService()

interface SubmitQcDto {
  conditionStatus: string
  quantityStatus: string
  qualityNotes?: string
}

export class QcService {
  async submit(orderId: string, customerId: string, body: SubmitQcDto, photoFilename?: string) {
    const order = await prisma.preOrder.findUnique({
      where: { id: orderId },
      include: { qualityControl: true, payment: true, commodity: { select: { name: true } } },
    })

    if (!order) throw new AppError('Pesanan tidak ditemukan.', 404)
    if (order.customerId !== customerId) throw new AppError('Anda tidak memiliki akses ke pesanan ini.', 403)
    if (order.status !== 'delivered') throw new AppError('QC hanya bisa dilakukan setelah barang diterima (status delivered).', 400)
    if (order.qualityControl) throw new AppError('QC sudah pernah disubmit untuk pesanan ini.', 409)

    const isGood = body.conditionStatus === 'good' && body.quantityStatus === 'complete'

    const result = await prisma.$transaction(async (tx) => {
      // Simpan QC
      const qc = await tx.qualityControl.create({
        data: {
          orderId,
          conditionStatus: body.conditionStatus,
          quantityStatus: body.quantityStatus,
          qualityNotes: body.qualityNotes,
          photoUrl: photoFilename ? getFileUrl('qc', photoFilename) : null,
          submittedById: customerId,
        },
      })

      if (isGood) {
        // QC baik → completed + release escrow + wallet farmer
        await tx.preOrder.update({ where: { id: orderId }, data: { status: 'completed' } })

        await tx.orderStatusHistory.create({
          data: { orderId, status: 'completed', notes: 'QC baik, pesanan selesai.', updatedById: customerId },
        })

        if (order.payment) {
          await tx.payment.update({
            where: { id: order.payment.id },
            data: { escrowStatus: 'released', releasedAt: new Date() },
          })
        }

        await tx.wallet.update({
          where: { farmerId: order.farmerId },
          data: {
            balanceAvailable: { increment: order.totalPrice },
            totalEarned: { increment: order.totalPrice },
          },
        })
      }

      return qc
    })

    // Notifikasi
    if (isGood) {
      await notificationService.create({
        userId: order.farmerId,
        type: 'order_completed',
        title: 'Pesanan Selesai',
        message: `Pesanan ${order.commodity.name} telah selesai. Dana telah masuk ke wallet Anda.`,
        data: { orderId },
        event: 'order.completed',
      })
    }

    return { qc: result, orderCompleted: isGood }
  }
}
