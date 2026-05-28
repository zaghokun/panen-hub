import { Request, Response, NextFunction } from 'express'
import { WalletService } from './wallet.service'
import { successResponse } from '../../../utils/response'

export class WalletController {
  private service = new WalletService()

  get = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const data = await this.service.getWallet(req.user!.id)
      res.json(successResponse(data))
    } catch (error) {
      next(error)
    }
  }
}
