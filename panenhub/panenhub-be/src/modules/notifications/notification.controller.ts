import { Request, Response, NextFunction } from 'express'
import { NotificationService } from './notification.service'
import { successResponse, paginatedResponse } from '../../utils/response'

export class NotificationController {
  private service = new NotificationService()

  list = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const { data, meta } = await this.service.list(req.user!.id, req.query as Record<string, string>)
      res.json(paginatedResponse(data, 'Berhasil.', meta))
    } catch (error) {
      next(error)
    }
  }

  markRead = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const data = await this.service.markRead(req.params.id, req.user!.id)
      res.json(successResponse(data, 'Notifikasi ditandai dibaca.'))
    } catch (error) {
      next(error)
    }
  }

  markAllRead = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const data = await this.service.markAllRead(req.user!.id)
      res.json(successResponse(data, 'Semua notifikasi ditandai dibaca.'))
    } catch (error) {
      next(error)
    }
  }
}
