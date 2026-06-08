import { Router } from 'express'
import { QcController } from './qc.controller'
import { authMiddleware } from '../../middlewares/auth.middleware'
import { roleMiddleware } from '../../middlewares/role.middleware'
import { upload } from '../../config/multer'

const controller = new QcController()

// QC routes — /api/v1/orders/:id/qc
export const qcRoutes = Router({ mergeParams: true })
qcRoutes.use(authMiddleware, roleMiddleware('customer'))
qcRoutes.post('/', upload.single('photo'), controller.submit)
