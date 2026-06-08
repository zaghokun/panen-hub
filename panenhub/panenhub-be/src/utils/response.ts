export const successResponse = (data: unknown, message = 'Berhasil.') => ({
  success: true,
  message,
  data,
})

export const errorResponse = (message: string, errors?: unknown) => ({
  success: false,
  message,
  errors,
})

export const paginatedResponse = (
  data: unknown[],
  message = 'Berhasil.',
  meta: { page: number; per_page: number; total: number }
) => ({
  success: true,
  message,
  data,
  meta: {
    ...meta,
    total_pages: Math.ceil(meta.total / meta.per_page),
  },
})
