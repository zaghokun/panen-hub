import express from 'express'
import cors from 'cors'
import helmet from 'helmet'
import path from 'path'
import { errorMiddleware } from './middlewares/error.middleware'

const app = express()

// Middleware global
app.use(helmet())
app.use(cors())
app.use(express.json())
app.use(express.urlencoded({ extended: true }))

// Serve static uploads
app.use('/uploads', express.static(path.join(__dirname, '..', 'uploads')))

// Health check
app.get('/api/v1/health', (_req, res) => {
  res.json({ success: true, message: 'PanenHub API berjalan.' })
})

// Module routes
import authRoutes from './modules/auth/auth.routes'
import { publicCommodityRoutes, farmerCommodityRoutes } from './modules/commodities/commodity.routes'
import { customerOrderRoutes, farmerOrderRoutes } from './modules/orders/order.routes'
import { paymentRoutes } from './modules/payments/payment.routes'
import { qcRoutes } from './modules/qc/qc.routes'
import { disputeCreateRoutes, disputeDetailRoutes } from './modules/disputes/dispute.routes'
import { farmerProfileRoutes } from './modules/farmer/profile/farmer-profile.routes'
import { walletRoutes } from './modules/farmer/wallet/wallet.routes'
import { withdrawalRoutes } from './modules/farmer/withdrawals/withdrawal.routes'
import { adminRoutes } from './modules/admin/admin.routes'
import { reviewRoutes, globalReviewRoutes } from './modules/reviews/review.routes'
import { notificationRoutes } from './modules/notifications/notification.routes'
app.use('/api/v1/auth', authRoutes)
app.use('/api/v1/commodities', publicCommodityRoutes)
app.use('/api/v1/farmer/commodities', farmerCommodityRoutes)
app.use('/api/v1/farmer/profile', farmerProfileRoutes)
app.use('/api/v1/farmer/wallet', walletRoutes)
app.use('/api/v1/farmer/withdrawals', withdrawalRoutes)
app.use('/api/v1/farmer/orders', farmerOrderRoutes)
app.use('/api/v1/orders', customerOrderRoutes)
app.use('/api/v1/orders/:id/payments', paymentRoutes)
app.use('/api/v1/orders/:id/qc', qcRoutes)
app.use('/api/v1/orders/:id/disputes', disputeCreateRoutes)
app.use('/api/v1/orders/:id/reviews', reviewRoutes)
app.use('/api/v1/reviews', globalReviewRoutes)
app.use('/api/v1/disputes', disputeDetailRoutes)
app.use('/api/v1/notifications', notificationRoutes)
app.use('/api/v1/admin', adminRoutes)

// Global error handler (harus di paling bawah)
app.use(errorMiddleware)

export default app
