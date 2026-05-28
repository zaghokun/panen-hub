import { Router } from 'express'
import { WithdrawalController } from './withdrawal.controller'
import { validate } from '../../../middlewares/validate.middleware'
import { authMiddleware } from '../../../middlewares/auth.middleware'
import { roleMiddleware } from '../../../middlewares/role.middleware'
import { createWithdrawalSchema } from './withdrawal.validation'

const controller = new WithdrawalController()

export const withdrawalRoutes = Router()
withdrawalRoutes.use(authMiddleware, roleMiddleware('farmer'))
withdrawalRoutes.post('/', validate(createWithdrawalSchema), controller.create)
withdrawalRoutes.get('/', controller.list)
