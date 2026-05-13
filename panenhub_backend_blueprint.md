# PanenHub — Blueprint Backend

**Nama proyek:** PanenHub  
**Jenis sistem:** Sistem rantai pasok B2B pertanian  
**Fokus dokumen:** Rancangan backend lengkap — tech stack, arsitektur, struktur folder, database schema, dan desain REST API  
**Basis:** Blueprint lengkap proyek + Blueprint frontend Android Flutter + hasil brainstorming tim  
**Versi:** 1.0  

---

## 1. Ringkasan Backend

Backend PanenHub berjalan secara **lokal** sebagai REST API server yang melayani aplikasi Flutter Android. Backend menangani seluruh logika bisnis platform: autentikasi, manajemen komoditas, alur pre-order, simulasi escrow, quality control, sengketa, withdrawal, dan notifikasi realtime.

---

## 2. Tech Stack

| Layer | Pilihan | Alasan |
|---|---|---|
| Runtime | Node.js | Sudah dikuasai tim |
| Language | TypeScript | Type safety, lebih mudah di-maintain tim kecil |
| Framework | Express.js | Simpel, fleksibel, komunitas besar |
| ORM | Prisma | Developer experience terbaik, schema terpusat, auto-generate types |
| Database | PostgreSQL | Relasi kompleks, gratis, mature |
| Auth | JWT (access + refresh token) | Stateless, cocok untuk mobile |
| Upload File | Multer | Standar untuk file upload di Express |
| Realtime | Socket.io | Notifikasi push ke Flutter tanpa polling |
| Hashing | bcrypt | Hashing password |
| Validasi | Zod | Schema validation di TypeScript |
| Environment | dotenv | Konfigurasi environment variable |

### 2.1 Versi Package Utama

```json
{
  "dependencies": {
    "express": "^4.x",
    "typescript": "^5.x",
    "@prisma/client": "^5.x",
    "socket.io": "^4.x",
    "jsonwebtoken": "^9.x",
    "bcrypt": "^5.x",
    "multer": "^1.x",
    "zod": "^3.x",
    "dotenv": "^16.x",
    "cors": "^2.x",
    "helmet": "^7.x"
  },
  "devDependencies": {
    "prisma": "^5.x",
    "ts-node": "^10.x",
    "ts-node-dev": "^2.x",
    "@types/express": "^4.x",
    "@types/jsonwebtoken": "^9.x",
    "@types/bcrypt": "^5.x",
    "@types/multer": "^1.x",
    "@types/cors": "^2.x"
  }
}
```

---

## 3. Arsitektur Backend

### 3.1 Pola Arsitektur

Backend menggunakan pola **modular MVC ringan** — setiap fitur memiliki folder sendiri dengan tiga lapisan:

```
Routes → Controller → Service → Prisma (Database)
```

- **Routes** mendefinisikan endpoint dan middleware yang berlaku.
- **Controller** menerima request, memanggil service, dan mengembalikan response.
- **Service** berisi seluruh logika bisnis dan interaksi dengan database via Prisma.
- **Middleware** menangani autentikasi, otorisasi role, dan validasi.

### 3.2 Prinsip Teknis

- Controller tidak boleh mengandung logika bisnis — delegasikan ke service.
- Service tidak boleh mengakses `req` atau `res` secara langsung.
- Semua response menggunakan format standar `{ success, message, data }`.
- Error ditangani terpusat di global error handler.
- Upload file disimpan di folder `/uploads` secara lokal.
- Socket.io berjalan di server yang sama dengan Express (shared HTTP server).

### 3.3 Alur Notifikasi Realtime

```
Backend logic (service) selesai
    ↓
socketService.emit(userId, event, payload)
    ↓
Socket.io kirim ke room `user_${userId}`
    ↓
Flutter client menerima event via socket
    ↓
Flutter tampilkan notifikasi in-app
    +
Backend simpan ke tabel notifications (untuk riwayat)
```

Setiap user yang login akan join room berdasarkan ID-nya:
```
socket.join(`user_${userId}`)
```

### 3.4 Alur Escrow Simulasi

Tidak ada payment gateway nyata. Semua alur escrow adalah update kolom di database.

```
Customer POST /orders/:id/payments
    ↓
Backend buat record Payment { status: unpaid, escrowStatus: unpaid }
Backend update Order { status: waiting_payment }
    ↓
Customer "konfirmasi bayar" (simulasi)
    ↓
Backend update Payment { status: paid, escrowStatus: held, paidAt: now }
Backend update Order { status: paid_escrow }
Backend emit notifikasi ke petani: order.paid
    ↓
Petani proses → harvesting → sorting_qc → shipped
    ↓
Customer konfirmasi terima + submit QC (kondisi baik)
    ↓
Backend update Payment { escrowStatus: released, releasedAt: now }
Backend update Wallet petani { balanceAvailable += totalPrice }
Backend update Order { status: completed }
    ↓
Jika dispute: Payment { escrowStatus: refunded, refundedAt: now }
```

---

## 4. Struktur Folder Project

```
panenhub-backend/
├── src/
│   ├── app.ts                      # Express app setup + Socket.io init
│   ├── server.ts                   # Entry point, listen port
│   │
│   ├── config/
│   │   ├── database.ts             # Prisma client singleton
│   │   ├── jwt.ts                  # JWT secret & expire config
│   │   └── multer.ts               # Multer storage config
│   │
│   ├── middlewares/
│   │   ├── auth.middleware.ts      # Verify JWT, attach user ke req
│   │   ├── role.middleware.ts      # Cek role (customer/farmer/admin)
│   │   ├── validate.middleware.ts  # Zod schema validation
│   │   └── error.middleware.ts     # Global error handler
│   │
│   ├── modules/
│   │   ├── auth/
│   │   │   ├── auth.routes.ts
│   │   │   ├── auth.controller.ts
│   │   │   ├── auth.service.ts
│   │   │   └── auth.validation.ts  # Zod schemas
│   │   │
│   │   ├── commodities/
│   │   │   ├── commodity.routes.ts
│   │   │   ├── commodity.controller.ts
│   │   │   ├── commodity.service.ts
│   │   │   └── commodity.validation.ts
│   │   │
│   │   ├── orders/
│   │   │   ├── order.routes.ts
│   │   │   ├── order.controller.ts
│   │   │   ├── order.service.ts
│   │   │   └── order.validation.ts
│   │   │
│   │   ├── payments/
│   │   │   ├── payment.routes.ts
│   │   │   ├── payment.controller.ts
│   │   │   └── payment.service.ts
│   │   │
│   │   ├── qc/
│   │   │   ├── qc.routes.ts
│   │   │   ├── qc.controller.ts
│   │   │   └── qc.service.ts
│   │   │
│   │   ├── disputes/
│   │   │   ├── dispute.routes.ts
│   │   │   ├── dispute.controller.ts
│   │   │   ├── dispute.service.ts
│   │   │   └── dispute.validation.ts
│   │   │
│   │   ├── reviews/
│   │   │   ├── review.routes.ts
│   │   │   ├── review.controller.ts
│   │   │   ├── review.service.ts
│   │   │   └── review.validation.ts
│   │   │
│   │   ├── farmer/
│   │   │   ├── profile/
│   │   │   │   ├── farmer-profile.routes.ts
│   │   │   │   ├── farmer-profile.controller.ts
│   │   │   │   └── farmer-profile.service.ts
│   │   │   ├── wallet/
│   │   │   │   ├── wallet.routes.ts
│   │   │   │   ├── wallet.controller.ts
│   │   │   │   └── wallet.service.ts
│   │   │   └── withdrawals/
│   │   │       ├── withdrawal.routes.ts
│   │   │       ├── withdrawal.controller.ts
│   │   │       ├── withdrawal.service.ts
│   │   │       └── withdrawal.validation.ts
│   │   │
│   │   ├── admin/
│   │   │   ├── admin.routes.ts
│   │   │   ├── admin.controller.ts
│   │   │   └── admin.service.ts
│   │   │
│   │   └── notifications/
│   │       ├── notification.routes.ts
│   │       ├── notification.controller.ts
│   │       └── notification.service.ts
│   │
│   ├── socket/
│   │   └── socket.service.ts       # Helper emit notifikasi realtime
│   │
│   └── utils/
│       ├── response.ts             # Format response standar
│       ├── pagination.ts           # Helper pagination query
│       └── file-url.ts             # Generate URL file upload
│
├── prisma/
│   ├── schema.prisma               # Database schema
│   └── seed.ts                     # Data awal (admin, akun dummy)
│
├── uploads/                        # File storage lokal
│   ├── commodities/
│   ├── farms/
│   ├── qc/
│   └── disputes/
│
├── .env                            # Environment variables
├── .env.example                    # Template .env untuk tim
├── tsconfig.json
├── package.json
└── README.md
```

### 4.1 Pembagian Kerja Tim

Struktur modular ini memudahkan pembagian kerja:

| Anggota | Modul |
|---|---|
| Member 1 | `auth`, `commodities`, `notifications` |
| Member 2 | `orders`, `payments`, `qc`, `reviews` |
| Member 3 | `farmer/*`, `admin`, `disputes` |

---

## 5. Environment Variables

```env
# Database
DATABASE_URL="postgresql://postgres:password@localhost:5432/panenhub_db"

# JWT
JWT_ACCESS_SECRET="panenhub_access_secret_ganti_ini"
JWT_REFRESH_SECRET="panenhub_refresh_secret_ganti_ini"
JWT_ACCESS_EXPIRES_IN="1h"
JWT_REFRESH_EXPIRES_IN="7d"

# Server
PORT=3000
NODE_ENV="development"

# Upload
UPLOAD_PATH="./uploads"
BASE_URL="http://localhost:3000"
```

---

## 6. Database Schema (Prisma)

```prisma
// PanenHub — Prisma Schema
// Database: PostgreSQL

generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

// ============================================================
// ENUMS
// ============================================================

enum Role {
  customer
  farmer
  admin
}

enum UserStatus {
  active
  inactive
  blocked
  pending_verification
}

enum VerificationStatus {
  unverified
  pending
  verified
  rejected
}

enum CommodityStatus {
  active
  inactive
  disabled
}

enum OrderStatus {
  waiting_payment
  paid_escrow
  pre_order_confirmed
  harvesting
  sorting_qc
  shipped
  delivered
  completed
  disputed
  refunded
  cancelled
}

enum EscrowStatus {
  unpaid
  held
  released
  refunded
}

enum PaymentMethod {
  bank_transfer
  virtual_account
}

enum PaymentStatus {
  unpaid
  paid
  refunded
}

enum DisputeReason {
  quality_issue
  wrong_quantity
  not_delivered
  other
}

enum DisputeStatus {
  submitted
  under_review
  resolved
  closed
}

enum DisputeDecision {
  approve_refund
  partial_refund
  reject
  request_more_evidence
}

enum WithdrawalStatus {
  requested
  approved
  paid
  rejected
}

enum NotificationType {
  order_paid
  order_confirmed
  order_status_updated
  order_shipped
  order_delivered
  order_completed
  dispute_submitted
  dispute_decided
  withdrawal_approved
  withdrawal_rejected
  farmer_verified
  farmer_rejected
}

// ============================================================
// USERS
// ============================================================

model User {
  id          String     @id @default(uuid())
  name        String
  email       String     @unique
  phone       String?
  password    String
  role        Role
  status      UserStatus @default(active)
  lastLoginAt DateTime?
  createdAt   DateTime   @default(now())
  updatedAt   DateTime   @updatedAt

  farmerProfile   FarmerProfile?
  customerProfile CustomerProfile?

  ordersAsCustomer     PreOrder[]           @relation("CustomerOrders")
  disputesAsCustomer   Dispute[]            @relation("CustomerDisputes")
  reviewsAsCustomer    Review[]             @relation("CustomerReviews")
  ordersAsFarmer       PreOrder[]           @relation("FarmerOrders")
  commodities          Commodity[]
  disputesAsFarmer     Dispute[]            @relation("FarmerDisputes")
  reviewsAsFarmer      Review[]             @relation("FarmerReviews")
  withdrawals          Withdrawal[]
  wallet               Wallet?
  orderStatusHistories OrderStatusHistory[]
  notifications        Notification[]

  @@map("users")
}

// ============================================================
// PROFILES
// ============================================================

model FarmerProfile {
  id                 String             @id @default(uuid())
  userId             String             @unique
  farmName           String
  landArea           Float
  address            String
  latitude           Float?
  longitude          Float?
  photoUrl           String?
  verificationStatus VerificationStatus @default(pending)
  verificationNotes  String?
  createdAt          DateTime           @default(now())
  updatedAt          DateTime           @updatedAt

  user User @relation(fields: [userId], references: [id], onDelete: Cascade)

  @@map("farmer_profiles")
}

model CustomerProfile {
  id              String   @id @default(uuid())
  userId          String   @unique
  businessName    String
  businessType    String
  businessAddress String
  picName         String?
  createdAt       DateTime @default(now())
  updatedAt       DateTime @updatedAt

  user User @relation(fields: [userId], references: [id], onDelete: Cascade)

  @@map("customer_profiles")
}

// ============================================================
// COMMODITIES
// ============================================================

model Commodity {
  id                   String          @id @default(uuid())
  farmerId             String
  name                 String
  category             String
  description          String?
  pricePerKg           Int
  availableQuotaKg     Float
  estimatedHarvestDate DateTime
  imageUrl             String?
  location             String
  status               CommodityStatus @default(active)
  createdAt            DateTime        @default(now())
  updatedAt            DateTime        @updatedAt

  farmer User       @relation(fields: [farmerId], references: [id])
  orders PreOrder[]

  @@map("commodities")
}

// ============================================================
// PRE ORDERS
// ============================================================

model PreOrder {
  id              String      @id @default(uuid())
  customerId      String
  farmerId        String
  commodityId     String
  quantityKg      Float
  pricePerKg      Int
  totalPrice      Int
  deliveryDate    DateTime
  deliveryAddress String
  notes           String?
  status          OrderStatus @default(waiting_payment)
  createdAt       DateTime    @default(now())
  updatedAt       DateTime    @updatedAt

  customer       User                 @relation("CustomerOrders", fields: [customerId], references: [id])
  farmer         User                 @relation("FarmerOrders", fields: [farmerId], references: [id])
  commodity      Commodity            @relation(fields: [commodityId], references: [id])
  payment        Payment?
  statusHistory  OrderStatusHistory[]
  qualityControl QualityControl?
  dispute        Dispute?
  review         Review?

  @@map("pre_orders")
}

// ============================================================
// ORDER STATUS HISTORY
// ============================================================

model OrderStatusHistory {
  id             String      @id @default(uuid())
  orderId        String
  status         OrderStatus
  notes          String?
  updatedById    String?
  courierName    String?
  trackingNumber String?
  createdAt      DateTime    @default(now())

  order     PreOrder @relation(fields: [orderId], references: [id], onDelete: Cascade)
  updatedBy User?    @relation(fields: [updatedById], references: [id])

  @@map("order_status_histories")
}

// ============================================================
// PAYMENTS (ESCROW SIMULASI)
// ============================================================

model Payment {
  id               String        @id @default(uuid())
  orderId          String        @unique
  amount           Int
  method           PaymentMethod @default(bank_transfer)
  status           PaymentStatus @default(unpaid)
  escrowStatus     EscrowStatus  @default(unpaid)
  paymentReference String?
  paidAt           DateTime?
  releasedAt       DateTime?
  refundedAt       DateTime?
  createdAt        DateTime      @default(now())
  updatedAt        DateTime      @updatedAt

  order PreOrder @relation(fields: [orderId], references: [id], onDelete: Cascade)

  @@map("payments")
}

// ============================================================
// QUALITY CONTROL
// ============================================================

model QualityControl {
  id              String   @id @default(uuid())
  orderId         String   @unique
  conditionStatus String
  quantityStatus  String
  qualityNotes    String?
  photoUrl        String?
  submittedById   String
  createdAt       DateTime @default(now())

  order PreOrder @relation(fields: [orderId], references: [id], onDelete: Cascade)

  @@map("quality_controls")
}

// ============================================================
// DISPUTES
// ============================================================

model Dispute {
  id                  String           @id @default(uuid())
  orderId             String           @unique
  customerId          String
  farmerId            String
  reason              DisputeReason
  description         String
  quantityProblematic Float?
  status              DisputeStatus    @default(submitted)
  adminDecision       DisputeDecision?
  adminNotes          String?
  refundAmount        Int?
  createdAt           DateTime         @default(now())
  updatedAt           DateTime         @updatedAt
  closedAt            DateTime?

  order     PreOrder          @relation(fields: [orderId], references: [id], onDelete: Cascade)
  customer  User              @relation("CustomerDisputes", fields: [customerId], references: [id])
  farmer    User              @relation("FarmerDisputes", fields: [farmerId], references: [id])
  evidences DisputeEvidence[]

  @@map("disputes")
}

model DisputeEvidence {
  id        String   @id @default(uuid())
  disputeId String
  fileUrl   String
  fileType  String
  createdAt DateTime @default(now())

  dispute Dispute @relation(fields: [disputeId], references: [id], onDelete: Cascade)

  @@map("dispute_evidences")
}

// ============================================================
// REVIEWS
// ============================================================

model Review {
  id             String   @id @default(uuid())
  orderId        String   @unique
  customerId     String
  farmerId       String
  rating         Int
  qualityRating  Int?
  deliveryRating Int?
  comment        String
  createdAt      DateTime @default(now())
  updatedAt      DateTime @updatedAt

  order    PreOrder @relation(fields: [orderId], references: [id], onDelete: Cascade)
  customer User     @relation("CustomerReviews", fields: [customerId], references: [id])
  farmer   User     @relation("FarmerReviews", fields: [farmerId], references: [id])

  @@map("reviews")
}

// ============================================================
// WALLET
// ============================================================

model Wallet {
  id               String   @id @default(uuid())
  farmerId         String   @unique
  balanceAvailable Int      @default(0)
  balancePending   Int      @default(0)
  totalEarned      Int      @default(0)
  updatedAt        DateTime @updatedAt

  farmer User @relation(fields: [farmerId], references: [id], onDelete: Cascade)

  @@map("wallets")
}

// ============================================================
// WITHDRAWALS
// ============================================================

model Withdrawal {
  id                String           @id @default(uuid())
  farmerId          String
  amount            Int
  bankName          String
  accountNumber     String
  accountHolderName String
  status            WithdrawalStatus @default(requested)
  adminNotes        String?
  requestedAt       DateTime         @default(now())
  processedAt       DateTime?

  farmer User @relation(fields: [farmerId], references: [id])

  @@map("withdrawals")
}

// ============================================================
// NOTIFICATIONS
// ============================================================

model Notification {
  id        String           @id @default(uuid())
  userId    String
  type      NotificationType
  title     String
  message   String
  isRead    Boolean          @default(false)
  data      Json?
  createdAt DateTime         @default(now())

  user User @relation(fields: [userId], references: [id], onDelete: Cascade)

  @@map("notifications")
}
```

---

## 7. Desain REST API

### 7.1 Konvensi Umum

**Base URL (lokal):**
```
http://localhost:3000/api/v1
```

**Autentikasi:**
```http
Authorization: Bearer <access_token>
```

**Format Response Success:**
```json
{
  "success": true,
  "message": "Berhasil.",
  "data": { }
}
```

**Format Response Success dengan Pagination:**
```json
{
  "success": true,
  "message": "Berhasil.",
  "data": [ ],
  "meta": {
    "page": 1,
    "per_page": 10,
    "total": 120,
    "total_pages": 12
  }
}
```

**Format Response Error:**
```json
{
  "success": false,
  "message": "Pesan error.",
  "errors": {
    "field": ["Validasi gagal."]
  }
}
```

**HTTP Status Code:**

| Code | Kondisi |
|---|---|
| `200` | OK |
| `201` | Created |
| `400` | Bad Request / Validasi gagal |
| `401` | Unauthorized |
| `403` | Forbidden / Role tidak diizinkan |
| `404` | Not Found |
| `409` | Conflict / Duplikasi |
| `500` | Internal Server Error |

---

### 7.2 Endpoint Auth

| Method | Endpoint | Access | Keterangan |
|---|---|---|---|
| `POST` | `/auth/login` | Public | Login semua role |
| `POST` | `/auth/register/customer` | Public | Register pelanggan |
| `POST` | `/auth/register/farmer` | Public | Register petani |
| `GET` | `/auth/me` | All | Data user aktif |
| `POST` | `/auth/logout` | All | Logout |
| `POST` | `/auth/refresh` | All | Refresh access token |

---

### 7.3 Endpoint Customer

| Method | Endpoint | Keterangan |
|---|---|---|
| `GET` | `/commodities` | List komoditas (support filter & pagination) |
| `GET` | `/commodities/:id` | Detail komoditas + profil petani |
| `POST` | `/orders` | Buat pre-order |
| `GET` | `/orders` | List pesanan customer |
| `GET` | `/orders/:id` | Detail pesanan lengkap |
| `POST` | `/orders/:id/payments` | Buat pembayaran (simulasi) |
| `GET` | `/orders/:id/payments/status` | Cek status pembayaran & escrow |
| `POST` | `/orders/:id/receipt-confirmation` | Konfirmasi barang diterima |
| `POST` | `/orders/:id/qc` | Submit quality control |
| `POST` | `/orders/:id/disputes` | Ajukan sengketa |
| `GET` | `/disputes/:id` | Detail sengketa milik customer |
| `POST` | `/orders/:id/reviews` | Beri ulasan (hanya order completed) |

**Query params `/commodities`:**

| Param | Tipe | Contoh |
|---|---|---|
| `search` | string | `tomat` |
| `category` | string | `sayur` |
| `location` | string | `semarang` |
| `harvest_date` | date | `2026-06-20` |
| `min_price` | integer | `10000` |
| `max_price` | integer | `50000` |
| `page` | integer | `1` |
| `per_page` | integer | `10` |

---

### 7.4 Endpoint Farmer

| Method | Endpoint | Keterangan |
|---|---|---|
| `GET` | `/farmer/dashboard` | Ringkasan dashboard petani |
| `GET` | `/farmer/profile` | Profil petani |
| `PATCH` | `/farmer/profile` | Update profil + foto lahan |
| `GET` | `/farmer/commodities` | List komoditas milik petani |
| `POST` | `/farmer/commodities` | Tambah komoditas baru |
| `PATCH` | `/farmer/commodities/:id` | Edit komoditas |
| `DELETE` | `/farmer/commodities/:id` | Nonaktifkan komoditas |
| `GET` | `/farmer/orders` | Daftar pesanan masuk |
| `PATCH` | `/farmer/orders/:id/status` | Update status pesanan |
| `GET` | `/farmer/wallet` | Info saldo wallet |
| `POST` | `/farmer/withdrawals` | Ajukan withdrawal |
| `GET` | `/farmer/withdrawals` | Riwayat withdrawal |

**Aturan transisi status pesanan** (divalidasi backend):

```
waiting_payment      → paid_escrow          (sistem/simulasi)
paid_escrow          → pre_order_confirmed  (sistem)
pre_order_confirmed  → harvesting           (petani)
harvesting           → sorting_qc           (petani)
sorting_qc           → shipped              (petani, wajib kurir + resi)
shipped              → delivered            (customer)
delivered            → completed            (customer via QC baik)
delivered            → disputed             (customer via QC buruk)
disputed             → refunded             (admin)
disputed             → completed            (admin)
```

---

### 7.5 Endpoint Admin

| Method | Endpoint | Keterangan |
|---|---|---|
| `GET` | `/admin/dashboard` | Ringkasan platform |
| `GET` | `/admin/users` | List semua user |
| `GET` | `/admin/users/:id` | Detail user |
| `PATCH` | `/admin/users/:id/verify` | Approve / reject verifikasi petani |
| `PATCH` | `/admin/users/:id/block` | Blokir user |
| `GET` | `/admin/disputes` | List semua sengketa |
| `GET` | `/admin/disputes/:id` | Detail sengketa |
| `PATCH` | `/admin/disputes/:id/decision` | Putuskan sengketa |
| `GET` | `/admin/withdrawals` | List withdrawal |
| `PATCH` | `/admin/withdrawals/:id/approve` | Approve withdrawal |
| `PATCH` | `/admin/withdrawals/:id/reject` | Reject withdrawal |
| `GET` | `/admin/commodities` | List semua komoditas |
| `PATCH` | `/admin/commodities/:id/disable` | Nonaktifkan komoditas |

---

### 7.6 Endpoint Notifikasi

| Method | Endpoint | Keterangan |
|---|---|---|
| `GET` | `/notifications` | List notifikasi user aktif |
| `PATCH` | `/notifications/:id/read` | Tandai satu notifikasi dibaca |
| `PATCH` | `/notifications/read-all` | Tandai semua dibaca |

---

## 8. Notifikasi Realtime (Socket.io)

### 8.1 Event yang Dikirim Backend

| Event | Trigger | Penerima |
|---|---|---|
| `order.paid` | Customer konfirmasi bayar | Petani |
| `order.confirmed` | Sistem konfirmasi pre-order | Petani |
| `order.status_updated` | Petani update status | Customer |
| `order.delivered` | Status berubah ke delivered | Customer |
| `order.completed` | QC selesai, order completed | Petani |
| `dispute.submitted` | Customer ajukan sengketa | Admin |
| `dispute.decided` | Admin putuskan sengketa | Customer + Petani |
| `withdrawal.approved` | Admin approve withdrawal | Petani |
| `withdrawal.rejected` | Admin reject withdrawal | Petani |
| `farmer.verified` | Admin verifikasi petani | Petani |
| `farmer.rejected` | Admin reject verifikasi | Petani |

### 8.2 Payload Event

```json
{
  "type": "order.status_updated",
  "title": "Pesanan Dikirim",
  "message": "Pesanan ORD-2026-001 telah dikirim via JNE.",
  "data": {
    "orderId": "uuid",
    "status": "shipped"
  }
}
```

---

## 9. Seed Data

File `prisma/seed.ts` menyediakan data awal untuk pengembangan:

```
Admin:
  email    : admin@panenhub.test
  password : admin123
  role     : admin

Petani Demo:
  email    : farmer@panenhub.test
  password : farmer123
  role     : farmer
  status   : active (verified)

Customer Demo:
  email    : customer@panenhub.test
  password : customer123
  role     : customer
```

---

## 10. Cara Menjalankan Lokal

```bash
# 1. Clone repository dan masuk folder backend
cd panenhub-backend

# 2. Install dependencies
npm install

# 3. Copy environment
cp .env.example .env
# Edit .env sesuai konfigurasi database lokal

# 4. Jalankan PostgreSQL lokal (pastikan sudah terinstall)

# 5. Migrasi database
npx prisma migrate dev --name init

# 6. Seed data awal
npx prisma db seed

# 7. Jalankan server
npm run dev

# Server berjalan di http://localhost:3000
# Socket.io aktif di port yang sama
```

---

## 11. Roadmap Pengerjaan Backend

| Fase | Modul | Prioritas |
|---|---|---|
| 1 | Setup project, Prisma schema, seed | Wajib pertama |
| 2 | Auth (login, register, JWT) | Wajib |
| 3 | Komoditas (CRUD) | Wajib |
| 4 | Pre-order + pembayaran simulasi | Wajib |
| 5 | Update status pesanan + notifikasi Socket.io | Wajib |
| 6 | QC + sengketa | Wajib |
| 7 | Wallet + withdrawal + admin | Wajib |
| 8 | Ulasan + moderasi konten | Pelengkap |
| 9 | Testing & cleanup | Terakhir |
