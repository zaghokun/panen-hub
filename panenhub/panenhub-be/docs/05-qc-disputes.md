# Modul QC & Disputes

## Deskripsi

Modul quality control dan sengketa PanenHub. Customer melakukan QC setelah barang diterima. Jika kualitas baik, pesanan selesai dan dana dirilis. Jika ada masalah, customer mengajukan sengketa dengan bukti foto.

---

## Daftar File

| File | Fungsi |
|---|---|
| `src/modules/qc/qc.service.ts` | Logika submit QC + auto-complete jika baik |
| `src/modules/qc/qc.controller.ts` | Handler endpoint QC |
| `src/modules/qc/qc.routes.ts` | Route POST /orders/:id/qc |
| `src/modules/disputes/dispute.validation.ts` | Zod schema: createDispute |
| `src/modules/disputes/dispute.service.ts` | Logika ajukan sengketa + upload evidence |
| `src/modules/disputes/dispute.controller.ts` | Handler endpoint disputes |
| `src/modules/disputes/dispute.routes.ts` | Routes create + detail |

---

## Endpoints

| Method | Endpoint | Auth | Keterangan |
|---|---|---|---|
| POST | `/api/v1/orders/:id/qc` | customer | Submit quality control |
| POST | `/api/v1/orders/:id/disputes` | customer | Ajukan sengketa |
| GET | `/api/v1/disputes/:id` | customer/farmer | Detail sengketa |

---

## Cara Kerja

### Submit QC (POST /orders/:id/qc)

1. Validasi order milik customer dan status `delivered`
2. Cek belum ada QC sebelumnya
3. Simpan record `QualityControl`
4. Jika `conditionStatus: "good"` DAN `quantityStatus: "complete"`:
   - Order status → `completed`
   - Payment escrowStatus → `released`
   - Wallet farmer: `balanceAvailable += totalPrice`, `totalEarned += totalPrice`
   - Notifikasi `order.completed` ke farmer
5. Jika ada masalah (bad/less):
   - QC tetap disimpan, tapi order TIDAK otomatis completed
   - Customer perlu ajukan sengketa secara terpisah

### Ajukan Sengketa (POST /orders/:id/disputes)

1. Validasi order milik customer dan status `delivered` atau `completed`
2. Cek belum ada dispute sebelumnya
3. Dalam transaction:
   - Update order status → `disputed`
   - Buat record `Dispute`
   - Upload evidence photos ke `uploads/disputes/` dan simpan ke `DisputeEvidence`
4. Notifikasi `dispute.submitted` ke semua admin

### Detail Sengketa (GET /disputes/:id)

Menampilkan detail dispute + order info + customer + farmer + evidences. Bisa diakses oleh customer atau farmer yang terlibat.

---

## Contoh Request & Response

### Submit QC — Baik

```http
POST /api/v1/orders/uuid-order/qc
Authorization: Bearer <token>
Content-Type: multipart/form-data

conditionStatus: good
quantityStatus: complete
qualityNotes: Semua dalam kondisi baik.
photo: [file opsional]
```

Response `201`:
```json
{
  "success": true,
  "message": "QC berhasil. Pesanan selesai, dana dirilis ke farmer.",
  "data": {
    "qc": {
      "id": "uuid",
      "orderId": "uuid",
      "conditionStatus": "good",
      "quantityStatus": "complete",
      "qualityNotes": "Semua dalam kondisi baik."
    },
    "orderCompleted": true
  }
}
```

### Submit QC — Ada Masalah

```http
conditionStatus: bad
quantityStatus: less
qualityNotes: Tomat banyak yang busuk, kuantitas kurang 5kg.
```

Response `201`:
```json
{
  "success": true,
  "message": "QC berhasil disubmit. Silakan ajukan sengketa jika ada masalah.",
  "data": {
    "qc": { "id": "uuid", "conditionStatus": "bad", "quantityStatus": "less" },
    "orderCompleted": false
  }
}
```

### Ajukan Sengketa

```http
POST /api/v1/orders/uuid-order/disputes
Authorization: Bearer <token>
Content-Type: multipart/form-data

reason: quality_issue
description: Tomat yang diterima banyak yang busuk dan tidak layak jual. Kuantitas juga kurang 5kg dari yang dipesan.
quantityProblematic: 5
evidence_photos: [file1, file2]
```

Response `201`:
```json
{
  "success": true,
  "message": "Sengketa berhasil diajukan.",
  "data": {
    "id": "uuid",
    "orderId": "uuid",
    "reason": "quality_issue",
    "description": "Tomat yang diterima...",
    "quantityProblematic": 5,
    "status": "submitted"
  }
}
```

### Detail Sengketa

```http
GET /api/v1/disputes/uuid-dispute
Authorization: Bearer <token>
```

Response `200`:
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "reason": "quality_issue",
    "description": "...",
    "status": "submitted",
    "adminDecision": null,
    "order": { "id": "uuid", "status": "disputed", "totalPrice": 700000, "commodity": { "name": "Tomat Segar" } },
    "customer": { "id": "uuid", "name": "Restoran Nusantara" },
    "farmer": { "id": "uuid", "name": "Bu Sari" },
    "evidences": [
      { "id": "uuid", "fileUrl": "http://localhost:3000/uploads/disputes/...", "fileType": "image/jpeg" }
    ]
  }
}
```

---

## Alur Status yang Ditangani

```
delivered → completed (via QC baik)
delivered → disputed (via ajukan sengketa)
completed → disputed (via ajukan sengketa, jika ada masalah setelah complete)
```

Keputusan admin (approve_refund, partial_refund, reject) akan ditangani di Fase 7 (modul admin).

---

## Hal Penting

- QC hanya bisa dilakukan 1x per order
- Dispute hanya bisa diajukan 1x per order
- Jika QC baik, escrow langsung dirilis dan wallet farmer bertambah (otomatis)
- Evidence photos disimpan di `uploads/disputes/`, max 5 file
- Notifikasi dispute dikirim ke SEMUA user dengan role admin
- Detail dispute bisa diakses oleh customer DAN farmer yang terlibat
- Nilai `reason`: `quality_issue`, `wrong_quantity`, `not_delivered`, `other`
