# Wedly - Wedding Services Marketplace

A comprehensive Flutter wedding services marketplace connecting couples with service providers. Built with Clean Architecture and BLoC pattern, featuring dual-role support for Users and Providers.

![Flutter](https://img.shields.io/badge/Flutter-3.9.2+-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?logo=dart&logoColor=white)
![BLoC](https://img.shields.io/badge/State-BLoC-brightgreen)
![License](https://img.shields.io/badge/License-MIT-yellow)

---

## Overview

Wedly enables couples to discover, compare, and book wedding services while allowing providers to showcase and manage their offerings. The app supports Arabic as the primary language with full RTL layout.

### Key Highlights

- Clean Architecture with clear separation of concerns
- BLoC Pattern for predictable state management
- Dual Role System (User & Provider modes)
- Arabic-First Design with RTL support
- Real API Integration with Dio HTTP client
- Material Design 3 with gold accent theming
- Social Authentication (Google, Facebook)
- OpenStreetMap Integration for venue locations
- Offline-aware with connectivity monitoring

---

## Features

### User Features

- **Home Dashboard** - Banners carousel, categories grid, services list, wedding countdown timer
- **Service Browsing** - Filter by category, city, and price range
- **Search** - Search services with suggestions, recent searches, and category filters
- **Venue Listings** - Dedicated venue browsing with map integration, capacity info, and pricing
- **Dynamic Booking** - Book services with forms that adapt based on service type
- **Shopping Cart** - Manage multiple bookings before checkout
- **Payment Flow** - Multiple payment methods with confirmation
- **Reviews & Ratings** - Submit and view 5-star ratings with comments
- **Bookings Management** - Track booking status (pending/confirmed/completed/cancelled)
- **Notifications** - Receive updates on bookings, offers, and reminders
- **Address Management** - Save and manage delivery addresses
- **Profile Management** - Edit profile, change password, upload profile picture
- **Promotional Offers** - View discounts and special deals

### Provider Features

- **Service Management** - Add, edit, delete, and toggle service availability
- **Venue Management** - Specialized forms for venue details (capacity, pricing tiers)
- **Bookings Dashboard** - View and manage incoming bookings by status
- **Booking Actions** - Accept, reject, or mark bookings as complete
- **Profile Management** - Business profile with document uploads
- **Analytics** - Track service performance (placeholder for future metrics)

### Authentication

- Email/Password login and registration
- Social login (Google, Facebook)
- OTP verification for signup
- Password reset with OTP
- Role selection (User or Provider)
- Session management with automatic token refresh

---

## Architecture

### Project Structure

```text
lib/
├── core/
│   ├── constants/          # Colors, strings, app constants
│   ├── di/                 # Dependency injection (GetIt)
│   ├── services/           # Connectivity, push notifications
│   ├── theme/              # Material Design 3 theming
│   └── utils/              # Enums, helpers, logger, permissions
├── data/
│   ├── models/             # Data classes (Equatable)
│   ├── repositories/       # Data access layer
│   └── services/           # API client, token manager, social auth
├── logic/
│   └── blocs/              # BLoC state management
│       ├── auth/
│       ├── home/
│       ├── service/
│       ├── venue/
│       ├── booking/
│       ├── cart/
│       ├── banner/
│       ├── review/
│       ├── search/
│       ├── notification/
│       ├── address/
│       └── provider_service/
├── presentation/
│   ├── screens/
│   │   ├── auth/           # Login, signup, OTP, password reset
│   │   ├── user/           # User role screens (25+ screens)
│   │   ├── provider/       # Provider role screens (10+ screens)
│   │   ├── splash/
│   │   └── onboarding/
│   └── widgets/            # 25+ reusable components
├── routes/
│   └── app_router.dart     # Centralized navigation
└── main.dart
```

### Data Models

| Model | Description |
| ----- | ----------- |
| UserModel | User data with role, profile info, phone, city |
| ServiceModel | Service with name, price, category, rating, location, dynamic sections |
| VenueModel | Venue with capacity, chair count, morning/evening pricing |
| BookingModel | Booking with status, amount, customer info, review |
| CartItemModel | Cart item with service, date, time, prices |
| ReviewModel | 5-star rating with comment and user info |
| BannerModel | Promotional banner with image and optional link |
| OfferModel | Promotional offer with discount and expiry |
| CategoryModel | Service category with name and image |
| AddressModel | User address with city, district, building |
| NotificationModel | Notification with type and timestamp |
| CountdownModel | Wedding countdown timer |

### Repositories

| Repository | Purpose |
| ---------- | ------- |
| AuthRepository | Login, register, OTP, password reset, profile |
| ServiceRepository | Services CRUD, categories, search, filtering |
| VenueRepository | Venues list and details |
| BookingRepository | Create/update bookings, status management |
| CartRepository | Shopping cart operations with persistence |
| ReviewRepository | Reviews CRUD for services and venues |
| BannerRepository | Promotional banners |
| OfferRepository | Promotional offers |
| NotificationRepository | User notifications |
| CategoryRepository | Service categories |
| AddressRepository | User addresses, cities, districts |

### BLoCs (State Management)

| BLoC | Responsibility |
| ---- | -------------- |
| AuthBloc | Authentication, session, profile updates |
| HomeBloc | Home screen data, layout configuration |
| ServiceBloc | Service details, filtering, pagination |
| VenueBloc | Venue list and details |
| BookingBloc | Booking operations for user/provider |
| CartBloc | Shopping cart state |
| ReviewBloc | Reviews submission and display |
| BannerBloc | Promotional banners |
| NotificationBloc | Notifications, unread count |
| ProviderServiceBloc | Provider service management |
| SearchBloc | Search functionality with suggestions |
| AddressBloc | Address management |

---

## Screens

### Authentication (7 screens)

- Login with demo credentials option
- Signup with phone and city
- OTP verification (6-digit input)
- Forgot password (3-step flow)
- Provider document upload
- Role selector
- Signup success

### User Role (20+ screens)

- Home with dynamic widgets
- Navigation wrapper with bottom nav
- Profile view and edit
- Search with filters
- Bookings list with status tabs
- Cart management
- Category services list
- Dynamic service booking
- Venue booking with time slots
- Venue details with map
- Venues list
- Payment method selection
- Payment confirmation
- Payment success
- Notifications list
- Offers list
- Address management
- Change password
- Help and support
- Terms and conditions

### Provider Role (10+ screens)

- Services list management
- Add new service
- Edit general service
- Edit venue service
- Bookings list with status tabs
- Booking details with actions
- Profile view and edit

---

## Getting Started

### Prerequisites

```bash
Flutter SDK: >=3.9.2
Dart SDK: >=3.0.0
```

### Installation

1. Clone the repository

```bash
git clone https://github.com/othdu/wedly-enhanced.git
cd wedly-enhanced
```

2. Install dependencies

```bash
flutter pub get
```

3. Run the app

```bash
flutter run
```

4. Build for production

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS (requires macOS)
flutter build ios --release

# Web
flutter build web --release
```

### Development Commands

```bash
# Analyze code
flutter analyze

# Format code
dart format .

# Run tests
flutter test

# Generate JSON serialization code
flutter pub run build_runner build
```

---

## API Integration

The app uses Dio HTTP client with automatic token refresh and error handling.

### Configuration

Update the base URL in `lib/data/services/api_constants.dart`:

```dart
class ApiConstants {
  static const String baseUrl = 'https://your-api-domain.com/api';
}
```

### API Endpoints

| Endpoint | Method | Description |
| -------- | ------ | ----------- |
| /auth/login | POST | User login |
| /auth/register | POST | User registration |
| /auth/verify-otp | POST | OTP verification |
| /auth/forgot-password | POST | Password reset |
| /services | GET | Get all services |
| /services/{id} | GET | Get service details |
| /services/category/{id} | GET | Services by category |
| /venues | GET | Get all venues |
| /venues/{id} | GET | Get venue details |
| /bookings | GET/POST | User bookings |
| /bookings/{id}/status | PUT | Update booking status |
| /cart | GET/POST/DELETE | Shopping cart |
| /reviews | GET/POST | Reviews |
| /banners | GET | Promotional banners |
| /offers | GET | Promotional offers |
| /notifications | GET | User notifications |
| /users/profile | GET/PUT | User profile |
| /users/profile/image | POST | Profile image upload |

### Mock Mode

Toggle between mock and real API in `lib/core/di/injection_container.dart`:

```dart
const bool _useMockData = false; // Set to true for mock data
```

---

## Dependencies

### Core

| Package | Version | Purpose |
| ------- | ------- | ------- |
| flutter_bloc | ^8.1.6 | State management |
| equatable | ^2.0.5 | Value equality |
| get_it | ^7.7.0 | Dependency injection |
| go_router | ^14.2.0 | Navigation |

### Networking

| Package | Version | Purpose |
| ------- | ------- | ------- |
| dio | ^5.9.0 | HTTP client |
| pretty_dio_logger | ^1.3.1 | Request logging |
| connectivity_plus | ^7.0.0 | Network status |

### Storage & Auth

| Package | Version | Purpose |
| ------- | ------- | ------- |
| flutter_secure_storage | ^9.2.4 | Secure token storage |
| shared_preferences | ^2.5.3 | Local preferences |
| google_sign_in | ^6.2.1 | Google authentication |
| flutter_facebook_auth | ^7.1.1 | Facebook authentication |

### UI & Media

| Package | Version | Purpose |
| ------- | ------- | ------- |
| cached_network_image | ^3.4.1 | Image caching |
| image_picker | ^1.2.0 | Photo selection |
| flutter_svg | ^2.0.10 | SVG support |
| shimmer | ^3.0.0 | Loading effects |
| google_fonts | ^6.2.0 | Custom fonts |

### Maps & Location

| Package | Version | Purpose |
| ------- | ------- | ------- |
| flutter_map | ^8.2.2 | OpenStreetMap integration |
| latlong2 | ^0.9.1 | Coordinates handling |
| geolocator | ^14.0.2 | Location services |

---

## Theming & Localization

### Material Design 3

- Gold accent color (#D4AF37)
- Light and dark mode support
- Consistent spacing and typography

### Localization

- Primary Language: Arabic (ar_SA)
- Full RTL layout support
- English fallback configured
- 27 Egyptian governorates translated

---

## Widgets Library

The app includes 25+ reusable widgets:

- ServiceCard, VenueCard, CategoryCard
- BannersCarousel, OffersCarousel
- CategoriesGrid, ServicesList
- ProfilePictureWidget with upload
- CachedImageWidget, SkeletonImage
- CountdownTimerWidget
- BookingCard, StatusBadge
- ReviewBottomSheet
- ErrorView, OfflineIndicator
- NotificationBadge
- AuthSessionListener
- WidgetFactory for dynamic UI

---

## Project Status

### Completed

- [x] Clean architecture setup
- [x] Authentication flow with social login
- [x] OTP verification and password reset
- [x] Role-based navigation (User/Provider)
- [x] Home screen with dynamic widgets
- [x] Service browsing and details
- [x] Venue listings with map integration
- [x] Dynamic booking system
- [x] Shopping cart
- [x] Payment flow
- [x] Reviews and ratings
- [x] Notifications system
- [x] Profile management
- [x] Address management
- [x] Search with filters
- [x] Provider service management
- [x] Provider booking management
- [x] Offline connectivity monitoring

### In Progress

- [ ] Push notifications (FCM)
- [ ] Payment gateway integration


---

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## License

This project is licensed under the MIT License - see the LICENSE file for details.

---

## Support

- Issues: [GitHub Issues](https://github.com/othdu/wedly-enhanced/issues)
- Email: moh.mus2019@gmail.com

---

Built with Flutter
