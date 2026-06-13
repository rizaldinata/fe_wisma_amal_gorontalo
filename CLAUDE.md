# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Flutter (Material 3) frontend for **Wisma Amal Gorontalo** — a dormitory management system. Targets admin staff and residents. Connects to a Laravel modular monolith backend via REST API.

## Common Commands

```bash
# Install dependencies
flutter pub get

# Run app (dev mode, connects to localhost:8000)
flutter run

# Regenerate route files after adding/editing @AutoRoute annotations
dart run build_runner build --delete-conflicting-outputs

# Run tests
flutter test

# Lint check
flutter analyze
```

> After any change to `auto_route.dart` route definitions, always run `build_runner` to regenerate `auto_route.gr.dart`. Never edit `.gr.dart` manually.

## Architecture

Semi-Clean Architecture with strict dependency direction: **Presentation → Domain ← Data**. Domain has no external dependencies.

```
lib/
├── core/               # DI, routing, theme, constants, network/storage services
├── domain/
│   ├── entity/         # Pure Dart business objects (by feature folder)
│   ├── repository/     # Abstract interfaces only
│   └── usecase/        # UseCase<T, Params> — one class per operation
├── data/
│   ├── datasource/     # Dio HTTP calls
│   ├── model/          # JSON DTOs with toEntity() method
│   └── repository/     # Concrete implementations of domain interfaces
└── presentation/
    ├── bloc/           # BLoC/Cubit (by feature folder)
    ├── pages/          # Screens (by feature folder)
    └── widget/         # Reusable UI components
```

**Critical rules:**
- BLoC must only call **UseCases**, never repositories or datasources directly
- Domain layer must stay pure Dart — no Flutter, Dio, or any external imports
- Every Model must have `toEntity()` — never return raw Models to BLoC

## Adding a New Feature (Checklist)

1. **Domain**: `entity/` → `repository/` (abstract) → `usecase/<feature>/`
2. **Data**: `model/` (with `toEntity()`) → `datasource/` → `repository/` (impl)
3. **DI** in `lib/core/dependency_injection/`:
   - `datasource.dart` → register datasource
   - `repository.dart` → bind interface to impl
   - `usecase.dart` → register usecase
   - `bloc.dart` → register BLoC
4. **Presentation**: BLoC (event + state) → Page → Widget
5. **Navigation**: add `@AutoRoute` in `auto_route.dart`, add constant in `route_constant.dart`, then run `build_runner`

## Key Files

| File | Purpose |
|------|---------|
| `lib/core/constant/endpoint_constant.dart` | All API endpoint strings |
| `lib/core/constant/route_constant.dart` | All named route strings |
| `lib/core/constant/permission_key.dart` | All RBAC permission key strings |
| `lib/core/constant/storage_constant.dart` | Secure storage key strings |
| `lib/core/services/network/api_config.dart` | Base URL config (dev vs prod) |
| `lib/core/services/network/interceptor.dart` | Auto-injects Bearer token, handles 401 |
| `lib/core/navigation/auto_route.dart` | Route definitions (edit here, then build_runner) |
| `lib/core/dependency_injection/dependency_injection.dart` | GetIt setup entrypoint |

## Network & Auth

- **Base URL dev**: `http://127.0.0.1:8000/api`
- **Base URL prod**: `https://alfian.taild9066e.ts.net/be/api`
- Switch via `ApiConfig.currentMode` (`DEVELOP` / `PRODUCTION`)
- Token stored in `flutter_secure_storage` under key `StorageConstant.token`
- `ApiInterceptor` auto-attaches `Authorization: Bearer <token>` on every non-public request
- On HTTP 401 → `SessionExpiredEvent` is dispatched to `AuthBloc` (auto logout)

## State Management Pattern

```dart
// BLoC receives UseCases via constructor (injected by get_it)
class InvoiceBloc extends Bloc<InvoiceEvent, InvoiceState> {
  final GetInvoiceListUseCase getInvoiceList;
  InvoiceBloc({required this.getInvoiceList}) : super(InvoiceInitial());
}

// UI consumes state
BlocBuilder<InvoiceBloc, InvoiceState>(
  builder: (context, state) { ... }
)
```

## Dependency Injection

All registrations use `serviceLocator` (GetIt singleton) initialized in `dependency_injection.dart`. Use `serviceLocator<T>()` to resolve anywhere. Register in this order: datasource → repository → usecase → bloc.

## Permissions (RBAC)

Permission keys are defined in `PermissionKeys` class (`permission_key.dart`). Check before rendering sensitive UI by reading the permissions list from `StorageConstant.permissions`. Finance-related keys: `financeDashboardView`, `financePaymentView`, `financePaymentVerify`, `financeInvoiceView`, `financeInvoiceCreate`, `financeExpenseView`, etc.

## Styling

- Theme tokens: `lib/core/theme/` — use `AppTheme`, `AppTextTheme`, `ColorSchemes`
- Fonts: `GoogleFonts` (from `google_fonts` package) — do not hardcode font families
- Icons: Material Icons (`uses-material-design: true` in pubspec)

## API Response Shape

Backend returns `{status: true, message: "...", data: ...}` for success. Index/paginated endpoints return `{success: true, message: "...", data: [...], links: {...}, meta: {...}}`. Always check `status`/`success` field before accessing `data`.
