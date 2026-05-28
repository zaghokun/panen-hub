import { Request, Response, NextFunction } from 'express'
import { FarmerProfileService } from './farmer-profile.service'
import { successResponse } from '../../../utils/response'

export class FarmerProfileController {
  private service = new FarmerProfileService()

  get = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const data = await this.service.getProfile(req.user!.id)
      res.json(successResponse(data))
    } catch (error) {
      next(error)
    }
  }

  update = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const data = await this.service.updateProfile(req.user!.id, req.body, req.file?.filename)
      res.json(successResponse(data, 'Profil berhasil diperbarui.'))
    } catch (error) {
      next(error)
    }
  }
}
