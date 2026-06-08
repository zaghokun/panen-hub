# Modul Reviews & Notifications

## Deskripsi

Modul ulasan customer ke farmer dan endpoint notifikasi (list, mark read). Customer memberikan rating setelah pesanan selesai. Notifikasi bisa diakses semua role.

---

## Daftar File

### Reviews
| File | Fungsi |
|---|---|
| `src/modules/reviews/review.validation.ts` | Zod schema: createReview |
| `src/modules/reviews/review.service.ts` | Logika create review |
| `src/modules/reviews/review.controller.ts` | Handler |
| `src/modules/reviews/review.routes.ts` | Route POST /orders/:id/reviews |

### Notifications
| File | Fungsi |
|---|---|
| `src/modules/notifications/notification.service.ts` | Create + list + markRead + markAllRead |
| `src/modules/notifications/notification.controller.ts` | Handler |
| `src/modules/notifications/notification.routes.ts` | Routes GET, PATCH |

---

## Endpoints

### Reviews

| Method | Endpoint | Auth | Keterangan |
|---|---|---|---|
| POST | `/api/v1/orders/:id/reviews` | customer | Beri ulasan |

### Notifications

| Method | Endpoint | Auth | Keterangan |
|---|---|---|---|
| GET | `/api/v1/notifications` | semua role | List notifikasi |
| PATCH | `/api/v1/notifications/:id/read` | semua role | Tandai satu dibaca |
| PATCH | `/api/v1/notifications/read-all` | semua role | Tandai semua dibaca |

---

## Cara Kerja

### Beri Ulasan (POST /orders/:id/reviews)

1. Validasi order milik customer dan status `completed`
2. Cek belum ada review sebelumnya (1 review per order)
3. Simpan review: rating (1-5), comment, qualityRating?, deliveryRating?

### List Notifikasi (GET /notifications)

Query params:
- `is_read` — filter: `true` | `false`
- `page` — halaman (default: 1)
- `per_page` — item per halaman (default: 10)

Return notifikasi milik user yang login, diurutkan terbaru.

### Mark Read (PATCH /notifications/:id/read)

Tandai satu notifikasi sebagai dibaca. Validasi ownership.

### Mark All Read (PATCH /notifications/read-all)

Tandai semua notifikasi unread milik user sebagai dibaca.

---

## Contoh Request & Response

### Beri Ulasan

```http
POST /api/v1/orders/uuid-order/reviews
Authorization: Bearer <customer_token>
Content-Type: application/json

{
  "rating": 5,
  "comment": "Tomat sangat segar dan berkualitas. Pengiriman tepat waktu.",
  "qualityRating": 5,
  "deliveryRating": 4
}
```

Response `201`:
```json
{
  "success": true,
  "message": "Ulasan berhasil diberikan.",
  "data": {
    "id": "uuid",
    "orderId": "uuid",
    "customerId": "uuid",
    "farmerId": "uuid",
    "rating": 5,
    "qualityRating": 5,
    "deliveryRating": 4,
    "comment": "Tomat sangat segar dan berkualitas. Pengiriman tepat waktu."
  }
}
```

### List Notifikasi

```http
GET /api/v1/notifications?is_read=false&page=1
Authorization: Bearer <token>
```

Response `200`:
```json
{
  "success": true,
  "message": "Berhasil.",
  "data": [
    {
      "id": "uuid",
      "type": "order_shipped",
      "title": "Dikirim",
      "message": "Pesanan Tomat Segar telah dikirim via JNE.",
      "isRead": false,
      "data": { "orderId": "uuid", "status": "shipped" },
      "createdAt": "2026-05-29T..."
    }
  ],
  "meta": { "page": 1, "per_page": 10, "total": 3, "total_pages": 1 }
}
```

### Mark All Read

```http
PATCH /api/v1/notifications/read-all
Authorization: Bearer <token>
```

Response `200`:
```json
{
  "success": true,
  "message": "Semua notifikasi ditandai dibaca.",
  "data": { "message": "Semua notifikasi ditandai dibaca." }
}
```

---

## Hal Penting

- Review hanya bisa diberikan 1x per order dan hanya untuk order `completed`
- Rating wajib 1-5, qualityRating dan deliveryRating opsional
- Endpoint notifikasi bisa diakses semua role (customer, farmer, admin)
- Notifikasi dibuat otomatis oleh service lain (payment, order-status, admin) — bukan manual
- Filter `is_read` berguna untuk menampilkan badge unread di frontend
