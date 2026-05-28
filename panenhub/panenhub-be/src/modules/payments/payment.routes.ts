import { Router } from 'express'
import { PaymentController } from './payment.controller'
import { validate } from '../../middlewares/validate.middleware'
import { authMiddleware } from '../../middlewares/auth.middleware'
import { roleMiddleware } from '../../middlewares/role.middleware'
import { createPaymentSchema } from '../orders/order.validation'

const controller = new PaymentController()

// Payment routes — /api/v1/orders/:id/payments
export const paymentRoutes = Router({ mergeParams: true })
paymentRoutes.use(authMiddleware, roleMiddleware('customer'))
paymentRoutes.post('/', validate(createPaymentSchema), controller.create)
paymentRoutes.get('/status', controller.status)
