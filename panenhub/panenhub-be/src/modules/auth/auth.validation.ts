import { z } from 'zod'

export const loginSchema = z.object({
  body: z.object({
    email: z.string().email('Format email tidak valid.'),
    password: z.string().min(6, 'Password minimal 6 karakter.'),
  }),
})

export const registerCustomerSchema = z.object({
  body: z.object({
    name: z.string().min(1, 'Nama wajib diisi.'),
    email: z.string().email('Format email tidak valid.'),
    phone: z.string().min(10, 'Nomor telepon minimal 10 digit.').optional(),
    password: z.string().min(6, 'Password minimal 6 karakter.'),
    businessName: z.string().min(1, 'Nama bisnis wajib diisi.'),
    businessType: z.string().min(1, 'Tipe bisnis wajib diisi.'),
    businessAddress: z.string().min(1, 'Alamat bisnis wajib diisi.'),
  }),
})

export const registerFarmerSchema = z.object({
  body: z.object({
    name: z.string().min(1, 'Nama wajib diisi.'),
    email: z.string().email('Format email tidak valid.'),
    phone: z.string().min(10, 'Nomor telepon minimal 10 digit.').optional(),
    password: z.string().min(6, 'Password minimal 6 karakter.'),
    farmName: z.string().min(1, 'Nama kebun wajib diisi.'),
    landArea: z.coerce.number().positive('Luas lahan harus lebih dari 0.'),
    address: z.string().min(1, 'Alamat wajib diisi.'),
    latitude: z.coerce.number().optional(),
    longitude: z.coerce.number().optional(),
  }),
})

export const refreshSchema = z.object({
  body: z.object({
    refresh_token: z.string().min(1, 'Refresh token wajib diisi.'),
  }),
})

export type LoginDto = z.infer<typeof loginSchema>['body']
export type RegisterCustomerDto = z.infer<typeof registerCustomerSchema>['body']
export type RegisterFarmerDto = z.infer<typeof registerFarmerSchema>['body']
export type RefreshDto = z.infer<typeof refreshSchema>['body']
