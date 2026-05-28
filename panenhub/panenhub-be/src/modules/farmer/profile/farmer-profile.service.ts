import { prisma } from '../../../config/database'
import { AppError } from '../../../utils/app-error'
import { getFileUrl } from '../../../utils/file-url'

export class FarmerProfileService {
  async getProfile(userId: string) {
    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: {
        id: true, name: true, email: true, phone: true, status: true,
        farmerProfile: true,
      },
    })
    if (!user) throw new AppError('User tidak ditemukan.', 404)
    return user
  }

  async updateProfile(userId: string, body: Record<string, unknown>, photoFilename?: string) {
    // Update user fields
    const userData: Record<string, unknown> = {}
    if (body.name) userData.name = body.name
    if (body.phone) userData.phone = body.phone

    // Update farmer profile fields
    const profileData: Record<string, unknown> = {}
    if (body.farmName) profileData.farmName = body.farmName
    if (body.landArea) profileData.landArea = Number(body.landArea)
    if (body.address) profileData.address = body.address
    if (body.latitude) profileData.latitude = Number(body.latitude)
    if (body.longitude) profileData.longitude = Number(body.longitude)
    if (photoFilename) profileData.photoUrl = getFileUrl('farms', photoFilename)

    const user = await prisma.user.update({
      where: { id: userId },
      data: {
        ...userData,
        farmerProfile: { update: profileData },
      },
      select: {
        id: true, name: true, email: true, phone: true,
        farmerProfile: true,
      },
    })

    return user
  }
}
