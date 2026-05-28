# Modul Commodities

## Deskripsi

Modul komoditas PanenHub. Menyediakan endpoint publik untuk customer melihat daftar & detail komoditas, serta endpoint CRUD untuk farmer mengelola komoditas miliknya.

---

## Daftar File

| File | Fungsi |
|---|---|
| `src/modules/commodities/commodity.validation.ts` | Zod schemas: create, update, list query |
| `src/modules/commodities/commodity.service.ts` | Logika bisnis: list publik, detail, CRUD farmer |
| `src/modules/commodities/commodity.controller.ts` | Handler endpoint |
| `src/modules/commodities/commodity.routes.ts` | Routes publik + farmer (exported terpisah) |

---

## Endpoints

### Publik (tanpa auth)

| Method | Endpoint | Keterangan |
|---|---|---|
| GET | `/api/v1/commodities` | List komoditas aktif + filter + pagination |
| GET | `/api/v1/commodities/:id` | Detail komoditas + profil farmer |

### Farmer (auth + role farmer)

| Method | Endpoint | Keterangan |
|---|---|---|
| GET | `/api/v1/farmer/commodities` | List komoditas milik farmer |
| POST | `/api/v1/farmer/commodities` | Tambah komoditas (multipart) |
| PATCH | `/api/v1/farmer/commodities/:id` | Edit komoditas |
| DELETE | `/api/v1/farmer/commodities/:id` | Nonaktifkan komoditas (soft delete) |

---

## Cara Kerja

### List Publik (GET /commodities)

Filter yang tersedia via query params:
- `search` — cari berdasarkan nama (case-insensitive, contains)
- `category` — filter kategori (exact, case-insensitive)
- `location` — filter lokasi (contains, case-insensitive)
- `harvest_date` — komoditas dengan estimasi panen >= tanggal ini
- `min_price` — harga minimum per kg
- `max_price` — harga maksimum per kg
- `page` — halaman (default: 1)
- `per_page` — item per halaman (default: 10, max: 100)

Hanya komoditas dengan `status: active` yang ditampilkan. Response include data farmer (nama + nama kebun + alamat).

### Detail (GET /commodities/:id)

Menampilkan detail komoditas lengkap + profil farmer (nama, nama kebun, luas lahan, alamat, foto, status verifikasi). Return 404 jika komoditas tidak ditemukan atau tidak aktif.

### Create (POST /farmer/commodities)

Farmer menambah komoditas baru. Menerima `multipart/form-data` dengan field `photo` opsional. File disimpan di `uploads/commodities/`.

### Update (PATCH /farmer/commodities/:id)

Farmer mengedit komoditas miliknya. Validasi ownership — return 403 jika bukan milik farmer yang login.

### Delete (DELETE /farmer/commodities/:id)

Soft delete — mengubah status menjadi `inactive`. Komoditas tidak tampil di list publik tapi masih terlihat di list farmer.

---

## Contoh Request & Response

### List Komoditas dengan Filter

```http
GET /api/v1/commodities?search=tomat&category=sayur&min_price=10000&page=1&per_page=5
```

Response `200`:
```json
{
  "success": true,
  "message": "Berhasil.",
  "data": [
    {
      "id": "uuid",
      "name": "Tomat Segar",
      "category": "sayur",
      "description": "Tomat merah segar dari kebun organik",
      "pricePerKg": 14000,
      "availableQuotaKg": 200,
      "estimatedHarvestDate": "2026-06-15T00:00:00.000Z",
      "imageUrl": null,
      "location": "Bogor, Jawa Barat",
      "status": "active",
      "farmer": {
        "id": "uuid",
        "name": "Bu Sari",
        "farmerProfile": {
          "farmName": "Kebun Sari Makmur",
          "address": "Desa Sukamaju, Kec. Ciawi, Bogor"
        }
      }
    }
  ],
  "meta": {
    "page": 1,
    "per_page": 5,
    "total": 1,
    "total_pages": 1
  }
}
```

### Tambah Komoditas

```http
POST /api/v1/farmer/commodities
Authorization: Bearer <token>
Content-Type: multipart/form-data

name: Kangkung Organik
category: sayur
description: Kangkung segar tanpa pestisida
pricePerKg: 6000
availableQuotaKg: 300
estimatedHarvestDate: 2026-07-01
location: Bogor, Jawa Barat
photo: [file]
```

Response `201`:
```json
{
  "success": true,
  "message": "Komoditas berhasil ditambahkan.",
  "data": {
    "id": "uuid",
    "farmerId": "uuid",
    "name": "Kangkung Organik",
    "category": "sayur",
    "pricePerKg": 6000,
    "availableQuotaKg": 300,
    "estimatedHarvestDate": "2026-07-01T00:00:00.000Z",
    "imageUrl": "http://localhost:3000/uploads/commodities/1234567890-123456789.jpg",
    "location": "Bogor, Jawa Barat",
    "status": "active"
  }
}
```

### Error — Bukan Pemilik

Response `403`:
```json
{
  "success": false,
  "message": "Anda tidak memiliki akses ke komoditas ini."
}
```

---

## Hal Penting

- Field `location` ada di model `Commodity` (bukan di `FarmerProfile` yang menggunakan `address`)
- Delete bersifat soft — status diubah ke `inactive`, data tetap ada di database
- List farmer menampilkan komoditas dengan status `active` dan `inactive` (exclude `disabled` yang di-disable admin)
- Upload foto opsional — jika tidak ada, `imageUrl` bernilai `null`
- Pagination default: page 1, per_page 10, max per_page 100
