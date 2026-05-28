export const jwtConfig = {
  accessSecret: process.env.JWT_ACCESS_SECRET || 'default_access_secret',
  refreshSecret: process.env.JWT_REFRESH_SECRET || 'default_refresh_secret',
  accessExpiresIn: 3600, // 1 hour in seconds
  refreshExpiresIn: 604800, // 7 days in seconds
}
