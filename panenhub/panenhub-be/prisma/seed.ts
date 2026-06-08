import { PrismaClient, Role } from '@prisma/client'
import * as bcrypt from 'bcrypt'

const prisma = new PrismaClient()

async function main() {
  const hash = async (password: string) => bcrypt.hash(password, 10)

  // Admin
  const admin = await prisma.user.upsert({
    where: { email: 'admin@panenhub.test' },
    update: {},
    create: {
      name: 'Admin PanenHub',
      email: 'admin@panenhub.test',
      password: await hash('admin123'),
      role: Role.admin,
      status: 'active',
    },
  })

  // Farmer
  const farmer = await prisma.user.upsert({
    where: { email: 'farmer@panenhub.test' },
    update: {},
    create: {
      name: 'Bu Sari',
      email: 'farmer@panenhub.test',
      password: await hash('farmer123'),
      role: Role.farmer,
      status: 'active',
      farmerProfile: {
        create: {
          farmName: 'Kebun Sari Makmur',
          landArea: 2.5,
          address: 'Desa Sukamaju, Kec. Ciawi, Bogor',
          latitude: -6.7,
          longitude: 106.85,
          verificationStatus: 'verified',
        },
      },
      wallet: {
        create: {
          balanceAvailable: 0,
          balancePending: 0,
          totalEarned: 0,
        },
      },
    },
  })

  // Customer
  const customer = await prisma.user.upsert({
    where: { email: 'customer@panenhub.test' },
    update: {},
    create: {
      name: 'Restoran Nusantara',
      email: 'customer@panenhub.test',
      password: await hash('customer123'),
      role: Role.customer,
      status: 'active',
      customerProfile: {
        create: {
          businessName: 'Restoran Nusantara',
          businessType: 'Restoran',
          businessAddress: 'Jl. Sudirman No. 45, Jakarta',
          picName: 'Budi Santoso',
        },
      },
    },
  })

  // Sample commodities untuk farmer
  await prisma.commodity.createMany({
    skipDuplicates: true,
    data: [
      {
        farmerId: farmer.id,
        name: 'Tomat Segar',
        category: 'sayur',
        description: 'Tomat merah segar dari kebun organik',
        pricePerKg: 14000,
        availableQuotaKg: 200,
        estimatedHarvestDate: new Date('2026-06-15'),
        location: 'Bogor, Jawa Barat',
      },
      {
        farmerId: farmer.id,
        name: 'Cabai Rawit Merah',
        category: 'bumbu',
        description: 'Cabai rawit merah pedas berkualitas',
        pricePerKg: 45000,
        availableQuotaKg: 100,
        estimatedHarvestDate: new Date('2026-06-20'),
        location: 'Bogor, Jawa Barat',
      },
      {
        farmerId: farmer.id,
        name: 'Bayam Hijau',
        category: 'sayur',
        description: 'Bayam hijau segar panen pagi',
        pricePerKg: 8000,
        availableQuotaKg: 150,
        estimatedHarvestDate: new Date('2026-06-10'),
        location: 'Bogor, Jawa Barat',
      },
    ],
  })

  console.log('Seed berhasil!')
  console.log({ admin: admin.email, farmer: farmer.email, customer: customer.email })
}

main()
  .catch((e) => {
    console.error(e)
    process.exit(1)
  })
  .finally(() => prisma.$disconnect())
