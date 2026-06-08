import { Server } from 'socket.io'

let io: Server

export const initSocket = (socketServer: Server) => {
  io = socketServer

  io.on('connection', (socket) => {
    socket.on('join', (data: { userId: string }) => {
      socket.join(`user_${data.userId}`)
    })
  })
}

export const emitToUser = (userId: string, event: string, payload: unknown) => {
  if (io) {
    io.to(`user_${userId}`).emit(event, payload)
  }
}
