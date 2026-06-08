import { z } from 'zod'

export const createCommoditySchema = z.object({
  body: z.object({
    name: z.string().min(1, 'Nama komoditas wajib diisi.'),
    category: z.string().min(1, 'Kategori wajib diisi.'),
    description: z.string().optional(),
    pricePerKg: z.coerce.number().int().positive('Harga harus lebih dari 0.'),
    availableQuotaKg: z.coerce.number().positive('Kuota harus lebih dari 0.'),
    estimatedHarvestDate: z.string().min(1, 'Tanggal panen wajib diisi.').transform((val) => new Date(val)),
    location: z.string().min(1, 'Lokasi wajib diisi.'),
  }),
})

export const updateCommoditySchema = z.object({
  body: z.object({
    name: z.string().min(1).optional(),
    category: z.string().min(1).optional(),
    description: z.string().optional(),
    pricePerKg: z.coerce.number().int().positive().optional(),
    availableQuotaKg: z.coerce.number().positive().optional(),
    estimatedHarvestDate: z.string().transform((val) => new Date(val)).optional(),
    location: z.string().min(1).optional(),
    status: z.enum(['active', 'inactive']).optional(),
  }),
})

export const listCommodityQuerySchema = z.object({
  query: z.object({
    search: z.string().optional(),
    category: z.string().optional(),
    location: z.string().optional(),
    harvest_date: z.string().optional(),
    min_price: z.coerce.number().int().optional(),
    max_price: z.coerce.number().int().optional(),
    page: z.coerce.number().int().optional(),
    per_page: z.coerce.number().int().optional(),
  }),
})

export type CreateCommodityDto = z.infer<typeof createCommoditySchema>['body']
export type UpdateCommodityDto = z.infer<typeof updateCommoditySchema>['body']
