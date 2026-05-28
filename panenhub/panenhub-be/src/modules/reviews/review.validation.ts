import { z } from 'zod'

export const createReviewSchema = z.object({
  body: z.object({
    rating: z.number().int().min(1).max(5, 'Rating harus 1-5.'),
    comment: z.string().min(1, 'Komentar wajib diisi.'),
    qualityRating: z.number().int().min(1).max(5).optional(),
    deliveryRating: z.number().int().min(1).max(5).optional(),
  }),
})

export type CreateReviewDto = z.infer<typeof createReviewSchema>['body']
