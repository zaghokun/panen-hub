import { Prisma } from '@prisma/client'
import { prisma } from '../../config/database'
import { AppError } from '../../utils/app-error'
import { getPaginationParams, buildPaginationMeta } from '../../utils/pagination'
import { getFileUrl } from '../../utils/file-url'
import { CreateCommodityDto, UpdateCommodityDto } from './commodity.validation'

export class CommodityService {
  async listPublic(query: {
    search?: string
    category?: string
    location?: string
    harvest_date?: string
    min_price?: number
    max_price?: number
    page?: string
    per_page?: string
  }) {
    const { page, perPage, skip, take } = getPaginationParams(query)

    const where: Prisma.CommodityWhereInput = { status: 'active' }

    if (query.search) {
      where.name = { contains: query.search, mode: 'insensitive' }
    }
    if (query.category) {
      where.category = { equals: query.category, mode: 'insensitive' }
    }
    if (query.location) {
      where.location = { contains: query.location, mode: 'insensitive' }
    }
    if (query.harvest_date) {
      where.estimatedHarvestDate = { gte: new Date(query.harvest_date) }
    }
    if (query.min_price !== undefined) {
      where.pricePerKg = { ...((where.pricePerKg as object) || {}), gte: query.min_price }
    }
    if (query.max_price !== undefined) {
      where.pricePerKg = { ...((where.pricePerKg as object) || {}), lte: query.max_price }
    }

    const [data, total] = await Promise.all([
      prisma.commodity.findMany({
        where,
        skip,
        take,
        orderBy: { createdAt: 'desc' },
        include: {
          farmer: { select: { id: true, name: true, farmerProfile: { select: { farmName: true, address: true } } } },
        },
      }),
      prisma.commodity.count({ where }),
    ])

    // Get all unique farmerIds in the returned data
    const farmerIds = Array.from(new Set(data.map(c => c.farmerId)))

    // Group reviews by farmerId and calculate average rating
    const ratings = await prisma.review.groupBy({
      by: ['farmerId'],
      _avg: {
        rating: true,
      },
      where: {
        farmerId: {
          in: farmerIds,
        },
      },
    })

    // Create a map of farmerId -> average rating
    const ratingMap = new Map<string, number>()
    for (const r of ratings) {
      ratingMap.set(r.farmerId, r._avg.rating || 0.0)
    }

    // Attach farmerRating to each commodity
    const dataWithRatings = data.map(c => ({
      ...c,
      farmerRating: ratingMap.get(c.farmerId) || 0.0,
    }))

    return { data: dataWithRatings, meta: buildPaginationMeta(page, perPage, total) }
  }

  async getDetail(id: string) {
    const commodity = await prisma.commodity.findUnique({
      where: { id },
      include: {
        farmer: {
          select: {
            id: true,
            name: true,
            farmerProfile: { select: { farmName: true, landArea: true, address: true, photoUrl: true, verificationStatus: true } },
          },
        },
      },
    })

    if (!commodity) throw new AppError('Komoditas tidak ditemukan.', 404)
    if (commodity.status !== 'active') throw new AppError('Komoditas tidak tersedia.', 404)

    // Calculate dynamic rating
    const aggregate = await prisma.review.aggregate({
      _avg: {
        rating: true,
      },
      where: {
        farmerId: commodity.farmerId,
      },
    })

    return {
      ...commodity,
      farmerRating: aggregate._avg.rating || 0.0,
    }
  }

  async listByFarmer(farmerId: string, query: { page?: string; per_page?: string }) {
    const { page, perPage, skip, take } = getPaginationParams(query)

    const where: Prisma.CommodityWhereInput = { farmerId, status: { not: 'disabled' } }

    const [data, total] = await Promise.all([
      prisma.commodity.findMany({ where, skip, take, orderBy: { createdAt: 'desc' } }),
      prisma.commodity.count({ where }),
    ])

    return { data, meta: buildPaginationMeta(page, perPage, total) }
  }

  async create(farmerId: string, body: CreateCommodityDto, photoFilename?: string) {
    return prisma.commodity.create({
      data: {
        farmerId,
        name: body.name,
        category: body.category,
        description: body.description,
        pricePerKg: Number(body.pricePerKg),
        availableQuotaKg: Number(body.availableQuotaKg),
        estimatedHarvestDate: new Date(body.estimatedHarvestDate),
        location: body.location,
        imageUrl: photoFilename ? getFileUrl('commodities', photoFilename) : null,
      },
    })
  }

  async update(farmerId: string, id: string, body: UpdateCommodityDto, photoFilename?: string) {
    const commodity = await prisma.commodity.findUnique({ where: { id } })
    if (!commodity) throw new AppError('Komoditas tidak ditemukan.', 404)
    if (commodity.farmerId !== farmerId) throw new AppError('Anda tidak memiliki akses ke komoditas ini.', 403)

    const updateData: any = { ...body }
    if (body.pricePerKg !== undefined) updateData.pricePerKg = Number(body.pricePerKg)
    if (body.availableQuotaKg !== undefined) updateData.availableQuotaKg = Number(body.availableQuotaKg)
    if (body.estimatedHarvestDate !== undefined) updateData.estimatedHarvestDate = new Date(body.estimatedHarvestDate)
    if (photoFilename) updateData.imageUrl = getFileUrl('commodities', photoFilename)

    return prisma.commodity.update({
      where: { id },
      data: updateData,
    })
  }

  async delete(farmerId: string, id: string) {
    const commodity = await prisma.commodity.findUnique({ where: { id } })
    if (!commodity) throw new AppError('Komoditas tidak ditemukan.', 404)
    if (commodity.farmerId !== farmerId) throw new AppError('Anda tidak memiliki akses ke komoditas ini.', 403)

    return prisma.commodity.update({ where: { id }, data: { status: 'inactive' } })
  }
}
