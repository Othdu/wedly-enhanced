# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Wedly is a Flutter wedding services marketplace app with dual role support (User and Provider). The app uses Clean Architecture with BLoC pattern for state management, currently running on mock data repositories designed for easy API integration.

## Development Commands

### Running the App
```bash
flutter run
```

### Building
```bash
# Android APK
flutter build apk

# iOS (requires macOS)
flutter build ios

# Web
flutter build web
```

### Dependencies
```bash
# Get dependencies
flutter pub get

# Update dependencies
flutter pub upgrade
```

### Testing & Analysis
```bash
# Run tests
flutter test

# Analyze code
flutter analyze

# Format code
dart format .
```

### Running Single Tests
```bash
flutter test test/widget_test.dart
```

## Architecture Overview

The app follows Clean Architecture with three main layers:

### Data Layer (`lib/data/`)
- **Models**: Immutable data classes using Equatable for value equality
  - `UserModel`: Represents user data with role (user/provider)
  - `ServiceModel`: Wedding service data (photography, catering, etc.)
- **Repositories**: Currently mock implementations with `Future.delayed()` to simulate network latency
  - `AuthRepository`: Authentication (login/logout/getCurrentUser)
  - `ServiceRepository`: Service data management (getServices/getServiceById/getServicesByCategory)

**IMPORTANT**: Repository method signatures must remain unchanged when adding real API integration to avoid breaking BLoCs.

### Logic Layer (`lib/logic/blocs/`)
- **BLoC Pattern**: State management using flutter_bloc
- **Three main BLoCs**:
  - `AuthBloc`: Manages authentication state and user sessions
  - `HomeBloc`: Manages home screen data (services list, categories)
  - `ServiceBloc`: Manages individual service operations
- **Pattern**: Each BLoC has separate files for events, states, and the bloc itself
- **State Flow**: Events → BLoC → Repository → New State → UI Update

### Presentation Layer (`lib/presentation/`)
- **Screens**: Organized by role (auth/user/provider)
  - Auth: Login, Signup, Role Selector
  - User: Home (service grid), Profile, Navigation Wrapper with bottom nav
  - Provider: Dashboard (services list), Profile, Navigation Wrapper with bottom nav
- **Widgets**: Reusable components like `ServiceCard`

### Core (`lib/core/`)
- **Dependency Injection**: GetIt setup in `injection_container.dart`
  - Repositories: Registered as lazy singletons
  - BLoCs: Registered as factories (new instance per use)
- **Theme**: Material Design 3 with light/dark theme support
- **Enums**: `UserRole` (user/provider), `AuthStatus`
- **Localization**: Configured for Arabic (primary) and English

### Routing (`lib/routes/`)
- **Current**: Using MaterialPageRoute with named routes
- **Helper Methods**: `AppRouter.goToLogin()`, `goToUserHome()`, `goToProviderHome()`
- **Note**: go_router is in dependencies but not fully implemented yet

## Key Architectural Patterns

### Role-Based Navigation
After login, users select a role (User or Provider) which determines their UI:
- **User Mode**: Service browsing, bookings, favorites
- **Provider Mode**: Service management, analytics, business dashboard

Navigation wrappers (`UserNavigationWrapper`, `ProviderNavigationWrapper`) handle bottom navigation for each role.

### State Management Flow
1. User interaction triggers an event
2. Event is added to BLoC
3. BLoC calls repository method
4. Repository returns data (currently mock)
5. BLoC emits new state
6. UI rebuilds based on new state

### Dependency Injection Pattern
```dart
// Repositories are singletons (shared instance)
getIt.registerLazySingleton<AuthRepository>(() => AuthRepository());

// BLoCs are factories (new instance each time)
getIt.registerFactory<AuthBloc>(() => AuthBloc(authRepository: getIt()));
```

BLoCs are provided at app level in `main.dart` using `MultiBlocProvider`.

## API Integration Readiness

The codebase is structured for seamless API integration:

1. **Mock Data**: All repositories use `Future.delayed()` to simulate async operations
2. **Repository Pattern**: BLoCs depend on repository interfaces, not implementations
3. **Mock Data Inventory**: See `API_MOCK_DATA_INVENTORY.md` for comprehensive documentation of ALL mock data
4. **Next Steps**: Replace mock repository implementations with HTTP calls
5. **Guidance**: See `API_INTEGRATION_PROMPT.md` for detailed integration instructions

### Mock Data Documentation

**IMPORTANT**: Before implementing API integration, refer to `API_MOCK_DATA_INVENTORY.md` which contains:
- Complete inventory of all 6 mock services and 7 mock bookings
- All hardcoded profile data (phone: '+20 100 123 4567', city: 'القاهرة')
- Network delay timings for each repository method
- Full API endpoint specifications with request/response formats
- 30-step API integration checklist
- List of all TODO comments requiring API implementation

**Mock Data Overview**:
- **Services**: 6 hardcoded wedding services (Photography, Catering, Decoration, Entertainment, Venue, Beauty)
- **Bookings**: 7 hardcoded bookings in Arabic with various statuses
- **Auth**: Mock login accepts ANY credentials and generates fake user IDs
- **Images**: 13 Unsplash URLs for service/booking images

**Global Mock Mode**: Set `_useMockData = false` in `lib/core/di/injection_container.dart` to switch to real API

When integrating APIs:
- Add `dio` or `http` package for networking
- Add `json_annotation` and `json_serializable` for JSON handling
- Create API service layer in `lib/data/services/`
- Add token storage using `flutter_secure_storage`
- Implement error handling and network interceptors
- Keep repository method signatures unchanged
- Update API base URL in `lib/data/services/api_constants.dart`
- Add `phone` and `city` fields to `UserModel`

## Testing Credentials

For mock authentication:
- Any email format with password (6+ characters)
- Or use "Use Demo Credentials" button on login screen

## Common Development Patterns

### Adding a New BLoC
1. Create folder in `lib/logic/blocs/[feature]/`
2. Create three files: `[feature]_bloc.dart`, `[feature]_event.dart`, `[feature]_state.dart`
3. Register BLoC as factory in `injection_container.dart`
4. Provide BLoC in widget tree or at app level in `main.dart`

### Adding a New Repository
1. Create class in `lib/data/repositories/`
2. Define async methods that return `Future<T>`
3. Register as lazy singleton in `injection_container.dart`
4. Inject into BLoCs that need it

### Adding a New Screen
1. Create screen widget in `lib/presentation/screens/[role]/`
2. Add route constant to `AppRouter`
3. Add route mapping in `onGenerateRoute`
4. Create navigation helper method if needed

## Localization

App is configured for Arabic (default) and English:
- Locale set to `ar_SA` in `main.dart:43`
- Flutter's localization delegates included
- RTL support enabled through Material localization

## Important Notes

- **No Real Backend**: All data is mock. Authentication always succeeds with any credentials.
- **Role Switching**: Users can switch between User/Provider mode via Role Selector for testing.
- **State Persistence**: No local storage yet; app state resets on restart.
- **Image Loading**: Service images use Unsplash URLs; no caching implemented yet.
- **Navigation**: Currently using MaterialPageRoute; can migrate to go_router for advanced features.
- **Testing**: Minimal test coverage; only default widget test exists.
- this app i arabic not english so everythig goes from right to left