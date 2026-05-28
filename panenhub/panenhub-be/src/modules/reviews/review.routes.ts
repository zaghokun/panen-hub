import { Router } from 'express'
import { ReviewController } from './review.controller'
import { validate } from '../../middlewares/validate.middleware'
import { authMiddleware } from '../../middlewares/auth.middleware'
import { roleMiddleware } from '../../middlewares/role.middleware'
import { createReviewSchema } from './review.validation'

const controller = new ReviewController()

// Review routes — /api/v1/orders/:id/reviews
export const reviewRoutes = Router({ mergeParams: true })
reviewRoutes.use(authMiddleware, roleMiddleware('customer'))
reviewRoutes.post('/', validate(createReviewSchema), controller.create)
