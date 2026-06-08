import { Request, Response, NextFunction } from 'express'
import { PaymentService } from './payment.service'
import { successResponse } from '../../utils/response'

export class PaymentController {
  private service = new PaymentService()

  create = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const data = await this.service.createPayment(req.params.id, req.user!.id, req.body)
      res.status(201).json(successResponse(data, 'Pembayaran berhasil (simulasi).'))
    } catch (error) {
      next(error)
    }
  }

  status = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const data = await this.service.getStatus(req.params.id, req.user!.id)
      res.json(successResponse(data))
    } catch (error) {
      next(error)
    }
  }
}
