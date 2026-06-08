import { NotificationType, Prisma } from '@prisma/client'
import { prisma } from '../../config/database'
import { emitToUser } from '../../socket/socket.service'
import { getPaginationParams, buildPaginationMeta } from '../../utils/pagination'
import { AppError } from '../../utils/app-error'

interface CreateNotificationDto {
  userId: string
  type: NotificationType
  title: string
  message: string
  data?: Record<string, unknown>
  event: string
}

export class NotificationService {
  async create(dto: CreateNotificationDto) {
    const notification = await prisma.notification.create({
      data: {
        userId: dto.userId,
        type: dto.type,
        title: dto.title,
        message: dto.message,
        data: (dto.data as Prisma.InputJsonValue) ?? undefined,
      },
    })

    emitToUser(dto.userId, dto.event, {
      type: dto.event,
      title: dto.title,
      message: dto.message,
      data: dto.data,
    })

    return notification
  }

  async list(userId: string, query: { is_read?: string; page?: string; per_page?: string }) {
    const { page, perPage, skip, take } = getPaginationParams(query)

    const where: Prisma.NotificationWhereInput = { userId }
    if (query.is_read === 'true') where.isRead = true
    if (query.is_read === 'false') where.isRead = false

    const [data, total] = await Promise.all([
      prisma.notification.findMany({ where, skip, take, orderBy: { createdAt: 'desc' } }),
      prisma.notification.count({ where }),
    ])

    return { data, meta: buildPaginationMeta(page, perPage, total) }
  }

  async markRead(notificationId: string, userId: string) {
    const notification = await prisma.notification.findUnique({ where: { id: notificationId } })
    if (!notification) throw new AppError('Notifikasi tidak ditemukan.', 404)
    if (notification.userId !== userId) throw new AppError('Anda tidak memiliki akses.', 403)

    return prisma.notification.update({ where: { id: notificationId }, data: { isRead: true } })
  }

  async markAllRead(userId: string) {
    await prisma.notification.updateMany({ where: { userId, isRead: false }, data: { isRead: true } })
    return { message: 'Semua notifikasi ditandai dibaca.' }
  }
}
