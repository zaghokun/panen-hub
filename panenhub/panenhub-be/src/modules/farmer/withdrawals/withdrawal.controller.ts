import { Request, Response, NextFunction } from 'express'
import { WithdrawalService } from './withdrawal.service'
import { successResponse, paginatedResponse } from '../../../utils/response'

export class WithdrawalController {
  private service = new WithdrawalService()

  create = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const data = await this.service.create(req.user!.id, req.body)
      res.status(201).json(successResponse(data, 'Withdrawal berhasil diajukan.'))
    } catch (error) {
      next(error)
    }
  }

  list = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const { data, meta } = await this.service.list(req.user!.id, req.query as Record<string, string>)
      res.json(paginatedResponse(data, 'Berhasil.', meta))
    } catch (error) {
      next(error)
    }
  }
}
