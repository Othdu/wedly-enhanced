# Wedly - Wedding Services Marketplace 💍

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.9.2+-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?logo=dart&logoColor=white)
![BLoC](https://img.shields.io/badge/State-BLoC-brightgreen)
![License](https://img.shields.io/badge/License-MIT-yellow)

**A comprehensive Flutter wedding services marketplace with dual-role support (User & Provider)**

[Features](#features) • [Architecture](#architecture) • [Getting Started](#getting-started) • [Screenshots](#screenshots) • [API Integration](#api-integration)

</div>

---

## 📱 Overview

Wedly is a modern Flutter application built with Clean Architecture and BLoC pattern, designed to connect wedding service providers with couples planning their special day. The app features a sophisticated dual-role system, allowing users to browse and book services while providers can manage their offerings.

### 🌟 Key Highlights

- **Clean Architecture** with clear separation of concerns
- **BLoC Pattern** for predictable state management
- **Dual Role System** (User & Provider modes)
- **Arabic-First Design** with RTL support
- **Mock Data Ready** for seamless API integration
- **Material Design 3** with custom theming

---

## 🎯 Features

### ✨ Current Implementation

#### User Features
- 🏠 **Dynamic Home Screen** with customizable widget layout
- 🎁 **Offers System** with carousel and dedicated list view
- 📋 **Category Browsing** with service filtering
- 🗓️ **Booking System** for multiple service types (Decoration, Wedding Dress, Wedding Planner)
- 🛒 **Shopping Cart** for managing multiple bookings
- 💳 **Payment Flow** with method selection
- 👤 **Profile Management** with edit capabilities
- 🔍 **Search & Filter** services by category
- ⭐ **Venue Listings** with dedicated browsing

#### Provider Features
- 📊 **Dashboard** with service management
- ➕ **Add/Edit Services** with comprehensive forms
- 📈 **Analytics** placeholder for future metrics
- 📅 **Booking Management** view
- 👤 **Profile Management**

#### Offers Feature (NEW)
- 🎯 **Offers Carousel** on home screen with "المزيد" navigation
- 📋 **Offers List Screen** displaying all active offers
- 💰 **Discount Badges** showing percentage off
- ⭐ **Provider Ratings** with review counts
- 💵 **Price Comparison** (original vs. discounted)
- 🔗 **Direct Booking** navigation to service-specific booking screens
- 🔄 **Pull-to-Refresh** functionality
- ⚡ **Fast Loading** with skeleton screens

---

## 🏗️ Architecture

### Project Structure

```
lib/
├── core/                          # Core utilities and configurations
│   ├── constants/                # App constants and strings
│   ├── di/                       # Dependency injection (GetIt)
│   ├── theme/                    # Material Design 3 theming
│   └── utils/                    # Utility classes and enums
├── data/                         # Data layer
│   ├── models/                   # Data models (Equatable)
│   │   ├── user_model.dart
│   │   ├── service_model.dart
│   │   ├── offer_model.dart      # NEW: Offer data model
│   │   ├── booking_model.dart
│   │   ├── venue_model.dart
│   │   └── category_model.dart
│   ├── repositories/             # Repository implementations
│   │   ├── auth_repository.dart
│   │   ├── service_repository.dart
│   │   ├── offer_repository.dart  # NEW: Offers data source
│   │   ├── booking_repository.dart
│   │   ├── cart_repository.dart
│   │   └── venue_repository.dart
│   └── services/                 # API services (ready for integration)
├── logic/                        # Business logic layer
│   └── blocs/                    # BLoC state management
│       ├── auth/                 # Authentication BLoC
│       ├── home/                 # Home screen BLoC (includes offers)
│       ├── service/              # Service management BLoC
│       ├── booking/              # Booking management BLoC
│       ├── cart/                 # Shopping cart BLoC
│       └── venue/                # Venue browsing BLoC
├── presentation/                 # Presentation layer
│   ├── screens/                  # Screen widgets
│   │   ├── auth/                # Authentication screens
│   │   ├── user/                # User role screens
│   │   │   ├── user_home_screen.dart
│   │   │   ├── offers_list_screen.dart  # NEW: Full offers list
│   │   │   ├── decoration_booking_screen.dart
│   │   │   ├── wedding_dress_booking_screen.dart
│   │   │   ├── weddingplanner_booking_screen.dart
│   │   │   └── user_cart_screen.dart
│   │   └── provider/            # Provider role screens
│   └── widgets/                 # Reusable widgets
│       ├── offers_carousel_widget.dart  # NEW: Offers carousel
│       ├── service_card.dart
│       └── skeleton_loading.dart
├── routes/                       # Navigation and routing
│   └── app_router.dart          # Centralized routing
└── main.dart                    # App entry point
```

### Architecture Layers

#### 1. **Data Layer**
- **Models**: Immutable data classes using Equatable for value equality
- **Repositories**: Mock implementations simulating API calls with realistic delays
- **Services**: API client setup (ready for backend integration)

#### 2. **Logic Layer**
- **BLoC Pattern**: Predictable state management with flutter_bloc
- **Events**: User actions (e.g., `HomeServicesRequested`)
- **States**: UI states (e.g., `HomeLoading`, `HomeLoaded`, `HomeError`)
- **Separation**: Business logic completely separated from UI

#### 3. **Presentation Layer**
- **Screens**: Organized by feature and role
- **Widgets**: Reusable, customizable components
- **Theming**: Consistent Material Design 3 styling

---

## 🚀 Getting Started

### Prerequisites

```bash
Flutter SDK: >=3.9.2
Dart SDK: >=3.0.0
```

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/wedly-enhanced.git
   cd wedly-enhanced
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

4. **Build for production**
   ```bash
   # Android
   flutter build apk --release

   # iOS (requires macOS)
   flutter build ios --release

   # Web
   flutter build web --release
   ```

### Testing Credentials

For testing purposes (mock authentication):
- **Email**: Any valid email format
- **Password**: Minimum 6 characters
- Or click **"Use Demo Credentials"** button to auto-fill

---

## 🔌 API Integration

The codebase is **API-ready** with comprehensive TODO comments throughout. All repositories currently use mock data but are structured for seamless API integration.

### Mock Data Details

| Repository | Mock Items | Network Delay |
|-----------|-----------|---------------|
| **OfferRepository** | 6 offers | 800ms |
| **ServiceRepository** | 6 services | 500ms |
| **BookingRepository** | 7 bookings | 600ms |
| **VenueRepository** | Mock venues | 700ms |
| **CartRepository** | Cart items | 400ms |

### Integration Steps

1. **Add HTTP package**
   ```yaml
   dependencies:
     dio: ^5.0.0  # or http: ^1.0.0
   ```

2. **Configure API base URL**
   ```dart
   // lib/data/services/api_constants.dart
   class ApiConstants {
     static const String baseUrl = 'https://api.yourbackend.com';
     static const String offers = '$baseUrl/offers';
     // ... other endpoints
   }
   ```

3. **Update repositories**
   - Replace mock methods with real API calls
   - Implement error handling
   - Add token management
   - See TODO comments in each repository file

4. **API Endpoints Required**

   ```
   Offers API:
   GET  /api/offers              - Get all active offers
   GET  /api/offers/:id          - Get offer by ID
   GET  /api/offers/provider/:id - Get offers by provider

   Services API:
   GET  /api/services            - Get all services
   GET  /api/services/:id        - Get service by ID
   POST /api/services            - Create service (provider)

   Auth API:
   POST /api/auth/login          - User login
   POST /api/auth/register       - User registration
   POST /api/auth/logout         - User logout

   Bookings API:
   GET  /api/bookings            - Get user bookings
   POST /api/bookings            - Create booking
   PUT  /api/bookings/:id        - Update booking
   ```

5. **Toggle Mock Mode**
   ```dart
   // lib/core/di/injection_container.dart
   const bool _useMockData = false;  // Switch to real API
   ```

### API Response Format Examples

<details>
<summary>Click to view expected API response formats</summary>

**Offers Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "1",
      "title": "Wedding Hall Decoration",
      "title_ar": "قاعة زفاف – التصميم الملكي",
      "description": "Premium decoration package",
      "description_ar": "تزيين فاخر لقاعة الزفاف",
      "image_url": "https://example.com/image.jpg",
      "discount": "-50%",
      "expiry_date": "2025-12-31T23:59:59Z",
      "provider_id": "provider_1",
      "provider_name": "استوديو الأحلام",
      "service_type": "decoration",
      "original_price": 14000.0,
      "discounted_price": 7000.0,
      "rating": 4.8,
      "review_count": 200
    }
  ]
}
```

**Services Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "1",
      "name": "Professional Photography",
      "name_ar": "تصوير احترافي",
      "description": "Wedding photography package",
      "description_ar": "باقة تصوير زفاف احترافية",
      "price": 5000.0,
      "category": "photography",
      "image_url": "https://example.com/photo.jpg",
      "provider_id": "provider_1",
      "rating": 4.9
    }
  ]
}
```

</details>

---

## 🎨 Theming & Localization

### Material Design 3
- Custom color scheme with gold accent (#D4AF37)
- Light and dark mode support
- Consistent spacing and typography

### Localization
- **Primary Language**: Arabic (ar_SA) 
- **RTL Support**: Full right-to-left layout
- **Fallback**: English support configured
- All UI text uses Arabic with proper text direction

---

## 📦 Dependencies

### Core Dependencies
```yaml
dependencies:
  flutter_bloc: ^8.1.3          # State management
  equatable: ^2.0.5             # Value equality
  get_it: ^7.6.4               # Dependency injection
  go_router: ^13.0.0           # Navigation (configured)
  flutter_secure_storage: ^9.0.0  # Secure token storage
```

### UI Dependencies
```yaml
  intl: ^0.18.1                # Internationalization
  cached_network_image: ^3.3.0 # Image caching (ready)
```

---

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Analyze code
flutter analyze
```

**Current Test Status:**
- Unit tests: Minimal (TODO)
- Widget tests: Default widget test
- Integration tests: Not implemented

---

## 🗺️ Roadmap

### Phase 1: Core Features (✅ Completed)
- [x] Clean architecture setup
- [x] Authentication flow
- [x] Role-based navigation
- [x] Home screen with dynamic widgets
- [x] Service browsing
- [x] Offers system with carousel and list
- [x] Booking flow for multiple service types
- [x] Shopping cart functionality

### Phase 2: API Integration (🚧 In Progress)
- [ ] Connect to backend API
- [ ] Implement authentication tokens
- [ ] Real-time data synchronization
- [ ] Image upload functionality
- [ ] Payment gateway integration

### Phase 3: Enhanced Features
- [ ] Push notifications
- [ ] Real-time chat between users and providers
- [ ] Reviews and ratings system
- [ ] Advanced search and filters
- [ ] Provider analytics dashboard
- [ ] Social media integration

### Phase 4: Optimization
- [ ] Performance optimization
- [ ] Offline mode with caching
- [ ] Image optimization
- [ ] Comprehensive testing suite
- [ ] CI/CD pipeline

---
## 🐛 Known Issues

- Unused `_isOffer` variable in booking screens (cosmetic warning)
- Some deprecated `withOpacity` calls (scheduled for update)
- Mock authentication accepts any credentials (intentional for testing)

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- Flutter & Dart teams for the amazing framework
- BLoC library maintainers
- Unsplash for placeholder images
- The open-source community
- claudeeeeeeeeee<3
---

## 📞 Support

For support, please:
- 📧 Email: moh.mus2019@gmail.com
- 🐛 Issues: [GitHub Issues](https://github.com/yourusername/wedly-enhanced/issues)

---

<div align="center">

**Built with ❤️ using Flutter**

</div>
