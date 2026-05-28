import { z } from 'zod'

export const createWithdrawalSchema = z.object({
  body: z.object({
    amount: z.number().int().positive('Jumlah withdrawal harus lebih dari 0.'),
    bankName: z.string().min(1, 'Nama bank wajib diisi.'),
    accountNumber: z.string().min(1, 'Nomor rekening wajib diisi.'),
    accountHolderName: z.string().min(1, 'Nama pemilik rekening wajib diisi.'),
  }),
})

export type CreateWithdrawalDto = z.infer<typeof createWithdrawalSchema>['body']
