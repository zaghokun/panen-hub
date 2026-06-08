import { Router } from 'express'
import { WalletController } from './wallet.controller'
import { authMiddleware } from '../../../middlewares/auth.middleware'
import { roleMiddleware } from '../../../middlewares/role.middleware'

const controller = new WalletController()

export const walletRoutes = Router()
walletRoutes.use(authMiddleware, roleMiddleware('farmer'))
walletRoutes.get('/', controller.get)
