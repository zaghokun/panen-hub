# Modul Order Status & Notifikasi

## Deskripsi

Modul update status pesanan oleh farmer dan sistem notifikasi realtime. Farmer dapat memperbarui status pesanan sesuai alur rantai pasok. Setiap perubahan status menghasilkan notifikasi yang disimpan ke database dan dikirim via Socket.io ke customer.

---

## Daftar File

| File | Fungsi |
|---|---|
| `src/modules/orders/order-status.service.ts` | Logika update status + validasi transisi |
| `src/modules/orders/order.validation.ts` | Ditambah: updateStatusSchema |
| `src/modules/orders/order.controller.ts` | Ditambah: handler updateStatus |
| `src/modules/orders/order.routes.ts` | Ditambah: PATCH /:id/status di farmerOrderRoutes |
| `src/modules/notifications/notification.service.ts` | Simpan notifikasi ke DB + emit socket |
| `src/modules/payments/payment.service.ts` | Diubah: gunakan NotificationService |

---

## Endpoint

| Method | Endpoint | Auth | Keterangan |
|---|---|---|---|
| PATCH | `/api/v1/farmer/orders/:id/status` | farmer | Update status pesanan |

---

## Validasi Transisi Status

Farmer hanya bisa melakukan transisi berikut:

```
paid_escrow         → pre_order_confirmed
pre_order_confirmed → harvesting
harvesting          → sorting_qc
sorting_qc          → shipped (wajib courierName + trackingNumber)
```

Transisi lain akan ditolak dengan error 400.

---

## Cara Kerja

### Update Status (PATCH /farmer/orders/:id/status)

1. Validasi order ada dan milik farmer yang login
2. Cek transisi diizinkan (berdasarkan status saat ini → status baru)
3. Jika status baru = `shipped`, validasi `courierName` dan `trackingNumber` wajib ada
4. Dalam transaction:
   - Update status order
   - Catat `OrderStatusHistory` (termasuk courier info jika shipped)
5. Kirim notifikasi ke customer:
   - Simpan ke tabel `notifications`
   - Emit socket event ke `user_{customerId}`

### Notifikasi yang Dikirim

| Status Baru | Event Socket | NotificationType |
|---|---|---|
| pre_order_confirmed | `order.status_updated` | `order_status_updated` |
| harvesting | `order.status_updated` | `order_status_updated` |
| sorting_qc | `order.status_updated` | `order_status_updated` |
| shipped | `order.shipped` | `order_shipped` |

### NotificationService

Service terpusat untuk semua notifikasi. Setiap pemanggilan:
1. Simpan record ke tabel `notifications` (untuk riwayat)
2. Emit event via Socket.io ke room user (untuk realtime)

Digunakan oleh:
- `order-status.service.ts` — notifikasi update status ke customer
- `payment.service.ts` — notifikasi pembayaran ke farmer

---

## Contoh Request & Response

### Update Status ke Harvesting

```http
PATCH /api/v1/farmer/orders/uuid-order/status
Authorization: Bearer <farmer_token>
Content-Type: application/json

{
  "status": "harvesting",
  "notes": "Mulai panen hari ini."
}
```

Response `200`:
```json
{
  "success": true,
  "message": "Status pesanan berhasil diperbarui.",
  "data": {
    "id": "uuid",
    "status": "harvesting",
    "updatedAt": "2026-05-29T..."
  }
}
```

### Update Status ke Shipped

```http
PATCH /api/v1/farmer/orders/uuid-order/status
Authorization: Bearer <farmer_token>
Content-Type: application/json

{
  "status": "shipped",
  "notes": "Dikirim pagi ini.",
  "courierName": "JNE",
  "trackingNumber": "JNE12345678"
}
```

### Error — Transisi Tidak Valid

```http
PATCH /api/v1/farmer/orders/uuid-order/status
{ "status": "shipped" }
```

Response `400` (jika status saat ini bukan `sorting_qc`):
```json
{
  "success": false,
  "message": "Transisi dari \"harvesting\" ke \"shipped\" tidak diizinkan."
}
```

### Error — Shipped Tanpa Courier

Response `400`:
```json
{
  "success": false,
  "message": "courierName dan trackingNumber wajib diisi untuk status shipped."
}
```

---

## Socket Event yang Diterima Customer

```json
{
  "type": "order.status_updated",
  "title": "Sedang Dipanen",
  "message": "Pesanan Tomat Segar diperbarui ke status: Sedang Dipanen.",
  "data": {
    "orderId": "uuid",
    "status": "harvesting"
  }
}
```

```json
{
  "type": "order.shipped",
  "title": "Dikirim",
  "message": "Pesanan Tomat Segar telah dikirim via JNE (JNE12345678).",
  "data": {
    "orderId": "uuid",
    "status": "shipped"
  }
}
```

---

## Hal Penting

- Transisi status divalidasi ketat — farmer tidak bisa loncat status
- `courierName` dan `trackingNumber` hanya wajib untuk status `shipped`
- Notifikasi disimpan ke DB (untuk riwayat) DAN dikirim via socket (untuk realtime)
- Prisma `Json?` field membutuhkan cast ke `Prisma.InputJsonValue`
- Payment service sekarang juga menggunakan NotificationService (bukan direct emitToUser)
