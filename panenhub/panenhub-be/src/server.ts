import dotenv from 'dotenv'
dotenv.config()

import http from 'http'
import { Server } from 'socket.io'
import app from './app'
import { initSocket } from './socket/socket.service'

const PORT = process.env.PORT || 3000

const server = http.createServer(app)
const io = new Server(server, { cors: { origin: '*' } })

initSocket(io)

server.listen(PORT, () => {
  console.log(`Server berjalan di http://localhost:${PORT}`)
  console.log(`Socket.io aktif di port ${PORT}`)
})
