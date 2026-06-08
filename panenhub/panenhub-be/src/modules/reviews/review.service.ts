import { prisma } from '../../config/database'
import { AppError } from '../../utils/app-error'
import { CreateReviewDto } from './review.validation'

export class ReviewService {
  async create(orderId: string, customerId: string, body: CreateReviewDto) {
    const order = await prisma.preOrder.findUnique({
      where: { id: orderId },
      include: { review: true },
    })

    if (!order) throw new AppError('Pesanan tidak ditemukan.', 404)
    if (order.customerId !== customerId) throw new AppError('Anda tidak memiliki akses ke pesanan ini.', 403)
    if (order.status !== 'completed') throw new AppError('Ulasan hanya bisa diberikan untuk pesanan yang sudah selesai.', 400)
    if (order.review) throw new AppError('Ulasan sudah pernah diberikan untuk pesanan ini.', 409)

    return prisma.review.create({
      data: {
        orderId,
        customerId,
        farmerId: order.farmerId,
        rating: body.rating,
        qualityRating: body.qualityRating,
        deliveryRating: body.deliveryRating,
        comment: body.comment,
      },
    })
  }

  async listByFarmer(farmerId: string) {
    return prisma.review.findMany({
      where: { farmerId },
      include: {
        customer: {
          select: {
            id: true,
            name: true,
          },
        },
      },
      orderBy: { createdAt: 'desc' },
    })
  }
}
