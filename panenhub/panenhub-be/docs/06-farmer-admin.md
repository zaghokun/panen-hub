# Modul Farmer & Admin

## Deskripsi

Modul farmer (profil, wallet, withdrawal) dan admin (dashboard, verifikasi petani, keputusan sengketa, approval withdrawal).

---

## Daftar File

### Farmer Profile
| File | Fungsi |
|---|---|
| `src/modules/farmer/profile/farmer-profile.service.ts` | Get + update profil |
| `src/modules/farmer/profile/farmer-profile.controller.ts` | Handler |
| `src/modules/farmer/profile/farmer-profile.routes.ts` | Routes |

### Farmer Wallet
| File | Fungsi |
|---|---|
| `src/modules/farmer/wallet/wallet.service.ts` | Get saldo |
| `src/modules/farmer/wallet/wallet.controller.ts` | Handler |
| `src/modules/farmer/wallet/wallet.routes.ts` | Routes |

### Farmer Withdrawals
| File | Fungsi |
|---|---|
| `src/modules/farmer/withdrawals/withdrawal.validation.ts` | Zod schema |
| `src/modules/farmer/withdrawals/withdrawal.service.ts` | Request + list |
| `src/modules/farmer/withdrawals/withdrawal.controller.ts` | Handler |
| `src/modules/farmer/withdrawals/withdrawal.routes.ts` | Routes |

### Admin
| File | Fungsi |
|---|---|
| `src/modules/admin/admin.service.ts` | Semua logika admin |
| `src/modules/admin/admin.controller.ts` | Handler |
| `src/modules/admin/admin.routes.ts` | Routes |

---

## Endpoints

### Farmer

| Method | Endpoint | Keterangan |
|---|---|---|
| GET | `/api/v1/farmer/profile` | Profil farmer |
| PATCH | `/api/v1/farmer/profile` | Update profil (multipart) |
| GET | `/api/v1/farmer/wallet` | Saldo wallet |
| POST | `/api/v1/farmer/withdrawals` | Ajukan withdrawal |
| GET | `/api/v1/farmer/withdrawals` | Riwayat withdrawal |

### Admin

| Method | Endpoint | Keterangan |
|---|---|---|
| GET | `/api/v1/admin/dashboard` | Ringkasan platform |
| PATCH | `/api/v1/admin/users/:id/verify` | Verifikasi farmer |
| GET | `/api/v1/admin/disputes` | List sengketa |
| PATCH | `/api/v1/admin/disputes/:id/decision` | Putuskan sengketa |
| GET | `/api/v1/admin/withdrawals` | List withdrawal |
| PATCH | `/api/v1/admin/withdrawals/:id/approve` | Approve withdrawal |
| PATCH | `/api/v1/admin/withdrawals/:id/reject` | Reject withdrawal |

---

## Cara Kerja

### Farmer Profile
- GET: return user + farmerProfile
- PATCH: update user fields (name, phone) + farmerProfile fields (farmName, landArea, address, lat, lng, photo)

### Farmer Wallet
- GET: return wallet (balanceAvailable, balancePending, totalEarned)

### Farmer Withdrawal
1. Validasi saldo cukup
2. Dalam transaction: kurangi `balanceAvailable`, buat record withdrawal (status: requested)
3. Admin akan approve/reject nanti

### Admin Dashboard
Return counts: totalUsers, totalFarmers, totalOrders, totalDisputes (submitted), pendingWithdrawals, pendingVerifications.

### Admin Verifikasi Farmer
- Body: `{ action: "approve" | "reject", notes? }`
- Update `verificationStatus` di FarmerProfile
- Kirim notifikasi ke farmer

### Admin Keputusan Sengketa
- Body: `{ decision, notes?, refundAmount? }`
- Decisions:
  - `approve_refund` → order refunded, escrow refunded
  - `partial_refund` → order refunded, escrow refunded (wajib refundAmount)
  - `reject` → order completed, escrow released ke farmer wallet
  - `request_more_evidence` → status under_review, tidak close
- Notifikasi ke customer + farmer

### Admin Approve Withdrawal
- Update status → approved, set processedAt
- Notifikasi ke farmer

### Admin Reject Withdrawal
- Update status → rejected
- Kembalikan saldo ke wallet farmer (increment balanceAvailable)
- Notifikasi ke farmer

---

## Contoh Request & Response

### Ajukan Withdrawal

```http
POST /api/v1/farmer/withdrawals
Authorization: Bearer <farmer_token>
Content-Type: application/json

{
  "amount": 500000,
  "bankName": "BCA",
  "accountNumber": "1234567890",
  "accountHolderName": "Bu Sari"
}
```

Response `201`:
```json
{
  "success": true,
  "message": "Withdrawal berhasil diajukan.",
  "data": {
    "id": "uuid",
    "amount": 500000,
    "bankName": "BCA",
    "status": "requested",
    "requestedAt": "2026-05-29T..."
  }
}
```

### Admin Putuskan Sengketa

```http
PATCH /api/v1/admin/disputes/uuid-dispute/decision
Authorization: Bearer <admin_token>
Content-Type: application/json

{
  "decision": "partial_refund",
  "notes": "Refund 50% karena kualitas sebagian buruk.",
  "refundAmount": 350000
}
```

### Admin Verifikasi Farmer

```http
PATCH /api/v1/admin/users/uuid-farmer/verify
Authorization: Bearer <admin_token>
Content-Type: application/json

{
  "action": "approve",
  "notes": "Dokumen lengkap."
}
```

---

## Hal Penting

- Semua endpoint farmer dilindungi `authMiddleware + roleMiddleware('farmer')`
- Semua endpoint admin dilindungi `authMiddleware + roleMiddleware('admin')`
- Withdrawal langsung mengurangi saldo saat diajukan (bukan saat approve)
- Jika withdrawal ditolak, saldo dikembalikan
- Keputusan sengketa `reject` → dana dirilis ke farmer (wallet bertambah)
- Keputusan sengketa `approve_refund` / `partial_refund` → escrow refunded
- `request_more_evidence` tidak menutup sengketa (status: under_review)
