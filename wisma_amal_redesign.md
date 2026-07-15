# AGENT PROMPT — Redesign UI/UX: Modul Inventaris & Operational (Wisma Amal)

## Konteks Proyek

Kamu sedang melakukan **redesign UI/UX** untuk modul **Inventaris & Operational** dari
aplikasi manajemen kost **Wisma Amal**, yang dibangun dengan **Flutter Web**. Aplikasi ini
digunakan oleh Admin dan Super Admin untuk mengelola operasional sehari-hari kost: pencatatan
inventaris, laporan kerusakan dari penghuni, tracking progres perbaikan, dan jadwal
pemeliharaan/kebersihan.

Target pengguna adalah **admin internal**, bukan end user publik. Prioritas utama:
kecepatan membaca data (scanability), kecepatan mengambil tindakan (action speed), dan
kepercayaan visual (trustworthiness) — bukan dekorasi.

---

## Design System yang Harus Diimplementasikan

### 1. Tema & Warna

Buat `AppTheme` kustom menggunakan `ThemeData` dengan **Material 3 (`useMaterial3: true`)**.
Aplikasi mendukung **light mode dan dark mode** dengan karakter visual yang berbeda:
- **Light mode** → referensi: FlyScope (bersih, putih, biru terang)
- **Dark mode** → referensi: Homical (navy gelap, biru-violet vivid)

Definisikan di `lib/core/theme/app_colors.dart` dengan dua kelas:

```dart
// ─────────────────────────────────────────────
// LIGHT MODE COLORS — FlyScope-inspired
// ─────────────────────────────────────────────
class AppColorsLight {
  // Primary — clean rich blue, no violet tint
  static const Color primary        = Color(0xFF2563EB); // Blue 600
  static const Color primaryLight   = Color(0xFFEFF6FF); // Blue 50 (button bg, badge bg)
  static const Color primaryDark    = Color(0xFF1D4ED8); // Blue 700 (hover state)

  // Background & surface
  static const Color background     = Color(0xFFF0F2FA); // Light blue-tinted page bg
  static const Color surface        = Color(0xFFFFFFFF); // Card, dialog, panel
  static const Color surfaceVariant = Color(0xFFF5F6FB); // Table row alt, input bg

  // Text
  static const Color textPrimary    = Color(0xFF1E293B); // Slate 800
  static const Color textSecondary  = Color(0xFF64748B); // Slate 500
  static const Color textHint       = Color(0xFF94A3B8); // Slate 400

  // Border
  static const Color borderLight    = Color(0xFFE2E8F0); // Slate 200
  static const Color borderMedium   = Color(0xFFCBD5E1); // Slate 300

  // Sidebar — white sidebar seperti FlyScope
  static const Color sidebarBg      = Color(0xFFFFFFFF); // White
  static const Color sidebarBorder  = Color(0xFFE2E8F0); // Right border
  static const Color sidebarActive  = Color(0xFF2563EB); // Filled blue active item
  static const Color sidebarActiveText = Color(0xFFFFFFFF);
  static const Color sidebarHoverBg = Color(0xFFEFF6FF); // Very light blue hover
  static const Color sidebarText    = Color(0xFF1E293B); // Dark text
  static const Color sidebarMuted   = Color(0xFF64748B); // Icon inactive
  static const Color sidebarSection = Color(0xFF94A3B8); // Section label

  // Status — semantic, sama di light & dark
  static const Color statusWaiting      = Color(0xFFD97706);
  static const Color statusWaitingBg    = Color(0xFFFFFBEB);
  static const Color statusWaitingBorder= Color(0xFFFDE68A);
  static const Color statusProcess      = Color(0xFF2563EB);
  static const Color statusProcessBg    = Color(0xFFEFF6FF);
  static const Color statusProcessBorder= Color(0xFFBFDBFE);
  static const Color statusDone         = Color(0xFF16A34A);
  static const Color statusDoneBg       = Color(0xFFF0FDF4);
  static const Color statusDoneBorder   = Color(0xFFBBF7D0);
  static const Color statusCancelled    = Color(0xFFDC2626);
  static const Color statusCancelledBg  = Color(0xFFFEF2F2);
  static const Color statusCancelledBorder = Color(0xFFFECACA);

  // Kondisi inventaris
  static const Color conditionGood = Color(0xFF16A34A);
  static const Color conditionFair = Color(0xFFD97706);
  static const Color conditionPoor = Color(0xFFDC2626);
}

// ─────────────────────────────────────────────
// DARK MODE COLORS — Homical-inspired
// ─────────────────────────────────────────────
class AppColorsDark {
  // Primary — blue-violet vivid yang pop di atas gelap
  static const Color primary        = Color(0xFF5B6EF5); // Vivid blue-violet
  static const Color primaryLight   = Color(0xFF252844); // Dark tinted primary bg
  static const Color primaryDark    = Color(0xFF7B8BFF); // Lighter for text on dark

  // Background & surface
  static const Color background     = Color(0xFF141627); // Deep navy — halaman utama
  static const Color surface        = Color(0xFF1E2237); // Card, panel, dialog
  static const Color surfaceVariant = Color(0xFF252844); // Hover row, input bg, active item

  // Text
  static const Color textPrimary    = Color(0xFFE8EAF6); // Near-white with blue tint
  static const Color textSecondary  = Color(0xFF8B93B3); // Muted blue-gray
  static const Color textHint       = Color(0xFF555E7A); // Very muted

  // Border
  static const Color borderLight    = Color(0xFF2A2D45); // Subtle dark border
  static const Color borderMedium   = Color(0xFF363A58); // Slightly visible

  // Sidebar — unified dark seperti Homical
  static const Color sidebarBg      = Color(0xFF141627); // Same as background (seamless)
  static const Color sidebarActive  = Color(0xFF252844); // Slightly lighter box for active
  static const Color sidebarActiveText = Color(0xFFFFFFFF);
  static const Color sidebarActiveIcon = Color(0xFF5B6EF5); // Blue-violet icon saat aktif
  static const Color sidebarHoverBg = Color(0xFF1E2237);
  static const Color sidebarText    = Color(0xFFE8EAF6);
  static const Color sidebarMuted   = Color(0xFF8B93B3);
  static const Color sidebarSection = Color(0xFF555E7A);

  // Status — warna sama, background disesuaikan gelap
  static const Color statusWaiting      = Color(0xFFD97706);
  static const Color statusWaitingBg    = Color(0xFF2D2010);
  static const Color statusWaitingBorder= Color(0xFF78450A);
  static const Color statusProcess      = Color(0xFF5B6EF5);
  static const Color statusProcessBg    = Color(0xFF141A40);
  static const Color statusProcessBorder= Color(0xFF2D3A7A);
  static const Color statusDone         = Color(0xFF22C55E);
  static const Color statusDoneBg       = Color(0xFF0D2818);
  static const Color statusDoneBorder   = Color(0xFF166534);
  static const Color statusCancelled    = Color(0xFFEF4444);
  static const Color statusCancelledBg  = Color(0xFF2D0A0A);
  static const Color statusCancelledBorder = Color(0xFF7F1D1D);

  // Kondisi inventaris
  static const Color conditionGood = Color(0xFF22C55E);
  static const Color conditionFair = Color(0xFFD97706);
  static const Color conditionPoor = Color(0xFFEF4444);
}
```

Buat helper getter di AppTheme untuk resolve warna berdasarkan `Brightness` aktif:

```dart
// lib/core/theme/app_theme.dart
class AppTheme {
  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  // Shorthand getter
  static dynamic colors(BuildContext context) =>
      isDark(context) ? AppColorsDark() : AppColorsLight();
}

// Penggunaan di widget:
// final c = AppTheme.isDark(context) ? AppColorsDark() : AppColorsLight();
// Container(color: c.surface)
```

Wire ke ThemeData:

```dart
static ThemeData get lightTheme => ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  scaffoldBackgroundColor: AppColorsLight.background,
  colorScheme: ColorScheme.light(
    primary: AppColorsLight.primary,
    surface: AppColorsLight.surface,
    onPrimary: Colors.white,
    onSurface: AppColorsLight.textPrimary,
  ),
  // ... textTheme, cardTheme, dll
);

static ThemeData get darkTheme => ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: AppColorsDark.background,
  colorScheme: ColorScheme.dark(
    primary: AppColorsDark.primary,
    surface: AppColorsDark.surface,
    onPrimary: Colors.white,
    onSurface: AppColorsDark.textPrimary,
  ),
  // ... textTheme, cardTheme, dll
);
```

Daftarkan di `MaterialApp`:

```dart
MaterialApp(
  theme: AppTheme.lightTheme,
  darkTheme: AppTheme.darkTheme,
  themeMode: ThemeMode.system, // atau simpan preference di SharedPreferences
  // ...
)
```

### 2. Tipografi

Install dan gunakan font **Plus Jakarta Sans** dari Google Fonts:

```yaml
# pubspec.yaml
dependencies:
  google_fonts: ^6.2.1
```

```dart
// lib/core/theme/app_theme.dart
TextTheme get textTheme => GoogleFonts.plusJakartaSansTextTheme().copyWith(
  displayLarge : GoogleFonts.plusJakartaSans(fontSize: 32, fontWeight: FontWeight.w700),
  headlineMedium: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.w600),
  titleLarge  : GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w600),
  titleMedium : GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w600),
  titleSmall  : GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600),
  bodyLarge   : GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w400),
  bodyMedium  : GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w400),
  bodySmall   : GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w400),
  labelLarge  : GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w500),
  labelSmall  : GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.5),
);
```

### 3. Spacing & Radius

```dart
// lib/core/theme/app_spacing.dart
static const double xs  = 4.0;
static const double sm  = 8.0;
static const double md  = 12.0;
static const double lg  = 16.0;
static const double xl  = 20.0;
static const double xxl = 24.0;
static const double xxxl = 32.0;

// Border radius
static const double radiusSm = 6.0;
static const double radiusMd = 8.0;
static const double radiusLg = 12.0;
static const double radiusXl = 16.0;
```

### 4. Shadows & Elevation

```dart
// lib/core/theme/app_shadows.dart
static const BoxShadow cardShadow = BoxShadow(
  color: Color(0x0A0F172A),
  blurRadius: 8,
  offset: Offset(0, 2),
);
static const BoxShadow cardShadowHover = BoxShadow(
  color: Color(0x140F172A),
  blurRadius: 16,
  offset: Offset(0, 4),
);
```

---

## Layout & Navigasi

### Sidebar

Redesign sidebar menjadi lebih tertata dengan:

```
┌──────────────────────┐
│  [Logo] Wisma Amal   │  ← logo kecil + nama, background sidebarBg
│  Operational & Maint │  ← subtitle, textSecondary kecil
├──────────────────────┤
│                      │
│  MANAJEMEN           │  ← section label: uppercase, 11px, sidebarMuted
│  □ Dashboard         │
│  □ Manajemen Akun    │
│  □ Manj. Penghuni ›  │  ← expand icon kanan
│                      │
│  OPERASIONAL         │  ← section label
│  □ Inventaris        │  ← item aktif: bg sidebarActive, rounded-lg, teks putih
│  ▶ Pemeliharaan      │
│  ▶ Lap. Kerusakan    │
│                      │
│  LAINNYA             │
│  □ Keuangan          │
│  □ Kamar & Reservasi │
│  □ Pengaturan        │
│                      │
├──────────────────────┤
│  [Avatar] Super Admin│  ← avatar circle 32px + nama + role kecil
│  super-admin         │
│             [Logout] │
└──────────────────────┘
```

Implementasi sidebar item aktif:

```dart
// SidebarItem widget — gunakan AnimatedContainer untuk transisi
// Resolve warna berdasarkan Brightness aktif:
final isDark = Theme.of(context).brightness == Brightness.dark;
final activeBg     = isDark ? AppColorsDark.sidebarActive    : AppColorsLight.sidebarActive;
final hoverBg      = isDark ? AppColorsDark.sidebarHoverBg   : AppColorsLight.sidebarHoverBg;
final activeIcon   = isDark ? AppColorsDark.sidebarActiveIcon : Colors.white;
final inactiveIcon = isDark ? AppColorsDark.sidebarMuted     : AppColorsLight.sidebarMuted;
final activeText   = isDark ? AppColorsDark.sidebarActiveText : AppColorsLight.sidebarActiveText;
final inactiveText = isDark ? AppColorsDark.sidebarText      : AppColorsLight.sidebarText;

AnimatedContainer(
  duration: Duration(milliseconds: 150),
  decoration: BoxDecoration(
    color: isActive ? activeBg : Colors.transparent,
    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
  ),
  child: ListTile(
    dense: true,
    leading: Icon(icon, color: isActive ? activeIcon : inactiveIcon, size: 18),
    title: Text(label, style: TextStyle(
      color: isActive ? activeText : inactiveText,
      fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
      fontSize: 14,
    )),
  ),
)

// CATATAN PERBEDAAN PERILAKU:
// Light mode: active item → filled blue (#2563EB) + white text (seperti FlyScope)
// Dark mode:  active item → kotak sedikit lebih terang (#252844) + icon blue-violet
//             sidebar dan bg unified warna sama, seperti Homical
```

### Content Area

```dart
// Layout utama
Scaffold(
  backgroundColor: AppColors.background,
  body: Row(children: [
    SizedBox(width: 240, child: AppSidebar()),
    Expanded(
      child: Column(children: [
        AppTopBar(),     // breadcrumb + actions
        Expanded(child: SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.xxxl),
          child: currentPage,
        )),
      ]),
    ),
  ]),
)
```

**TopBar** berisi:
- Breadcrumb: `Inventaris & Pemeliharaan / Laporan Kerusakan`
- Di kanan: tombol aksi utama halaman (Tambah, Refresh, dsb.)
- Ukuran topbar: 64px height, background `surface`, border-bottom `borderLight`

---

## Komponen Reusable (Wajib Buat)

### A. `StatusBadge` Widget

```dart
// Gunakan di SEMUA halaman yang menampilkan status
Widget StatusBadge({required String status}) {
  final config = _statusConfig[status] ?? _defaultConfig;
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: config.backgroundColor,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: config.borderColor, width: 1),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 6, height: 6, decoration: BoxDecoration(
          color: config.dotColor, shape: BoxShape.circle,
        )),
        SizedBox(width: 6),
        Text(config.label, style: TextStyle(
          color: config.textColor, fontSize: 12, fontWeight: FontWeight.w600,
        )),
      ],
    ),
  );
}

// Status config map:
// 'menunggu'   → Amber colors + label 'Menunggu'
// 'dalam_proses' → Blue colors + label 'Dalam Proses'
// 'selesai'    → Green colors + label 'Selesai'
// 'dibatalkan' → Red colors + label 'Dibatalkan'
```

### B. `SummaryStatCard` Widget

Dipakai di bagian atas halaman list sebagai ringkasan KPI:

```dart
Widget SummaryStatCard({
  required String label,
  required String value,
  required IconData icon,
  required Color iconColor,
  required Color iconBg,
  String? trend,          // opsional: "+3 hari ini"
  Color? trendColor,
})
// Layout:
// ┌─────────────────────────┐
// │ [Icon bg]    label kecil│
// │              VALUE besar│
// │              trend kecil│
// └─────────────────────────┘
// Card: background surface, border borderLight, shadow cardShadow
// Value: fontSize 26, fontWeight 700, textPrimary
// Label: fontSize 12, textSecondary, uppercase
```

### C. `AppDataTable` Widget

Wrapper untuk tabel yang konsisten:

```dart
// Gunakan DataTable Flutter dengan custom styling
// - Header row: background surfaceVariant, text textSecondary, fontSize 12, uppercase
// - Data row hover: background primaryLight opacity 0.3
// - Border: hanya horizontal borderLight, tidak ada border vertikal
// - Padding row: vertical 14px, horizontal 16px
// - Zebra striping: baris genap surface, ganjil surfaceVariant
```

### D. `EmptyStateWidget` Widget

```dart
Widget EmptyStateWidget({
  required IconData icon,
  required String title,
  required String subtitle,
  Widget? action,         // tombol CTA
})
// Layout: center, icon 48px textHint, judul titleMedium, subtitle bodySmall textSecondary
// Contoh: icon=Icons.assignment_outlined, title="Belum ada laporan",
//         subtitle="Laporan dari penghuni akan muncul di sini"
```

### E. `SearchAndFilterBar` Widget

```dart
// Row berisi:
// [SearchField (flex: 1)] [FilterChips/Dropdown] [Sort button]
// SearchField: rounded, prefixIcon search, height 40px, border borderLight
// FilterChip: menggunakan StatusBadge colors, bisa multi-select
```

---

## Redesign Per Halaman

---

### HALAMAN 1: Inventaris (`/app/inventory`)

**Masalah saat ini:** Tabel polos tanpa ringkasan, tidak ada search/filter, tombol Edit tidak
deskriptif, tidak ada insight cepat.

**Redesign:**

```
┌──────────────────────────────────────────────────────────────┐
│ Inventaris                              [+ Tambah Inventaris] │
│                                                              │
│ ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐        │
│ │ 47       │ │ Rp 82.5jt│ │ 44 Baik  │ │ 3 Cukup  │        │
│ │ TOTAL    │ │ TOTAL    │ │ KONDISI  │ │ PERLU    │        │
│ │ BARANG   │ │ NILAI    │ │ BAIK     │ │ PERHATIAN│        │
│ └──────────┘ └──────────┘ └──────────┘ └──────────┘        │
│                                                              │
│ Daftar Barang                                               │
│ [🔍 Cari nama barang...] [Semua Kondisi ▼] [Sort: Nama ▼]   │
│                                                              │
│ NAMA              KETERANGAN           JML  KONDISI  NILAI  │
│ Kasur Single King Berkualitas untuk..  10   ● Baik   2.5jt  │
│ AC Split 1/2 PK   AC hemat energi      15   ● Baik   3.2jt  │
│ ...                                                          │
│                                          [Edit] [Hapus]      │
└──────────────────────────────────────────────────────────────┘
```

**Detail implementasi:**

1. **Summary Cards (4 kartu di atas tabel):**
   - Total Barang (count semua item)
   - Total Nilai Inventaris (sum total_harga, format Rp X.Xjt/X.Xm)
   - Jumlah Kondisi Baik (count dengan kondisi='Baik')
   - Perlu Perhatian (count kondisi !='Baik'), card ini gunakan warna amber jika > 0

2. **Search & Filter Bar:**
   - TextField search by nama/keterangan
   - DropdownButton filter kondisi: Semua / Baik / Cukup / Buruk
   - Tombol sort icon, default by nama ascending

3. **Tabel Redesign:**
   - Kolom KONDISI: ganti teks biasa dengan `ConditionDot` + label
     - `● Baik` = dot hijau + teks hijau
     - `● Cukup` = dot amber + teks amber
     - `● Buruk` = dot merah + teks merah
   - Kolom NILAI: format rupiah yang proper `Rp 2.500.000` → singkat jika > juta
   - Kolom aksi: ganti tombol kuning besar menjadi:
     ```dart
     Row(children: [
       IconButton(icon: Icon(Icons.edit_outlined, size: 18), onPressed: ..., tooltip: 'Edit'),
       IconButton(icon: Icon(Icons.delete_outline, size: 18, color: Colors.red[400]), ...),
     ])
     ```
   - Baris tabel bisa di-hover (InkWell)

4. **Tambah/Edit Inventaris Dialog:**
   - Gunakan `Dialog` yang muncul di tengah, lebar max 520px
   - Bukan navigate ke halaman baru
   - Field: Nama Barang, Keterangan, Jumlah (int), Kondisi (dropdown), Harga Satuan
   - Total Harga auto-calculate: Jumlah × Harga Satuan, tampilkan real-time
   - Tombol: `Batal` (outlined) + `Simpan` (primary filled)

---

### HALAMAN 2: Laporan Kerusakan (`/app/maintenance-reports`)

**Masalah saat ini:** Cards terlalu polos, tidak ada summary, tidak ada pagination,
tombol kecil di kanan bawah tidak jelas fungsinya.

**Redesign:**

```
┌──────────────────────────────────────────────────────────────┐
│ Laporan Kerusakan            [🔄]                            │
│ Semua laporan kerusakan dari penghuni                        │
│                                                              │
│ ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐                 │
│ │ 12     │ │ 8      │ │ 3      │ │ 1      │                 │
│ │ TOTAL  │ │ MENUNGGU│ │ PROSES │ │ SELESAI│                 │
│ └────────┘ └────────┘ └────────┘ └────────┘                 │
│                                                              │
│ [Semua] [Menunggu 8] [Dalam Proses 3] [Selesai] [Dibatalkan] │
│ ──── tab bar dengan badge count ────                         │
│                                                              │
│ ┌────────────────────────────────────────────────────────┐   │
│ │ ● Menunggu                    14 Jun 2026, 15:02      │   │
│ │                                                        │   │
│ │ AC Kamar Bocor                                        │   │
│ │ ac kamar bocor, jadinya kamar selalu banjir           │   │
│ │                                                        │   │
│ │ 👤 Ahmad Hidayat · Kamar 12                           │   │
│ │                                    [Lihat Detail →]   │   │
│ └────────────────────────────────────────────────────────┘   │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

**Detail implementasi:**

1. **Summary Cards:**
   - Total, Menunggu (amber), Dalam Proses (blue), Selesai (green)
   - Klik card → filter tab otomatis berpindah ke status tersebut

2. **Tab Bar Redesign:**
   - Ganti tombol outlined biasa menjadi `TabBar` custom dengan badge count
   ```dart
   Tab(child: Row(children: [
     Text('Menunggu'),
     SizedBox(width: 6),
     Container(
       padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
       decoration: BoxDecoration(color: AppColors.statusWaiting, borderRadius: ...),
       child: Text('8', style: TextStyle(color: Colors.white, fontSize: 11)),
     ),
   ]))
   ```

3. **Card Redesign:**
   - Hapus tombol bulat di pojok kanan bawah yang tidak jelas
   - Status badge di atas kiri menggunakan `StatusBadge` widget
   - Judul laporan: `titleMedium` (15px, semibold)
   - Deskripsi: maksimal 2 baris, overflow ellipsis
   - Footer card: icon person + nama + icon kamar + nomor kamar | tanggal
   - Tombol aksi: `TextButton` "Lihat Detail →" di kanan bawah, teks primary color
   - Card clickable seluruhnya (InkWell) → navigate ke detail
   - Hover effect: border berubah jadi `primary`

4. **Empty State (per tab):**
   - Tab "Menunggu" kosong: icon check_circle, "Tidak ada laporan menunggu", subtitle "Semua laporan telah ditangani"
   - Tab "Dalam Proses" kosong: icon engineering, "Tidak ada yang sedang dikerjakan"

---

### HALAMAN 3: Detail Laporan (`/app/maintenance-reports/:id`)

**Masalah saat ini:** Layout linear dan datar. Tidak ada visual tracking status.
Section "Riwayat Penanganan" tidak punya desain yang engaging. Form update di bawah terasa
terpisah dari konteks.

**Redesign konsep:** Layout **dua kolom** untuk layar ≥ 1200px:
- **Kolom kiri (60%):** Info laporan + foto + timeline riwayat
- **Kolom kanan (40%):** Panel sticky untuk tindakan admin

```
┌──────────────────────────────────────────────────────────────┐
│ ← Kembali ke Laporan      Detail Laporan  ID #2              │
│                                     ● Menunggu Penanganan    │
├────────────────────────────┬─────────────────────────────────┤
│                            │                                 │
│  📋 Informasi Laporan      │  ─── Panel Tindakan ────        │
│  ─────────────────         │                                 │
│  AC Kamar Bocor            │  Perbarui Status                │
│  (judul H2 besar)          │  ┌─────────────────────────┐   │
│                            │  │ Menunggu  ← tab aktif   │   │
│  📅 14 Jun 2026, 15:02     │  │ Dalam Proses            │   │
│  👤 Ahmad Hidayat          │  │ Selesai                 │   │
│  🏠 Kamar 12 (jika ada)    │  │ Dibatalkan              │   │
│                            │  └─────────────────────────┘   │
│  Deskripsi                 │  (gunakan segmented button      │
│  ac kamar bocor, jadinya   │   bukan chip outline biasa)     │
│  kamar selalu banjir       │                                 │
│                            │  Catatan Update *               │
│  Foto Kerusakan            │  ┌─────────────────────────┐   │
│  ┌──────┐                  │  │ contoh: Tukang sedang..│   │
│  │ img  │ (clickable       │  │                         │   │
│  │      │  expand)         │  └─────────────────────────┘   │
│  └──────┘                  │                                 │
│                            │  Lampirkan Foto (opsional)      │
│  📊 Riwayat Penanganan     │  ┌─────────────────────────┐   │
│  ─────────────────         │  │  + Tambah foto          │   │
│  [TIMELINE VERTICAL]       │  └─────────────────────────┘   │
│                            │                                 │
│  (lihat spec timeline      │  [    Kirim Update    ]         │
│   di bawah)                │  tombol primary full-width      │
│                            │                                 │
└────────────────────────────┴─────────────────────────────────┘
```

**Timeline Riwayat Penanganan:**

```dart
// Komponen: MaintenanceTimeline
// Gunakan CustomPaint atau Column dengan connector lines

// Setiap item timeline:
Row(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    // Kiri: dot + garis vertikal
    Column(children: [
      Container(width: 12, height: 12, decoration: BoxDecoration(
        color: statusColor,    // sesuai status
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      )),
      if (!isLast) Container(width: 2, height: 60, color: borderLight),
    ]),
    SizedBox(width: 16),
    // Kanan: konten
    Expanded(child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          StatusBadge(status: item.status),
          Spacer(),
          Text(item.formattedDateTime, style: bodySmall + textSecondary),
        ]),
        SizedBox(height: 6),
        Text(item.catatan, style: bodyMedium),
        if (item.fotoUrls.isNotEmpty) ...[
          SizedBox(height: 8),
          // Grid foto kecil 60x60px, clickable untuk expand
        ],
        SizedBox(height: 8),
        Text('oleh ${item.adminName}', style: bodySmall + textHint),
        SizedBox(height: 20),
      ],
    )),
  ],
)
```

**State kosong timeline:**
```
[Icon: clipboard dengan jam kosong, 48px, warna textHint]
Belum ada update penanganan
Tim pengelola akan memperbarui laporan ini
```

**Panel Tindakan (kanan):**
- Background `surface`, border `borderLight`, border-radius `radiusLg`
- Sticky saat di-scroll (gunakan `Positioned` atau `StickyHeader`)
- Segmented button untuk status menggunakan `SegmentedButton<String>` dari Material 3
- Textarea catatan: minimal 3 baris, maxLines: null
- Upload foto: `DottedBorder` 2px dashed + icon add_photo + teks "Tambah Foto"
- Tombol submit: full-width, height 48px, `ElevatedButton` warna primary

---

### HALAMAN 4: Pemeliharaan / Jadwal (`/app/maintenance`)

*(Halaman ini belum ter-screenshot, namun wajib dibuat konsisten dengan modul ini)*

**Layout:**

```
┌──────────────────────────────────────────────────────────────┐
│ Pemeliharaan                           [+ Tambah Jadwal]     │
│                                                              │
│ ┌────────────┐ ┌────────────┐ ┌────────────┐                │
│ │ 5          │ │ 2          │ │ 8          │                │
│ │ JADWAL     │ │ JATUH TEMPO│ │ SELESAI    │                │
│ │ AKTIF      │ │ MINGGU INI │ │ BULAN INI  │                │
│ └────────────┘ └────────────┘ └────────────┘                │
│                                                              │
│ Tampilan: [📅 Kalender] [☰ Daftar]   [Filter: Semua Area ▼] │
│                                                              │
│ ── Mode Daftar ──                                            │
│ ┌────────────────────────────────────────────────────────┐   │
│ │ Pembersihan Ruang Umum        📅 Setiap Senin 08:00   │   │
│ │ Area lobby, tangga, toilet    ● Aktif                  │   │
│ │ 👤 Pak Budi (PIC)            [Tandai Selesai] [Edit]   │   │
│ └────────────────────────────────────────────────────────┘   │
└──────────────────────────────────────────────────────────────┘
```

**Fitur minimum:**
- Toggle view: Daftar (ListView) dan Kalender (gunakan `table_calendar` package)
- Status jadwal: Aktif, Selesai, Terlewat (overdue)
- PIC assignment per jadwal
- Tombol "Tandai Selesai" yang prominent

---

## UX Improvements Global

### 1. Loading States

Setiap halaman yang fetch data wajib punya skeleton loading, bukan `CircularProgressIndicator` polos:

```dart
// Skeleton untuk card laporan
Container(
  height: 120,
  decoration: BoxDecoration(
    color: Colors.grey[200],
    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
  ),
  child: ShimmerEffect(), // gunakan shimmer package atau implementasi manual
)
```

### 2. Toast / Snackbar Feedback

Setiap aksi (simpan, update status, hapus) wajib tampilkan feedback:

```dart
// Sukses
ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  content: Row(children: [
    Icon(Icons.check_circle, color: AppColors.statusDone),
    SizedBox(width: 8),
    Text('Status laporan berhasil diperbarui'),
  ]),
  backgroundColor: AppColors.statusDoneBg,
  behavior: SnackBarBehavior.floating,
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  margin: EdgeInsets.all(16),
  duration: Duration(seconds: 3),
));

// Error
// Gunakan warna statusCancelled + statusCancelledBg
```

### 3. Konfirmasi Destruktif

Setiap aksi hapus/batalkan wajib tampilkan `AlertDialog` konfirmasi:

```dart
showDialog(context, builder: (_) => AlertDialog(
  title: Text('Batalkan laporan?'),
  content: Text('Laporan yang dibatalkan tidak dapat dikembalikan.'),
  actions: [
    TextButton(child: Text('Kembali'), onPressed: () => Navigator.pop(context)),
    ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: AppColors.statusCancelled),
      child: Text('Ya, Batalkan'),
      onPressed: () { /* aksi */ },
    ),
  ],
));
```

### 4. Micro-Interactions

Gunakan package `flutter_animate: ^4.5.0` untuk animasi yang subtle:

```dart
// Card laporan masuk dengan animasi
LaporanCard(data: item)
  .animate()
  .fadeIn(duration: 300.ms)
  .slideY(begin: 0.05, end: 0, duration: 300.ms)
```

Animasi wajib dipakai di:
- Card list saat pertama kali load (staggered, delay 50ms per item)
- Status badge saat status berubah (scale pulse)
- Summary stats saat data masuk (count-up animation)

### 5. Responsivitas

Gunakan breakpoints berikut (sudah pernah didefinisikan sebelumnya di codebase):

```dart
// Sesuaikan dengan breakpoint yang sudah ada di project
// Mobile  < 600px  : tidak diprioritaskan (admin pakai desktop/tablet)
// Tablet  600-1024px : sidebar collapsible, 1 kolom layout
// Desktop ≥ 1024px   : sidebar fixed, layout 2 kolom untuk detail laporan
// Wide    ≥ 1400px   : padding konten lebih besar, tabel lebih lebar
```

---

## Hal yang JANGAN Diubah

1. **Routing** — Jangan ubah path URL yang sudah ada
2. **State management** — Tetap gunakan `flutter_bloc` yang sudah ada
3. **API/Service layer** — Jangan ubah logika data fetching
4. **Authentication flow** — Jangan sentuh AuthCubit/AuthBloc
5. **Model/Entity classes** — Jangan ubah struktur data

---

## Urutan Pengerjaan yang Disarankan

1. **[Setup]** Buat `AppColors`, `AppSpacing`, `AppTheme`, update `pubspec.yaml` dengan font
2. **[Components]** Buat `StatusBadge`, `SummaryStatCard`, `EmptyStateWidget`, `AppDataTable`
3. **[Sidebar]** Redesign `AppSidebar` widget
4. **[Inventaris]** Redesign halaman list + dialog tambah/edit
5. **[Laporan List]** Redesign halaman list laporan kerusakan
6. **[Laporan Detail]** Redesign halaman detail dengan timeline
7. **[Pemeliharaan]** Redesign/buat halaman jadwal
8. **[Polish]** Tambah loading skeleton, toast feedback, animasi

---

## Referensi Visual

Aesthetic target: mirip dengan **Linear** (linear.app) atau **Plane** (plane.so) —
clean, data-dense, professional internal tool. Bukan consumer app, bukan landing page.
Ciri khasnya: typography yang kuat, warna status yang tegas, whitespace yang cukup tapi
tidak berlebihan, dan setiap elemen punya fungsi yang jelas.

---

*Prompt ini dibuat untuk Wisma Amal - Modul Inventaris & Operational*
*Generated: 14 Juni 2026*