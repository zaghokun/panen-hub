# PanenHub — Dokumen Lengkap Proyek Aplikasi Android Flutter

**Mata kuliah:** Rekayasa Perangkat Lunak  
**Nama proyek:** PanenHub  
**Jenis sistem:** Sistem rantai pasok B2B pertanian  
**Platform aplikasi:** Android Mobile App  
**Framework utama frontend:** Flutter SDK  
**Status dokumen:** Blueprint lengkap proyek untuk kebutuhan analisis, perancangan, dan implementasi awal  
**Versi:** 1.0  

---

## 1. Ringkasan Eksekutif

PanenHub adalah aplikasi rantai pasok pertanian berbasis B2B yang menghubungkan petani lokal dengan pelanggan bisnis seperti restoran, katering, hotel, atau pelaku usaha kuliner lain. Fokus utama aplikasi adalah **pre-order komoditas berdasarkan estimasi masa panen**, sehingga pelanggan dapat memesan bahan baku segar lebih awal, sedangkan petani memperoleh kepastian permintaan sebelum masa panen.

Aplikasi ini dirancang sebagai **aplikasi Android profesional**, bukan website. Karena itu, rancangan frontend dalam dokumen ini mengutamakan pengalaman pengguna mobile: navigasi cepat, UI modern, layout responsif Android, state visual yang jelas, serta alur transaksi yang mudah dipahami.

Sistem PanenHub memiliki tiga aktor utama:

1. **Pelanggan B2B**  
   Restoran, katering, hotel, atau bisnis kuliner yang mencari bahan baku segar, melakukan pre-order, membayar melalui escrow, memantau pengiriman, melakukan QC, mengajukan sengketa, dan memberikan ulasan.

2. **Petani / Mitra Supplier**  
   Pengguna yang mengelola profil lahan, membuat posting estimasi panen, menerima pesanan, memperbarui status rantai pasok, dan mengajukan pencairan dana.

3. **Admin PanenHub**  
   Pengelola sistem yang memverifikasi akun, mengelola pengguna dan konten, memantau transaksi, menangani sengketa, dan memvalidasi pencairan dana.

---

## 2. Ruang Lingkup Dokumen

Dokumen ini mencakup keseluruhan proyek PanenHub dari sudut pandang perancangan aplikasi, termasuk:

- konsep produk,
- aktor dan hak akses,
- kebutuhan fungsional,
- kebutuhan non-fungsional,
- rancangan frontend Android Flutter,
- rancangan backend secara konseptual,
- alur kerja frontend dan backend,
- rancangan navigasi aplikasi,
- rancangan screen aplikasi,
- model data frontend,
- rancangan API awal,
- state machine pesanan,
- rancangan database logis,
- ringkasan UML, activity diagram, ERD, DFD Level 0, dan DFD Level 1,
- strategi UI profesional,
- strategi validasi, error handling, testing, dan deployment,
- roadmap pengerjaan.

> Catatan penting: laporan awal belum menetapkan framework backend, database fisik, payment gateway, cloud storage, push notification service, maupun desain low-fidelity/high-fidelity final. Bagian yang belum pasti akan diberi label **TBD** atau **rekomendasi**, bukan dianggap keputusan final.

---

## 3. Tujuan Aplikasi

Tujuan utama PanenHub adalah menyediakan platform mobile yang:

1. menghubungkan petani lokal dengan pelanggan bisnis secara langsung;
2. membantu pelanggan melakukan pemesanan komoditas sebelum masa panen;
3. memberi kepastian permintaan bagi petani;
4. mengurangi ketergantungan pada tengkulak;
5. menyediakan alur pembayaran aman berbasis escrow;
6. menyediakan pelacakan status rantai pasok secara transparan;
7. menyediakan pencatatan Quality Control saat barang diterima;
8. menyediakan mekanisme sengketa jika kualitas barang tidak sesuai;
9. membangun reputasi petani melalui rating dan ulasan.

---

## 4. Platform Target

### 4.1 Platform Utama

Aplikasi ditargetkan untuk:

```text
Platform : Android
Tipe     : Mobile Application
UI       : Touch-first interface
Mode     : Portrait-first
```

### 4.2 Bukan Website

PanenHub dalam implementasi ini tidak dirancang sebagai website. Semua keputusan frontend dalam dokumen ini mengacu pada aplikasi Android Flutter, seperti:

- bottom navigation,
- mobile app bar,
- card-based layout,
- gesture-friendly button,
- mobile form,
- modal bottom sheet,
- responsive layout untuk berbagai ukuran layar Android,
- local session storage,
- Android permission untuk kamera, galeri, lokasi, dan notifikasi jika dipakai.

---

## 5. Tech Stack

## 🛠️ Tech Stack Flutter

### Core Framework

```text
Flutter SDK : ^3.x (latest stable)
Dart        : ^3.x
Target OS   : Android
```

### Frontend Recommended Stack

Rekomendasi ini dibuat agar aplikasi terlihat profesional, terstruktur, dan mudah dikembangkan oleh tim frontend.

| Kebutuhan | Rekomendasi | Status |
|---|---|---|
| UI Framework | Flutter Material 3 | Direkomendasikan |
| Routing | `go_router` | Direkomendasikan |
| State Management | `flutter_riverpod` atau `bloc` | Perlu dipilih tim |
| HTTP Client | `dio` | Direkomendasikan |
| Local Storage Token | `flutter_secure_storage` | Direkomendasikan |
| Lightweight Cache | `shared_preferences` atau `hive` | Direkomendasikan |
| Image Loading | `cached_network_image` | Direkomendasikan |
| Upload Foto | `image_picker` | Direkomendasikan |
| Format Tanggal & Angka | `intl` | Direkomendasikan |
| Skeleton Loading | `shimmer` | Opsional |
| Toast/Snackbar | Flutter built-in `SnackBar` | Direkomendasikan |
| Map/Location | TBD | Belum ditentukan |
| Push Notification | TBD | Belum ditentukan |

### Backend Stack

Backend stack **belum ditentukan dalam laporan awal**. Karena itu dokumen ini tidak menetapkan Laravel, Express, NestJS, Firebase, Supabase, atau framework lain sebagai keputusan final.

Namun secara konseptual, backend harus menyediakan:

- REST API atau GraphQL API;
- autentikasi dan otorisasi berbasis role;
- database relasional atau dokumen;
- manajemen file untuk foto produk, bukti QC, dan bukti sengketa;
- transaksi escrow;
- status rantai pasok;
- dashboard admin;
- notifikasi kepada pelanggan, petani, dan admin.

### Backend Recommendation Placeholder

```text
Backend Framework : TBD
Database          : TBD
Payment Gateway   : TBD
Storage Service    : TBD
Notification       : TBD
Deployment         : TBD
```

---

## 6. Aktor Sistem

### 6.1 Pelanggan B2B

Pelanggan B2B adalah pihak pembeli dari sektor bisnis kuliner seperti restoran, katering, hotel, atau usaha makanan.

#### Hak Akses Pelanggan

Pelanggan dapat:

- registrasi dan login;
- mengelola profil bisnis;
- mencari komoditas;
- memfilter komoditas berdasarkan jenis, lokasi, dan estimasi panen;
- melihat detail petani dan komoditas;
- membuat pre-order;
- melakukan pembayaran escrow;
- memantau status pesanan;
- mengonfirmasi penerimaan barang;
- melakukan Quality Control;
- mengajukan sengketa/retur jika barang tidak sesuai;
- memberikan rating dan ulasan.

### 6.2 Petani / Mitra Supplier

Petani adalah pihak penyedia komoditas pertanian yang menjual produk kepada pelanggan B2B.

#### Hak Akses Petani

Petani dapat:

- registrasi dan login;
- mengelola profil;
- mendaftarkan data lahan;
- mengunggah komoditas dan estimasi panen;
- mengelola kuota/stok panen;
- menerima pesanan pre-order;
- memperbarui status rantai pasok;
- mengisi informasi kurir saat status dikirim;
- melihat status pembayaran;
- mengajukan pencairan dana;
- melihat rating dan ulasan dari pelanggan.

### 6.3 Admin PanenHub

Admin adalah pengelola sistem yang memastikan transaksi dan operasional aplikasi berjalan sesuai aturan.

#### Hak Akses Admin

Admin dapat:

- login ke sistem;
- memverifikasi akun petani;
- mengelola akun pengguna;
- memblokir atau menghapus pengguna bermasalah;
- menghapus atau menonaktifkan posting panen yang melanggar aturan;
- memantau transaksi;
- memantau dana escrow;
- meninjau bukti sengketa;
- memutuskan refund atau pencairan dana;
- menyetujui withdrawal petani;
- mengelola data master seperti kategori dan wilayah.

---

## 7. Kebutuhan Fungsional

### 7.1 Registrasi & Login

Aktor:

- Pelanggan
- Petani
- Admin

Deskripsi:

Pengguna dapat membuat akun atau masuk ke aplikasi sesuai peran masing-masing. Role menentukan halaman, fitur, dan hak akses setelah login.

Input utama:

- nama;
- email;
- nomor telepon;
- password;
- role;
- data tambahan sesuai role.

Output:

- akun berhasil dibuat;
- sesi login aktif;
- pengguna diarahkan ke dashboard sesuai role.

### 7.2 Kelola Profil & Lahan

Aktor:

- Petani

Deskripsi:

Petani dapat melengkapi data profil dan data lahan untuk keperluan logistik dan transparansi kepada pelanggan.

Data yang dikelola:

- nama petani;
- nama lahan;
- luas lahan;
- alamat lahan;
- titik lokasi;
- nomor telepon;
- foto lahan;
- deskripsi lahan.

### 7.3 Posting Estimasi Panen

Aktor:

- Petani

Deskripsi:

Petani membuat penawaran komoditas yang akan tersedia pada masa panen tertentu.

Data posting:

- nama komoditas;
- kategori;
- deskripsi;
- foto produk;
- harga per kilogram;
- kuota tersedia;
- estimasi tanggal panen;
- lokasi;
- status penawaran.

### 7.4 Mencari & Filter Komoditas

Aktor:

- Pelanggan

Deskripsi:

Pelanggan mencari bahan baku berdasarkan kebutuhan bisnisnya.

Filter utama:

- nama komoditas;
- kategori;
- lokasi terdekat;
- estimasi panen;
- harga;
- rating petani;
- ketersediaan kuota.

### 7.5 Membuat Pre-Order

Aktor:

- Pelanggan

Deskripsi:

Pelanggan melakukan booking kuota panen untuk pengiriman di masa depan.

Input:

- komoditas;
- jumlah kilogram;
- tanggal pengiriman;
- alamat pengiriman;
- catatan pesanan.

Output:

- pre-order dibuat;
- kuota komoditas dikunci sementara;
- pelanggan diarahkan ke pembayaran.

### 7.6 Pembayaran Aman / Escrow

Aktor:

- Pelanggan
- Sistem Backend
- Admin

Deskripsi:

Pelanggan membayar pesanan di awal. Dana ditahan oleh sistem sampai barang diterima dan pelanggan menyetujui hasil QC.

Status pembayaran:

```text
UNPAID
WAITING_VERIFICATION
PAID_ESCROW
FAILED
REFUNDED
RELEASED_TO_FARMER
```

### 7.7 Update Status Rantai Pasok

Aktor:

- Petani

Deskripsi:

Petani memperbarui status pesanan secara bertahap sesuai kondisi real.

Urutan status:

```text
PRE_ORDER
DIBAYAR
PANEN
SORTIR_QC
DIKIRIM
DITERIMA
SELESAI
SENGKETA
DIBATALKAN
```

Aturan:

- status tidak boleh melompat sembarangan;
- status `DIKIRIM` wajib memiliki informasi kurir;
- status `SELESAI` hanya terjadi setelah pelanggan menyetujui penerimaan atau admin menyelesaikan sengketa.

### 7.8 Konfirmasi Penerimaan & Quality Control

Aktor:

- Pelanggan

Deskripsi:

Pelanggan mengonfirmasi barang telah diterima dan mengecek kondisi fisik komoditas.

Kemungkinan hasil:

1. barang sesuai;
2. barang rusak/tidak sesuai;
3. pelanggan mengajukan retur/sengketa.

### 7.9 Pengajuan Retur/Sengketa

Aktor:

- Pelanggan

Deskripsi:

Pelanggan dapat mengajukan komplain jika kualitas komoditas membusuk, rusak, kurang jumlah, atau tidak sesuai kesepakatan.

Input sengketa:

- alasan komplain;
- deskripsi masalah;
- foto bukti;
- jumlah barang bermasalah;
- tanggal diterima;
- catatan tambahan.

> Catatan normalisasi: pada salah satu bagian laporan awal terdapat kalimat yang tampak tidak sesuai konteks, yaitu deskripsi “customer meninjau hasil kerja”. Dalam dokumen ini, alur retur/sengketa dinormalisasi mengikuti konteks PanenHub, yaitu sengketa kualitas komoditas pertanian.

### 7.10 Penyelesaian Sengketa

Aktor:

- Admin

Deskripsi:

Admin meninjau laporan komplain, memvalidasi bukti, membandingkan dengan deskripsi produk, lalu mengambil keputusan.

Keputusan admin:

- refund penuh;
- refund sebagian;
- tolak retur dan cairkan dana ke petani;
- minta bukti tambahan;
- tutup kasus.

### 7.11 Pencairan Dana / Withdrawal

Aktor:

- Petani
- Admin

Deskripsi:

Petani dapat mengajukan pencairan dana setelah pesanan selesai dan dana escrow sudah bisa dilepas.

Status withdrawal:

```text
REQUESTED
UNDER_REVIEW
APPROVED
REJECTED
PAID
```

### 7.12 Rating & Ulasan

Aktor:

- Pelanggan

Deskripsi:

Pelanggan memberikan penilaian terhadap kualitas produk dan layanan petani setelah transaksi selesai.

Input:

- rating bintang;
- komentar;
- foto opsional;
- aspek kualitas produk;
- aspek ketepatan pengiriman.

### 7.13 Manajemen Pengguna & Konten

Aktor:

- Admin

Deskripsi:

Admin dapat mengelola pengguna dan konten yang ada di aplikasi.

Aksi admin:

- menyetujui akun petani;
- memblokir akun;
- menghapus akun;
- menonaktifkan komoditas;
- melihat histori transaksi;
- melihat laporan sengketa.

---

## 8. Kebutuhan Non-Fungsional

### 8.1 Usability

Aplikasi harus mudah digunakan oleh pengguna non-teknis seperti petani dan pemilik usaha kuliner.

Kriteria:

- navigasi jelas;
- teks mudah dibaca;
- tombol cukup besar;
- form tidak terlalu panjang;
- alur transaksi tidak membingungkan;
- error message mudah dipahami.

### 8.2 Performance

Kriteria:

- halaman utama terbuka cepat;
- list komoditas menggunakan pagination;
- gambar dikompresi;
- cache gambar digunakan;
- loading state ditampilkan saat data diproses.

### 8.3 Security

Kriteria:

- password tidak disimpan di frontend;
- token disimpan di secure storage;
- endpoint backend memvalidasi role;
- upload file dibatasi ukuran dan tipe;
- data pembayaran tidak dikelola sembarangan di frontend;
- keputusan escrow dan refund hanya dilakukan backend/admin.

### 8.4 Reliability

Kriteria:

- aplikasi tetap menampilkan pesan error saat koneksi gagal;
- user dapat mencoba ulang request;
- status transaksi tidak berubah hanya dari sisi frontend;
- status penting harus divalidasi backend.

### 8.5 Maintainability

Kriteria:

- struktur folder modular;
- logic bisnis tidak dicampur langsung di widget;
- service/repository dipisahkan;
- model data terdokumentasi;
- naming konsisten.

---

## 9. Arsitektur Sistem

### 9.1 Gambaran Umum

```text
+---------------------------+
| Android App Flutter       |
| - UI                      |
| - State Management        |
| - Routing                 |
| - Form Validation         |
| - API Client              |
+-------------+-------------+
              |
              | HTTPS / REST API
              |
+-------------v-------------+
| Backend API               |
| - Auth                    |
| - User Management         |
| - Commodity Management    |
| - Pre-Order               |
| - Escrow                  |
| - Supply Chain Status     |
| - QC                      |
| - Dispute                 |
| - Withdrawal              |
| - Review                  |
+-------------+-------------+
              |
              |
+-------------v-------------+
| Database / Storage        |
| - User Data               |
| - Commodity Data          |
| - Order Data              |
| - Payment Data            |
| - Status History          |
| - Image/File Evidence     |
+---------------------------+
```

### 9.2 Prinsip Pembagian Tanggung Jawab

| Area | Frontend Flutter | Backend |
|---|---|---|
| UI | Ya | Tidak |
| Navigasi | Ya | Tidak |
| Validasi form awal | Ya | Ya, validasi final |
| Autentikasi tampilan | Ya | Ya |
| Token/session | Simpan token | Buat dan validasi token |
| Role access UI | Ya | Ya, sebagai otoritas final |
| Data komoditas | Tampilkan | Simpan dan validasi |
| Pre-order | Kirim request | Proses transaksi |
| Escrow | Tampilkan status | Mengatur logika dana |
| Update status | Kirim input petani | Validasi transisi status |
| QC | Kirim konfirmasi/bukti | Simpan hasil QC |
| Sengketa | Form dan upload bukti | Proses keputusan |
| Withdrawal | Form request | Verifikasi dan proses |
| Notifikasi | Tampilkan | Mengirim notifikasi |
| Database | Tidak langsung | Ya |

---

## 10. Arsitektur Frontend Android Flutter

### 10.1 Layer Frontend

Direkomendasikan menggunakan struktur layer berikut:

```text
Presentation Layer
- Screen
- Widget
- Form
- View State

Application Layer
- Controller / Notifier / Bloc
- Use Case
- Validation Logic

Domain Layer
- Entity
- Repository Contract
- Business Rule

Data Layer
- DTO / Model
- API Service
- Repository Implementation
- Local Storage
```

### 10.2 Struktur Folder Flutter

```text
lib/
├── main.dart
├── app/
│   ├── app.dart
│   ├── router/
│   │   ├── app_router.dart
│   │   └── route_names.dart
│   ├── theme/
│   │   ├── app_theme.dart
│   │   ├── app_colors.dart
│   │   ├── app_typography.dart
│   │   └── app_spacing.dart
│   └── constants/
│       ├── app_assets.dart
│       ├── app_config.dart
│       └── app_strings.dart
│
├── core/
│   ├── network/
│   │   ├── api_client.dart
│   │   ├── api_endpoints.dart
│   │   ├── api_exception.dart
│   │   └── auth_interceptor.dart
│   ├── storage/
│   │   ├── secure_storage_service.dart
│   │   └── local_cache_service.dart
│   ├── utils/
│   │   ├── currency_formatter.dart
│   │   ├── date_formatter.dart
│   │   └── validators.dart
│   └── widgets/
│       ├── app_button.dart
│       ├── app_text_field.dart
│       ├── app_empty_state.dart
│       ├── app_error_state.dart
│       ├── app_loading.dart
│       ├── commodity_card.dart
│       ├── order_status_chip.dart
│       └── section_header.dart
│
├── features/
│   ├── auth/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── customer/
│   │   ├── home/
│   │   ├── commodity/
│   │   ├── preorder/
│   │   ├── payment/
│   │   ├── order_tracking/
│   │   ├── qc/
│   │   ├── dispute/
│   │   └── review/
│   ├── farmer/
│   │   ├── dashboard/
│   │   ├── land_profile/
│   │   ├── harvest_post/
│   │   ├── incoming_orders/
│   │   ├── supply_status/
│   │   └── withdrawal/
│   └── admin/
│       ├── dashboard/
│       ├── user_management/
│       ├── content_management/
│       ├── dispute_management/
│       └── withdrawal_approval/
│
└── shared/
    ├── models/
    ├── enums/
    └── extensions/
```

### 10.3 Prinsip UI Profesional

Aplikasi harus terlihat seperti aplikasi produksi, bukan sekadar prototype tugas.

Prinsip desain:

- gunakan Material 3;
- gunakan warna primer hijau pertanian yang modern;
- gunakan putih/off-white sebagai background utama;
- gunakan card dengan radius konsisten;
- gunakan shadow ringan;
- gunakan typography yang jelas;
- jangan menampilkan terlalu banyak informasi dalam satu layar;
- gunakan bottom navigation sesuai role;
- tampilkan status transaksi dengan chip warna;
- gunakan ilustrasi/empty state untuk halaman kosong;
- tampilkan skeleton loading pada list;
- tampilkan snackbar untuk feedback singkat;
- gunakan dialog hanya untuk keputusan penting;
- gunakan bottom sheet untuk filter atau pilihan aksi.

### 10.4 Rekomendasi Design Token

```text
Primary Color       : #2E7D32
Primary Dark        : #1B5E20
Primary Light       : #A5D6A7
Accent Color        : #F9A825
Background          : #F8FAF7
Surface             : #FFFFFF
Text Primary        : #1F2933
Text Secondary      : #6B7280
Error               : #D32F2F
Warning             : #F57C00
Success             : #388E3C
Info                : #1976D2
Border              : #E5E7EB
```

### 10.5 Tipografi

```text
Heading Large  : 24sp / Bold
Heading Medium : 20sp / SemiBold
Title          : 16sp / SemiBold
Body           : 14sp / Regular
Caption        : 12sp / Regular
Button         : 14sp / SemiBold
```

### 10.6 Spacing

```text
XS : 4
SM : 8
MD : 16
LG : 24
XL : 32
```

### 10.7 Komponen UI Global

Komponen yang sebaiknya dibuat reusable:

- `AppButton`
- `AppOutlinedButton`
- `AppTextField`
- `AppPasswordField`
- `AppDropdownField`
- `AppDatePickerField`
- `AppImagePicker`
- `CommodityCard`
- `OrderCard`
- `StatusTimeline`
- `OrderStatusChip`
- `ProfileAvatar`
- `PriceText`
- `EmptyState`
- `ErrorState`
- `LoadingOverlay`
- `ConfirmationDialog`
- `FilterBottomSheet`

---

## 11. Navigasi Aplikasi

### 11.1 Alur Splash

```text
Splash Screen
  ├── token tidak ada      -> Onboarding / Login
  ├── token ada, role customer -> Customer Main
  ├── token ada, role farmer   -> Farmer Main
  └── token ada, role admin    -> Admin Main
```

### 11.2 Auth Flow

```text
Onboarding
  -> Login
  -> Register
       -> Select Role
       -> Register Form
       -> Success / Waiting Verification
  -> Forgot Password (opsional)
```

### 11.3 Customer Navigation

Bottom navigation untuk pelanggan:

```text
Home
Explore
Orders
Notifications
Profile
```

Halaman turunan:

```text
Home
  -> Commodity Detail
  -> Farmer Profile
  -> Pre-Order Form
  -> Payment Screen

Explore
  -> Search Result
  -> Filter Bottom Sheet
  -> Commodity Detail

Orders
  -> Order Detail
  -> Tracking Timeline
  -> Confirm Receipt
  -> QC Form
  -> Dispute Form
  -> Review Form

Profile
  -> Business Profile
  -> Saved Address
  -> Payment History
  -> Help Center
  -> Logout
```

### 11.4 Farmer Navigation

Bottom navigation untuk petani:

```text
Dashboard
Harvest
Orders
Wallet
Profile
```

Halaman turunan:

```text
Dashboard
  -> Summary Card
  -> Active Orders
  -> Pending Actions

Harvest
  -> My Commodity List
  -> Create Harvest Post
  -> Edit Harvest Post
  -> Commodity Detail

Orders
  -> Incoming Orders
  -> Order Detail
  -> Update Supply Status
  -> Courier Form

Wallet
  -> Balance
  -> Withdrawal Request
  -> Withdrawal History

Profile
  -> Farmer Profile
  -> Land Profile
  -> Verification Status
  -> Reviews
  -> Logout
```

### 11.5 Admin Navigation

Admin dapat dibuat sebagai bagian aplikasi Android yang sama, tetapi untuk proyek produksi lebih ideal admin menggunakan dashboard web. Karena kebutuhan saat ini adalah Android app, admin tetap disediakan dalam aplikasi.

Bottom navigation untuk admin:

```text
Dashboard
Users
Disputes
Withdrawals
Profile
```

Halaman turunan:

```text
Dashboard
  -> Transaction Summary
  -> Pending Verification
  -> Pending Dispute
  -> Pending Withdrawal

Users
  -> User List
  -> User Detail
  -> Verify Farmer
  -> Block User

Disputes
  -> Dispute List
  -> Dispute Detail
  -> Evidence Preview
  -> Decision Form

Withdrawals
  -> Withdrawal List
  -> Withdrawal Detail
  -> Approve / Reject

Profile
  -> Admin Profile
  -> Logout
```

---

## 12. Screen Specification

## 12.1 Splash Screen

Tujuan:

- mengecek session;
- menentukan role;
- mengarahkan user ke halaman sesuai role.

Komponen:

- logo PanenHub;
- loading indicator;
- background bersih.

State:

- loading;
- unauthenticated;
- authenticated customer;
- authenticated farmer;
- authenticated admin;
- error.

## 12.2 Onboarding Screen

Tujuan:

- memperkenalkan value proposition PanenHub.

Konten:

- pesan utama: pre-order bahan baku segar langsung dari petani;
- manfaat untuk pelanggan;
- manfaat untuk petani;
- CTA login dan register.

## 12.3 Login Screen

Field:

- email;
- password.

Aksi:

- login;
- lupa password;
- daftar akun.

Validasi:

- email wajib;
- format email valid;
- password wajib;
- tombol login disabled jika form tidak valid.

## 12.4 Register Role Screen

Pilihan role:

- Pelanggan B2B;
- Petani Mitra.

Admin tidak sebaiknya melakukan registrasi publik.

## 12.5 Register Customer Screen

Field:

- nama penanggung jawab;
- nama bisnis;
- tipe bisnis;
- email;
- nomor telepon;
- password;
- konfirmasi password;
- alamat bisnis.

## 12.6 Register Farmer Screen

Field:

- nama petani;
- nama lahan;
- email;
- nomor telepon;
- password;
- alamat lahan;
- luas lahan;
- foto lahan;
- titik lokasi.

Output:

- akun dibuat;
- status akun menunggu verifikasi admin jika verifikasi diwajibkan.

---

## 13. Screen Customer

### 13.1 Customer Home

Konten utama:

- greeting;
- search bar;
- kategori komoditas;
- komoditas mendekati panen;
- rekomendasi petani;
- pesanan aktif;
- banner edukatif.

Komponen:

- `SearchBar`
- `CategoryChip`
- `CommodityCard`
- `ActiveOrderCard`
- `FarmerRecommendationCard`

### 13.2 Explore Commodity

Fungsi:

- mencari komoditas;
- filter berdasarkan kategori, lokasi, tanggal panen, harga, rating.

State:

- loading;
- result;
- empty result;
- error.

### 13.3 Commodity Detail

Konten:

- foto komoditas;
- nama komoditas;
- harga per kg;
- estimasi tanggal panen;
- kuota tersedia;
- deskripsi;
- lokasi petani;
- profil petani;
- rating;
- CTA buat pre-order.

### 13.4 Pre-Order Form

Field:

- jumlah kg;
- tanggal pengiriman;
- alamat pengiriman;
- catatan pesanan.

Validasi:

- jumlah kg wajib;
- jumlah kg tidak boleh melebihi kuota;
- tanggal pengiriman tidak boleh sebelum estimasi panen;
- alamat wajib.

Output:

- ringkasan pesanan;
- total harga;
- lanjut pembayaran.

### 13.5 Payment Screen

Konten:

- invoice;
- metode pembayaran;
- nominal;
- instruksi pembayaran;
- status pembayaran.

Aksi:

- pilih metode pembayaran;
- upload bukti bayar jika sistem masih manual;
- cek status;
- batalkan pesanan jika belum dibayar.

Catatan:

- jika menggunakan payment gateway, frontend hanya menerima redirect/payment token dari backend;
- jika pembayaran manual, backend tetap harus memvalidasi bukti pembayaran.

### 13.6 Order List

Tab:

- semua;
- menunggu pembayaran;
- diproses;
- dikirim;
- selesai;
- sengketa.

### 13.7 Order Detail

Konten:

- nomor pesanan;
- status;
- detail komoditas;
- data petani;
- alamat pengiriman;
- timeline status;
- pembayaran;
- tombol aksi sesuai status.

Aksi berdasarkan status:

| Status | Aksi Customer |
|---|---|
| `WAITING_PAYMENT` | Bayar |
| `PAID_ESCROW` | Lihat detail |
| `PANEN` | Lihat progress |
| `SORTIR_QC` | Lihat progress |
| `DIKIRIM` | Konfirmasi penerimaan |
| `DITERIMA` | Isi QC |
| `SELESAI` | Beri ulasan |
| `SENGKETA` | Lihat status sengketa |

### 13.8 Confirm Receipt & QC Screen

Pertanyaan:

- apakah barang sudah diterima?
- apakah kondisi sesuai?
- apakah jumlah sesuai?
- apakah kualitas sesuai?

Aksi:

- setujui penerimaan;
- ajukan retur/sengketa.

### 13.9 Dispute Form

Field:

- alasan;
- deskripsi;
- foto bukti;
- jumlah barang bermasalah;
- permintaan penyelesaian.

Validasi:

- alasan wajib;
- deskripsi wajib;
- minimal satu foto bukti;
- jumlah bermasalah tidak boleh melebihi jumlah pesanan.

### 13.10 Review Form

Field:

- rating bintang;
- komentar;
- foto opsional.

---

## 14. Screen Farmer

### 14.1 Farmer Dashboard

Konten:

- total posting aktif;
- pesanan aktif;
- saldo tertahan;
- saldo tersedia;
- aksi cepat;
- daftar pesanan terbaru.

Aksi cepat:

- tambah komoditas;
- lihat pesanan;
- update status;
- ajukan withdrawal.

### 14.2 Land Profile

Konten:

- data lahan;
- luas;
- alamat;
- titik lokasi;
- foto lahan;
- status verifikasi.

### 14.3 Harvest List

Konten:

- daftar komoditas yang diposting;
- status aktif/nonaktif;
- kuota tersisa;
- estimasi panen.

Aksi:

- tambah;
- edit;
- nonaktifkan.

### 14.4 Create Harvest Post

Field:

- nama komoditas;
- kategori;
- harga per kg;
- kuota;
- estimasi panen;
- deskripsi;
- foto.

Validasi:

- nama wajib;
- harga > 0;
- kuota > 0;
- estimasi panen tidak boleh tanggal lampau;
- foto direkomendasikan.

### 14.5 Incoming Orders

Tab:

- baru;
- dibayar;
- panen;
- sortir;
- dikirim;
- selesai.

### 14.6 Farmer Order Detail

Konten:

- detail customer;
- detail komoditas;
- jumlah pesanan;
- alamat pengiriman;
- status pembayaran;
- status rantai pasok.

Aksi:

- terima pesanan;
- update status;
- isi data kurir;
- lihat histori.

### 14.7 Update Supply Status

Status yang dapat dipilih:

- `PANEN`;
- `SORTIR_QC`;
- `DIKIRIM`.

Jika status `DIKIRIM`, field tambahan:

- nama kurir;
- nomor resi;
- estimasi tiba;
- catatan pengiriman.

### 14.8 Wallet Screen

Konten:

- saldo tersedia;
- saldo tertahan;
- riwayat pencairan;
- CTA withdrawal.

### 14.9 Withdrawal Form

Field:

- nominal;
- bank;
- nomor rekening;
- nama pemilik rekening.

Validasi:

- nominal tidak boleh lebih besar dari saldo tersedia;
- nomor rekening wajib;
- nama pemilik rekening wajib.

---

## 15. Screen Admin

### 15.1 Admin Dashboard

Konten:

- total user;
- petani menunggu verifikasi;
- transaksi aktif;
- sengketa aktif;
- withdrawal pending.

### 15.2 User Management

Fungsi:

- cari user;
- filter role;
- lihat detail;
- verifikasi petani;
- blokir user;
- hapus user jika diperlukan.

### 15.3 Content Management

Fungsi:

- lihat posting komoditas;
- nonaktifkan posting bermasalah;
- validasi konten.

### 15.4 Dispute Management

Konten:

- daftar sengketa;
- status;
- detail pesanan;
- bukti foto;
- deskripsi customer;
- data petani;
- histori status.

Aksi:

- setujui refund;
- tolak retur;
- minta bukti tambahan;
- tutup kasus.

### 15.5 Withdrawal Approval

Konten:

- daftar request withdrawal;
- data petani;
- nominal;
- rekening;
- saldo;
- histori.

Aksi:

- approve;
- reject;
- tandai paid.

---

## 16. Alur Kerja Frontend dan Backend

## 16.1 Alur Login

### Frontend

```text
User membuka Login Screen
User mengisi email dan password
Frontend validasi format email dan password
Frontend mengirim request login ke backend
Frontend menerima token dan data user
Frontend menyimpan token di secure storage
Frontend redirect berdasarkan role
```

### Backend

```text
Backend menerima email dan password
Backend validasi input
Backend cek user di database
Backend verifikasi password
Backend cek status akun
Backend membuat token
Backend mengirim response user + token
```

### API

```http
POST /auth/login
```

Request:

```json
{
  "email": "customer@example.com",
  "password": "password"
}
```

Response:

```json
{
  "token": "jwt-token",
  "user": {
    "id": "USR001",
    "name": "Restoran Segar",
    "role": "CUSTOMER",
    "status": "ACTIVE"
  }
}
```

---

## 16.2 Alur Posting Estimasi Panen

### Frontend

```text
Petani membuka Harvest Screen
Petani memilih Tambah Komoditas
Petani mengisi form
Petani memilih foto produk
Frontend validasi harga, kuota, tanggal panen
Frontend upload data ke backend
Frontend menampilkan status berhasil
Data muncul di daftar posting petani
```

### Backend

```text
Backend validasi token dan role FARMER
Backend validasi field
Backend simpan file foto
Backend simpan data komoditas
Backend mengembalikan data komoditas baru
```

### API

```http
POST /farmer/commodities
```

---

## 16.3 Alur Pencarian Komoditas

### Frontend

```text
Customer membuka Explore
Customer mengetik keyword atau memilih filter
Frontend mengirim query ke backend
Frontend menampilkan loading
Backend mengembalikan list komoditas
Frontend menampilkan result dalam bentuk card
```

### Backend

```text
Backend membaca query
Backend filter berdasarkan nama, kategori, lokasi, tanggal, harga
Backend mengembalikan data paginated
```

### API

```http
GET /commodities?search=tomat&category=sayur&harvest_date=2026-06-10&page=1
```

---

## 16.4 Alur Pre-Order

### Frontend

```text
Customer membuka detail komoditas
Customer klik Buat Pre-Order
Customer mengisi jumlah kg, tanggal kirim, dan alamat
Frontend validasi jumlah tidak melebihi kuota
Frontend mengirim request pre-order
Frontend menerima invoice
Frontend redirect ke Payment Screen
```

### Backend

```text
Backend validasi token role CUSTOMER
Backend cek komoditas tersedia
Backend cek kuota cukup
Backend membuat pre-order
Backend mengunci kuota
Backend membuat invoice
Backend mengembalikan data pembayaran
```

### API

```http
POST /orders
```

---

## 16.5 Alur Pembayaran Escrow

### Frontend

```text
Customer membuka Payment Screen
Customer memilih metode pembayaran
Frontend meminta instruksi pembayaran ke backend
Customer melakukan pembayaran
Frontend menampilkan status menunggu verifikasi
Setelah backend memverifikasi pembayaran, status berubah menjadi PAID_ESCROW
```

### Backend

```text
Backend membuat payment session atau instruksi pembayaran
Backend menerima callback payment gateway atau bukti manual
Backend validasi nominal
Jika sesuai, dana dicatat sebagai escrow
Backend update status order menjadi DIBAYAR / PAID_ESCROW
Backend kirim notifikasi ke petani
```

### API

```http
POST /orders/{orderId}/payments
GET /orders/{orderId}/payments/status
```

---

## 16.6 Alur Update Status Rantai Pasok

### Frontend

```text
Petani membuka detail pesanan
Petani klik Update Status
Frontend menampilkan status berikutnya yang valid
Petani memilih status
Jika status DIKIRIM, petani wajib mengisi kurir/resi
Frontend mengirim update ke backend
Frontend memperbarui timeline
```

### Backend

```text
Backend validasi role FARMER
Backend cek ownership pesanan
Backend validasi transisi status
Backend simpan status baru
Backend catat status history
Backend kirim notifikasi ke customer
```

### API

```http
PATCH /orders/{orderId}/status
```

---

## 16.7 Alur Konfirmasi Penerimaan & QC

### Frontend

```text
Customer membuka pesanan berstatus DIKIRIM
Customer klik Konfirmasi Penerimaan
Customer memilih kondisi sesuai atau tidak sesuai
Jika sesuai, frontend mengirim approval
Jika tidak sesuai, frontend membuka form dispute
```

### Backend

```text
Backend validasi role CUSTOMER
Backend cek order milik customer
Jika sesuai, backend update status menjadi DITERIMA/SELESAI
Backend melepas dana escrow sesuai aturan
Jika tidak sesuai, backend membuka kasus sengketa
```

### API

```http
POST /orders/{orderId}/receipt-confirmation
POST /orders/{orderId}/qc
```

---

## 16.8 Alur Sengketa

### Frontend

```text
Customer memilih Barang Tidak Sesuai
Customer mengisi alasan dan deskripsi
Customer upload foto bukti
Frontend mengirim laporan sengketa
Frontend menampilkan status sengketa aktif
```

### Backend

```text
Backend validasi order
Backend menyimpan data sengketa dan foto bukti
Backend membekukan dana escrow
Backend mengirim notifikasi ke admin
Admin meninjau bukti
Admin membuat keputusan refund atau release
Backend menutup kasus
```

### API

```http
POST /orders/{orderId}/disputes
GET /disputes/{disputeId}
PATCH /admin/disputes/{disputeId}/decision
```

---

## 16.9 Alur Withdrawal

### Frontend

```text
Petani membuka Wallet
Petani melihat saldo tersedia
Petani mengisi form withdrawal
Frontend mengirim request ke backend
Frontend menampilkan status menunggu approval
```

### Backend

```text
Backend validasi saldo tersedia
Backend membuat request withdrawal
Admin meninjau request
Admin approve atau reject
Backend update status withdrawal
```

### API

```http
POST /farmer/withdrawals
GET /farmer/withdrawals
PATCH /admin/withdrawals/{withdrawalId}
```

---

## 17. State Machine Pesanan

### 17.1 Status Utama

```text
DRAFT
WAITING_PAYMENT
PAID_ESCROW
PRE_ORDER_CONFIRMED
PANEN
SORTIR_QC
DIKIRIM
DITERIMA
SELESAI
SENGKETA
REFUNDED
CANCELLED
```

### 17.2 Transisi Status

```text
DRAFT
  -> WAITING_PAYMENT
  -> CANCELLED

WAITING_PAYMENT
  -> PAID_ESCROW
  -> CANCELLED

PAID_ESCROW
  -> PRE_ORDER_CONFIRMED
  -> CANCELLED

PRE_ORDER_CONFIRMED
  -> PANEN

PANEN
  -> SORTIR_QC

SORTIR_QC
  -> DIKIRIM

DIKIRIM
  -> DITERIMA
  -> SENGKETA

DITERIMA
  -> SELESAI
  -> SENGKETA

SENGKETA
  -> REFUNDED
  -> SELESAI

REFUNDED
  -> CLOSED

SELESAI
  -> REVIEWED
```

### 17.3 Aturan Status

| Dari | Ke | Aktor | Syarat |
|---|---|---|---|
| `WAITING_PAYMENT` | `PAID_ESCROW` | Backend | pembayaran valid |
| `PAID_ESCROW` | `PANEN` | Petani | pesanan aktif |
| `PANEN` | `SORTIR_QC` | Petani | hasil panen tersedia |
| `SORTIR_QC` | `DIKIRIM` | Petani | data kurir diisi |
| `DIKIRIM` | `DITERIMA` | Customer | barang diterima |
| `DITERIMA` | `SELESAI` | Customer/Backend | QC sesuai |
| `DITERIMA` | `SENGKETA` | Customer | bukti masalah diupload |
| `SENGKETA` | `REFUNDED` | Admin | komplain valid |
| `SENGKETA` | `SELESAI` | Admin | komplain ditolak |

---

## 18. Model Data Frontend

### 18.1 UserRole

```dart
enum UserRole {
  customer,
  farmer,
  admin,
}
```

### 18.2 UserStatus

```dart
enum UserStatus {
  active,
  pendingVerification,
  blocked,
  deleted,
}
```

### 18.3 OrderStatus

```dart
enum OrderStatus {
  draft,
  waitingPayment,
  paidEscrow,
  preOrderConfirmed,
  panen,
  sortirQc,
  dikirim,
  diterima,
  selesai,
  sengketa,
  refunded,
  cancelled,
}
```

### 18.4 User Model

```dart
class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final UserRole role;
  final UserStatus status;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.status,
  });
}
```

### 18.5 FarmerProfile Model

```dart
class FarmerProfileModel {
  final String id;
  final String userId;
  final String farmName;
  final String address;
  final double? latitude;
  final double? longitude;
  final double landArea;
  final String? photoUrl;
  final String verificationStatus;

  FarmerProfileModel({
    required this.id,
    required this.userId,
    required this.farmName,
    required this.address,
    this.latitude,
    this.longitude,
    required this.landArea,
    this.photoUrl,
    required this.verificationStatus,
  });
}
```

### 18.6 Commodity Model

```dart
class CommodityModel {
  final String id;
  final String farmerId;
  final String name;
  final String category;
  final String description;
  final int pricePerKg;
  final double availableQuotaKg;
  final DateTime estimatedHarvestDate;
  final String? imageUrl;
  final String status;

  CommodityModel({
    required this.id,
    required this.farmerId,
    required this.name,
    required this.category,
    required this.description,
    required this.pricePerKg,
    required this.availableQuotaKg,
    required this.estimatedHarvestDate,
    this.imageUrl,
    required this.status,
  });
}
```

### 18.7 PreOrder Model

```dart
class PreOrderModel {
  final String id;
  final String customerId;
  final String commodityId;
  final double quantityKg;
  final int totalPrice;
  final DateTime deliveryDate;
  final String deliveryAddress;
  final OrderStatus status;
  final DateTime createdAt;

  PreOrderModel({
    required this.id,
    required this.customerId,
    required this.commodityId,
    required this.quantityKg,
    required this.totalPrice,
    required this.deliveryDate,
    required this.deliveryAddress,
    required this.status,
    required this.createdAt,
  });
}
```

### 18.8 Payment Model

```dart
class PaymentModel {
  final String id;
  final String orderId;
  final int amount;
  final String method;
  final String status;
  final DateTime? paidAt;

  PaymentModel({
    required this.id,
    required this.orderId,
    required this.amount,
    required this.method,
    required this.status,
    this.paidAt,
  });
}
```

### 18.9 Dispute Model

```dart
class DisputeModel {
  final String id;
  final String orderId;
  final String reason;
  final String description;
  final List<String> evidenceImageUrls;
  final String status;
  final String? adminDecision;

  DisputeModel({
    required this.id,
    required this.orderId,
    required this.reason,
    required this.description,
    required this.evidenceImageUrls,
    required this.status,
    this.adminDecision,
  });
}
```

### 18.10 Review Model

```dart
class ReviewModel {
  final String id;
  final String orderId;
  final String customerId;
  final String farmerId;
  final int rating;
  final String comment;
  final DateTime createdAt;

  ReviewModel({
    required this.id,
    required this.orderId,
    required this.customerId,
    required this.farmerId,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });
}
```

---

## 19. Repository Contract Frontend

### 19.1 AuthRepository

```dart
abstract class AuthRepository {
  Future<UserModel> login({
    required String email,
    required String password,
  });

  Future<UserModel> registerCustomer({
    required Map<String, dynamic> payload,
  });

  Future<UserModel> registerFarmer({
    required Map<String, dynamic> payload,
  });

  Future<void> logout();

  Future<UserModel?> getCurrentUser();
}
```

### 19.2 CommodityRepository

```dart
abstract class CommodityRepository {
  Future<List<CommodityModel>> getCommodities({
    String? search,
    String? category,
    DateTime? harvestDate,
    String? location,
    int page = 1,
  });

  Future<CommodityModel> getCommodityDetail(String id);

  Future<CommodityModel> createCommodity(Map<String, dynamic> payload);

  Future<CommodityModel> updateCommodity(
    String id,
    Map<String, dynamic> payload,
  );

  Future<void> deleteCommodity(String id);
}
```

### 19.3 OrderRepository

```dart
abstract class OrderRepository {
  Future<PreOrderModel> createPreOrder(Map<String, dynamic> payload);

  Future<List<PreOrderModel>> getMyOrders({
    OrderStatus? status,
    int page = 1,
  });

  Future<PreOrderModel> getOrderDetail(String id);

  Future<void> updateOrderStatus({
    required String orderId,
    required OrderStatus status,
    Map<String, dynamic>? extraData,
  });

  Future<void> confirmReceipt(String orderId);
}
```

### 19.4 PaymentRepository

```dart
abstract class PaymentRepository {
  Future<PaymentModel> createPayment(String orderId);

  Future<PaymentModel> getPaymentStatus(String orderId);
}
```

### 19.5 DisputeRepository

```dart
abstract class DisputeRepository {
  Future<DisputeModel> createDispute({
    required String orderId,
    required String reason,
    required String description,
    required List<String> evidencePaths,
  });

  Future<DisputeModel> getDisputeDetail(String disputeId);

  Future<void> submitAdminDecision({
    required String disputeId,
    required String decision,
    required String notes,
  });
}
```

### 19.6 WithdrawalRepository

```dart
abstract class WithdrawalRepository {
  Future<void> requestWithdrawal(Map<String, dynamic> payload);

  Future<List<dynamic>> getWithdrawalHistory();

  Future<void> approveWithdrawal(String withdrawalId);

  Future<void> rejectWithdrawal(String withdrawalId, String reason);
}
```

---

## 20. Kontrak API Awal

### 20.1 Auth

| Method | Endpoint | Role | Deskripsi |
|---|---|---|---|
| `POST` | `/auth/login` | Public | Login |
| `POST` | `/auth/register/customer` | Public | Register pelanggan |
| `POST` | `/auth/register/farmer` | Public | Register petani |
| `POST` | `/auth/logout` | All | Logout |
| `GET` | `/auth/me` | All | Ambil user aktif |

### 20.2 Customer

| Method | Endpoint | Deskripsi |
|---|---|---|
| `GET` | `/commodities` | List komoditas |
| `GET` | `/commodities/{id}` | Detail komoditas |
| `POST` | `/orders` | Buat pre-order |
| `GET` | `/orders` | List pesanan customer |
| `GET` | `/orders/{id}` | Detail pesanan |
| `POST` | `/orders/{id}/payments` | Buat pembayaran |
| `GET` | `/orders/{id}/payments/status` | Cek status pembayaran |
| `POST` | `/orders/{id}/receipt-confirmation` | Konfirmasi penerimaan |
| `POST` | `/orders/{id}/qc` | Submit QC |
| `POST` | `/orders/{id}/disputes` | Ajukan sengketa |
| `POST` | `/orders/{id}/reviews` | Beri ulasan |

### 20.3 Farmer

| Method | Endpoint | Deskripsi |
|---|---|---|
| `GET` | `/farmer/dashboard` | Ringkasan dashboard |
| `GET` | `/farmer/profile` | Profil petani |
| `PATCH` | `/farmer/profile` | Update profil |
| `POST` | `/farmer/commodities` | Tambah komoditas |
| `GET` | `/farmer/commodities` | List komoditas petani |
| `PATCH` | `/farmer/commodities/{id}` | Edit komoditas |
| `DELETE` | `/farmer/commodities/{id}` | Hapus/nonaktifkan komoditas |
| `GET` | `/farmer/orders` | Pesanan masuk |
| `PATCH` | `/farmer/orders/{id}/status` | Update status |
| `GET` | `/farmer/wallet` | Saldo petani |
| `POST` | `/farmer/withdrawals` | Ajukan pencairan |
| `GET` | `/farmer/withdrawals` | Riwayat pencairan |

### 20.4 Admin

| Method | Endpoint | Deskripsi |
|---|---|---|
| `GET` | `/admin/dashboard` | Ringkasan admin |
| `GET` | `/admin/users` | List user |
| `GET` | `/admin/users/{id}` | Detail user |
| `PATCH` | `/admin/users/{id}/verify` | Verifikasi user |
| `PATCH` | `/admin/users/{id}/block` | Blokir user |
| `GET` | `/admin/disputes` | List sengketa |
| `GET` | `/admin/disputes/{id}` | Detail sengketa |
| `PATCH` | `/admin/disputes/{id}/decision` | Keputusan sengketa |
| `GET` | `/admin/withdrawals` | List withdrawal |
| `PATCH` | `/admin/withdrawals/{id}/approve` | Approve withdrawal |
| `PATCH` | `/admin/withdrawals/{id}/reject` | Reject withdrawal |
| `GET` | `/admin/commodities` | Moderasi komoditas |
| `PATCH` | `/admin/commodities/{id}/disable` | Nonaktifkan konten |

---

## 21. Rancangan Database Logis

Rancangan ini bersifat logis dan perlu disesuaikan dengan ERD final tim.

### 21.1 Tabel `users`

```text
id
name
email
phone
password_hash
role
status
last_login_at
created_at
updated_at
```

### 21.2 Tabel `farmer_profiles`

```text
id
user_id
farm_name
land_area
address
latitude
longitude
photo_url
verification_status
created_at
updated_at
```

### 21.3 Tabel `customer_profiles`

```text
id
user_id
business_name
business_type
business_address
pic_name
created_at
updated_at
```

### 21.4 Tabel `commodities`

```text
id
farmer_id
name
category
description
price_per_kg
available_quota_kg
estimated_harvest_date
image_url
status
created_at
updated_at
```

### 21.5 Tabel `pre_orders`

```text
id
customer_id
farmer_id
commodity_id
quantity_kg
price_per_kg
total_price
delivery_date
delivery_address
status
notes
created_at
updated_at
```

### 21.6 Tabel `payments`

```text
id
order_id
amount
method
status
escrow_status
payment_reference
paid_at
released_at
refunded_at
created_at
updated_at
```

### 21.7 Tabel `order_status_histories`

```text
id
order_id
status
notes
updated_by
courier_name
tracking_number
created_at
```

### 21.8 Tabel `quality_controls`

```text
id
order_id
condition_status
quantity_status
quality_notes
photo_url
submitted_by
created_at
```

### 21.9 Tabel `disputes`

```text
id
order_id
customer_id
farmer_id
reason
description
status
admin_decision
admin_notes
created_at
updated_at
closed_at
```

### 21.10 Tabel `dispute_evidences`

```text
id
dispute_id
file_url
file_type
created_at
```

### 21.11 Tabel `withdrawals`

```text
id
farmer_id
amount
bank_name
account_number
account_holder_name
status
admin_notes
requested_at
processed_at
```

### 21.12 Tabel `reviews`

```text
id
order_id
customer_id
farmer_id
rating
comment
created_at
updated_at
```

---

## 22. Ringkasan UML dan Diagram

### 22.1 Use Case

Use case utama sistem:

1. Registrasi & Login
2. Kelola Profil & Lahan
3. Posting Estimasi Panen
4. Mencari & Filter Komoditas
5. Membuat Pre-Order
6. Pembayaran Aman / Escrow
7. Update Status Rantai Pasok
8. Konfirmasi Penerimaan & QC
9. Pengajuan Retur/Sengketa
10. Penyelesaian Sengketa
11. Pencairan Dana / Withdrawal
12. Memberikan Ulasan & Rating
13. Manajemen Pengguna & Konten

### 22.2 Activity Diagram Pembayaran Escrow

Ringkasan alur:

```text
Customer memilih metode pembayaran
Customer transfer ke virtual account / metode pembayaran
Backend mengecek mutasi atau callback pembayaran
Jika nominal sesuai:
  dana disimpan di escrow
  status menjadi dibayar
  notifikasi dikirim ke petani
Jika tidak sesuai:
  pembayaran gagal
  customer diminta mengulang pembayaran
```

### 22.3 Activity Diagram Update Status Rantai Pasok

Ringkasan alur:

```text
Petani membuka daftar pesanan aktif
Petani memilih update status
Jika status DIKIRIM:
  petani wajib mengisi data kurir
Backend menyimpan status ke database
Backend mencatat waktu update
Backend mengirim notifikasi ke customer
```

### 22.4 Activity Diagram Konfirmasi Penerimaan & QC

Ringkasan alur:

```text
Customer menerima barang
Customer membuka detail pesanan
Customer menekan konfirmasi penerimaan
Jika kondisi sesuai:
  customer menyetujui
  escrow dicairkan ke petani
  status menjadi selesai
  form ulasan muncul
Jika tidak sesuai:
  customer diarahkan ke pengajuan retur/sengketa
```

### 22.5 Activity Diagram Sengketa

Ringkasan alur:

```text
Customer memilih barang tidak sesuai
Customer mengisi form dan upload foto bukti
Backend membekukan dana escrow
Admin menerima notifikasi
Admin meninjau bukti
Jika komplain valid:
  admin menyetujui retur/refund
Jika komplain tidak valid:
  admin menolak retur
Backend mengirim keputusan ke customer dan petani
Kasus sengketa ditutup
```

### 22.6 DFD Level 0

Entitas eksternal:

- Petani / Mitra Supplier
- Pelanggan B2B
- Admin PanenHub

Proses utama:

- Sistem PanenHub Rantai Pasok B2B Pertanian

Aliran data utama:

- petani mengirim data komoditas dan estimasi panen;
- sistem mengirim update status rantai pasok ke petani;
- sistem mengirim notifikasi pesanan dan info pencairan ke petani;
- pelanggan mengirim pre-order dan data pembayaran;
- sistem mengirim status pesanan dan invoice ke pelanggan;
- admin menerima laporan transaksi dan daftar akun pending;
- admin mengirim validasi akun dan keputusan sengketa.

### 22.7 DFD Level 1

Proses utama:

1. Registrasi & Autentikasi
2. Kelola Komoditas & Estimasi Panen
3. Pencarian & Pre-Order
4. Pembayaran Escrow
5. Update Status Rantai Pasok & QC
6. Sengketa, Pencairan & Ulasan

Data store utama:

- data pengguna;
- data komoditas;
- data pre-order;
- data pembayaran/escrow;
- data QC dan status;
- data sengketa dan ulasan.

---

## 23. Strategi Mock Data untuk Demo Frontend

Jika backend belum siap, frontend tetap dapat dikembangkan menggunakan mock repository.

### 23.1 Mode Mock

```text
APP_ENV=mock
```

Perilaku:

- login menerima akun dummy;
- data komoditas dari JSON lokal;
- pre-order tersimpan di memory/local cache;
- status order dapat disimulasikan;
- dispute dan review masuk ke dummy list.

### 23.2 Akun Dummy

```text
Customer:
email    : customer@panenhub.test
password : password

Farmer:
email    : farmer@panenhub.test
password : password

Admin:
email    : admin@panenhub.test
password : password
```

### 23.3 Contoh Komoditas Dummy

```json
[
  {
    "id": "CMD001",
    "name": "Cabai Merah Keriting",
    "category": "Bumbu",
    "pricePerKg": 32000,
    "availableQuotaKg": 120,
    "estimatedHarvestDate": "2026-06-12",
    "farmerName": "Pak Budi",
    "location": "Bandungan, Semarang"
  },
  {
    "id": "CMD002",
    "name": "Tomat Segar",
    "category": "Sayur",
    "pricePerKg": 14000,
    "availableQuotaKg": 250,
    "estimatedHarvestDate": "2026-06-20",
    "farmerName": "Bu Sari",
    "location": "Ungaran, Semarang"
  }
]
```

---

## 24. Error Handling

### 24.1 Error Network

Tampilan:

```text
Koneksi bermasalah. Periksa internet Anda dan coba lagi.
```

Aksi:

- tombol coba lagi;
- jangan langsung logout user;
- simpan state terakhir jika memungkinkan.

### 24.2 Error Validasi

Contoh:

```text
Jumlah pesanan tidak boleh melebihi kuota tersedia.
```

### 24.3 Error Unauthorized

Tindakan:

- hapus token;
- redirect ke login;
- tampilkan pesan session berakhir.

### 24.4 Error Forbidden

Contoh:

```text
Anda tidak memiliki akses untuk melakukan aksi ini.
```

### 24.5 Error Payment

Contoh:

```text
Pembayaran belum berhasil diverifikasi. Silakan cek kembali nominal pembayaran.
```

---

## 25. Validasi Form

### 25.1 Validasi Umum

| Field | Aturan |
|---|---|
| Email | wajib, format email |
| Password | wajib, minimal 8 karakter |
| Nomor telepon | wajib, angka |
| Nama | wajib |
| Foto | tipe jpg/png, ukuran maksimum TBD |
| Harga | wajib, lebih dari 0 |
| Kuota | wajib, lebih dari 0 |
| Tanggal panen | tidak boleh tanggal lampau |
| Rating | 1 sampai 5 |

### 25.2 Validasi Pre-Order

| Field | Aturan |
|---|---|
| jumlah kg | tidak boleh kosong |
| jumlah kg | tidak boleh lebih dari kuota |
| tanggal pengiriman | tidak boleh sebelum estimasi panen |
| alamat | wajib |

### 25.3 Validasi Sengketa

| Field | Aturan |
|---|---|
| alasan | wajib |
| deskripsi | minimal 20 karakter |
| foto bukti | minimal 1 foto |
| jumlah bermasalah | tidak boleh melebihi jumlah pesanan |

---

## 26. Security Frontend

Frontend harus mengikuti aturan berikut:

1. token disimpan di `flutter_secure_storage`;
2. jangan menyimpan password di local storage;
3. jangan menaruh secret API di source code;
4. jangan menentukan keputusan escrow dari frontend;
5. validasi role di frontend hanya untuk UX, bukan keamanan utama;
6. semua endpoint penting tetap harus divalidasi backend;
7. upload file harus dibatasi;
8. tampilkan data sesuai role saja;
9. lakukan logout bersih dengan menghapus token dan cache user.

---

## 27. Testing Plan

### 27.1 Unit Test

Target:

- validator email;
- validator password;
- validator kuota;
- formatter harga;
- mapper DTO ke model;
- logic transisi status.

### 27.2 Widget Test

Target:

- login form;
- commodity card;
- order status chip;
- pre-order form;
- dispute form;
- review form.

### 27.3 Integration Test

Target flow:

1. login customer;
2. cari komoditas;
3. buat pre-order;
4. simulasi pembayaran;
5. lihat status pesanan;
6. konfirmasi penerimaan;
7. beri ulasan.

Target farmer flow:

1. login petani;
2. tambah komoditas;
3. lihat pesanan masuk;
4. update status;
5. ajukan withdrawal.

Target admin flow:

1. login admin;
2. verifikasi petani;
3. tinjau sengketa;
4. approve withdrawal.

---

## 28. Roadmap Implementasi

### 28.1 Sprint 1 — Setup Project dan Auth

Target:

- setup Flutter project;
- setup theme;
- setup routing;
- splash screen;
- onboarding;
- login;
- register;
- role-based redirect;
- mock repository auth.

### 28.2 Sprint 2 — Customer Core Flow

Target:

- customer home;
- explore commodity;
- commodity detail;
- filter;
- pre-order form;
- order list;
- order detail.

### 28.3 Sprint 3 — Farmer Core Flow

Target:

- farmer dashboard;
- land profile;
- harvest list;
- create harvest post;
- incoming orders;
- update status;
- wallet screen.

### 28.4 Sprint 4 — Payment, QC, Dispute

Target:

- payment screen;
- escrow status;
- tracking timeline;
- confirm receipt;
- QC form;
- dispute form;
- admin dispute list;
- admin decision screen.

### 28.5 Sprint 5 — Admin dan Polishing

Target:

- admin dashboard;
- user management;
- withdrawal approval;
- content moderation;
- rating & review;
- empty/loading/error states;
- UI polish;
- testing;
- build APK.

---

## 29. Definition of Done

Sebuah fitur dianggap selesai jika:

- UI sesuai desain aplikasi Android;
- validasi form berjalan;
- loading state tersedia;
- empty state tersedia jika data kosong;
- error state tersedia jika request gagal;
- logic dipisahkan dari widget;
- repository interface digunakan;
- data model jelas;
- role access sesuai;
- tidak ada crash saat input invalid;
- sudah diuji minimal manual test;
- sudah siap diganti dari mock API ke real API.

---

## 30. Checklist Demo Aplikasi

### Customer

- [ ] Login sebagai customer
- [ ] Melihat home
- [ ] Mencari komoditas
- [ ] Filter komoditas
- [ ] Melihat detail komoditas
- [ ] Membuat pre-order
- [ ] Melihat invoice
- [ ] Melihat status pembayaran escrow
- [ ] Melihat tracking pesanan
- [ ] Konfirmasi penerimaan
- [ ] Mengajukan sengketa
- [ ] Memberi rating

### Farmer

- [ ] Login sebagai petani
- [ ] Melihat dashboard
- [ ] Mengelola profil lahan
- [ ] Posting estimasi panen
- [ ] Melihat pesanan masuk
- [ ] Update status panen
- [ ] Update status sortir/QC
- [ ] Update status dikirim
- [ ] Mengisi data kurir
- [ ] Melihat wallet
- [ ] Mengajukan withdrawal

### Admin

- [ ] Login sebagai admin
- [ ] Melihat dashboard admin
- [ ] Verifikasi petani
- [ ] Kelola user
- [ ] Kelola konten komoditas
- [ ] Tinjau sengketa
- [ ] Putuskan refund/release
- [ ] Approve withdrawal

---

## 31. Keputusan yang Perlu Dikonfirmasi Tim

Bagian ini sengaja tidak diputuskan sepihak karena belum ada kepastian pada laporan awal.

| Topik | Status | Pertanyaan |
|---|---|---|
| Backend framework | TBD | Apakah memakai Laravel, Express/NestJS, Firebase, Supabase, atau lainnya? |
| Database | TBD | Apakah memakai MySQL, PostgreSQL, Firebase Firestore, atau lainnya? |
| Payment gateway | TBD | Apakah escrow disimulasikan atau memakai payment gateway nyata? |
| Upload foto | TBD | Apakah file disimpan lokal, cloud storage, atau server backend? |
| Peta/lokasi | TBD | Apakah menggunakan Google Maps, OpenStreetMap, atau input alamat manual? |
| Push notification | TBD | Apakah menggunakan Firebase Cloud Messaging? |
| Admin platform | TBD | Apakah admin tetap Android app atau dibuat dashboard web terpisah? |
| Low-fidelity | Belum tersedia | Apakah sudah ada wireframe? |
| High-fidelity | Belum tersedia | Apakah sudah ada desain final Figma? |
| Logo final | Belum tersedia | Apakah logo sudah final? |

---

## 32. Rekomendasi Prioritas Implementasi

Untuk proyek akhir mata kuliah, prioritas terbaik adalah menyelesaikan alur utama terlebih dahulu.

### Prioritas 1 — Wajib Ada

- login/register role-based;
- dashboard customer;
- list komoditas;
- detail komoditas;
- create pre-order;
- dashboard petani;
- create posting panen;
- update status rantai pasok;
- order tracking;
- admin basic dashboard.

### Prioritas 2 — Sangat Disarankan

- payment escrow simulation;
- QC confirmation;
- dispute form;
- admin dispute decision;
- withdrawal request;
- review/rating.

### Prioritas 3 — Opsional

- push notification;
- map integration;
- payment gateway nyata;
- chat customer-petani;
- analytics dashboard;
- multi-language;
- dark mode.

---

## 33. Risiko dan Mitigasi

| Risiko | Dampak | Mitigasi |
|---|---|---|
| Backend belum siap | Frontend terhambat | Gunakan mock repository |
| Payment gateway belum ada | Escrow tidak bisa real | Simulasi status pembayaran |
| Upload foto kompleks | Sengketa dan produk terhambat | Gunakan dummy image atau local picker |
| Admin terlalu besar | Scope membengkak | Buat admin minimal untuk verifikasi, sengketa, withdrawal |
| UI tidak konsisten | Aplikasi terlihat tidak profesional | Gunakan design token dan reusable component |
| State pesanan rumit | Bug transaksi | Gunakan enum dan validasi transisi status |
| Waktu terbatas | Fitur tidak selesai | Prioritaskan flow customer-petani-admin utama |

---

## 34. Batasan Implementasi Saat Ini

Dokumen ini tidak menetapkan:

- backend framework final;
- database final;
- payment gateway final;
- desain Figma final;
- provider maps final;
- provider push notification final;
- implementasi escrow real dengan bank.

Dokumen ini menetapkan:

- arah produk;
- role dan fitur;
- alur utama aplikasi;
- arsitektur Android Flutter;
- rancangan UI profesional;
- kontrak API awal;
- model data frontend;
- struktur folder;
- roadmap implementasi.

---

## 35. Penutup

PanenHub dirancang sebagai aplikasi Android profesional berbasis Flutter untuk membantu rantai pasok pertanian B2B. Nilai utama aplikasi terletak pada pre-order berbasis masa panen, transparansi status rantai pasok, pembayaran aman berbasis escrow, Quality Control, sengketa, pencairan dana, dan reputasi petani melalui rating.

Dokumen ini dapat digunakan sebagai blueprint utama tim frontend dan backend untuk menyelaraskan pemahaman proyek, membagi tugas, membuat mock data, menyusun API, serta mengembangkan aplikasi Android Flutter secara bertahap.
