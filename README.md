# PanenHub

Aplikasi rantai pasok pertanian B2B yang menghubungkan petani lokal dengan pelanggan bisnis kuliner seperti restoran, katering, dan hotel. Pelanggan dapat melakukan **pre-order komoditas berbasis estimasi masa panen**, membayar melalui mekanisme escrow, memantau rantai pasok, dan melaporkan kualitas barang. Petani mendapatkan kepastian permintaan sebelum panen dan dapat mencairkan dana setelah pesanan selesai.

> Proyek ini dikembangkan sebagai tugas mata kuliah **Rekayasa Perangkat Lunak** — Kelompok 3.

---

## Struktur Repository

Repository ini menggunakan struktur **monorepo** — frontend dan backend berada dalam satu repository.

```
panenhub/
├── panenhub-mobile/        # Flutter Android App
└── panenhub-backend/       # Express.js REST API
```

---

## Aktor Sistem

| Aktor | Peran |
|---|---|
| **Pelanggan B2B** | Restoran, katering, hotel — memesan komoditas, membayar, konfirmasi, QC, sengketa, ulasan |
| **Petani / Mitra** | Memposting estimasi panen, memproses pesanan, update status rantai pasok, withdrawal |
| **Admin PanenHub** | Verifikasi akun petani, moderasi konten, penyelesaian sengketa, approval withdrawal |

---

## Tech Stack

### Frontend — Flutter Android

| Kebutuhan | Package |
|---|---|
| Framework | Flutter SDK ^3.x + Dart ^3.x |
| State Management | `flutter_riverpod` ^2.x |
| Routing | `go_router` ^14.x |
| HTTP Client | `dio` ^5.x |
| Secure Storage | `flutter_secure_storage` ^9.x |
| Data Class | `freezed` + `json_serializable` |
| Image | `cached_network_image`, `image_picker` |
| Formatting | `intl` |
| Loading UI | `shimmer` |

### Backend — Express.js

| Kebutuhan | Pilihan |
|---|---|
| Runtime | Node.js |
| Language | TypeScript ^5.x |
| Framework | Express.js ^4.x |
| ORM | Prisma ^5.x |
| Database | PostgreSQL |
| Auth | JWT (`jsonwebtoken`) |
| Hashing | bcrypt |
| Upload File | Multer |
| Validasi | Zod |
| Realtime | Socket.io ^4.x |

---

## Fitur Utama

- **Registrasi & Login** berbasis role (Customer, Farmer, Admin)
- **Verifikasi akun petani** oleh Admin
- **Pre-order komoditas** berdasarkan estimasi masa panen
- **Pembayaran Escrow** (simulasi) — dana ditahan hingga QC selesai
- **Tracking rantai pasok** — status order dari pre-order hingga terkirim
- **Konfirmasi penerimaan & Quality Control** oleh Customer
- **Sistem sengketa** dengan keputusan Admin
- **Wallet & Withdrawal** untuk petani
- **Ulasan & Rating** petani oleh Customer
- **Notifikasi realtime** via Socket.io untuk event-event penting

---

## Alur Status Pesanan

```
waiting_payment
    ↓ (customer bayar)
paid_escrow
    ↓ (sistem konfirmasi)
pre_order_confirmed
    ↓ (petani mulai)
harvesting
    ↓
sorting_qc
    ↓ (petani isi kurir + resi)
shipped
    ↓ (customer konfirmasi terima)
delivered
    ↓               ↓
completed        disputed
(QC baik)       (QC buruk)
                   ↓
              refunded / completed
              (keputusan admin)
```

---

## Panduan Setup

### Prasyarat

- Flutter SDK ^3.x
- Dart ^3.x
- Node.js ^18.x
- PostgreSQL (lokal)
- npm atau yarn

---

### Setup Backend

```bash
# Masuk ke folder backend
cd panenhub-backend

# Install dependencies
npm install

# Copy environment
cp .env.example .env
```

Edit file `.env`:

```env
DATABASE_URL="postgresql://postgres:password@localhost:5432/panenhub_db"
JWT_ACCESS_SECRET="ganti_dengan_secret_aman"
JWT_REFRESH_SECRET="ganti_dengan_refresh_secret_aman"
JWT_ACCESS_EXPIRES_IN="1h"
JWT_REFRESH_EXPIRES_IN="7d"
PORT=3000
NODE_ENV="development"
BASE_URL="http://localhost:3000"
```

```bash
# Jalankan migrasi database
npx prisma migrate dev --name init

# Seed data awal (akun admin, farmer demo, customer demo)
npx prisma db seed

# Jalankan server
npm run dev
```

Server berjalan di `http://localhost:3000`  
Socket.io aktif di port yang sama.

---

### Setup Frontend

```bash
# Masuk ke folder mobile
cd panenhub-mobile

# Install dependencies
flutter pub get

# Jalankan code generation (freezed + json_serializable)
dart run build_runner build --delete-conflicting-outputs

# Pastikan emulator atau device Android terhubung
flutter run
```

> Pastikan `BASE_URL` di konfigurasi Flutter mengarah ke `http://10.0.2.2:3000` jika menggunakan Android Emulator, atau IP lokal mesin jika menggunakan device fisik.

---

## Akun Demo

| Role | Email | Password |
|---|---|---|
| Admin | `admin@panenhub.test` | `admin123` |
| Petani | `farmer@panenhub.test` | `farmer123` |
| Customer | `customer@panenhub.test` | `customer123` |

---

## API Overview

Base URL: `http://localhost:3000/api/v1`

Semua endpoint terproteksi membutuhkan header:
```
Authorization: Bearer <access_token>
```

### Auth
| Method | Endpoint | Keterangan |
|---|---|---|
| POST | `/auth/login` | Login |
| POST | `/auth/register/customer` | Register pelanggan |
| POST | `/auth/register/farmer` | Register petani |
| GET | `/auth/me` | Data user aktif |
| POST | `/auth/logout` | Logout |
| POST | `/auth/refresh` | Refresh token |

### Customer
| Method | Endpoint | Keterangan |
|---|---|---|
| GET | `/commodities` | List komoditas |
| GET | `/commodities/:id` | Detail komoditas |
| POST | `/orders` | Buat pre-order |
| GET | `/orders` | Pesanan saya |
| GET | `/orders/:id` | Detail pesanan |
| POST | `/orders/:id/payments` | Buat pembayaran |
| POST | `/orders/:id/receipt-confirmation` | Konfirmasi terima |
| POST | `/orders/:id/qc` | Submit QC |
| POST | `/orders/:id/disputes` | Ajukan sengketa |
| POST | `/orders/:id/reviews` | Beri ulasan |

### Farmer
| Method | Endpoint | Keterangan |
|---|---|---|
| GET | `/farmer/dashboard` | Dashboard petani |
| GET | `/farmer/commodities` | Komoditas saya |
| POST | `/farmer/commodities` | Tambah komoditas |
| GET | `/farmer/orders` | Pesanan masuk |
| PATCH | `/farmer/orders/:id/status` | Update status |
| GET | `/farmer/wallet` | Saldo wallet |
| POST | `/farmer/withdrawals` | Ajukan withdrawal |

### Admin
| Method | Endpoint | Keterangan |
|---|---|---|
| GET | `/admin/dashboard` | Dashboard admin |
| PATCH | `/admin/users/:id/verify` | Verifikasi petani |
| PATCH | `/admin/disputes/:id/decision` | Putuskan sengketa |
| PATCH | `/admin/withdrawals/:id/approve` | Approve withdrawal |

> Dokumentasi API lengkap tersedia di [`panenhub-backend/BLUEPRINT.md`](./panenhub-backend/BLUEPRINT.md)

---

## Struktur Folder

### Frontend (`panenhub-mobile/`)

```
lib/
  main.dart
  app/              # Router, theme, config
  core/             # Network, storage, utils, shared widgets
  features/
    auth/           # Login, register
    commodities/    # List & detail komoditas
    orders/         # Pre-order, detail pesanan
    payments/       # Pembayaran escrow
    qc/             # Quality control
    disputes/       # Sengketa
    reviews/        # Ulasan
    farmer/         # Dashboard, komoditas, wallet petani
    admin/          # Dashboard admin, verifikasi, sengketa
    notifications/  # Notifikasi
    profile/        # Profil user
```

### Backend (`panenhub-backend/`)

```
src/
  app.ts            # Express + Socket.io setup
  config/           # Database, JWT, Multer config
  middlewares/      # Auth, role, validasi, error handler
  modules/
    auth/
    commodities/
    orders/
    payments/
    qc/
    disputes/
    reviews/
    farmer/         # Profile, wallet, withdrawals
    admin/
    notifications/
  socket/           # Socket.io emit helper
  utils/            # Response format, pagination, file URL
prisma/
  schema.prisma     # Database schema
  seed.ts           # Data awal
uploads/            # File storage lokal
```

---

## Notifikasi Realtime

Backend menggunakan **Socket.io** untuk mengirim notifikasi ke user yang relevan tanpa polling. Flutter terhubung ke socket saat login dan bergabung ke room pribadi berdasarkan `userId`.

Event yang dikirim:

| Event | Penerima |
|---|---|
| `order.paid` | Petani |
| `order.status_updated` | Customer |
| `order.shipped` | Customer |
| `dispute.submitted` | Admin |
| `dispute.decided` | Customer + Petani |
| `withdrawal.approved` | Petani |
| `farmer.verified` | Petani |

---

## Dokumen Referensi

| Dokumen | Lokasi |
|---|---|
| Blueprint Lengkap Proyek | `docs/panenhub_complete_project_blueprint.md` |
| Blueprint Frontend Flutter | `panenhub-mobile/BLUEPRINT.md` |
| Blueprint Backend | `panenhub-backend/BLUEPRINT.md` |
| Prisma Schema | `panenhub-backend/prisma/schema.prisma` |

---

## Tim Pengembang

Kelompok 3 — Rekayasa Perangkat Lunak

---

## Lisensi

Proyek ini dibuat untuk keperluan akademik.
