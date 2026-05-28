import { Request, Response, NextFunction } from 'express'
import { AdminService } from './admin.service'
import { successResponse, paginatedResponse } from '../../utils/response'

export class AdminController {
  private service = new AdminService()

  dashboard = async (_req: Request, res: Response, next: NextFunction) => {
    try {
      const data = await this.service.dashboard()
      res.json(successResponse(data))
    } catch (error) {
      next(error)
    }
  }

  verifyFarmer = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const data = await this.service.verifyFarmer(req.params.id, req.body)
      res.json(successResponse(data, 'Verifikasi berhasil diproses.'))
    } catch (error) {
      next(error)
    }
  }

  decideDispute = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const data = await this.service.decideDispute(req.params.id, req.body)
      res.json(successResponse(data, 'Keputusan sengketa berhasil.'))
    } catch (error) {
      next(error)
    }
  }

  approveWithdrawal = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const data = await this.service.approveWithdrawal(req.params.id, req.body)
      res.json(successResponse(data, 'Withdrawal disetujui.'))
    } catch (error) {
      next(error)
    }
  }

  rejectWithdrawal = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const data = await this.service.rejectWithdrawal(req.params.id, req.body)
      res.json(successResponse(data, 'Withdrawal ditolak.'))
    } catch (error) {
      next(error)
    }
  }

  listWithdrawals = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const { data, meta } = await this.service.listWithdrawals(req.query as Record<string, string>)
      res.json(paginatedResponse(data, 'Berhasil.', meta))
    } catch (error) {
      next(error)
    }
  }

  listDisputes = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const { data, meta } = await this.service.listDisputes(req.query as Record<string, string>)
      res.json(paginatedResponse(data, 'Berhasil.', meta))
    } catch (error) {
      next(error)
    }
  }
}
