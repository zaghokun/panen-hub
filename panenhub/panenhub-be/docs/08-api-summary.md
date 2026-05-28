# API Summary — Semua Endpoint PanenHub

Base URL: `http://localhost:3000/api/v1`

---

## Auth (Public)

| Method | Endpoint | Keterangan |
|---|---|---|
| POST | `/auth/login` | Login semua role |
| POST | `/auth/register/customer` | Register pelanggan |
| POST | `/auth/register/farmer` | Register petani (multipart) |
| POST | `/auth/refresh` | Refresh access token |
| POST | `/auth/logout` | Logout (auth) |
| GET | `/auth/me` | Data user aktif (auth) |

---

## Commodities (Public)

| Method | Endpoint | Keterangan |
|---|---|---|
| GET | `/commodities` | List komoditas + filter + pagination |
| GET | `/commodities/:id` | Detail komoditas + profil farmer |

---

## Customer Orders (role: customer)

| Method | Endpoint | Keterangan |
|---|---|---|
| POST | `/orders` | Buat pre-order |
| GET | `/orders` | List pesanan customer |
| GET | `/orders/:id` | Detail pesanan |
| POST | `/orders/:id/receipt-confirmation` | Konfirmasi terima barang |
| POST | `/orders/:id/payments` | Buat pembayaran (simulasi) |
| GET | `/orders/:id/payments/status` | Cek status escrow |
| POST | `/orders/:id/qc` | Submit quality control (multipart) |
| POST | `/orders/:id/disputes` | Ajukan sengketa (multipart) |
| POST | `/orders/:id/reviews` | Beri ulasan |

---

## Disputes (role: customer/farmer)

| Method | Endpoint | Keterangan |
|---|---|---|
| GET | `/disputes/:id` | Detail sengketa |

---

## Farmer (role: farmer)

| Method | Endpoint | Keterangan |
|---|---|---|
| GET | `/farmer/profile` | Profil farmer |
| PATCH | `/farmer/profile` | Update profil (multipart) |
| GET | `/farmer/commodities` | List komoditas milik farmer |
| POST | `/farmer/commodities` | Tambah komoditas (multipart) |
| PATCH | `/farmer/commodities/:id` | Edit komoditas (multipart) |
| DELETE | `/farmer/commodities/:id` | Nonaktifkan komoditas |
| GET | `/farmer/orders` | List pesanan masuk |
| GET | `/farmer/orders/:id` | Detail pesanan |
| PATCH | `/farmer/orders/:id/status` | Update status pesanan |
| GET | `/farmer/wallet` | Saldo wallet |
| POST | `/farmer/withdrawals` | Ajukan withdrawal |
| GET | `/farmer/withdrawals` | Riwayat withdrawal |

---

## Admin (role: admin)

| Method | Endpoint | Keterangan |
|---|---|---|
| GET | `/admin/dashboard` | Ringkasan platform |
| PATCH | `/admin/users/:id/verify` | Verifikasi farmer |
| GET | `/admin/disputes` | List semua sengketa |
| PATCH | `/admin/disputes/:id/decision` | Putuskan sengketa |
| GET | `/admin/withdrawals` | List withdrawal |
| PATCH | `/admin/withdrawals/:id/approve` | Approve withdrawal |
| PATCH | `/admin/withdrawals/:id/reject` | Reject withdrawal |

---

## Notifications (semua role)

| Method | Endpoint | Keterangan |
|---|---|---|
| GET | `/notifications` | List notifikasi |
| PATCH | `/notifications/:id/read` | Tandai satu dibaca |
| PATCH | `/notifications/read-all` | Tandai semua dibaca |

---

## Health Check

| Method | Endpoint | Keterangan |
|---|---|---|
| GET | `/health` | Status server |

---

## Total: 39 Endpoints

### Breakdown per Role

| Role | Jumlah Endpoint |
|---|---|
| Public (tanpa auth) | 4 |
| Customer | 9 |
| Farmer | 12 |
| Admin | 7 |
| Semua role | 4 (auth/me, logout, notifications) |
| Shared (customer+farmer) | 2 (order detail, dispute detail) |
| Health | 1 |

---

## Autentikasi

Semua endpoint terproteksi membutuhkan header:
```
Authorization: Bearer <access_token>
```

Access token berlaku 1 jam. Gunakan `/auth/refresh` untuk mendapatkan token baru.

---

## Format Response

```json
// Success
{ "success": true, "message": "...", "data": {} }

// Success + Pagination
{ "success": true, "message": "...", "data": [], "meta": { "page": 1, "per_page": 10, "total": 100, "total_pages": 10 } }

// Error
{ "success": false, "message": "...", "errors": {} }
```

---

## Akun Demo

| Role | Email | Password |
|---|---|---|
| Admin | `admin@panenhub.test` | `admin123` |
| Farmer | `farmer@panenhub.test` | `farmer123` |
| Customer | `customer@panenhub.test` | `customer123` |
