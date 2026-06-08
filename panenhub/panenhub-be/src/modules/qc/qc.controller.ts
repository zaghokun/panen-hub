import { Request, Response, NextFunction } from 'express'
import { QcService } from './qc.service'
import { successResponse } from '../../utils/response'

export class QcController {
  private service = new QcService()

  submit = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const data = await this.service.submit(req.params.id, req.user!.id, req.body, req.file?.filename)
      const message = data.orderCompleted
        ? 'QC berhasil. Pesanan selesai, dana dirilis ke farmer.'
        : 'QC berhasil disubmit. Silakan ajukan sengketa jika ada masalah.'
      res.status(201).json(successResponse(data, message))
    } catch (error) {
      next(error)
    }
  }
}
