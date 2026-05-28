import { Router } from 'express'
import { AdminController } from './admin.controller'
import { authMiddleware } from '../../middlewares/auth.middleware'
import { roleMiddleware } from '../../middlewares/role.middleware'

const controller = new AdminController()

export const adminRoutes = Router()
adminRoutes.use(authMiddleware, roleMiddleware('admin'))

adminRoutes.get('/dashboard', controller.dashboard)
adminRoutes.patch('/users/:id/verify', controller.verifyFarmer)
adminRoutes.get('/disputes', controller.listDisputes)
adminRoutes.patch('/disputes/:id/decision', controller.decideDispute)
adminRoutes.get('/withdrawals', controller.listWithdrawals)
adminRoutes.patch('/withdrawals/:id/approve', controller.approveWithdrawal)
adminRoutes.patch('/withdrawals/:id/reject', controller.rejectWithdrawal)
