export const getFileUrl = (subfolder: string, filename: string) =>
  `${process.env.BASE_URL}/uploads/${subfolder}/${filename}`
