import { z } from 'zod'

export const createOrderSchema = z.object({
  body: z.object({
    commodityId: z.string().uuid('ID komoditas tidak valid.'),
    quantityKg: z.number().positive('Jumlah harus lebih dari 0.'),
    deliveryDate: z.coerce.date({ message: 'Format tanggal tidak valid.' }),
    deliveryAddress: z.string().min(1, 'Alamat pengiriman wajib diisi.'),
    notes: z.string().optional(),
  }),
})

export const receiptConfirmationSchema = z.object({
  body: z.object({
    is_received: z.boolean({ required_error: 'Status penerimaan wajib diisi.' }),
    notes: z.string().optional(),
  }),
})

export const createPaymentSchema = z.object({
  body: z.object({
    method: z.enum(['bank_transfer', 'virtual_account'], {
      message: 'Metode pembayaran tidak valid.',
    }),
  }),
})

export const updateStatusSchema = z.object({
  body: z.object({
    status: z.enum(['pre_order_confirmed', 'harvesting', 'sorting_qc', 'shipped'], {
      message: 'Status tidak valid.',
    }),
    notes: z.string().optional(),
    courierName: z.string().optional(),
    trackingNumber: z.string().optional(),
  }),
})

export type CreateOrderDto = z.infer<typeof createOrderSchema>['body']
export type ReceiptConfirmationDto = z.infer<typeof receiptConfirmationSchema>['body']
export type CreatePaymentDto = z.infer<typeof createPaymentSchema>['body']
export type UpdateStatusDto = z.infer<typeof updateStatusSchema>['body']
