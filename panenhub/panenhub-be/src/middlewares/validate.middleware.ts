import { Request, Response, NextFunction } from 'express'
import { AnyZodObject, ZodError } from 'zod'
import { AppError } from '../utils/app-error'

export const validate = (schema: AnyZodObject) => {
  return (req: Request, _res: Response, next: NextFunction) => {
    try {
      schema.parse({
        body: req.body,
        query: req.query,
        params: req.params,
      })
      next()
    } catch (error) {
      if (error instanceof ZodError) {
        const errors = error.errors.reduce((acc, err) => {
          const field = err.path.join('.')
          if (!acc[field]) acc[field] = []
          acc[field].push(err.message)
          return acc
        }, {} as Record<string, string[]>)

        return next(new AppError('Validasi gagal.', 400, errors))
      }
      next(error)
    }
  }
}
