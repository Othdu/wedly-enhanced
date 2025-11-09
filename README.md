# Wedly - Flutter App

A clean architecture Flutter application built with BLoC pattern for state management, featuring role-based navigation for Users and Providers.

## Architecture

The project follows a clean architecture pattern with clear separation of concerns:

```
lib/
├── core/                    # Core utilities and configurations
│   ├── constants/          # App constants
│   ├── di/                 # Dependency injection setup
│   ├── theme/              # App theming
│   └── utils/              # Utility classes and enums
├── data/                   # Data layer
│   ├── models/             # Data models
│   └── repositories/       # Repository implementations (mocked for now)
├── logic/                  # Business logic layer
│   └── blocs/              # BLoC state management
│       ├── auth/           # Authentication BLoC
│       ├── home/           # Home screen BLoC
│       └── service/        # Service management BLoC
├── presentation/           # Presentation layer
│   ├── screens/           # Screen widgets
│   │   ├── auth/          # Authentication screens
│   │   ├── user/          # User role screens
│   │   └── provider/      # Provider role screens
│   └── widgets/           # Reusable widgets
├── routes/                 # Navigation and routing
└── main.dart              # App entry point
```

## Features

### Current Implementation

- ✅ Clean architecture with BLoC pattern
- ✅ Role-based navigation (User & Provider)
- ✅ Authentication flow with mock login
- ✅ Dynamic home widgets with service cards
- ✅ Mock data repositories (ready for API integration)
- ✅ Dependency injection with GetIt
- ✅ Material Design 3 theming

### User Flow

1. **Login Screen**: Users can login with email/password (mock authentication)
2. **Role Selector**: After login, users can choose between User or Provider mode
3. **User Mode**: 
   - Home screen with service grid
   - Profile screen
   - Bottom navigation (Home, Bookings, Favorites, Profile)
4. **Provider Mode**:
   - Dashboard with services list
   - Profile screen
   - Bottom navigation (Dashboard, Services, Bookings, Analytics, Profile)

### Service Cards

The app includes a reusable `ServiceCard` widget that displays:
- Service image
- Service name and description
- Price (if available)
- Category badge

Services are currently loaded from mock data in `ServiceRepository` but are structured to easily swap with real API calls.

## Getting Started

### Prerequisites

- Flutter SDK (3.9.2 or higher)
- Dart SDK

### Installation

1. Clone the repository
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run the app:
   ```bash
   flutter run
   ```

### Testing Login

For testing purposes, you can:
- Enter any email and password (minimum 6 characters)
- Or click "Use Demo Credentials" button to auto-fill

## Project Structure Details

### Data Layer

- **Models**: `UserModel`, `ServiceModel` - Data classes with Equatable
- **Repositories**: Mock implementations that simulate API calls with delays
  - `AuthRepository`: Handles authentication (mock)
  - `ServiceRepository`: Manages services data (mock)

### Logic Layer

- **BLoCs**: State management using flutter_bloc
  - `AuthBloc`: Manages authentication state
  - `HomeBloc`: Manages home screen data (services, categories)
  - `ServiceBloc`: Manages individual service operations

### Presentation Layer

- **Screens**: Organized by feature/role
- **Widgets**: Reusable components like `ServiceCard`

## Future API Integration

The architecture is designed for easy API integration:

1. **Replace Mock Repositories**: Update `AuthRepository` and `ServiceRepository` to make real HTTP calls
2. **Add API Service Layer**: Create API service classes in `data/services/`
3. **Update Models**: Add JSON serialization/deserialization
4. **Error Handling**: Enhance error states in BLoCs

The repository pattern ensures that BLoCs don't need to change when switching from mock to real APIs.

## Dependencies

- `flutter_bloc`: State management
- `equatable`: Value equality for models
- `get_it`: Dependency injection
- `go_router`: Navigation (configured but using MaterialPageRoute for now)

## Development Notes

- All API calls are currently mocked with `Future.delayed()` to simulate network latency
- Service data is hardcoded in `ServiceRepository` but structured to match expected API response format
- Role switching is available via the Role Selector screen for testing
- Navigation uses MaterialPageRoute; can be upgraded to go_router for more advanced routing

## Next Steps

1. Implement remaining screens (Bookings, Favorites, Analytics)
2. Add service detail screens
3. Integrate real API endpoints
4. Add local storage/caching
5. Implement search and filtering
6. Add image caching for service images
