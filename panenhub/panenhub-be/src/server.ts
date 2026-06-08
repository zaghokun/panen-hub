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

server.listen(Number(PORT), '0.0.0.0', () => {
  console.log(`Server berjalan di port ${PORT}`)
  console.log(`Akses lokal: http://localhost:${PORT}`)
  console.log(`Akses jaringan: http://0.0.0.0:${PORT}`)
  console.log(`Socket.io aktif di port ${PORT}`)
})
