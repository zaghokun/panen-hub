import { Router } from 'express'
import { NotificationController } from './notification.controller'
import { authMiddleware } from '../../middlewares/auth.middleware'

const controller = new NotificationController()

export const notificationRoutes = Router()
notificationRoutes.use(authMiddleware)
notificationRoutes.get('/', controller.list)
notificationRoutes.patch('/:id/read', controller.markRead)
notificationRoutes.patch('/read-all', controller.markAllRead)
