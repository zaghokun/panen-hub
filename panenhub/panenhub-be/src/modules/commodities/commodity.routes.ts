import { Router } from 'express'
import { CommodityController } from './commodity.controller'
import { validate } from '../../middlewares/validate.middleware'
import { authMiddleware } from '../../middlewares/auth.middleware'
import { roleMiddleware } from '../../middlewares/role.middleware'
import { upload } from '../../config/multer'
import { createCommoditySchema, updateCommoditySchema, listCommodityQuerySchema } from './commodity.validation'

const controller = new CommodityController()

// Public routes — /api/v1/commodities
export const publicCommodityRoutes = Router()
publicCommodityRoutes.get('/', validate(listCommodityQuerySchema), controller.list)
publicCommodityRoutes.get('/:id', controller.detail)

// Farmer routes — /api/v1/farmer/commodities
export const farmerCommodityRoutes = Router()
farmerCommodityRoutes.use(authMiddleware, roleMiddleware('farmer'))
farmerCommodityRoutes.get('/', controller.listMine)
farmerCommodityRoutes.post('/', upload.single('photo'), validate(createCommoditySchema), controller.create)
farmerCommodityRoutes.patch('/:id', upload.single('photo'), validate(updateCommoditySchema), controller.update)
farmerCommodityRoutes.delete('/:id', controller.remove)
