import { Request, Response, NextFunction } from 'express'
import jwt from 'jsonwebtoken'
import { jwtConfig } from '../config/jwt'
import { AppError } from '../utils/app-error'

interface JwtPayload {
  id: string
  email: string
  role: string
}

declare global {
  namespace Express {
    interface Request {
      user?: JwtPayload
    }
  }
}

export const authMiddleware = (req: Request, _res: Response, next: NextFunction) => {
  const authHeader = req.headers.authorization

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return next(new AppError('Token tidak ditemukan.', 401))
  }

  const token = authHeader.split(' ')[1]

  try {
    const decoded = jwt.verify(token, jwtConfig.accessSecret) as JwtPayload
    req.user = decoded
    next()
  } catch {
    next(new AppError('Token tidak valid atau sudah kadaluarsa.', 401))
  }
}
