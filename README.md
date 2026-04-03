# Wedly

Your favourite wedding planner -- a Flutter marketplace connecting couples with wedding service providers across Egypt.

![Flutter](https://img.shields.io/badge/Flutter-3.9.2+-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?logo=dart&logoColor=white)
![BLoC](https://img.shields.io/badge/State-BLoC_Pattern-brightgreen)
![Architecture](https://img.shields.io/badge/Arch-Clean_Architecture-blueviolet)
![Platform](https://img.shields.io/badge/Platform-Android_|_iOS_|_Web-orange)
![Language](https://img.shields.io/badge/Language-Arabic_RTL-red)

---

## What is Wedly?

Wedly is a dual-role wedding services marketplace built for the Egyptian market. Couples browse, compare, and book wedding services (photographers, venues, caterers, makeup artists, decorators, and more), while providers manage their listings, bookings, and business profiles -- all in Arabic with full RTL support.

### Core Capabilities

- **Dual Role System** -- Users switch between Customer and Provider modes from a single account
- **Arabic-First** -- Primary locale is `ar_SA` with complete RTL layout, Arabic error messages, and localized content
- **Real API Backend** -- Connected to a live API at `api.wedlyinfo.com` with Dio, automatic token refresh, and TLS retry
- **Paymob Payments** -- Integrated payment flow via Paymob WebView
- **Social Auth** -- Google Sign-In and Sign in with Apple
- **Offline-Aware** -- Connectivity monitoring with offline banners and graceful degradation
- **Material Design 3** -- Gold accent theme (#D4AF37) with Readex Pro typography

---

## Screenshots

> _Add screenshots here_

---

## Getting Started

### Prerequisites

| Tool        | Version   |
| ----------- | --------- |
| Flutter SDK | >= 3.9.2  |
| Dart SDK    | >= 3.0.0  |
| Android SDK | API 21+   |
| Xcode       | 14+ (iOS) |

### Installation

```bash
# Clone the repository
git clone https://github.com/othdu/wedly-enhanced.git
cd wedly-enhanced

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### Build for Production

```bash
# Android APK
flutter build apk --release

# Android App Bundle (Play Store)
flutter build appbundle --release

# iOS (requires macOS + Xcode)
flutter build ios --release

# Web
flutter build web --release
```

### Development Commands

```bash
# Analyze code for issues
flutter analyze

# Format all Dart files
dart format .

# Run tests
flutter test

# Generate JSON serialization code
dart run build_runner build --delete-conflicting-outputs
```

---

## Architecture

The app follows **Clean Architecture** with three distinct layers, ensuring separation of concerns and testability.

```
lib/
├── main.dart                          # App entry point, MultiBlocProvider setup
│
├── core/                              # Cross-cutting concerns
│   ├── constants/                     # AppColors, AppConstants, AppStrings
│   ├── di/                            # GetIt dependency injection container
│   │   └── injection_container.dart   # All singletons and factories
│   ├── services/                      # Connectivity, push notifications
│   ├── theme/                         # Material 3 light/dark themes
│   └── utils/                         # Enums, error handler, logger, helpers
│
├── data/                              # Data layer
│   ├── models/                        # 14 immutable data classes (Equatable)
│   ├── repositories/                  # 12 repositories (data access)
│   └── services/                      # ApiClient, TokenManager, API constants
│
├── logic/                             # Business logic layer
│   └── blocs/                         # 12 BLoCs (events + states + bloc)
│       ├── auth/                      # Authentication & session management
│       ├── home/                      # Home screen data orchestration
│       ├── service/                   # Service details & filtering
│       ├── venue/                     # Venue listings
│       ├── booking/                   # Booking lifecycle
│       ├── cart/                      # Shopping cart operations
│       ├── review/                    # Ratings & reviews
│       ├── banner/                    # Promotional banners
│       ├── notification/              # User notifications
│       ├── search/                    # Search with suggestions
│       ├── address/                   # Address management
│       └── provider_service/          # Provider CRUD operations
│
├── presentation/                      # UI layer
│   ├── screens/                       # 42 screens across 5 sections
│   │   ├── auth/                      # Login, signup, OTP, password reset (7)
│   │   ├── user/                      # Customer-facing screens (22)
│   │   ├── provider/                  # Provider-facing screens (11)
│   │   ├── splash/                    # Animated splash screen
│   │   └── onboarding/               # First-launch onboarding
│   └── widgets/                       # 25 reusable components
│
└── routes/
    └── app_router.dart                # Centralized named routing
```

**152 Dart files** total across the project.

### State Management Flow

```
User Action → Event → BLoC → Repository → API/Cache → New State → UI Rebuild
```

Each BLoC follows a strict pattern:
1. UI dispatches an **Event**
2. BLoC processes it, calls the **Repository**
3. Repository communicates with the **ApiClient**
4. BLoC emits a new **State**
5. UI rebuilds via `BlocBuilder` / `BlocListener`

### Dependency Injection

All dependencies are wired through **GetIt** in `injection_container.dart`:

- **Core services** (FlutterSecureStorage, TokenManager, ApiClient) -- lazy singletons
- **Repositories** (12 total) -- lazy singletons, injected with ApiClient
- **BLoCs** (12 total) -- factories (new instance per widget tree scope)

---

## Features

### Authentication (7 screens)

| Feature                | Description                                         |
| ---------------------- | --------------------------------------------------- |
| Email/Password Login   | Standard login with validation                      |
| Social Login           | Google Sign-In and Sign in with Apple               |
| Registration           | User or Provider signup with phone and city          |
| OTP Verification       | 6-digit code verification for email confirmation    |
| Forgot Password        | 3-step flow: email → OTP → new password             |
| Provider Documents     | Document upload during provider registration        |
| Role Selector          | Choose between User and Provider mode after login   |
| Session Management     | JWT access/refresh tokens with automatic renewal    |
| Provider Pending State | Providers see a pending message until admin approval |

### User Mode (22 screens)

| Feature                 | Description                                                    |
| ----------------------- | -------------------------------------------------------------- |
| Home Dashboard          | Banner carousel, wedding countdown, category grid              |
| Guest Browsing          | Browse categories and services without logging in              |
| Service Categories      | Grid of wedding service categories with images                 |
| Category Services List  | Filtered service listings within a category                    |
| Dynamic Service Booking | Booking forms that adapt based on service type and sections    |
| Venue Listings          | Browse venues with filtering                                   |
| Venue Details           | Photos, capacity, pricing tiers, map location, reviews         |
| Venue Booking           | Book morning or evening time slots with date picker            |
| Shopping Cart           | Multi-item cart with price validation and time slot management |
| Payment Method          | Payment method selection screen                                |
| Payment (Paymob)       | WebView-based Paymob payment integration                       |
| Payment Confirmation    | Order summary and confirmation                                 |
| My Bookings             | Booking history with status tabs (pending/confirmed/completed) |
| Search                  | Service search with suggestions and filters                    |
| Notifications           | Notification list with unread badge count                      |
| Offers                  | Promotional offers and discounts list                          |
| Profile                 | View profile with settings menu                                |
| Edit Profile            | Update name, phone, city, profile picture                      |
| Manage Event            | Set/edit/delete wedding date and event name                    |
| Change Password         | Current + new password form                                    |
| Address Management      | Save and manage delivery/event addresses                       |
| Help & Support          | FAQ and WhatsApp support link                                  |
| Terms & Conditions      | Legal terms display                                            |

### Provider Mode (11 screens)

| Feature                   | Description                                          |
| ------------------------- | ---------------------------------------------------- |
| Services Dashboard        | List of provider's services with status toggle       |
| Add Service               | Create new service listing with photos and details   |
| Edit Service              | Update general service details                       |
| Edit Venue Service        | Specialized venue editing (capacity, pricing tiers)  |
| Bookings List             | Incoming bookings organized by status                |
| Booking Details           | Full booking info with accept/reject/complete actions|
| Confirmed Bookings        | Filtered view of confirmed bookings                  |
| Profile                   | Business profile view                                |
| Edit Profile              | Update business information                          |
| Navigation Wrapper        | Bottom navigation for provider screens               |

---

## Data Models

| Model              | Key Fields                                                         |
| ------------------ | ------------------------------------------------------------------ |
| `UserModel`        | id, name, email, phone, city, role, profileImageUrl, weddingDate   |
| `ServiceModel`     | id, name, price, category, rating, location, morningPrice, eveningPrice, dynamicSections |
| `VenueModel`       | id, name, capacity, chairCount, morningPrice, eveningPrice, location |
| `BookingModel`     | id, status, amount, date, timeSlot, customerInfo, service          |
| `CartItemModel`    | id, service, date, timeSlot, servicePrice, totalPrice              |
| `ReviewModel`      | id, rating (1-5), comment, userId, createdAt                      |
| `CategoryModel`    | id, name, nameAr, image                                           |
| `BannerModel`      | id, image, title, link, isActive                                   |
| `OfferModel`       | id, discount, expiry, serviceId                                    |
| `NotificationModel`| id, type, message, isRead, createdAt                               |
| `AddressModel`     | id, city, district, building, details                              |
| `CountdownModel`   | weddingDate, timeRemaining                                         |
| `HomeLayoutModel`  | widgets configuration for dynamic home screen                      |
| `WidgetConfigModel`| type, order, data for home layout widgets                          |

---

## API Integration

### Backend

The app connects to a live REST API:

```
Base URL: https://api.wedlyinfo.com
```

Configuration is centralized in `lib/data/services/api_constants.dart`.

### ApiClient Features

- **Dio HTTP Client** with configurable timeouts (10s connect, 15s receive)
- **Automatic Token Refresh** -- queues concurrent requests during refresh
- **TLS Retry** -- exponential backoff for transient TLS handshake failures
- **Session Expiry** -- stream-based notification that triggers auto-logout
- **Request Logging** -- PrettyDioLogger in debug mode only
- **Typed Exceptions** -- every API error maps to a specific exception class

### Error Handling

All API errors are classified into typed exceptions and translated to Arabic user-friendly messages:

| Exception                | Arabic Message                                              |
| ------------------------ | ----------------------------------------------------------- |
| `NoInternetException`    | لا يوجد اتصال بالإنترنت، تحقق من الشبكة وحاول مجدداً       |
| `TimeoutException`       | انتهت مهلة الاتصال، الخادم يستغرق وقتاً أطول من المعتاد     |
| `ServerException`        | الخادم غير متاح حالياً، حاول مرة أخرى بعد قليل              |
| `UnauthorizedException`  | انتهت جلستك، سجّل الدخول مرة أخرى للمتابعة                  |
| `ValidationException`    | البيانات المدخلة غير صحيحة، راجعها وحاول مجدداً              |
| `NotFoundException`      | المحتوى المطلوب غير موجود أو تم حذفه                        |

Context-aware messages: a 401 during login returns "wrong credentials" instead of "session expired."

### API Endpoints

<details>
<summary>Authentication</summary>

| Endpoint                         | Method | Description              |
| -------------------------------- | ------ | ------------------------ |
| `/api/auth/login`                | POST   | Email/password login     |
| `/api/auth/register`             | POST   | User registration        |
| `/api/auth/register-provider`    | POST   | Provider registration    |
| `/api/auth/verify-otp`           | POST   | OTP verification         |
| `/api/auth/resend-otp`           | POST   | Resend OTP code          |
| `/api/auth/forgot-password`      | POST   | Request password reset   |
| `/api/auth/reset-password`       | POST   | Reset with OTP           |
| `/api/auth/refresh`              | POST   | Refresh access token     |
| `/api/auth/logout`               | POST   | Logout                   |
| `/api/auth/me`                   | GET    | Current user profile     |
| `/api/auth/google-login`         | POST   | Google social login      |
| `/api/auth/apple-login`          | POST   | Apple social login       |
| `/api/auth/delete-account`       | DELETE | Delete account           |

</details>

<details>
<summary>Users</summary>

| Endpoint                         | Method | Description              |
| -------------------------------- | ------ | ------------------------ |
| `/api/users/profile`             | GET    | Get user profile         |
| `/api/users/profile`             | PUT    | Update user profile      |
| `/api/users/profile/image`       | POST   | Upload profile image     |
| `/api/users/change-password`     | POST   | Change password          |
| `/api/users/switch-role`         | POST   | Switch user/provider     |
| `/api/users/wedding-date`        | GET    | Get wedding date         |
| `/api/users/wedding-date`        | POST   | Set wedding date         |
| `/api/users/event`               | POST   | Set event name & date    |
| `/api/users/bookings`            | GET    | User's bookings          |

</details>

<details>
<summary>Services</summary>

| Endpoint                                          | Method | Description              |
| ------------------------------------------------- | ------ | ------------------------ |
| `/api/services`                                   | GET    | List services (filterable) |
| `/api/services`                                   | POST   | Create service           |
| `/api/services/:id`                               | GET    | Service details          |
| `/api/services/:id`                               | PUT    | Update service           |
| `/api/services/:id/toggle-status`                 | PATCH  | Toggle availability      |
| `/api/services/:id/dynamic-sections`              | GET    | Get dynamic sections     |
| `/api/services/:id/dynamic-sections`              | POST   | Create section           |
| `/api/services/:id/dynamic-sections/:sid`         | PUT    | Update section           |
| `/api/services/:id/dynamic-sections/:sid`         | DELETE | Delete section           |
| `/api/services/:id/available-dates?month=YYYY-MM` | GET    | Available dates calendar |

</details>

<details>
<summary>Venues, Bookings, Cart, Payments, Reviews, Notifications, Banners, Offers, Categories</summary>

| Endpoint                                  | Method     | Description                  |
| ----------------------------------------- | ---------- | ---------------------------- |
| `/api/venues`                             | GET        | List venues                  |
| `/api/venues/:id`                         | GET        | Venue details                |
| `/api/venues/:id/available-dates`         | GET        | Venue available dates        |
| `/api/venues/:id/reviews`                 | GET/POST   | Venue reviews                |
| `/api/bookings`                           | POST       | Create booking               |
| `/api/bookings/:id`                       | GET        | Booking details              |
| `/api/bookings/:id/status`                | PUT        | Update booking status        |
| `/api/providers/bookings`                 | GET        | Provider's bookings          |
| `/api/providers/bookings/stats`           | GET        | Booking statistics           |
| `/api/cart`                               | GET/POST   | Cart items / Add to cart     |
| `/api/cart/:itemId`                       | DELETE     | Remove cart item             |
| `/api/payments/cart`                      | POST       | Initiate Paymob payment      |
| `/api/services/:id/reviews`               | GET/POST   | Service reviews              |
| `/api/notifications`                      | GET        | List notifications           |
| `/api/notifications/unread-count`         | GET        | Unread count                 |
| `/api/notifications/:id/mark-read`        | PATCH      | Mark as read                 |
| `/api/notifications/mark-all-read`        | PATCH      | Mark all as read             |
| `/api/banners`                            | GET        | Active banners               |
| `/api/offers`                             | GET        | Active offers                |
| `/api/offers/services/:id`               | PATCH      | Submit offer for service     |
| `/api/categories`                         | GET        | List categories              |

</details>

---

## Reusable Widgets

The `lib/presentation/widgets/` directory contains 25 components:

| Widget                         | Description                                              |
| ------------------------------ | -------------------------------------------------------- |
| `ServiceCard`                  | Service listing card with image, price, rating           |
| `VenueCard`                    | Venue card with capacity and pricing                     |
| `CategoryCardWidget`           | Category tile with icon/image                            |
| `CategoryServiceCard`          | Service card within category listing                     |
| `BannersCarouselWidget`        | Auto-playing banner slider with indicators               |
| `OffersCarouselWidget`         | Promotional offers slider                                |
| `CategoriesGridWidget`         | Responsive category grid layout                          |
| `ServicesListWidget`           | Scrollable services list                                 |
| `CountdownTimerWidget`         | Wedding countdown (weeks/days/hours/minutes)             |
| `BookingCardNew`               | Booking item with status and details                     |
| `StatusBadge`                  | Colored status indicator (pending/confirmed/etc.)        |
| `ReviewBottomSheet`            | Star rating and comment submission sheet                 |
| `ProfilePictureWidget`         | Avatar with image upload capability                      |
| `CachedImageWidget`            | Network image with caching and placeholder               |
| `SkeletonLoading`              | Shimmer loading placeholders for all screen types        |
| `SkeletonImage`                | Image placeholder with shimmer effect                    |
| `ErrorView`                    | Error state with retry button                            |
| `OfflineBanner`                | Top banner showing offline status                        |
| `OfflineIndicator`             | Connectivity status indicator                            |
| `NotificationBadge`            | Badge with unread count overlay                          |
| `ProviderServiceCard`          | Provider's service card with edit/toggle actions         |
| `BookingSuccessDialog`         | Booking confirmation dialog                              |
| `DuplicateBookingWarningDialog`| Warning for duplicate booking dates                      |
| `AuthSessionListener`          | Listens for session expiry and triggers logout           |
| `WidgetFactory`                | Dynamic widget builder for home layout configuration     |

---

## Theming

### Color Palette

| Color           | Hex       | Usage                          |
| --------------- | --------- | ------------------------------ |
| Gold (Primary)  | `#D4AF37` | Accent, buttons, highlights    |
| Gold Dark       | `#B8941F` | Gradient stops                 |
| Gold Light      | `#E5C866` | Light accents                  |
| Black           | `#1A1A1A` | Text, elevated buttons         |
| Grey            | `#9E9E9E` | Borders, hints                 |
| Grey Light      | `#F5F5F5` | Input backgrounds, scaffolds   |

### Typography

**Readex Pro** (Google Fonts) is applied globally -- optimized for Arabic script readability.

### Theme Modes

- **Light Theme** -- fully customized with gold accents, white surfaces
- **Dark Theme** -- defined with grey-900 surfaces (currently light mode is default)

---

## Enums

| Enum            | Values                                  |
| --------------- | --------------------------------------- |
| `UserRole`      | `user`, `provider`                      |
| `AuthStatus`    | `initial`, `authenticated`, `unauthenticated` |
| `BookingStatus` | `pending`, `confirmed`, `cancelled`, `completed` |
| `PaymentStatus` | `pending`, `paid`, `refunded`           |
| `Gender`        | `male`, `female`                        |

All enums include `value` getters, `arabicLabel` getters (where applicable), and `fromString` factory methods.

---

## Dependencies

### State & Architecture

| Package            | Version  | Purpose                       |
| ------------------ | -------- | ----------------------------- |
| `flutter_bloc`     | ^8.1.6   | BLoC state management         |
| `equatable`        | ^2.0.5   | Value equality for models     |
| `get_it`           | ^7.7.0   | Service locator / DI          |

### Networking

| Package              | Version  | Purpose                       |
| -------------------- | -------- | ----------------------------- |
| `dio`                | ^5.9.0   | HTTP client                   |
| `pretty_dio_logger`  | ^1.3.1   | Debug request/response logging|
| `connectivity_plus`  | ^7.0.0   | Network status monitoring     |

### Storage & Security

| Package                  | Version  | Purpose                       |
| ------------------------ | -------- | ----------------------------- |
| `flutter_secure_storage` | ^9.2.4   | Encrypted token storage       |
| `shared_preferences`     | ^2.5.3   | User cache & preferences      |

### Authentication

| Package              | Version  | Purpose                       |
| -------------------- | -------- | ----------------------------- |
| `google_sign_in`     | ^6.2.1   | Google OAuth                  |
| `sign_in_with_apple` | ^6.1.4   | Apple Sign-In                 |
| `crypto`             | ^3.0.6   | Nonce generation for Apple    |

### UI & Media

| Package                | Version  | Purpose                       |
| ---------------------- | -------- | ----------------------------- |
| `google_fonts`         | ^6.2.0   | Readex Pro typography         |
| `cached_network_image` | ^3.4.1   | Image caching                 |
| `flutter_svg`          | ^2.0.10  | SVG asset rendering           |
| `shimmer`              | ^3.0.0   | Skeleton loading effects      |
| `image_picker`         | ^1.2.0   | Camera/gallery image selection|
| `webview_flutter`      | ^4.10.0  | Paymob payment WebView        |

### Maps & Location

| Package            | Version  | Purpose                       |
| ------------------ | -------- | ----------------------------- |
| `flutter_map`      | ^8.2.2   | OpenStreetMap widget          |
| `latlong2`         | ^0.9.1   | Geographic coordinates        |
| `geolocator`       | ^14.0.2  | Device location services      |

### Utilities

| Package              | Version  | Purpose                       |
| -------------------- | -------- | ----------------------------- |
| `intl`               | ^0.20.2  | Date/number formatting        |
| `formz`              | ^0.8.0   | Form validation               |
| `url_launcher`       | ^6.2.5   | Open URLs, WhatsApp links     |
| `permission_handler` | ^12.0.1  | Runtime permissions           |
| `json_annotation`    | ^4.9.0   | JSON serialization annotations|

### Dev Dependencies

| Package              | Version  | Purpose                       |
| -------------------- | -------- | ----------------------------- |
| `flutter_test`       | SDK      | Testing framework             |
| `flutter_lints`      | ^5.0.0   | Lint rules                    |
| `build_runner`       | ^2.10.4  | Code generation runner        |
| `json_serializable`  | ^6.11.3  | JSON serialization generator  |

---

## Project Status

### Completed

- [x] Clean Architecture with BLoC pattern
- [x] Full authentication flow (email, Google, Apple)
- [x] OTP verification and password reset
- [x] Role-based navigation (User / Provider)
- [x] Home dashboard with banners, countdown, categories
- [x] Guest browsing mode
- [x] Service categories and listings
- [x] Dynamic service booking (adapts per service type)
- [x] Venue listings, details, and booking
- [x] Shopping cart with price validation
- [x] Paymob payment integration (WebView)
- [x] Reviews and ratings system
- [x] Notifications with unread count
- [x] Profile management with image upload
- [x] Event/wedding date management
- [x] Address management
- [x] Search with filters
- [x] Provider service CRUD
- [x] Provider booking management
- [x] Promotional banners and offers
- [x] Offline connectivity monitoring
- [x] Skeleton loading states
- [x] Comprehensive error handling with Arabic messages
- [x] Token refresh with request queueing
- [x] Onboarding and splash screens
- [x] Provider document upload registration

### Planned

- [ ] Push notifications (FCM integration)
- [ ] Unit and widget test coverage
- [ ] Analytics and crash reporting
- [ ] Image caching strategy optimization
- [ ] Migration to go_router for declarative navigation

---

## Contributing

1. Fork the repository
2. Create your feature branch: `git checkout -b feature/your-feature`
3. Commit your changes: `git commit -m 'Add your feature'`
4. Push to the branch: `git push origin feature/your-feature`
5. Open a Pull Request

### Code Style

- Run `flutter analyze` before committing
- Run `dart format .` to ensure consistent formatting
- Follow existing BLoC/Repository/Screen patterns when adding features
- All user-facing strings must be in Arabic
- Use `AppColors` and theme constants instead of hardcoded color values

---

## License

This project is proprietary. All rights reserved.

---

## Contact

- **Email**: moh.mus2019@gmail.com
- **GitHub**: [github.com/othdu/wedly-enhanced](https://github.com/othdu/wedly-enhanced)

---

Built with Flutter and BLoC
