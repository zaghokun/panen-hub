# Modul Orders & Payments

## Deskripsi

Modul pre-order dan pembayaran simulasi PanenHub. Customer membuat pesanan berdasarkan komoditas, membayar (simulasi escrow), dan mengkonfirmasi penerimaan barang. Farmer melihat pesanan masuk.

---

## Daftar File

| File | Fungsi |
|---|---|
| `src/modules/orders/order.validation.ts` | Zod schemas: createOrder, receiptConfirmation, createPayment |
| `src/modules/orders/order.service.ts` | Logika bisnis: create, list, detail, confirmReceipt |
| `src/modules/orders/order.controller.ts` | Handler endpoint orders |
| `src/modules/orders/order.routes.ts` | Routes customer + farmer orders |
| `src/modules/payments/payment.service.ts` | Logika pembayaran simulasi + socket notify |
| `src/modules/payments/payment.controller.ts` | Handler endpoint payments |
| `src/modules/payments/payment.routes.ts` | Routes payments (nested under orders) |

---

## Endpoints

### Customer Orders

| Method | Endpoint | Keterangan |
|---|---|---|
| POST | `/api/v1/orders` | Buat pre-order |
| GET | `/api/v1/orders` | List pesanan customer |
| GET | `/api/v1/orders/:id` | Detail pesanan lengkap |
| POST | `/api/v1/orders/:id/receipt-confirmation` | Konfirmasi terima barang |

### Payments

| Method | Endpoint | Keterangan |
|---|---|---|
| POST | `/api/v1/orders/:id/payments` | Buat pembayaran (simulasi) |
| GET | `/api/v1/orders/:id/payments/status` | Cek status escrow |

### Farmer Orders

| Method | Endpoint | Keterangan |
|---|---|---|
| GET | `/api/v1/farmer/orders` | List pesanan masuk |
| GET | `/api/v1/farmer/orders/:id` | Detail pesanan |

---

## Cara Kerja

### Buat Pre-Order (POST /orders)

1. Validasi komoditas ada dan aktif
2. Cek kuota tersedia >= quantity yang diminta
3. Hitung `totalPrice = quantityKg × pricePerKg`
4. Dalam transaction:
   - Kurangi `availableQuotaKg` di komoditas
   - Buat record `PreOrder` (status: `waiting_payment`)
   - Catat `OrderStatusHistory`
5. Return order + info komoditas + nama farmer

### Pembayaran Simulasi (POST /orders/:id/payments)

Tidak ada payment gateway nyata. Alur simulasi:

1. Validasi order milik customer dan status `waiting_payment`
2. Cek belum ada payment untuk order ini
3. Dalam transaction:
   - Buat `Payment` (status: `paid`, escrowStatus: `held`, paidAt: now)
   - Update order status → `paid_escrow`
   - Catat history
4. Emit socket event `order.paid` ke farmer
5. Return data payment

### Konfirmasi Terima (POST /orders/:id/receipt-confirmation)

1. Validasi order milik customer dan status `shipped`
2. Jika `is_received: true`:
   - Update order status → `delivered`
   - Catat history
3. Jika `is_received: false`:
   - Return error — arahkan customer untuk ajukan sengketa

### Cek Status Escrow (GET /orders/:id/payments/status)

Return info payment: status, escrowStatus, amount, method, reference, timestamps.

---

## Contoh Request & Response

### Buat Pre-Order

```http
POST /api/v1/orders
Authorization: Bearer <token>
Content-Type: application/json

{
  "commodityId": "uuid-komoditas",
  "quantityKg": 50,
  "deliveryDate": "2026-06-22",
  "deliveryAddress": "Jl. Pemuda No. 12, Semarang",
  "notes": "Pilih yang matang sempurna."
}
```

Response `201`:
```json
{
  "success": true,
  "message": "Pre-order berhasil dibuat.",
  "data": {
    "id": "uuid",
    "customerId": "uuid",
    "farmerId": "uuid",
    "commodityId": "uuid",
    "quantityKg": 50,
    "pricePerKg": 14000,
    "totalPrice": 700000,
    "deliveryDate": "2026-06-22T00:00:00.000Z",
    "deliveryAddress": "Jl. Pemuda No. 12, Semarang",
    "status": "waiting_payment",
    "commodity": { "name": "Tomat Segar", "pricePerKg": 14000 },
    "farmer": { "name": "Bu Sari" }
  }
}
```

### Bayar Pesanan

```http
POST /api/v1/orders/uuid-order/payments
Authorization: Bearer <token>
Content-Type: application/json

{
  "method": "bank_transfer"
}
```

Response `201`:
```json
{
  "success": true,
  "message": "Pembayaran berhasil (simulasi).",
  "data": {
    "id": "uuid",
    "orderId": "uuid",
    "amount": 700000,
    "method": "bank_transfer",
    "status": "paid",
    "escrowStatus": "held",
    "paymentReference": "PAY-1716940000000",
    "paidAt": "2026-05-29T..."
  }
}
```

### Konfirmasi Terima

```http
POST /api/v1/orders/uuid-order/receipt-confirmation
Authorization: Bearer <token>
Content-Type: application/json

{
  "is_received": true,
  "notes": "Barang diterima dalam kondisi baik."
}
```

Response `200`:
```json
{
  "success": true,
  "message": "Konfirmasi penerimaan berhasil.",
  "data": {
    "id": "uuid",
    "status": "delivered"
  }
}
```

---

## Alur Status yang Ditangani Fase Ini

```
waiting_payment → paid_escrow (via payment)
shipped → delivered (via receipt-confirmation)
```

Status lainnya (harvesting, sorting_qc, shipped, completed, disputed) ditangani di fase berikutnya.

---

## Hal Penting

- Kuota komoditas langsung dikurangi saat order dibuat (optimistic)
- Pembayaran bersifat simulasi — langsung `paid` + `escrow: held` tanpa proses verifikasi
- Socket event `order.paid` dikirim ke farmer setelah pembayaran berhasil
- Payment routes menggunakan `mergeParams: true` untuk akses `:id` dari parent route
- Detail pesanan bisa diakses oleh customer maupun farmer (cek ownership kedua role)
- Konfirmasi terima hanya bisa dilakukan jika status order = `shipped`
