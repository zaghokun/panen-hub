# Modul Auth

## Deskripsi

Modul autentikasi PanenHub. Menangani login, registrasi (customer & farmer), refresh token, logout, dan endpoint `/me` untuk mendapatkan data user aktif.

---

## Daftar File

| File | Fungsi |
|---|---|
| `src/modules/auth/auth.validation.ts` | Zod schemas untuk validasi request body |
| `src/modules/auth/auth.service.ts` | Logika bisnis: hash password, generate JWT, query user |
| `src/modules/auth/auth.controller.ts` | Handler endpoint, panggil service, return response |
| `src/modules/auth/auth.routes.ts` | Definisi routes + middleware yang berlaku |

---

## Endpoints

| Method | Endpoint | Auth | Body |
|---|---|---|---|
| POST | `/api/v1/auth/login` | ❌ | `{ email, password }` |
| POST | `/api/v1/auth/register/customer` | ❌ | `{ name, email, phone?, password, businessName, businessType, businessAddress }` |
| POST | `/api/v1/auth/register/farmer` | ❌ | `multipart: name, email, phone?, password, farmName, landArea, address, latitude?, longitude?, farm_photo?` |
| POST | `/api/v1/auth/refresh` | ❌ | `{ refresh_token }` |
| POST | `/api/v1/auth/logout` | ✅ | — |
| GET | `/api/v1/auth/me` | ✅ | — |

---

## Cara Kerja

### Login
1. Cari user berdasarkan email
2. Bandingkan password dengan bcrypt
3. Cek apakah akun diblokir
4. Update `lastLoginAt`
5. Generate access token (1 jam) + refresh token (7 hari)
6. Return tokens + data user (tanpa password)

### Register Customer
1. Cek apakah email sudah terdaftar (409 jika duplikat)
2. Hash password dengan bcrypt (salt 10)
3. Buat user dengan role `customer` + `CustomerProfile`
4. Generate tokens, return sama seperti login

### Register Farmer
1. Cek duplikasi email
2. Hash password
3. Buat user dengan role `farmer` + `FarmerProfile` (status: pending) + `Wallet` (saldo 0)
4. Jika ada file `farm_photo`, simpan di `uploads/farms/` dan set `photoUrl`
5. Generate tokens, return

### Refresh Token
1. Verify refresh token dengan `JWT_REFRESH_SECRET`
2. Cek user masih ada dan tidak diblokir
3. Generate token pair baru

### Logout
- Stateless — hanya return success. Client hapus token di sisi mereka.

### /me
- Ambil data user berdasarkan `req.user.id` (dari JWT)
- Include `farmerProfile` atau `customerProfile` sesuai role
- Tidak expose field `password`

---

## Contoh Request & Response

### Login

```http
POST /api/v1/auth/login
Content-Type: application/json

{
  "email": "customer@panenhub.test",
  "password": "customer123"
}
```

Response `200`:
```json
{
  "success": true,
  "message": "Login berhasil.",
  "data": {
    "access_token": "eyJ...",
    "refresh_token": "eyJ...",
    "token_type": "Bearer",
    "expires_in": 3600,
    "user": {
      "id": "uuid",
      "name": "Restoran Nusantara",
      "email": "customer@panenhub.test",
      "role": "customer",
      "status": "active"
    }
  }
}
```

### Register Customer

```http
POST /api/v1/auth/register/customer
Content-Type: application/json

{
  "name": "Katering Sehat",
  "email": "katering@mail.com",
  "phone": "08123456789",
  "password": "secret123",
  "businessName": "Katering Sehat Sentosa",
  "businessType": "Katering",
  "businessAddress": "Jl. Merdeka No. 10, Bandung"
}
```

Response `201`: sama format seperti login.

### Register Farmer

```http
POST /api/v1/auth/register/farmer
Content-Type: multipart/form-data

name: Pak Joko
email: joko@mail.com
phone: 08198765432
password: farmer456
farmName: Kebun Joko Makmur
landArea: 3.5
address: Desa Cikaret, Bogor
latitude: -6.65
longitude: 106.8
farm_photo: [file]
```

Response `201`: sama format seperti login.

### Error — Email Duplikat

Response `409`:
```json
{
  "success": false,
  "message": "Email sudah terdaftar."
}
```

### Error — Validasi Gagal

Response `400`:
```json
{
  "success": false,
  "message": "Validasi gagal.",
  "errors": {
    "body.email": ["Format email tidak valid."],
    "body.password": ["Password minimal 6 karakter."]
  }
}
```

---

## Hal Penting

- JWT access token berlaku 1 jam (3600 detik), refresh token 7 hari (604800 detik)
- Password tidak pernah dikembalikan di response apapun
- Farmer yang baru register memiliki `verificationStatus: pending` — perlu diverifikasi admin
- Wallet otomatis dibuat saat farmer register (saldo 0)
- File upload farmer disimpan di `uploads/farms/`
- `@types/jsonwebtoken` v9 membutuhkan `expiresIn` berupa `number` (detik), bukan string seperti `"1h"`
