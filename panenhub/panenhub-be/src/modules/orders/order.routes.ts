import { Router } from 'express'
import { OrderController } from './order.controller'
import { validate } from '../../middlewares/validate.middleware'
import { authMiddleware } from '../../middlewares/auth.middleware'
import { roleMiddleware } from '../../middlewares/role.middleware'
import { createOrderSchema, receiptConfirmationSchema, updateStatusSchema } from './order.validation'

const controller = new OrderController()

// Customer order routes — /api/v1/orders
export const customerOrderRoutes = Router()
customerOrderRoutes.use(authMiddleware, roleMiddleware('customer'))
customerOrderRoutes.post('/', validate(createOrderSchema), controller.create)
customerOrderRoutes.get('/', controller.listCustomer)
customerOrderRoutes.get('/:id', controller.detail)
customerOrderRoutes.post('/:id/receipt-confirmation', validate(receiptConfirmationSchema), controller.confirmReceipt)

// Farmer order routes — /api/v1/farmer/orders
export const farmerOrderRoutes = Router()
farmerOrderRoutes.use(authMiddleware, roleMiddleware('farmer'))
farmerOrderRoutes.get('/', controller.listFarmer)
farmerOrderRoutes.get('/:id', controller.detail)
farmerOrderRoutes.patch('/:id/status', validate(updateStatusSchema), controller.updateStatus)
