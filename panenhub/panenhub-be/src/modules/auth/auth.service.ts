import bcrypt from 'bcrypt'
import jwt from 'jsonwebtoken'
import { prisma } from '../../config/database'
import { jwtConfig } from '../../config/jwt'
import { AppError } from '../../utils/app-error'
import { LoginDto, RegisterCustomerDto, RegisterFarmerDto, RefreshDto } from './auth.validation'
import { getFileUrl } from '../../utils/file-url'

export class AuthService {
  private generateTokens(payload: { id: string; email: string; role: string }) {
    const accessToken = jwt.sign(payload, jwtConfig.accessSecret, {
      expiresIn: jwtConfig.accessExpiresIn,
    })
    const refreshToken = jwt.sign(payload, jwtConfig.refreshSecret, {
      expiresIn: jwtConfig.refreshExpiresIn,
    })
    return { accessToken, refreshToken }
  }

  async login(body: LoginDto) {
    const user = await prisma.user.findUnique({ where: { email: body.email } })
    if (!user) throw new AppError('Email atau password salah.', 401)

    const valid = await bcrypt.compare(body.password, user.password)
    if (!valid) throw new AppError('Email atau password salah.', 401)

    if (user.status === 'blocked') throw new AppError('Akun Anda diblokir.', 403)

    await prisma.user.update({ where: { id: user.id }, data: { lastLoginAt: new Date() } })

    const tokens = this.generateTokens({ id: user.id, email: user.email, role: user.role })

    return {
      access_token: tokens.accessToken,
      refresh_token: tokens.refreshToken,
      token_type: 'Bearer',
      expires_in: 3600,
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        role: user.role,
        status: user.status,
      },
    }
  }

  async registerCustomer(body: RegisterCustomerDto) {
    const exists = await prisma.user.findUnique({ where: { email: body.email } })
    if (exists) throw new AppError('Email sudah terdaftar.', 409)

    const hashedPassword = await bcrypt.hash(body.password, 10)

    const user = await prisma.user.create({
      data: {
        name: body.name,
        email: body.email,
        phone: body.phone,
        password: hashedPassword,
        role: 'customer',
        customerProfile: {
          create: {
            businessName: body.businessName,
            businessType: body.businessType,
            businessAddress: body.businessAddress,
          },
        },
      },
    })

    const tokens = this.generateTokens({ id: user.id, email: user.email, role: user.role })

    return {
      access_token: tokens.accessToken,
      refresh_token: tokens.refreshToken,
      token_type: 'Bearer',
      expires_in: 3600,
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        role: user.role,
        status: user.status,
      },
    }
  }

  async registerFarmer(body: RegisterFarmerDto, photoFilename?: string) {
    const exists = await prisma.user.findUnique({ where: { email: body.email } })
    if (exists) throw new AppError('Email sudah terdaftar.', 409)

    const hashedPassword = await bcrypt.hash(body.password, 10)

    const user = await prisma.user.create({
      data: {
        name: body.name,
        email: body.email,
        phone: body.phone,
        password: hashedPassword,
        role: 'farmer',
        farmerProfile: {
          create: {
            farmName: body.farmName,
            landArea: Number(body.landArea),
            address: body.address,
            latitude: body.latitude,
            longitude: body.longitude,
            photoUrl: photoFilename ? getFileUrl('farms', photoFilename) : null,
            verificationStatus: 'pending',
          },
        },
        wallet: {
          create: { balanceAvailable: 0, balancePending: 0, totalEarned: 0 },
        },
      },
    })

    const tokens = this.generateTokens({ id: user.id, email: user.email, role: user.role })

    return {
      access_token: tokens.accessToken,
      refresh_token: tokens.refreshToken,
      token_type: 'Bearer',
      expires_in: 3600,
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        role: user.role,
        status: user.status,
      },
    }
  }

  async refresh(body: RefreshDto) {
    try {
      const decoded = jwt.verify(body.refresh_token, jwtConfig.refreshSecret) as {
        id: string; email: string; role: string
      }

      const user = await prisma.user.findUnique({ where: { id: decoded.id } })
      if (!user) throw new AppError('User tidak ditemukan.', 401)
      if (user.status === 'blocked') throw new AppError('Akun Anda diblokir.', 403)

      const tokens = this.generateTokens({ id: user.id, email: user.email, role: user.role })

      return {
        access_token: tokens.accessToken,
        refresh_token: tokens.refreshToken,
        token_type: 'Bearer',
        expires_in: 3600,
      }
    } catch (error) {
      if (error instanceof AppError) throw error
      throw new AppError('Refresh token tidak valid atau sudah kadaluarsa.', 401)
    }
  }

  async me(userId: string) {
    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: {
        id: true,
        name: true,
        email: true,
        phone: true,
        role: true,
        status: true,
        lastLoginAt: true,
        createdAt: true,
        farmerProfile: true,
        customerProfile: true,
      },
    })

    if (!user) throw new AppError('User tidak ditemukan.', 404)
    return user
  }
}
