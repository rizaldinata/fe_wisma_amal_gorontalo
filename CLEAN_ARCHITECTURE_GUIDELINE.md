# Clean Architecture Guidelines 

Dokumen ini berisi panduan implementasi Clean Architecture yang digunakan dalam proyek ini. Panduan ini ditujukan untuk **Developer** dan **AI Assistant** agar dapat menjaga konsistensi arsitektur kode.

## 🏗️ Struktur Arsitektur
Aplikasi ini dibagi menjadi 3 lapisan (layer) utama yang saling terpisah.
Aturan utamanya adalah **Dependency Rule**: *Layer luar (Presentation/Data) boleh bergantung pada layer dalam (Domain), tetapi layer dalam TIDAK BOLEH bergantung pada layer luar*.

### 1. Domain Layer (`lib/domain/`)
Ini adalah lapisan inti (core) aplikasi yang tidak bergantung pada framework atau *library* pihak ketiga (seperti Flutter, Dio, dll).
* **Entities**: Objek data murni (business objects).
* **Repository Interfaces**: Kelas abstrak (`abstract class`) yang mendefinisikan kontrak apa saja yang bisa dilakukan terhadap data. Contoh: `AuthRepository`.
* **Use Cases**: Berisi spesifik *business logic* untuk satu fungsionalitas. Setiap UseCase hanya memiliki SATU tugas (Single Responsibility Principle) dan bergantung HANYA pada *Repository Interfaces*. Semua UseCase mengimplementasikan bentuk `UseCase<Type, Params>`.

> ⚠️ **AI / Developer Rule**: Dilarang mengimpor UI (Material/Cupertino), HTTP client, atau eksternal library apa pun di layer ini. Dilarang mengimplementasikan fungsi HTTP request di layer ini.

### 2. Data Layer (`lib/data/`)
Lapisan ini bertanggung jawab untuk mendapatkan, memanipulasi, dan mengelola data dari luar (API, Local Storage, Database).
* **Models**: Representasi data dari luar (contoh: JSON). Harus memiliki fungsi konversi ke *Entities*.
* **Datasources**: Kelas yang langsung berinteraksi dengan API atau Database.
* **Repository Implementation**: Kelas yang mengimplementasikan *Repository Interfaces* yang telah didefinisikan di Domain layer. Contoh: `AuthRepositoryImpl` mengimplementasi `AuthRepository`.

> ⚠️ **AI / Developer Rule**: Di sini diperbolehkan untuk melakukan HTTP request (menggunakan Dio) atau parsing JSON. Konversikan selalu raw data (Model) menjadi *Entity* sebelum dikembalikan.

### 3. Presentation Layer (`lib/presentation/`)
Lapisan terluar yang berinteraksi langsung dengan pengguna (UI/UX).
* **Pages/Widgets**: Tampilan antarmuka pengguna (UI).
* **State Management (Bloc/Cubit)**: Menjembatani UI dengan Domain layer. 

> ⚠️ **AI / Developer Rule**: BLoC **TIDAK BOLEH** bergantung langsung pada kelas Repository (seperti `AuthRepositoryImpl` atau `AuthRepository`). BLoC **HARUS** bergantung pada **Use Cases**.

---

## 🛠️ Dependency Injection (DI)
Proyek ini menggunakan library `get_it` untuk manajemen *dependency*. File konfigurasinya berada di `lib/core/dependency_injection/`.
Alur Injeksinya adalah:
1. Registrasi *Datasource* (`datasource.dart`).
2. Registrasi *Repository Interfaces* ke *Repository Implementation* (`repository.dart`).
3. Registrasi *Use Cases* (`usecase.dart`).
4. Registrasi *Bloc* (`bloc.dart`).

---

## 🤖 Instruksi untuk AI & Developer (SOP Pembuatan Fitur Baru)

Jika Anda (AI atau Developer) diminta untuk **MEMBUAT FITUR BARU**, ikuti urutan langkah berikut **TANPA TERLEWAT**:

### Langkah 1: Buat Layer Domain
1. Buat **Entity** jika fitur membutuhkan data struktur baru.
2. Buat **Repository Interface** di `lib/domain/repository/` (Contoh: `abstract class ProductRepository { Future<List<ProductEntity>> getProducts(); }`).
3. Buat **Use Cases** di `lib/domain/usecase/<nama_fitur>/` untuk tiap operasi (Contoh: `GetProductsUseCase`). Pastikan UseCase mengimplementasi kelas `UseCase<T, Params>`.

### Langkah 2: Buat Layer Data
1. Buat **Model** jika ada response JSON baru. Jangan lupa buat `toEntity()`.
2. Buat **Datasource** di `lib/data/datasource/` untuk hit API/Database.
3. Buat implementasi dari repository di `lib/data/repository/` (Contoh: `class ProductRepositoryImpl implements ProductRepository`). Panggil datasource di dalam sini dan kembalikan *Entity*.

### Langkah 3: Setup Dependency Injection (DI)
1. Daftarkan di `core/dependency_injection/repository.dart`: 
   `serviceLocator.registerFactory<ProductRepository>(() => ProductRepositoryImpl(...));`
2. Daftarkan di `core/dependency_injection/usecase.dart`: 
   `serviceLocator.registerFactory(() => GetProductsUseCase(serviceLocator()));`

### Langkah 4: Buat Layer Presentation
1. Buat **Event** dan **State** BLoC.
2. Buat **Bloc** yang menerima parameter *Use Case(s)* melalui constructor, bukan menginjeksi repository.
   ```dart
   class ProductBloc extends Bloc<ProductEvent, ProductState> {
     final GetProductsUseCase getProducts;
     ProductBloc({required this.getProducts}) : super(InitialState());
   }
   ```
3. Daftarkan Bloc tersebut di `core/dependency_injection/bloc.dart`.
4. Implementasikan UI (Bikin Screen, Widget, tangkap state dari Bloc menggunakan `BlocBuilder` atau `BlocListener`).

---
**PENGINGAT (REMINDER):** Jangan pernah men-skip/melewatkan pembuatan antarmuka (interface) repository dan UseCase dengan alasan mempercepat kodingan. Semua komponen logic presentasi (Bloc/ViewModel) harus passing data lewat UseCase!
