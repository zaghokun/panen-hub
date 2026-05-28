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
}
