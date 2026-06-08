import { Router } from 'express'
import { FarmerProfileController } from './farmer-profile.controller'
import { authMiddleware } from '../../../middlewares/auth.middleware'
import { roleMiddleware } from '../../../middlewares/role.middleware'
import { upload } from '../../../config/multer'

const controller = new FarmerProfileController()

export const farmerProfileRoutes = Router()
farmerProfileRoutes.use(authMiddleware, roleMiddleware('farmer'))
farmerProfileRoutes.get('/', controller.get)
farmerProfileRoutes.patch('/', upload.single('farm_photo'), controller.update)
