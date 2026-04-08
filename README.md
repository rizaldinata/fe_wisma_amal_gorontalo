# Wisma Amal Gorontalo - Frontend

Aplikasi mobile untuk manajemen Wisma Amal Gorontalo.

## 🏗️ Architecture

Project ini menggunakan **Semi-Clean Architecture** dengan pendekatan pragmatis untuk development yang lebih cepat:

### Karakteristik:
- ✅ Separation of concerns (presentation, data, domain)
- ✅ BLoC pattern untuk state management
- ✅ Dependency injection dengan GetIt
- ❌ **Tidak ada abstraksi/interface** (langsung concrete implementation)
- ❌ **Repository hanya ada di layer Data**

### Flow Data:
```
UI (Presentation) → BLoC → Repository (Data) → DataSource → API/Local
                      ↓
                   Entity (Domain)
```

### Keuntungan Semi-Clean:
- ⚡ Development lebih cepat (less boilerplate)
- 🎯 Lebih simple untuk project skala kecil-menengah
- 📝 Tetap maintainable dengan separation of concerns
- 🔄 Mudah di-refactor ke full Clean Architecture jika diperlukan

## 📋 Project Structure

```
lib/
├── core/
│   ├── constant/           # Konstanta aplikasi
│   ├── dependency_injection/ # Setup DI (GetIt)
│   ├── navigation/         # Routing (AutoRoute)
│   ├── services/           # Services layer
│   └── theme/              # Theme configuration
├── data/
│   ├── datasource/         # Data sources (API, Local)
│   ├── model/              # Data models (DTO)
│   └── repository/         # Repository implementation (langsung concrete)
├── domain/
│   └── entity/             # Business entities
└── presentation/
    ├── bloc/               # BLoC state management
    ├── pages/              # UI pages
    └── widget/             # Reusable widgets
```

### Layer Explanation:

#### 1️⃣ **Presentation Layer**
- **Pages**: UI screens
- **Widgets**: Reusable components
- **BLoC**: Business logic & state management
- Bertanggung jawab untuk UI dan user interaction

#### 2️⃣ **Data Layer**
- **DataSource**: Komunikasi dengan external sources (API, Database)
- **Model**: DTO (Data Transfer Object) dengan JSON serialization
- **Repository**: Bridge antara DataSource dan BLoC (concrete class, no interface)
- Bertanggung jawab untuk data management

#### 3️⃣ **Domain Layer**
- **Entity**: Plain Dart objects, business model
- Pure Dart, no dependencies
- Digunakan untuk transfer data antar layer

#### 4️⃣ **Core Layer**
- Shared utilities, constants, themes
- Dependency injection setup
- Navigation configuration

## 🚀 Getting Started

### Prerequisites
- Flutter SDK `^3.8.1`
- Dart SDK `^3.8.1`

### Installation

1. Clone repository
```bash
git clone https://github.com/rizaldinata/fe_wisma_amal_gorontalo.git
cd fe_wisma_amal_gorontalo
```

2. Install dependencies
```bash
flutter pub get
```

3. Generate code (AutoRoute, etc.)
```bash
dart run build_runner build
```

4. Run aplikasi
```bash
flutter run
```

## 📦 Tech Stack

- **State Management**: BLoC Pattern
- **Dependency Injection**: GetIt
- **Routing**: AutoRoute
- **Code Generation**: build_runner
- **UI**: Material 3 Design

## 📝 Development Guidelines

### Naming Convention
- File: `snake_case.dart`
- Class: `PascalCase`
- Variable/Function: `camelCase`
- Constant: `camelCase` atau `UPPER_CASE`

### Branch Strategy
- `main` - Production ready
- `develop` - Development branch
- `feature/*` - Feature development
- `bugfix/*` - Bug fixes

## ✅ TODO List

### Authentication
- [v] Setup project structure
- [ ] Implement theme system
- [v] Login page
- [v] Auth Guard
- [v] Register page
- [v] save token in secure storage
- [ ] form validation
- [ ] Forgot password
- [ ] Token management

## 🐛 Known Issues
- None

