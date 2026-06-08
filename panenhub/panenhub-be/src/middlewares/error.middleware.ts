import { Request, Response, NextFunction } from 'express'
import { AppError } from '../utils/app-error'

export const errorMiddleware = (
  err: Error,
  _req: Request,
  res: Response,
  _next: NextFunction
) => {
  if (err instanceof AppError) {
    return res.status(err.statusCode).json({
      success: false,
      message: err.message,
      errors: err.errors,
    })
  }

  console.error(err)
  res.status(500).json({
    success: false,
    message: 'Terjadi kesalahan pada server.',
  })
}
