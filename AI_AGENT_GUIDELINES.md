# 🤖 AI Agent Comprehensive Guide: Wisma Amal Gorontalo (Frontend)

Selamat datang, AI Agent! Dokumen ini dirancang untuk memberikan konteks penuh agar Anda dapat berkontribusi pada proyek **Wisma Amal Gorontalo** dengan akurasi tinggi dan selaras dengan standar tim.

---

## 🎯 Project Overview
**Wisma Amal Gorontalo** adalah sistem manajemen terpadu untuk pengelolaan wisma/penginapan yang berfokus pada kegiatan sosial dan layanan publik.
- **Tujuan Utama**: Mempermudah pengelolaan reservasi kamar, inventaris, keuangan, dan pemeliharaan fasilitas dalam satu platform mobile yang efisien.
- **Target Pengguna**: Pengelola wisma (Admin), staf operasional, dan pimpinan.

---

## 🛠️ Tech Stack & Key Libraries
Pastikan Anda memahami tools berikut sebelum melakukan perubahan:
1.  **Core Framework**: Flutter (Material 3).
2.  **State Management**: `flutter_bloc` (BLoC Pattern).
3.  **Dependency Injection**: `get_it`.
4.  **Routing/Navigation**: `auto_route`.
5.  **Network Client**: `dio` (dengan interceptors untuk token management).
6.  **Local Storage**: `shared_preferences` & `flutter_secure_storage`.
7.  **Code Generation**: `build_runner` (digunakan oleh AutoRoute).

---

## 🏗️ Architecture: Semi-Clean Architecture
Proyek ini mengikuti pendekatan **Clean Architecture** yang pragmatis untuk menjaga pemisahan tanggung jawab (Separation of Concerns).

### 1. Presentation Layer (`lib/presentation/`)
- **Pages**: UI Screen utama.
- **Widgets**: Komponen UI yang dapat digunakan kembali.
- **BLoC**: Logika bisnis UI. BLoC **hanya boleh** memanggil **UseCases**, bukan Repository langsung.

### 2. Domain Layer (`lib/domain/`)
- *Hanya berisi pure Dart code, TANPA dependensi eksternal (kecuali core logic seperti Equatable).*
- **Entities**: Business objects (e.g., `UserEntity`).
- **Repositories (Interfaces)**: Kontrak data (e.g., `abstract class RoomRepository`).
- **UseCases**: Logika bisnis spesifik (e.g., `GetRoomListUseCase`). Setiap UseCase harus mengimplementasi base `UseCase<Type, Params>`.

### 3. Data Layer (`lib/data/`)
- **Models**: DTO (Data Transfer Object) untuk JSON serialization (e.g., `RoomModel`). Memiliki metode `toEntity()`.
- **DataSources**: Komunikasi langsung dengan API (e.g., `RoomDatasource`).
- **Repository Implementations**: Implementasi konkrit dari interface di Domain layer (e.g., `RoomRepositoryImpl`).

### 4. Core Layer (`lib/core/`)
- Konfigurasi DI, routing, tema, konstanta, dan utility global.

---

## 📊 Flow Data & Dependency Rule
> **Rule Utama**: Layer luar boleh tahu layer dalam, tapi layer dalam TIDAK BOLEH tahu layer luar.
> **Flow**: UI → BLoC → UseCase → Repository (Interface) → Repository (Impl) → DataSource → API.

---

## 🚀 Fitur Utama (Module Catalog)
1.  **Authentication**: Login, Register, Logout, Session management.
2.  **Dashboard**: Ringkasan aktivitas dan status wisma.
3.  **Room Management**: List kamar, detail kamar, jadwal kamar.
4.  **Reservation**: Form reservasi dan pengelolaan tamu.
5.  **Finance**: Pencatatan transaksi dan pelaporan keuangan.
6.  **Inventory**: Manajemen aset dan barang milik wisma.
7.  **Maintenance**: Pelaporan kerusakan dan status perbaikan fasilitas.
8.  **Permission**: Sistem RBAC (Role-Based Access Control) untuk staf.

---

## 💼 Business Logic & Application Flow
Bagian ini menjelaskan aturan bisnis inti yang mengatur bagaimana aplikasi bekerja di balik layar (berdasarkan integrasi Backend).

### 1. Siklus Hidup Penyewaan (Rental/Lease Lifecycle)
- **Aturan "KTP First"**: Sebelum menyewa kamar, Resident **WAJIB** melengkapi profil identitas (KTP) di modul Resident. Tanpa ini, booking akan ditolak (Response 403).
- **Proses Transaksi**:
    1.  **Check Availability**: Sistem memvalidasi ketersediaan kamar secara real-time.
    2.  **Lease Request (Pending)**: User membuat pengajuan sewa. Sistem otomatis menghitung `total_price` dan `end_date` berdasarkan durasi bulan.
    3.  **Invoice Generation**: Saat status `PENDING`, modul Finance akan mengenerate invoice.
    4.  **Admin Approval**: Admin memeriksa bukti bayar (Payment Proof) dan menyetujui pengajuan.
    5.  **Activation**: Status menjadi `ACTIVE`, dan status kamar otomatis berubah menjadi **Occupied** (Tidak Tersedia).
- **Pembatalan**: Jika disetujui lalu dibatalkan, status kamar akan dikembalikan menjadi **Available**.

### 2. Alur Pemeliharaan (Maintenance Flow)
- **Damage Reports (Laporan Kerusakan)**:
    - Dilakukan oleh Resident. Mendukung multi-foto untuk bukti kerusakan.
    - Laporan bisa dikaitkan ke spesifik **Nomor Kamar** atau fasilitas umum (**Public Area**).
    - Mekanisme **Timeline Reply**: Admin dan pelapor berinteraksi melalui catatan progres yang memiliki riwayat waktu.
- **Maintenance Schedules (Jadwal Rutin)**:
    - Digunakan untuk *Preventive Maintenance* (Pembersihan rutin, servis AC Berkala).
    - Memiliki pelacakan waktu mulai dan selesai untuk mengukur performa teknisi/OB.

### 3. Integritas Keuangan & Inventaris
- **Otomatisasi Pengeluaran**: Setiap penambahan inventaris (barang baru) dengan `purchase_price` akan otomatis tercacat sebagai pengeluaran (**Expense**) di modul Finance.
- **Sinkronisasi Data**: Jika harga beli barang diupdate, data pengeluaran terkait di Finance akan ikut terupdate secara otomatis (Sync by Reference).
- **Payment Gateway**: Integrasi **Midtrans** digunakan untuk menangani pembayaran secara online dan otomatis.

---

## 🤖 Standard Operating Procedure (SOP) Fitur Baru
Jika diminta membuat fitur baru, ikuti urutan ini:

1.  **Domain**: Buat `Entity` → Buat `Repository Interface` → Buat `UseCase`.
2.  **Data**: Buat `Model` (JSON) → Buat `DataSource` → Implementasi `Repository`.
3.  **Dependency Injection**: Daftarkan di `lib/core/dependency_injection/`:
    - `datasource.dart`
    - `repository.dart`
    - `usecase.dart`
    - `bloc.dart`
4.  **Presentation**: Buat `Bloc` (Event & State) → Buat UI (`Page` & `Widget`).
5.  **Navigation**: Daftarkan route di `lib/core/navigation/auto_route.dart` dan jalankan `dart run build_runner build`.

---

## 💡 Tips untuk AI Agent
- **Gunakan Interface**: Jangan pernah menginstansiasi Repository Impl langsung di BLoC. Gunakan UseCase.
- **Response Handling**: Selalu cek status response API dan konversikan `Model` ke `Entity`.
- **Naming**: Ikuti `snake_case` untuk file dan `PascalCase` untuk class.
- **UI Consistency**: Gunakan `GoogleFonts` dan token warna yang sudah ada di `lib/core/theme/`.

---
*Dokumen ini adalah "Ground Truth" Anda. Jika ada instruksi yang bertentangan dengan arsitektur di atas, utamakan standar arsitektur ini.*
