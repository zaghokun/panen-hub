import { Request, Response, NextFunction } from 'express'
import { CommodityService } from './commodity.service'
import { successResponse, paginatedResponse } from '../../utils/response'

export class CommodityController {
  private service = new CommodityService()

  // Public
  list = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const { data, meta } = await this.service.listPublic(req.query as Record<string, string>)
      res.json(paginatedResponse(data, 'Berhasil.', meta))
    } catch (error) {
      next(error)
    }
  }

  detail = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const data = await this.service.getDetail(req.params.id)
      res.json(successResponse(data))
    } catch (error) {
      next(error)
    }
  }

  // Farmer
  listMine = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const { data, meta } = await this.service.listByFarmer(req.user!.id, req.query as Record<string, string>)
      res.json(paginatedResponse(data, 'Berhasil.', meta))
    } catch (error) {
      next(error)
    }
  }

  create = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const data = await this.service.create(req.user!.id, req.body, req.file?.filename)
      res.status(201).json(successResponse(data, 'Komoditas berhasil ditambahkan.'))
    } catch (error) {
      next(error)
    }
  }

  update = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const data = await this.service.update(req.user!.id, req.params.id, req.body, req.file?.filename)
      res.json(successResponse(data, 'Komoditas berhasil diperbarui.'))
    } catch (error) {
      next(error)
    }
  }

  remove = async (req: Request, res: Response, next: NextFunction) => {
    try {
      await this.service.delete(req.user!.id, req.params.id)
      res.json(successResponse(null, 'Komoditas berhasil dinonaktifkan.'))
    } catch (error) {
      next(error)
    }
  }
}
