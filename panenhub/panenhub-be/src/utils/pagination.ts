export const getPaginationParams = (query: { page?: string; per_page?: string }) => {
  const page = Math.max(1, parseInt(query.page || '1', 10))
  const perPage = Math.min(100, Math.max(1, parseInt(query.per_page || '10', 10)))
  const skip = (page - 1) * perPage

  return { page, perPage, skip, take: perPage }
}

export const buildPaginationMeta = (page: number, perPage: number, total: number) => ({
  page,
  per_page: perPage,
  total,
  total_pages: Math.ceil(total / perPage),
})
