import { prisma } from '../../config/database'
import { AppError } from '../../utils/app-error'
import { getPaginationParams, buildPaginationMeta } from '../../utils/pagination'
import { CreateOrderDto, ReceiptConfirmationDto } from './order.validation'

export class OrderService {
  async create(customerId: string, body: CreateOrderDto) {
    const commodity = await prisma.commodity.findUnique({ where: { id: body.commodityId } })
    if (!commodity) throw new AppError('Komoditas tidak ditemukan.', 404)
    if (commodity.status !== 'active') throw new AppError('Komoditas tidak tersedia.', 400)
    if (body.quantityKg > commodity.availableQuotaKg) {
      throw new AppError(`Kuota tersedia hanya ${commodity.availableQuotaKg} kg.`, 400)
    }

    const totalPrice = Math.round(body.quantityKg * commodity.pricePerKg)

    const order = await prisma.$transaction(async (tx) => {
      // Kurangi kuota
      await tx.commodity.update({
        where: { id: commodity.id },
        data: { availableQuotaKg: { decrement: body.quantityKg } },
      })

      // Buat order
      const newOrder = await tx.preOrder.create({
        data: {
          customerId,
          farmerId: commodity.farmerId,
          commodityId: commodity.id,
          quantityKg: body.quantityKg,
          pricePerKg: commodity.pricePerKg,
          totalPrice,
          deliveryDate: body.deliveryDate,
          deliveryAddress: body.deliveryAddress,
          notes: body.notes,
        },
        include: {
          commodity: { select: { name: true, pricePerKg: true } },
          farmer: { select: { name: true } },
        },
      })

      // Catat status history
      await tx.orderStatusHistory.create({
        data: { orderId: newOrder.id, status: 'waiting_payment' },
      })

      return newOrder
    })

    return order
  }

  async listByCustomer(customerId: string, query: { page?: string; per_page?: string }) {
    const { page, perPage, skip, take } = getPaginationParams(query)

    const [data, total] = await Promise.all([
      prisma.preOrder.findMany({
        where: { customerId },
        skip,
        take,
        orderBy: { createdAt: 'desc' },
        include: {
          commodity: { select: { name: true, imageUrl: true } },
          farmer: { select: { name: true } },
        },
      }),
      prisma.preOrder.count({ where: { customerId } }),
    ])

    return { data, meta: buildPaginationMeta(page, perPage, total) }
  }

  async listByFarmer(farmerId: string, query: { page?: string; per_page?: string }) {
    const { page, perPage, skip, take } = getPaginationParams(query)

    const [data, total] = await Promise.all([
      prisma.preOrder.findMany({
        where: { farmerId },
        skip,
        take,
        orderBy: { createdAt: 'desc' },
        include: {
          commodity: { select: { name: true, imageUrl: true } },
          customer: { select: { name: true } },
        },
      }),
      prisma.preOrder.count({ where: { farmerId } }),
    ])

    return { data, meta: buildPaginationMeta(page, perPage, total) }
  }

  async getDetail(orderId: string, userId: string) {
    const order = await prisma.preOrder.findUnique({
      where: { id: orderId },
      include: {
        commodity: true,
        customer: { select: { id: true, name: true, email: true } },
        farmer: { select: { id: true, name: true, farmerProfile: { select: { farmName: true } } } },
        payment: true,
        statusHistory: { orderBy: { createdAt: 'desc' } },
        qualityControl: true,
      },
    })

    if (!order) throw new AppError('Pesanan tidak ditemukan.', 404)
    if (order.customerId !== userId && order.farmerId !== userId) {
      throw new AppError('Anda tidak memiliki akses ke pesanan ini.', 403)
    }

    return order
  }

  async confirmReceipt(orderId: string, customerId: string, body: ReceiptConfirmationDto) {
    const order = await prisma.preOrder.findUnique({
      where: { id: orderId },
      include: { payment: true },
    })

    if (!order) throw new AppError('Pesanan tidak ditemukan.', 404)
    if (order.customerId !== customerId) throw new AppError('Anda tidak memiliki akses ke pesanan ini.', 403)
    if (order.status !== 'shipped') throw new AppError('Pesanan belum dikirim.', 400)

    if (!body.is_received) {
      throw new AppError('Konfirmasi penerimaan ditolak. Ajukan sengketa jika ada masalah.', 400)
    }

    // Update status ke delivered
    const updated = await prisma.$transaction(async (tx) => {
      const updatedOrder = await tx.preOrder.update({
        where: { id: orderId },
        data: { status: 'delivered' },
      })

      await tx.orderStatusHistory.create({
        data: {
          orderId,
          status: 'delivered',
          notes: body.notes || 'Barang diterima oleh customer.',
          updatedById: customerId,
        },
      })

      return updatedOrder
    })

    return updated
  }
}
