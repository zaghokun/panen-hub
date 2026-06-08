import { Request, Response, NextFunction } from 'express'
import { DisputeService } from './dispute.service'
import { successResponse } from '../../utils/response'

export class DisputeController {
  private service = new DisputeService()

  create = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const files = req.files as Express.Multer.File[] | undefined
      const data = await this.service.create(req.params.id, req.user!.id, req.body, files)
      res.status(201).json(successResponse(data, 'Sengketa berhasil diajukan.'))
    } catch (error) {
      next(error)
    }
  }

  detail = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const data = await this.service.getDetail(req.params.id, req.user!.id)
      res.json(successResponse(data))
    } catch (error) {
      next(error)
    }
  }
}
