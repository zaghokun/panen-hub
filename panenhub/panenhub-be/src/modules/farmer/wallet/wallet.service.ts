import { prisma } from '../../../config/database'
import { AppError } from '../../../utils/app-error'

export class WalletService {
  async getWallet(farmerId: string) {
    const wallet = await prisma.wallet.findUnique({ where: { farmerId } })
    if (!wallet) throw new AppError('Wallet tidak ditemukan.', 404)
    return wallet
  }
}
