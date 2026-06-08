import { Router } from 'express'
import { DisputeController } from './dispute.controller'
import { validate } from '../../middlewares/validate.middleware'
import { authMiddleware } from '../../middlewares/auth.middleware'
import { roleMiddleware } from '../../middlewares/role.middleware'
import { upload } from '../../config/multer'
import { createDisputeSchema } from './dispute.validation'

const controller = new DisputeController()

// Dispute create — /api/v1/orders/:id/disputes
export const disputeCreateRoutes = Router({ mergeParams: true })
disputeCreateRoutes.use(authMiddleware, roleMiddleware('customer'))
disputeCreateRoutes.post('/', upload.array('evidence_photos', 5), validate(createDisputeSchema), controller.create)

// Dispute detail — /api/v1/disputes/:id
export const disputeDetailRoutes = Router()
disputeDetailRoutes.use(authMiddleware, roleMiddleware('customer', 'farmer'))
disputeDetailRoutes.get('/:id', controller.detail)
