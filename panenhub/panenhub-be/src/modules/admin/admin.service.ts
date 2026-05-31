import { DisputeDecision, Prisma } from '@prisma/client'
import { prisma } from '../../config/database'
import { AppError } from '../../utils/app-error'
import { NotificationService } from '../notifications/notification.service'

const notificationService = new NotificationService()

export class AdminService {
  async dashboard() {
    const [totalUsers, totalFarmers, totalOrders, totalDisputes, pendingWithdrawals, pendingVerifications, activeCommodities] =
      await Promise.all([
        prisma.user.count(),
        prisma.user.count({ where: { role: 'farmer' } }),
        prisma.preOrder.count(),
        prisma.dispute.count({ where: { status: 'submitted' } }),
        prisma.withdrawal.count({ where: { status: 'requested' } }),
        prisma.farmerProfile.count({ where: { verificationStatus: 'pending' } }),
        prisma.commodity.count({ where: { status: 'active' } }),
      ])

    return { totalUsers, totalFarmers, totalOrders, totalDisputes, pendingWithdrawals, pendingVerifications, activeCommodities }
  }

  async listPendingFarmers() {
    return prisma.user.findMany({
      where: { role: 'farmer', farmerProfile: { verificationStatus: 'pending' } },
      select: {
        id: true,
        name: true,
        email: true,
        phone: true,
        role: true,
        createdAt: true,
        farmerProfile: true,
      },
      orderBy: { createdAt: 'desc' },
    })
  }

  async verifyFarmer(userId: string, body: { action: string; notes?: string }) {
    const user = await prisma.user.findUnique({
      where: { id: userId },
      include: { farmerProfile: true },
    })

    if (!user || user.role !== 'farmer') throw new AppError('Farmer tidak ditemukan.', 404)
    if (!user.farmerProfile) throw new AppError('Profil farmer tidak ditemukan.', 404)

    const status = body.action === 'approve' ? 'verified' : 'rejected'

    await prisma.farmerProfile.update({
      where: { userId },
      data: { verificationStatus: status, verificationNotes: body.notes },
    })

    await notificationService.create({
      userId,
      type: body.action === 'approve' ? 'farmer_verified' : 'farmer_rejected',
      title: body.action === 'approve' ? 'Akun Terverifikasi' : 'Verifikasi Ditolak',
      message: body.action === 'approve'
        ? 'Selamat! Akun Anda telah diverifikasi.'
        : `Verifikasi ditolak. ${body.notes || ''}`,
      data: { userId },
      event: body.action === 'approve' ? 'farmer.verified' : 'farmer.rejected',
    })

    return { userId, verificationStatus: status }
  }

  async decideDispute(disputeId: string, body: { decision: string; notes?: string; refundAmount?: number }) {
    const dispute = await prisma.dispute.findUnique({
      where: { id: disputeId },
      include: { order: { include: { payment: true } } },
    })

    if (!dispute) throw new AppError('Sengketa tidak ditemukan.', 404)
    if (dispute.status !== 'submitted' && dispute.status !== 'under_review') {
      throw new AppError('Sengketa sudah diputuskan.', 400)
    }

    if (body.decision === 'partial_refund' && !body.refundAmount) {
      throw new AppError('refundAmount wajib diisi untuk partial_refund.', 400)
    }

    const result = await prisma.$transaction(async (tx) => {
      const updatedDispute = await tx.dispute.update({
        where: { id: disputeId },
        data: {
          status: body.decision === 'request_more_evidence' ? 'under_review' : 'resolved',
          adminDecision: body.decision as DisputeDecision,
          adminNotes: body.notes,
          refundAmount: body.refundAmount,
          closedAt: body.decision !== 'request_more_evidence' ? new Date() : undefined,
        },
      })

      if (body.decision === 'approve_refund' || body.decision === 'partial_refund') {
        const refundAmt = body.decision === 'approve_refund' ? dispute.order.totalPrice : body.refundAmount!

        // Refund: update order + payment
        await tx.preOrder.update({ where: { id: dispute.orderId }, data: { status: 'refunded' } })
        if (dispute.order.payment) {
          await tx.payment.update({
            where: { id: dispute.order.payment.id },
            data: { escrowStatus: 'refunded', refundedAt: new Date() },
          })
        }

        await tx.orderStatusHistory.create({
          data: { orderId: dispute.orderId, status: 'refunded', notes: `Refund: Rp ${refundAmt}` },
        })
      } else if (body.decision === 'reject') {
        // Reject: complete order, release escrow to farmer
        await tx.preOrder.update({ where: { id: dispute.orderId }, data: { status: 'completed' } })
        if (dispute.order.payment) {
          await tx.payment.update({
            where: { id: dispute.order.payment.id },
            data: { escrowStatus: 'released', releasedAt: new Date() },
          })
        }
        await tx.wallet.update({
          where: { farmerId: dispute.farmerId },
          data: {
            balanceAvailable: { increment: dispute.order.totalPrice },
            totalEarned: { increment: dispute.order.totalPrice },
          },
        })

        await tx.orderStatusHistory.create({
          data: { orderId: dispute.orderId, status: 'completed', notes: 'Sengketa ditolak, dana dirilis ke farmer.' },
        })
      }

      return updatedDispute
    })

    // Notify both parties
    for (const userId of [dispute.customerId, dispute.farmerId]) {
      await notificationService.create({
        userId,
        type: 'dispute_decided',
        title: 'Keputusan Sengketa',
        message: `Sengketa telah diputuskan: ${body.decision}.`,
        data: { disputeId, decision: body.decision },
        event: 'dispute.decided',
      })
    }

    return result
  }

  async approveWithdrawal(withdrawalId: string, body: { notes?: string }) {
    const withdrawal = await prisma.withdrawal.findUnique({ where: { id: withdrawalId } })
    if (!withdrawal) throw new AppError('Withdrawal tidak ditemukan.', 404)
    if (withdrawal.status !== 'requested') throw new AppError('Withdrawal sudah diproses.', 400)

    const updated = await prisma.withdrawal.update({
      where: { id: withdrawalId },
      data: { status: 'approved', adminNotes: body.notes, processedAt: new Date() },
    })

    await notificationService.create({
      userId: withdrawal.farmerId,
      type: 'withdrawal_approved',
      title: 'Withdrawal Disetujui',
      message: `Withdrawal Rp ${withdrawal.amount} telah disetujui.`,
      data: { withdrawalId },
      event: 'withdrawal.approved',
    })

    return updated
  }

  async rejectWithdrawal(withdrawalId: string, body: { reason: string }) {
    const withdrawal = await prisma.withdrawal.findUnique({ where: { id: withdrawalId } })
    if (!withdrawal) throw new AppError('Withdrawal tidak ditemukan.', 404)
    if (withdrawal.status !== 'requested') throw new AppError('Withdrawal sudah diproses.', 400)

    const updated = await prisma.$transaction(async (tx) => {
      const result = await tx.withdrawal.update({
        where: { id: withdrawalId },
        data: { status: 'rejected', adminNotes: body.reason, processedAt: new Date() },
      })

      // Kembalikan saldo
      await tx.wallet.update({
        where: { farmerId: withdrawal.farmerId },
        data: { balanceAvailable: { increment: withdrawal.amount } },
      })

      return result
    })

    await notificationService.create({
      userId: withdrawal.farmerId,
      type: 'withdrawal_rejected',
      title: 'Withdrawal Ditolak',
      message: `Withdrawal Rp ${withdrawal.amount} ditolak. Alasan: ${body.reason}`,
      data: { withdrawalId },
      event: 'withdrawal.rejected',
    })

    return updated
  }

  async listWithdrawals(query: { page?: string; per_page?: string }) {
    const page = Math.max(1, parseInt(query.page || '1', 10))
    const perPage = Math.min(100, Math.max(1, parseInt(query.per_page || '10', 10)))
    const skip = (page - 1) * perPage

    const [data, total] = await Promise.all([
      prisma.withdrawal.findMany({
        skip,
        take: perPage,
        orderBy: { requestedAt: 'desc' },
        include: { farmer: { select: { name: true, email: true } } },
      }),
      prisma.withdrawal.count(),
    ])

    return { data, meta: { page, per_page: perPage, total, total_pages: Math.ceil(total / perPage) } }
  }

  async listDisputes(query: { page?: string; per_page?: string }) {
    const page = Math.max(1, parseInt(query.page || '1', 10))
    const perPage = Math.min(100, Math.max(1, parseInt(query.per_page || '10', 10)))
    const skip = (page - 1) * perPage

    const [data, total] = await Promise.all([
      prisma.dispute.findMany({
        skip,
        take: perPage,
        orderBy: { createdAt: 'desc' },
        include: {
          customer: { select: { name: true } },
          farmer: { select: { name: true } },
          order: { select: { totalPrice: true, commodity: { select: { name: true } } } },
        },
      }),
      prisma.dispute.count(),
    ])

    return { data, meta: { page, per_page: perPage, total, total_pages: Math.ceil(total / perPage) } }
  }
}
