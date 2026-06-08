# PanenHub — Rangkuman Pengerjaan & Cara Testing

## Status Project

| Komponen | Status | Lokasi |
|---|---|---|
| Backend (Express.js) | ✅ Selesai | `panenhub/panenhub-be/` |
| Frontend (Flutter) | ✅ Selesai + Terintegrasi | `panenhub/panenhub-fe/` |
| Database (PostgreSQL) | ✅ Schema + Seed | via Docker |

---

## Arsitektur

```
┌─────────────────┐       HTTP/REST        ┌─────────────────┐       SQL        ┌──────────────┐
│  Flutter App    │  ──────────────────►   │  Express.js     │  ─────────────►  │  PostgreSQL  │
│  (Chrome/HP)    │  ◄──────────────────   │  localhost:3000  │  ◄─────────────  │  (Docker)    │
└─────────────────┘       JSON             └─────────────────┘                  └──────────────┘
                                                   │
                                                   │ Socket.io
                                                   ▼
                                           Realtime Notifications
```

---

## Cara Testing (Lokal)

### Prasyarat

- Node.js ≥ 18
- Docker Desktop (untuk PostgreSQL)
- Flutter SDK ≥ 3.10
- Chrome browser

### Langkah 1 — Jalankan Database

```bash
cd panenhub/panenhub-be
docker-compose up -d
```

Ini menjalankan PostgreSQL 16 di port 5432.

### Langkah 2 — Setup & Jalankan Backend

```bash
cd panenhub/panenhub-be

# Install dependencies (pertama kali saja)
npm install

# Copy environment file (pertama kali saja)
cp .env.example .env

# Generate Prisma client
npx prisma generate

# Jalankan migrasi database
npx prisma migrate dev --name init

# Seed data demo
npx prisma db seed

# Jalankan server
npm run dev
```

Server berjalan di `http://localhost:3000`.
Verifikasi: `curl http://localhost:3000/api/v1/health`

### Langkah 3 — Jalankan Frontend

```bash
cd panenhub/panenhub-fe

# Install dependencies (pertama kali saja)
flutter pub get

# Jalankan di Chrome
flutter run -d chrome
```

### Langkah 4 — Login

| Role | Email | Password |
|---|---|---|
| Admin | `admin@panenhub.test` | `admin123` |
| Farmer | `farmer@panenhub.test` | `farmer123` |
    | Customer | `customer@panenhub.test` | `customer123` |

---

## Testing di HP Fisik

### Via USB (paling mudah)

```bash
# Di terminal, jalankan:
adb reverse tcp:3000 tcp:3000

# Lalu run Flutter ke device:
flutter run
```

Flutter di HP akan bisa akses `localhost:3000` yang di-forward ke laptop.

### Via WiFi (tanpa USB)

Ganti `BASE_URL` saat run:
```bash
flutter run --dart-define=BASE_URL=http://192.168.x.x:3000/api/v1
```

Ganti `192.168.x.x` dengan IP laptop di jaringan WiFi yang sama.

### Via Android Emulator

```bash
flutter run --dart-define=BASE_URL=http://10.0.2.2:3000/api/v1
```

---

## Deploy ke Server

Jika ingin deploy agar bisa diakses tanpa laptop nyala:

```bash
# Di server (sistemcerdas.online)
git clone <repo>
cd panenhub/panenhub-be
npm install
cp .env.example .env
# Edit .env: DATABASE_URL, BASE_URL=https://sistemcerdas.online, JWT secrets
npx prisma migrate deploy
npx prisma db seed
npm run build
pm2 start dist/server.js --name panenhub
```

Lalu Flutter:
```bash
flutter run --dart-define=BASE_URL=https://sistemcerdas.online/api/v1
```

---

## Rangkuman Backend

### Tech Stack
- Node.js + TypeScript + Express.js
- Prisma ORM + PostgreSQL
- JWT Authentication (access + refresh token)
- Socket.io (notifikasi realtime)
- Multer (upload file)
- Zod (validasi)

### Total: 39 API Endpoints

| Grup | Endpoints |
|---|---|
| Auth | 6 (login, register customer/farmer, refresh, logout, me) |
| Commodities | 6 (list publik, detail, farmer CRUD) |
| Orders | 5 (create, list, detail, receipt-confirmation, farmer list) |
| Payments | 2 (create, status) |
| Order Status | 1 (farmer update status) |
| QC | 1 (submit quality control) |
| Disputes | 2 (create, detail) |
| Reviews | 1 (create) |
| Notifications | 3 (list, mark read, mark all read) |
| Farmer | 5 (profile, wallet, withdrawals) |
| Admin | 7 (dashboard, verify, disputes, withdrawals) |
| Health | 1 |

### Dokumentasi Detail Backend
Lihat `panenhub/panenhub-be/docs/`:
- `00-setup.md` — Setup project
- `01-auth.md` — Modul auth
- `02-commodities.md` — Modul commodities
- `03-orders-payments.md` — Modul orders + payments
- `04-order-status.md` — Update status + notifikasi
- `05-qc-disputes.md` — QC + sengketa
- `06-farmer-admin.md` — Farmer + admin
- `07-reviews-notifications.md` — Reviews + notifications
- `08-api-summary.md` — Ringkasan semua endpoint

---

## Rangkuman Frontend

### Tech Stack
- Flutter 3.10+ / Dart 3
- State Management: flutter_riverpod
- HTTP Client: dio
- Token Storage: flutter_secure_storage
- Routing: MaterialApp + onGenerateRoute

### Integrasi FE ↔ BE

| Layer | File |
|---|---|
| Network Client | `lib/core/network/api_client.dart` |
| Token Storage | `lib/core/network/token_storage.dart` |
| Error Handling | `lib/core/network/api_exceptions.dart` |
| API Services | `lib/core/network/services/*.dart` (9 file) |
| State/Providers | `lib/providers/app_providers.dart` |
| Models | `lib/shared/models/app_models.dart` |
| Enums | `lib/shared/enums/app_enums.dart` |
| Config | `lib/app/config/env.dart` |

### Data Flow

```
UI Screen (ConsumerWidget)
    ↓ ref.watch(provider)
Provider (Riverpod)
    ↓ calls
API Service (Dio)
    ↓ HTTP request
Backend (Express.js)
    ↓ query
PostgreSQL
```

---

## Alur Bisnis Utama

### 1. Customer Pesan Komoditas
```
Login → Lihat Komoditas → Buat Pre-Order → Bayar (simulasi)
→ Tunggu Farmer Proses → Terima Barang → QC → Selesai/Sengketa
```

### 2. Farmer Proses Pesanan
```
Login → Lihat Pesanan Masuk → Update Status:
harvesting → sorting_qc → shipped (isi kurir + resi)
→ Tunggu Customer Konfirmasi → Dana Masuk Wallet → Withdrawal
```

### 3. Admin Kelola Platform
```
Login → Dashboard → Verifikasi Farmer → Putuskan Sengketa → Approve Withdrawal
```

---

## Troubleshooting

| Masalah | Solusi |
|---|---|
| `Connection refused` di Flutter | Pastikan backend running (`npm run dev`) |
| `CORS error` di Chrome | Backend sudah enable CORS. Cek port benar (3000) |
| Login gagal | Pastikan sudah `npx prisma db seed` |
| Database error | Pastikan Docker running (`docker-compose up -d`) |
| Token expired | App otomatis refresh. Jika gagal, login ulang |
| Flutter analyze error | Pastikan `flutter pub get` sudah dijalankan |

---

## Tim Pengembang

Kelompok 3 — Rekayasa Perangkat Lunak
