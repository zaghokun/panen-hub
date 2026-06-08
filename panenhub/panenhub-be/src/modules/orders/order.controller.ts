import { Request, Response, NextFunction } from 'express'
import { OrderService } from './order.service'
import { OrderStatusService } from './order-status.service'
import { successResponse, paginatedResponse } from '../../utils/response'

export class OrderController {
  private service = new OrderService()
  private statusService = new OrderStatusService()

  create = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const data = await this.service.create(req.user!.id, req.body)
      res.status(201).json(successResponse(data, 'Pre-order berhasil dibuat.'))
    } catch (error) {
      next(error)
    }
  }

  listCustomer = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const { data, meta } = await this.service.listByCustomer(req.user!.id, req.query as Record<string, string>)
      res.json(paginatedResponse(data, 'Berhasil.', meta))
    } catch (error) {
      next(error)
    }
  }

  listFarmer = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const { data, meta } = await this.service.listByFarmer(req.user!.id, req.query as Record<string, string>)
      res.json(paginatedResponse(data, 'Berhasil.', meta))
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

  confirmReceipt = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const data = await this.service.confirmReceipt(req.params.id, req.user!.id, req.body)
      res.json(successResponse(data, 'Konfirmasi penerimaan berhasil.'))
    } catch (error) {
      next(error)
    }
  }

  updateStatus = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const data = await this.statusService.updateStatus(req.params.id, req.user!.id, req.body)
      res.json(successResponse(data, 'Status pesanan berhasil diperbarui.'))
    } catch (error) {
      next(error)
    }
  }
}
