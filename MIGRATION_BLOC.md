# Migrasi State Management dari GetX ke BLoC

## Ringkasan Perubahan

Proyek ini telah berhasil dimigrasi dari GetX ke BLoC pattern tanpa mengubah hasil dan alur aplikasi.

## Struktur File BLoC

### 1. Auth BLoC
- **Location**: `lib/presentation/bloc/auth/`
- **Files**:
  - `auth_event.dart` - Mendefinisikan semua events (Login, Register, Logout, GetUserInfo, InitLoginStatus, ToggleObscureText)
  - `auth_state.dart` - Mendefinisikan state dengan properties: isLoggedIn, userInfo, obscureText, isLoading, errorMessage, successMessage
  - `auth_bloc.dart` - Business logic layer yang menggantikan AuthController
  - `bloc.dart` - Barrel file untuk export semua bloc

## Perubahan Detail

### 1. Dependency Injection (`lib/core/dependency_injection/dependency_injection.dart`)
- Menambahkan registrasi `AuthBloc` di service locator
- AuthBloc menggunakan factory pattern untuk membuat instance baru

### 2. Main App (`lib/main.dart`)
- Menghapus `Get.put()` untuk AuthController
- Menambahkan `BlocProvider` untuk AuthBloc
- Menggunakan `BlocProvider.value()` untuk menyediakan instance ke seluruh aplikasi

### 3. Router (`lib/core/navigation/go_router.dart`)
- Mengganti `Get.find<AuthController>()` dengan passing `AuthBloc` via constructor
- Menggunakan `authBloc.loginStatusNotifier` untuk refreshListenable
- Redirect logic tetap sama, hanya mengakses state dari `authBloc.state.isLoggedIn`

### 4. Login Page (`lib/presentation/pages/auth/login_page.dart`)
- Menghapus `Get.find<AuthController>()`
- Menggunakan `context.read<AuthBloc>()` untuk dispatch events
- Mengganti `Obx` dengan `BlocConsumer` untuk reactive UI
- Menggunakan `BlocConsumer` listener untuk navigasi otomatis saat login sukses
- State management untuk obscureText sekarang dari BLoC state

### 5. Register Page (`lib/presentation/pages/auth/register_page.dart`)
- Menghapus `Get.find<AuthController>()`
- Menggunakan `context.read<AuthBloc>()` untuk dispatch events
- Mengganti `Obx` dengan `BlocConsumer` untuk reactive UI
- Menggunakan `BlocConsumer` listener untuk navigasi otomatis saat register sukses
- Form validation tetap sama

### 6. Sidebar (`lib/presentation/widget/sidebar.dart`)
- Menghapus `Get.find<AuthController>()`
- Mengganti `GetBuilder` dengan `BlocBuilder`
- Menggunakan `context.read<AuthBloc>()` untuk dispatch `LogoutEvent`
- Auto-load user info saat state.userInfo null

### 7. Dependencies (`pubspec.yaml`)
- Menghapus dependency `get: ^4.7.2`
- Mempertahankan `bloc: ^9.1.0` dan `flutter_bloc: ^9.1.1` yang sudah ada
- Dependencies lain tetap sama

## Keuntungan Migrasi ke BLoC

1. **Testability**: BLoC pattern lebih mudah di-test karena pemisahan yang jelas antara business logic dan UI
2. **Predictability**: State management yang lebih predictable dengan immutable states
3. **Debugging**: Lebih mudah tracking state changes dengan BLoC observer
4. **Architecture**: Mengikuti pattern yang direkomendasikan oleh Flutter team
5. **Separation of Concerns**: Business logic terpisah dari UI layer

## Alur Kerja Yang Sama

Semua fitur berjalan dengan cara yang sama:

1. **Login Flow**: User input email & password → dispatch LoginEvent → AuthBloc process → update state → UI react → navigate to dashboard
2. **Register Flow**: User input data → dispatch RegisterEvent → AuthBloc process → update state → UI react → navigate to dashboard
3. **Logout Flow**: User click logout → dispatch LogoutEvent → AuthBloc reset state → navigate to login
4. **Router Redirect**: Tetap menggunakan loginStatusNotifier untuk refresh router saat state berubah
5. **Password Visibility**: Toggle obscureText via ToggleObscureTextEvent
6. **User Info Display**: Auto-load via GetUserInfoEvent saat sidebar render

## Testing

Untuk memastikan migrasi berhasil, test skenario berikut:

1. ✅ Login dengan credentials valid
2. ✅ Login dengan credentials invalid  
3. ✅ Register user baru
4. ✅ Logout dan redirect ke login page
5. ✅ Protected route redirect jika belum login
6. ✅ Display user info di sidebar
7. ✅ Toggle password visibility

## Notes

- Semua logika bisnis tetap sama, hanya cara state management yang berubah
- Error handling tetap menggunakan SnackBar global
- Router refresh menggunakan ValueNotifier yang sama (loginStatusNotifier)
- No breaking changes pada API atau data flow
