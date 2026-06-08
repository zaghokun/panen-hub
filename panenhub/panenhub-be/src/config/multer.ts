import multer from 'multer'
import path from 'path'
import { AppError } from '../utils/app-error'

const UPLOAD_PATH = process.env.UPLOAD_PATH || './uploads'
const MAX_FILE_SIZE = 5 * 1024 * 1024 // 5MB

const storage = multer.diskStorage({
  destination: (_req, _file, cb) => {
    cb(null, UPLOAD_PATH)
  },
  filename: (_req, file, cb) => {
    const uniqueSuffix = `${Date.now()}-${Math.round(Math.random() * 1e9)}`
    const ext = path.extname(file.originalname)
    cb(null, `${uniqueSuffix}${ext}`)
  },
})

const fileFilter = (_req: Express.Request, file: Express.Multer.File, cb: multer.FileFilterCallback) => {
  const allowed = ['image/jpeg', 'image/png', 'image/webp']
  if (allowed.includes(file.mimetype)) {
    cb(null, true)
  } else {
    cb(new AppError('Format file tidak didukung. Gunakan JPEG, PNG, atau WebP.', 400))
  }
}

export const upload = multer({ storage, fileFilter, limits: { fileSize: MAX_FILE_SIZE } })
