import { prisma } from '../../../config/database'
import { AppError } from '../../../utils/app-error'
import { getPaginationParams, buildPaginationMeta } from '../../../utils/pagination'
import { CreateWithdrawalDto } from './withdrawal.validation'

export class WithdrawalService {
  async create(farmerId: string, body: CreateWithdrawalDto) {
    const wallet = await prisma.wallet.findUnique({ where: { farmerId } })
    if (!wallet) throw new AppError('Wallet tidak ditemukan.', 404)
    if (wallet.balanceAvailable < body.amount) {
      throw new AppError(`Saldo tidak cukup. Saldo tersedia: Rp ${wallet.balanceAvailable}.`, 400)
    }

    const result = await prisma.$transaction(async (tx) => {
      await tx.wallet.update({
        where: { farmerId },
        data: { balanceAvailable: { decrement: body.amount } },
      })

      return tx.withdrawal.create({
        data: {
          farmerId,
          amount: body.amount,
          bankName: body.bankName,
          accountNumber: body.accountNumber,
          accountHolderName: body.accountHolderName,
        },
      })
    })

    return result
  }

  async list(farmerId: string, query: { page?: string; per_page?: string }) {
    const { page, perPage, skip, take } = getPaginationParams(query)

    const [data, total] = await Promise.all([
      prisma.withdrawal.findMany({
        where: { farmerId },
        skip,
        take,
        orderBy: { requestedAt: 'desc' },
      }),
      prisma.withdrawal.count({ where: { farmerId } }),
    ])

    return { data, meta: buildPaginationMeta(page, perPage, total) }
  }
}
