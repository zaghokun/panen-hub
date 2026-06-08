import { z } from 'zod'

export const createDisputeSchema = z.object({
  body: z.object({
    reason: z.enum(['quality_issue', 'wrong_quantity', 'not_delivered', 'other'], {
      message: 'Alasan sengketa tidak valid.',
    }),
    description: z.string().min(10, 'Deskripsi minimal 10 karakter.'),
    quantityProblematic: z.coerce.number().positive().optional(),
  }),
})

export type CreateDisputeDto = z.infer<typeof createDisputeSchema>['body']
