# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Selly Clone is a Flutter-based Android application for Southeast Asian online sellers, featuring an integrated keyboard overlay system for WhatsApp/Instagram, invoice management, and order processing.

## Core Architecture

**Clean Architecture with BLoC Pattern:**
- `lib/domain/` - Business logic entities, repositories, and use cases
- `lib/data/` - Repository implementations, models, and data sources (Supabase remote, SQLite local)
- `lib/presentation/` - UI screens, widgets, and BLoC state management
- `lib/core/` - Shared utilities, configurations, and constants
- `lib/services/` - External service integrations (AdMob, shipping, PDF)

**Key Technologies:**
- **Flutter 3.x** with BLoC pattern for state management
- **Supabase** as primary backend (PostgreSQL with real-time sync)
- **SQLite** for local storage and offline capabilities
- **GetIt** for dependency injection (configured in `injection_container.dart`)

## Essential Commands

### Development
```bash
flutter pub get                    # Install dependencies
dart run build_runner build --delete-conflicting-outputs  # Generate code (required after entity changes)
flutter run                       # Start development server
flutter run --dart-define=APP_ENV=development  # Run with environment variables
```

### Quality Assurance
```bash
flutter analyze                   # Static code analysis (must pass for CI)
flutter test                      # Run all unit tests
flutter test --coverage           # Run tests with coverage report
flutter test test/specific_test.dart  # Run single test file
```

### Building
```bash
flutter build apk --release       # Production APK
flutter build appbundle --release # App Bundle for Play Store
# Production build with environment variables:
flutter build apk --release --dart-define=SUPABASE_URL=your_url --dart-define=SUPABASE_ANON_KEY=your_key
```

### Integration Testing
```bash
flutter drive --driver=test_driver/integration_test.dart --target=integration_test/dashboard_test.dart
```

## Required Configuration

Before development, configure these API keys:

1. **RajaOngkir API** (shipping calculator): Update `lib/core/config/app_config.dart`
2. **Supabase**: Set URL and anon key in `lib/core/config/supabase_config.dart`
3. **AdMob**: Configure IDs in `lib/core/config/admob_config.dart`

## Database Schema

Supabase tables with Row Level Security enabled:
- `users` - User profiles and business info
- `templates` - Message templates for keyboard
- `products` - Product catalog with stock
- `invoices` - Sales invoices with JSON items field

## Key Features Architecture

**Custom Keyboard Integration:**
- `lib/presentation/screens/keyboard/keyboard_view.dart` - Main keyboard interface
- Templates system for quick responses in chat apps

**Invoice System:**
- PDF generation via `lib/services/pdf/pdf_generator.dart`
- Invoice BLoC manages state in `lib/presentation/bloc/invoice/`

**Shipping Calculator:**
- RajaOngkir integration in `lib/services/shipping/rajaongkir_api.dart`
- Support for JNE, J&T, SiCepat carriers

## Dependency Injection & State Management

**GetIt Configuration** (`lib/injection_container.dart`):
- **Data Sources**: `PreferencesDatasource`, `SqliteDatasource`, `SupabaseDatasource`
- **Repositories**: Abstract interfaces with concrete implementations
- **Use Cases**: Single-responsibility business logic units
- **Services**: `PdfGenerator`, `ShippingCalculator`, `AdMobService`
- **BLoCs**: Factory registration for proper disposal

**BLoC Pattern Implementation**:
- Events define user actions (e.g., `LoginEvent`, `CreateInvoiceEvent`)
- States represent UI states (loading, success, error)
- BLoCs handle business logic and emit states
- Repository pattern abstracts data sources
- Use Cases encapsulate single business operations

Main BLoCs: `AuthBloc`, `InvoiceBloc`

## Testing Architecture

**Unit Tests** (`test/` directory):
- Core utilities: `currency_formatter_test.dart`, `validators_test.dart`, `date_formatter_test.dart`
- Domain entities: `invoice_test.dart`
- Services: `shipping_calculator_test.dart`

**Integration Tests** (`integration_test/` directory):
- Dashboard flow testing: `dashboard_test.dart`
- Run with: `flutter drive --driver=test_driver/integration_test.dart --target=integration_test/dashboard_test.dart`

## CI/CD Pipeline

GitHub Actions workflow in `.github/workflows/flutter_ci.yml`:
- Flutter 3.22.3 stable channel
- Automated testing with coverage reports
- APK builds with environment variables
- Integration testing with local Supabase
- Artifacts upload for releases

## Important Notes

- App uses Indonesian locale (`id_ID`) for date formatting
- AdMob integration is non-blocking and handles failures gracefully
- Supabase is initialized before app startup in `main.dart`
- All external API failures should be handled gracefully for offline functionality
- Build runner is required after entity changes: `dart run build_runner build --delete-conflicting-outputs`
- CI requires `flutter analyze` to pass without warnings