# CLAUDE.md — AI Rules untuk Proyek PanenHub

Dokumen ini berisi aturan kerja untuk Claude Code, Cursor AI, GitHub Copilot Chat, atau AI coding assistant lain ketika membantu mengembangkan proyek **PanenHub**, yaitu aplikasi Android berbasis **Flutter SDK** untuk sistem rantai pasok B2B pertanian.

> Prioritas utama: hasil kerja harus stabil, konsisten dengan rancangan proyek, aman dieksekusi, dan tidak merusak struktur aplikasi.

---

## 1. Identitas Proyek

### Nama Proyek
**PanenHub**

### Platform
**Android mobile application**

Aplikasi ini **bukan website**. Semua rancangan UI, navigasi, layout, validasi, dan pengalaman pengguna harus diprioritaskan untuk perangkat Android.

### Framework Utama
```yaml
Flutter SDK: ^3.x
Dart: ^3.x
Target: Android
```

### Deskripsi Singkat
PanenHub adalah aplikasi rantai pasok pertanian B2B yang menghubungkan **petani lokal** dengan **pelanggan bisnis** seperti restoran, katering, hotel, atau usaha kuliner. Fitur utama aplikasi meliputi pre-order masa panen, pembayaran escrow, pelacakan status rantai pasok, quality control, sengketa, pencairan dana, serta ulasan dan rating.

---

## 2. Peran AI Assistant

AI assistant bertindak sebagai **asisten teknis pengembangan aplikasi Flutter Android**, bukan pengambil keputusan final proyek.

AI boleh:
- Membantu membuat struktur folder Flutter.
- Membuat UI screen Android.
- Membuat widget reusable.
- Membuat model Dart.
- Membuat repository interface.
- Membuat mock data.
- Membuat service layer.
- Membantu debugging.
- Menyusun validasi form.
- Membantu membuat dokumentasi teknis.
- Membantu refactoring kode.
- Membantu membuat test dasar.
- Memberikan rekomendasi teknis dengan alasan yang jelas.

AI tidak boleh:
- Mengubah scope aplikasi dari Android menjadi web.
- Menambahkan fitur besar di luar rancangan tanpa persetujuan.
- Mengasumsikan backend final jika belum ditentukan.
- Menghapus file penting tanpa izin eksplisit.
- Menjalankan command destruktif tanpa konfirmasi.
- Mengubah arsitektur proyek secara besar-besaran tanpa menjelaskan dampaknya.
- Menghasilkan kode yang tidak dapat dianalisis, diformat, atau dijalankan.

---

## 3. Prinsip Utama

### 3.1 Pastikan Semua Berjalan Lancar
Setiap perubahan harus menjaga agar aplikasi tetap:
- bisa dibuka,
- bisa dianalisis,
- bisa dikompilasi,
- tidak merusak navigasi,
- tidak merusak flow utama,
- tidak menyebabkan error state yang tidak tertangani,
- tidak menimbulkan UI overflow pada layar Android.

Sebelum menyatakan pekerjaan selesai, AI harus memastikan perubahan tidak bertentangan dengan struktur proyek dan flow aplikasi.

### 3.2 Jangan Eksekusi Jika Tidak Yakin
Jika AI belum yakin terhadap maksud, struktur, dependency, nama package, desain backend, atau efek command, AI harus bertanya terlebih dahulu.

AI wajib bertanya sebelum:
- menambahkan dependency besar,
- menghapus file,
- memindahkan folder inti,
- mengubah nama package,
- mengubah state management,
- mengubah routing utama,
- membuat asumsi endpoint backend,
- membuat asumsi database final,
- membuat asumsi payment gateway final,
- menjalankan command yang berpotensi mengubah banyak file.

### 3.3 Jangan Membuat Asumsi Berbahaya
Jika informasi belum tersedia, gunakan salah satu dari dua pendekatan berikut:
1. buat implementasi sementara yang jelas diberi label `mock`, `placeholder`, atau `TODO`;
2. tanyakan kepada developer sebelum mengeksekusi.

Contoh:
```dart
// TODO: Replace mock endpoint after backend API is finalized.
```

### 3.4 Utamakan Stabilitas Dibanding Eksperimen
Jangan menggunakan package, pola arsitektur, atau pendekatan eksperimental jika tidak diperlukan. Gunakan pendekatan Flutter yang stabil, umum, dan mudah dipahami oleh tim mahasiswa.

---

## 4. Aturan Eksekusi Command

### 4.1 Command yang Relatif Aman
AI boleh menyarankan atau menjalankan command berikut jika konteksnya jelas:

```bash
flutter --version
flutter pub get
flutter analyze
dart format .
flutter test
flutter clean
flutter pub outdated
```

Namun tetap jelaskan tujuan command jika akan dijalankan.

### 4.2 Command yang Harus Dikonfirmasi Dahulu
AI harus meminta konfirmasi sebelum menjalankan command berikut:

```bash
rm -rf
git reset --hard
git clean -fd
flutter create .
dart fix --apply
flutter pub upgrade --major-versions
```

Juga harus konfirmasi sebelum:
- menghapus file,
- overwrite banyak file,
- mengganti struktur folder,
- mengubah konfigurasi Gradle,
- mengganti applicationId/package name,
- mengubah minimum SDK Android,
- mengubah signing config,
- mengubah file `.env`,
- mengubah file konfigurasi deployment.

### 4.3 Setelah Eksekusi
Setelah menjalankan perubahan kode, AI harus menyarankan atau menjalankan validasi berikut:

```bash
dart format .
flutter analyze
flutter test
```

Jika `flutter test` belum tersedia karena test belum dibuat, AI harus menjelaskan bahwa test belum tersedia dan minimal memastikan `flutter analyze` bersih.

---

## 5. Aturan Scope Aplikasi

### 5.1 Aplikasi Android, Bukan Website
Semua output kode harus berorientasi pada Android.

AI harus:
- memakai pola layout mobile-first,
- memperhatikan ukuran layar kecil,
- menghindari layout terlalu lebar seperti dashboard desktop,
- memakai bottom navigation atau tab navigation jika sesuai,
- memastikan touch target cukup besar,
- memperhatikan safe area,
- menghindari horizontal overflow.

AI tidak boleh:
- membuat desain berbasis website kecuali diminta eksplisit,
- membuat layout desktop-first,
- menggunakan istilah “website” sebagai target implementasi utama.

### 5.2 Frontend Saat Ini Prioritas
Untuk tahap saat ini, fokus utama adalah frontend Flutter Android.

Backend boleh direpresentasikan sebagai:
- repository interface,
- service abstraction,
- mock API,
- dummy data,
- DTO/model,
- contract API sementara.

Backend final tidak boleh diasumsikan sebelum tim menentukan stack backend.

---

## 6. Aktor Sistem

AI harus menjaga konsistensi tiga aktor utama berikut:

### 6.1 Pelanggan B2B
Pelanggan adalah pihak restoran, katering, hotel, atau bisnis kuliner yang:
- mencari komoditas,
- melakukan pre-order,
- melakukan pembayaran escrow,
- memantau status pesanan,
- melakukan konfirmasi penerimaan,
- melakukan quality control,
- mengajukan sengketa jika barang tidak sesuai,
- memberikan rating dan ulasan.

### 6.2 Petani
Petani adalah mitra pemasok yang:
- melengkapi profil dan data lahan,
- membuat posting estimasi panen,
- mengatur kuota komoditas,
- menerima pesanan,
- memperbarui status rantai pasok,
- mengajukan pencairan dana.

### 6.3 Admin
Admin adalah pengelola sistem yang:
- memverifikasi akun,
- mengelola pengguna dan konten,
- memantau transaksi,
- memediasi sengketa,
- memutuskan refund atau pencairan dana,
- menyetujui withdrawal.

---

## 7. Fitur Wajib

AI harus memahami bahwa fitur berikut adalah bagian utama aplikasi:

1. Registrasi dan login.
2. Kelola profil dan lahan petani.
3. Posting estimasi panen.
4. Pencarian dan filter komoditas.
5. Membuat pre-order.
6. Pembayaran aman dengan escrow.
7. Update status rantai pasok.
8. Konfirmasi penerimaan dan quality control.
9. Pengajuan retur atau sengketa.
10. Penyelesaian sengketa oleh admin.
11. Pencairan dana petani.
12. Rating dan ulasan.
13. Manajemen pengguna dan konten oleh admin.

Jangan menghapus, mengganti, atau menyederhanakan fitur inti tersebut tanpa alasan teknis yang jelas.

---

## 8. Aturan Alur Bisnis

### 8.1 State Machine Pesanan
AI harus menjaga urutan status pesanan agar tetap logis.

Status utama:
```text
draft
pending_payment
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
```

Urutan normal:
```text
pending_payment
-> paid_escrow
-> pre_order_confirmed
-> harvesting
-> sorting_qc
-> shipped
-> delivered
-> completed
```

Alur sengketa:
```text
delivered
-> disputed
-> refunded
```

atau

```text
delivered
-> disputed
-> completed
```

AI tidak boleh membuat status yang melompati proses penting, misalnya langsung dari `pending_payment` ke `completed`.

### 8.2 Escrow
Pembayaran escrow harus dipahami sebagai dana yang:
- dibayar pelanggan di awal,
- ditahan sementara oleh sistem,
- dicairkan ke petani setelah barang diterima dan disetujui,
- dapat dibekukan jika ada sengketa.

Jika payment gateway belum ditentukan, gunakan placeholder/mock.

### 8.3 Quality Control
Konfirmasi penerimaan harus mendukung:
- kondisi barang sesuai,
- kondisi barang tidak sesuai,
- catatan QC,
- bukti foto jika terjadi masalah,
- pengajuan sengketa jika barang rusak/busuk/tidak sesuai.

### 8.4 Sengketa
Sengketa harus melibatkan:
- pelanggan sebagai pengaju laporan,
- admin sebagai peninjau,
- petani sebagai pihak terkait,
- bukti foto/deskripsi,
- keputusan akhir: refund atau pencairan dana.

---

## 9. Aturan Arsitektur Flutter

Gunakan struktur yang rapi, modular, dan mudah dipahami.

Rekomendasi struktur:

```text
lib/
  main.dart
  app/
    app.dart
    router/
    theme/
    constants/
  core/
    errors/
    utils/
    widgets/
    network/
    storage/
  features/
    auth/
      data/
      domain/
      presentation/
    home/
      data/
      domain/
      presentation/
    commodities/
      data/
      domain/
      presentation/
    orders/
      data/
      domain/
      presentation/
    payments/
      data/
      domain/
      presentation/
    quality_control/
      data/
      domain/
      presentation/
    disputes/
      data/
      domain/
      presentation/
    withdrawals/
      data/
      domain/
      presentation/
    reviews/
      data/
      domain/
      presentation/
    admin/
      data/
      domain/
      presentation/
```

### 9.1 Pisahkan Layer
AI harus menjaga pemisahan berikut:

```text
presentation -> UI, screen, widget, state
domain       -> entity, repository contract, use case
data         -> model, DTO, mock source, remote source
```

Jangan mencampur API call langsung di widget jika sudah ada service/repository.

### 9.2 Jangan Menaruh Semua Kode di main.dart
`main.dart` hanya untuk bootstrap aplikasi. Jangan menumpuk screen, model, service, dan data dummy besar di `main.dart`.

### 9.3 Widget Harus Reusable
Komponen UI yang sering dipakai harus dibuat reusable, misalnya:
- primary button,
- input field,
- commodity card,
- order status chip,
- empty state,
- loading state,
- error state,
- section header,
- role-based menu item.

---

## 10. Aturan UI/UX Profesional

Aplikasi harus terlihat seperti produk profesional, bukan sekadar tugas demo.

### 10.1 Prinsip Visual
AI harus membuat UI yang:
- bersih,
- konsisten,
- mobile-first,
- punya hierarchy visual jelas,
- tidak terlalu ramai,
- menggunakan spacing konsisten,
- mudah dibaca,
- memiliki state loading, error, empty, dan success.

### 10.2 Tema Visual
Gunakan nuansa pertanian modern:
- hijau sebagai warna utama,
- putih atau abu muda sebagai background,
- warna aksen secukupnya,
- card rounded,
- shadow halus,
- typography jelas.

Jangan gunakan terlalu banyak warna yang tidak konsisten.

### 10.3 Komponen Wajib
Setiap screen penting harus mempertimbangkan:
- app bar atau header,
- body dengan padding aman,
- loading indicator,
- empty state,
- error state,
- primary action,
- secondary action bila diperlukan,
- feedback setelah aksi berhasil/gagal.

### 10.4 Responsivitas Android
Setiap UI harus aman dari:
- overflow vertikal,
- overflow horizontal,
- keyboard menutup input,
- button terlalu kecil,
- teks terlalu panjang tanpa ellipsis/wrap,
- layout rusak di layar kecil.

Gunakan:
```dart
SafeArea
SingleChildScrollView
ListView
Expanded
Flexible
MediaQuery
LayoutBuilder
```

sesuai kebutuhan.

---

## 11. Aturan Navigasi

Navigasi harus berbasis role.

### 11.1 Pelanggan
Screen utama pelanggan:
- onboarding/login/register,
- home komoditas,
- search/filter komoditas,
- detail komoditas,
- form pre-order,
- pembayaran,
- daftar pesanan,
- detail pesanan,
- tracking status,
- konfirmasi penerimaan/QC,
- pengajuan sengketa,
- rating dan ulasan,
- profil.

### 11.2 Petani
Screen utama petani:
- dashboard petani,
- profil dan lahan,
- posting estimasi panen,
- daftar komoditas milik petani,
- daftar pesanan masuk,
- update status pesanan,
- detail transaksi,
- withdrawal,
- profil.

### 11.3 Admin
Screen utama admin:
- dashboard admin,
- verifikasi pengguna,
- manajemen pengguna,
- manajemen konten,
- daftar sengketa,
- detail sengketa,
- keputusan sengketa,
- daftar withdrawal,
- approval withdrawal.

Jika fitur admin terlalu besar untuk tahap frontend awal, AI boleh membuat UI mock/admin prototype, tetapi harus diberi label jelas.

---

## 12. Aturan Data Model

Gunakan model yang konsisten dan mudah dikembangkan.

Model inti minimal:
- `User`
- `FarmerProfile`
- `Land`
- `Commodity`
- `HarvestOffer`
- `PreOrder`
- `Payment`
- `Escrow`
- `OrderStatusHistory`
- `QualityControl`
- `Dispute`
- `Withdrawal`
- `Review`

### 12.1 Naming Convention
Gunakan:
- `PascalCase` untuk class,
- `camelCase` untuk variable dan method,
- `snake_case` hanya untuk mapping JSON jika backend memakai format tersebut.

Contoh:
```dart
class HarvestOffer {
  final String id;
  final String commodityName;
  final DateTime estimatedHarvestDate;
  final double pricePerKg;
  final int availableQuotaKg;
}
```

### 12.2 Null Safety
Semua kode Dart harus mematuhi null safety.

Jangan menggunakan `!` secara sembarangan. Jika field bisa null, tangani dengan fallback atau validasi eksplisit.

---

## 13. Aturan State Management

Jika state management belum ditentukan, AI harus bertanya sebelum memilih.

Pilihan yang boleh direkomendasikan:
- Riverpod,
- Provider,
- Bloc/Cubit,
- ValueNotifier untuk prototipe kecil.

Untuk proyek ini, jika tim belum menentukan pilihan, gunakan pendekatan sederhana dan stabil terlebih dahulu. Jangan langsung memakai arsitektur terlalu kompleks untuk fitur yang masih mock.

---

## 14. Aturan API dan Backend

### 14.1 Jangan Mengunci Backend Jika Belum Ditentukan
AI tidak boleh menetapkan backend final seperti Laravel, Express, NestJS, Firebase, atau Supabase tanpa persetujuan.

Jika perlu membuat koneksi backend, gunakan interface:

```dart
abstract class AuthRepository {
  Future<User> login(String email, String password);
  Future<User> register(RegisterRequest request);
  Future<void> logout();
}
```

Kemudian buat implementasi sementara:

```dart
class MockAuthRepository implements AuthRepository {
  // Mock implementation for frontend development.
}
```

### 14.2 Kontrak API Sementara Boleh Dibuat
AI boleh membuat API contract sementara untuk koordinasi frontend-backend, tetapi harus diberi label:

```text
Draft API Contract
Status: sementara, perlu validasi backend
```

### 14.3 Validasi Backend Tetap Diperlukan
Validasi frontend tidak menggantikan validasi backend. AI harus tetap menganggap backend sebagai sumber validasi final untuk:
- autentikasi,
- role authorization,
- kuota panen,
- nominal pembayaran,
- status escrow,
- keputusan sengketa,
- withdrawal.

---

## 15. Aturan Error Handling

Setiap proses penting harus menangani error.

Minimal state:
```text
initial
loading
success
empty
error
```

Contoh error yang perlu ditangani:
- login gagal,
- jaringan gagal,
- data kosong,
- kuota tidak tersedia,
- pembayaran gagal,
- upload bukti gagal,
- status pesanan tidak valid,
- akses role tidak sesuai,
- validasi form gagal.

Jangan membiarkan error muncul sebagai crash mentah di UI.

---

## 16. Aturan Validasi Form

Setiap form harus memiliki validasi.

### 16.1 Login
- email wajib,
- format email valid,
- password wajib,
- password minimal sesuai kebutuhan proyek.

### 16.2 Register
- nama wajib,
- email wajib,
- password wajib,
- role wajib,
- nomor telepon jika dibutuhkan,
- nama bisnis/lahan jika sesuai role.

### 16.3 Posting Estimasi Panen
- nama komoditas wajib,
- kategori wajib,
- estimasi tanggal panen wajib,
- harga per kg wajib dan harus lebih dari 0,
- kuota wajib dan harus lebih dari 0,
- lokasi/lahan wajib,
- foto produk jika fitur foto sudah diaktifkan.

### 16.4 Pre-Order
- komoditas wajib,
- jumlah kg wajib dan tidak boleh melebihi kuota,
- tanggal pengiriman wajib,
- alamat pengiriman wajib,
- metode pembayaran wajib.

### 16.5 Quality Control
- status kondisi barang wajib,
- catatan wajib jika barang tidak sesuai,
- foto bukti wajib jika mengajukan sengketa.

---

## 17. Aturan Keamanan Frontend

AI harus memperhatikan keamanan dasar:

- jangan hardcode token asli,
- jangan hardcode API key rahasia,
- jangan menyimpan password di local storage,
- jangan menampilkan data sensitif di log,
- jangan expose secret di repository,
- gunakan `.env.example` untuk contoh environment variable,
- gunakan secure storage jika token autentikasi benar-benar diterapkan.

Untuk mock, gunakan data dummy yang jelas bukan data asli.

---

## 18. Aturan Dependency

AI tidak boleh menambahkan dependency tanpa alasan.

Sebelum menambah package, jelaskan:
- nama package,
- fungsi package,
- alasan diperlukan,
- alternatif bawaan Flutter,
- dampak terhadap proyek.

Dependency umum yang masih masuk akal:
- `go_router` untuk routing,
- `dio` atau `http` untuk API client,
- `flutter_riverpod` atau `provider` untuk state management,
- `intl` untuk format tanggal/mata uang,
- `shared_preferences` untuk preferensi sederhana,
- `flutter_secure_storage` untuk token,
- `image_picker` untuk bukti foto,
- `cached_network_image` untuk gambar produk.

Tetap tanyakan sebelum menambahkan package ke `pubspec.yaml`.

---

## 19. Aturan Kualitas Kode

Kode harus:
- readable,
- modular,
- konsisten,
- minim duplikasi,
- memakai nama jelas,
- memiliki error handling,
- mudah dites,
- tidak over-engineered.

### 19.1 Hindari
- widget terlalu panjang,
- logic bisnis di UI,
- magic number tanpa konteks,
- nested widget yang sulit dibaca,
- copy-paste screen tanpa refactoring,
- function terlalu panjang,
- variable tidak deskriptif.

### 19.2 Wajib
- format kode dengan `dart format .`,
- pastikan `flutter analyze` tidak menghasilkan error,
- gunakan `const` jika memungkinkan,
- pisahkan file berdasarkan tanggung jawab,
- gunakan komentar hanya jika membantu menjelaskan logic yang tidak obvious.

---

## 20. Aturan Testing

AI harus membantu menjaga kualitas melalui testing jika memungkinkan.

Minimal:
- unit test untuk formatter/helper,
- unit test untuk validasi form,
- widget test untuk screen penting,
- mock repository test untuk state management.

Prioritas test:
1. login validation,
2. pre-order validation,
3. status transition validation,
4. QC/sengketa validation,
5. currency/date formatter.

Jika test belum dibuat, AI harus menyarankan struktur test, bukan mengklaim aplikasi sudah sepenuhnya teruji.

---

## 21. Aturan Dokumentasi

Setiap fitur besar harus memiliki dokumentasi singkat:
- tujuan fitur,
- aktor yang memakai,
- file utama,
- flow UI,
- dependency terkait,
- catatan backend/mock.

Dokumentasi bisa ditempatkan di:
```text
docs/
  frontend.md
  api-contract.md
  feature-flow.md
```

atau langsung di README jika proyek masih kecil.

---

## 22. Aturan Git dan Perubahan File

AI harus menyarankan perubahan yang mudah di-review.

### 22.1 Sebelum Mengubah Banyak File
AI harus menjelaskan:
- file apa yang akan dibuat/diubah,
- alasan perubahan,
- dampak terhadap fitur lain,
- cara rollback jika terjadi masalah.

### 22.2 Commit Message
Gunakan format commit yang rapi:

```text
feat(auth): add login and register screens
feat(orders): add pre-order flow mockup
fix(ui): prevent overflow on commodity card
refactor(core): extract reusable primary button
docs: update frontend architecture guide
```

### 22.3 Jangan Mengubah File Tidak Terkait
AI tidak boleh mengubah file yang tidak relevan dengan permintaan.

---

## 23. Aturan Saat Terjadi Error

Jika terjadi error, AI harus:
1. membaca pesan error secara lengkap,
2. mengidentifikasi file dan line penyebab,
3. menjelaskan penyebab paling mungkin,
4. memberi solusi minimal,
5. menghindari perubahan besar yang tidak diperlukan,
6. menjalankan ulang validasi setelah perbaikan.

Jangan menebak error tanpa melihat pesan error.

Jika error berkaitan dengan dependency, periksa:
- `pubspec.yaml`,
- versi Flutter,
- import,
- breaking changes package,
- platform Android config.

---

## 24. Aturan Output Jawaban AI

Saat menjawab developer, AI harus:
- langsung ke inti masalah,
- tidak memberi jawaban terlalu umum,
- menjelaskan asumsi,
- menandai bagian yang masih perlu konfirmasi,
- memberikan langkah eksekusi yang urut,
- tidak mengklaim berhasil jika belum menjalankan validasi.

Format jawaban yang disarankan:

```text
Ringkasan:
...

Yang saya ubah:
...

File terdampak:
...

Validasi yang perlu dijalankan:
...

Catatan risiko:
...
```

---

## 25. Definisi Selesai

Sebuah task dianggap selesai jika:

- kode sudah dibuat sesuai permintaan,
- tidak keluar dari scope Android Flutter,
- tidak merusak flow PanenHub,
- UI tetap profesional dan mobile-friendly,
- tidak ada error sintaks,
- `dart format .` sudah dilakukan atau disarankan,
- `flutter analyze` sudah dilakukan atau disarankan,
- perubahan file dijelaskan,
- bagian yang belum pasti diberi TODO atau ditanyakan.

Jika salah satu poin belum terpenuhi, AI tidak boleh menyatakan task selesai sepenuhnya.

---

## 26. Instruksi Khusus untuk Proyek PanenHub

AI harus selalu mengingat bahwa PanenHub memiliki flow utama:

```text
Petani posting estimasi panen
-> Pelanggan mencari komoditas
-> Pelanggan membuat pre-order
-> Pelanggan melakukan pembayaran escrow
-> Petani memproses dan memperbarui status rantai pasok
-> Pelanggan melakukan konfirmasi penerimaan dan QC
-> Jika sesuai, dana dicairkan ke petani
-> Jika tidak sesuai, pelanggan mengajukan sengketa
-> Admin memutuskan refund atau pencairan
-> Pelanggan memberi rating dan ulasan
```

Semua fitur, screen, model, dan validasi harus mendukung flow tersebut.

---

## 27. Instruksi Untuk UI Demo

Jika developer meminta UI demo, AI harus menghasilkan tampilan yang:
- rapi,
- realistis,
- konsisten dengan produk agritech,
- memiliki data dummy yang masuk akal,
- tidak terlihat seperti template kosong,
- mencakup role pelanggan dan petani minimal,
- menampilkan status pesanan secara jelas,
- memakai komponen visual seperti card, badge, status chip, timeline, dan bottom navigation.

---

## 28. Batasan yang Belum Boleh Diputuskan Sendiri

AI harus bertanya sebelum menentukan:

- backend final,
- database final,
- payment gateway final,
- service upload gambar final,
- service notifikasi final,
- maps/geolocation provider final,
- state management final jika belum ada keputusan tim,
- desain logo final,
- warna brand final jika belum ditentukan,
- format API final,
- deployment backend,
- integrasi rekening bank asli,
- autentikasi production.

Jika tetap perlu lanjut tanpa keputusan final, gunakan mock atau placeholder.

---

## 29. Ringkasan Perintah Utama untuk AI

Selalu ikuti aturan berikut:

1. Pastikan aplikasi tetap berjalan.
2. Jangan mengeksekusi hal berisiko tanpa konfirmasi.
3. Jangan membuat asumsi final jika data belum tersedia.
4. Fokus pada Android Flutter, bukan website.
5. Jaga UI agar terlihat profesional.
6. Pisahkan UI, domain, dan data layer.
7. Gunakan mock jika backend belum final.
8. Tangani loading, error, empty, dan success state.
9. Validasi semua form penting.
10. Jaga flow PanenHub sesuai rancangan.
11. Jalankan atau sarankan `dart format .`, `flutter analyze`, dan `flutter test`.
12. Tanyakan dulu jika belum yakin.

---

## 30. Prompt Tambahan untuk AI Assistant

Gunakan instruksi berikut setiap kali mulai mengerjakan task baru:

```text
Sebelum mengubah kode, pahami dulu konteks proyek PanenHub.
Aplikasi ini adalah Android app berbasis Flutter, bukan website.
Pastikan perubahan tidak merusak flow registrasi, komoditas, pre-order, escrow, status rantai pasok, QC, sengketa, withdrawal, rating, dan admin.
Jika ada informasi yang belum jelas, tanyakan dulu.
Jika perlu membuat backend sementara, gunakan mock/repository interface.
Setelah membuat perubahan, pastikan kode diformat, dianalisis, dan siap dijalankan.
Jangan menjalankan command destruktif tanpa konfirmasi.
```
