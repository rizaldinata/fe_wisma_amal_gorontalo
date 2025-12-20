# Wisma Amal Gorontalo - Frontend

Aplikasi mobile untuk manajemen Wisma Amal Gorontalo.

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
│   ├── model/              # Data models
│   └── repository/         # Repository implementation
├── domain/
│   └── entity/             # Business entities
└── presentation/
    ├── bloc/               # BLoC state management
    ├── pages/              # UI pages
    └── widget/             # Reusable widgets
```

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
- [x] Setup project structure
- [ ] Implement theme system
- [x] Login page
- [x] Auth Guard
- [x] Register page
- [ ] Forgot password
- [ ] Token management

## 🐛 Known Issues
- None

