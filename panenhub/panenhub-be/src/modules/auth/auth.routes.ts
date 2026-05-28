import { Router } from 'express'
import { AuthController } from './auth.controller'
import { validate } from '../../middlewares/validate.middleware'
import { authMiddleware } from '../../middlewares/auth.middleware'
import { upload } from '../../config/multer'
import { loginSchema, registerCustomerSchema, registerFarmerSchema, refreshSchema } from './auth.validation'

const router = Router()
const controller = new AuthController()

router.post('/login', validate(loginSchema), controller.login)
router.post('/register/customer', validate(registerCustomerSchema), controller.registerCustomer)
router.post('/register/farmer', upload.single('farm_photo'), validate(registerFarmerSchema), controller.registerFarmer)
router.post('/refresh', validate(refreshSchema), controller.refresh)
router.post('/logout', authMiddleware, controller.logout)
router.get('/me', authMiddleware, controller.me)

export default router
