# Fase 1 — Setup Project

## Deskripsi

Inisialisasi project backend PanenHub: konfigurasi TypeScript, Prisma ORM, Docker PostgreSQL, dan semua file fondasi (config, utils, middlewares, socket, entry point).

---

## Daftar File yang Dibuat

### Root Config
| File | Fungsi |
|---|---|
| `package.json` | Dependencies & scripts |
| `tsconfig.json` | TypeScript compiler config |
| `.env.example` | Template environment variables |
| `.gitignore` | File/folder yang di-ignore git |
| `docker-compose.yml` | PostgreSQL 16 container |

### Prisma
| File | Fungsi |
|---|---|
| `prisma/schema.prisma` | Schema database lengkap (15 model, 12 enum) |
| `prisma/seed.ts` | Data awal: admin, farmer, customer, 3 komoditas |

### Config (`src/config/`)
| File | Fungsi |
|---|---|
| `database.ts` | Prisma client singleton |
| `jwt.ts` | JWT secret & expiry dari env |
| `multer.ts` | Multer disk storage (5MB, JPEG/PNG/WebP) |

### Utils (`src/utils/`)
| File | Fungsi |
|---|---|
| `response.ts` | Helper format response standar |
| `app-error.ts` | Custom AppError class |
| `pagination.ts` | Helper pagination (skip, take, meta) |
| `file-url.ts` | Generate URL file upload |

### Middlewares (`src/middlewares/`)
| File | Fungsi |
|---|---|
| `auth.middleware.ts` | Verify JWT, attach user ke `req.user` |
| `role.middleware.ts` | Cek role user (customer/farmer/admin) |
| `validate.middleware.ts` | Validasi request body/query/params via Zod |
| `error.middleware.ts` | Global error handler |

### Socket & Entry Point
| File | Fungsi |
|---|---|
| `src/socket/socket.service.ts` | Socket.io init + helper `emitToUser` |
| `src/app.ts` | Express app setup (helmet, cors, static, routes) |
| `src/server.ts` | Entry point: HTTP server + Socket.io listen |

---

## Cara Setup

### 1. Copy environment file

```bash
cp .env.example .env
```

Edit `.env` jika perlu (default sudah sesuai untuk development lokal).

### 2. Jalankan PostgreSQL via Docker

```bash
docker-compose up -d
```

Ini akan menjalankan PostgreSQL 16 di port 5432 dengan:
- User: `postgres`
- Password: `password`
- Database: `panenhub_db`
- Data persistent di volume `panenhub_pgdata`

Untuk stop: `docker-compose down`
Untuk stop + hapus data: `docker-compose down -v`

### 3. Install dependencies

```bash
npm install
```

### 4. Generate Prisma Client

```bash
npx prisma generate
```

### 5. Jalankan migrasi database

```bash
npx prisma migrate dev --name init
```

### 6. Seed data awal

```bash
npx prisma db seed
```

Akun demo yang dibuat:

| Role | Email | Password |
|---|---|---|
| Admin | `admin@panenhub.test` | `admin123` |
| Farmer | `farmer@panenhub.test` | `farmer123` |
| Customer | `customer@panenhub.test` | `customer123` |

### 7. Jalankan development server

```bash
npm run dev
```

Server berjalan di `http://localhost:3000`. Health check: `GET /api/v1/health`.

---

## Perintah Berguna

| Perintah | Fungsi |
|---|---|
| `npm run dev` | Jalankan dev server (auto-reload) |
| `npm run build` | Compile TypeScript ke `dist/` |
| `npm start` | Jalankan production build |
| `npx prisma studio` | Buka GUI database |
| `npx prisma migrate dev --name <nama>` | Buat migration baru |
| `npx prisma migrate reset` | Reset database (hapus semua data) |
| `docker-compose up -d` | Start PostgreSQL |
| `docker-compose down` | Stop PostgreSQL |

---

## Hal Penting

- Jangan commit file `.env` — gunakan `.env.example` sebagai template
- Folder `uploads/` di-ignore git kecuali `.gitkeep`
- Prisma Client harus di-generate ulang setiap kali `schema.prisma` berubah
- Socket.io berjalan di port yang sama dengan Express (port 3000)
- Semua response menggunakan format standar dari `utils/response.ts`
- Error handling terpusat di `middlewares/error.middleware.ts`
