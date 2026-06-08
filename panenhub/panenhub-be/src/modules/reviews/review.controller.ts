import { Request, Response, NextFunction } from 'express'
import { ReviewService } from './review.service'
import { successResponse } from '../../utils/response'

export class ReviewController {
  private service = new ReviewService()

  create = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const data = await this.service.create(req.params.id, req.user!.id, req.body)
      res.status(201).json(successResponse(data, 'Ulasan berhasil diberikan.'))
    } catch (error) {
      next(error)
    }
  }

  list = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const farmerId = req.query.farmerId as string
      if (!farmerId) {
        res.status(400).json({ success: false, message: 'farmerId wajib diisi.' })
        return
      }
      const data = await this.service.listByFarmer(farmerId)
      res.json(successResponse(data))
    } catch (error) {
      next(error)
    }
  }
}
