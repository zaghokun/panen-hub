import { Request, Response, NextFunction } from 'express'
import { AuthService } from './auth.service'
import { successResponse } from '../../utils/response'

export class AuthController {
  private authService = new AuthService()

  login = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const data = await this.authService.login(req.body)
      res.status(200).json(successResponse(data, 'Login berhasil.'))
    } catch (error) {
      next(error)
    }
  }

  registerCustomer = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const data = await this.authService.registerCustomer(req.body)
      res.status(201).json(successResponse(data, 'Registrasi customer berhasil.'))
    } catch (error) {
      next(error)
    }
  }

  registerFarmer = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const photoFilename = req.file?.filename
      const data = await this.authService.registerFarmer(req.body, photoFilename)
      res.status(201).json(successResponse(data, 'Registrasi farmer berhasil.'))
    } catch (error) {
      next(error)
    }
  }

  refresh = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const data = await this.authService.refresh(req.body)
      res.status(200).json(successResponse(data, 'Token berhasil diperbarui.'))
    } catch (error) {
      next(error)
    }
  }

  logout = async (_req: Request, res: Response, _next: NextFunction) => {
    res.status(200).json(successResponse(null, 'Logout berhasil.'))
  }

  me = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const data = await this.authService.me(req.user!.id)
      res.status(200).json(successResponse(data))
    } catch (error) {
      next(error)
    }
  }
}
