# API MOCK DATA INVENTORY - WEDLY APP

**Last Updated:** 2025-11-09
**Purpose:** Complete inventory of all mock data, hardcoded values, and simulated network calls for future API integration

---

## TABLE OF CONTENTS
1. [Mock Data Configuration](#1-mock-data-configuration)
2. [Auth Repository Mock Data](#2-auth-repository-mock-data)
3. [Service Repository Mock Data](#3-service-repository-mock-data)
4. [Booking Repository Mock Data](#4-booking-repository-mock-data)
5. [Hardcoded Profile Data](#5-hardcoded-profile-data)
6. [API Configuration](#6-api-configuration)
7. [Demo/Test Code](#7-demotest-code)
8. [TODO Comments](#8-todo-comments)
9. [Summary by Type](#9-summary-by-type)
10. [API Endpoints to Implement](#10-api-endpoints-to-implement)
11. [API Integration Steps](#11-api-integration-steps)

---

## 1. MOCK DATA CONFIGURATION

### Global Mock Mode Flag
**File:** `lib/core/di/injection_container.dart:16-18`

```dart
/// Set to true to use mock data, false to use real API
/// Change this when backend is ready
const bool _useMockData = true;
```

**Action:** Change to `false` when switching to real API

---

## 2. AUTH REPOSITORY MOCK DATA

**File:** `lib/data/repositories/auth_repository.dart`

### 2.1 Mock Login Method
**Lines:** 42-64
**Network Delay:** 1000ms (1 second)

```dart
Future<UserModel> _mockLogin({
  required String email,
  required String password,
  UserRole? role,
}) async {
  await Future.delayed(const Duration(seconds: 1));

  final userRole = role ?? UserRole.user;
  _currentUser = UserModel(
    id: 'user_${DateTime.now().millisecondsSinceEpoch}',
    email: email,
    name: email.split('@')[0],
    role: userRole,
  );

  await _saveUserToCache(_currentUser!);
  return _currentUser!;
}
```

**Mock Behavior:**
- ✅ Accepts **ANY** email/password combination (always succeeds)
- Generates fake user ID from timestamp
- Extracts name from email prefix (before @)
- Assigns selected role (user or provider)

**API Endpoint:** `POST /api/v1/auth/login`

**Expected API Request:**
```json
{
  "email": "string",
  "password": "string",
  "role": "user|provider"
}
```

**Expected API Response:**
```json
{
  "access_token": "string",
  "refresh_token": "string",
  "user": {
    "id": "string",
    "email": "string",
    "name": "string",
    "role": "user|provider",
    "gender": "male|female",
    "phone": "string",
    "city": "string",
    "profile_image_url": "string"
  }
}
```

### 2.2 Mock Logout
**Lines:** 128-131
**Network Delay:** 500ms

```dart
await Future.delayed(const Duration(milliseconds: 500));
_currentUser = null;
await _clearUserCache();
```

**API Endpoint:** `POST /api/v1/auth/logout`

**Expected API Request:**
```json
{
  "refresh_token": "string"
}
```

### 2.3 Mock Get Current User
**Lines:** 144-171

```dart
Future<UserModel?> getCurrentUser() async {
  // Returns cached user in mock mode
  if (_currentUser != null) return _currentUser;

  final cachedUser = await _loadUserFromCache();
  if (cachedUser != null) {
    _currentUser = cachedUser;
    return _currentUser;
  }

  return null;
}
```

**API Endpoint:** `GET /api/v1/auth/me`

**Expected API Response:**
```json
{
  "user": {
    "id": "string",
    "email": "string",
    "name": "string",
    "role": "user|provider",
    "phone": "string",
    "city": "string",
    "profile_image_url": "string"
  }
}
```

---

## 3. SERVICE REPOSITORY MOCK DATA

**File:** `lib/data/repositories/service_repository.dart`

### 3.1 Mock Services List
**Lines:** 11-60
**Count:** 6 hardcoded services

```dart
final List<ServiceModel> _mockServices = [
  const ServiceModel(
    id: '1',
    name: 'Wedding Photography',
    description: 'Professional wedding photography services to capture your special day',
    imageUrl: 'https://images.unsplash.com/photo-1519741497674-611481863552?w=400',
    price: 1500.0,
    category: 'Photography',
  ),
  const ServiceModel(
    id: '2',
    name: 'Catering Services',
    description: 'Delicious catering options for your wedding reception',
    imageUrl: 'https://images.unsplash.com/photo-1556910103-1c02745aae4d?w=400',
    price: 2500.0,
    category: 'Catering',
  ),
  const ServiceModel(
    id: '3',
    name: 'Floral Arrangements',
    description: 'Beautiful floral decorations and bouquets',
    imageUrl: 'https://images.unsplash.com/photo-1462275646964-a0e3386b89fa?w=400',
    price: 800.0,
    category: 'Decoration',
  ),
  const ServiceModel(
    id: '4',
    name: 'DJ & Music',
    description: 'Professional DJ services for your wedding party',
    imageUrl: 'https://images.unsplash.com/photo-1470229722913-7c0f2dbbafb3?w=400',
    price: 1200.0,
    category: 'Entertainment',
  ),
  const ServiceModel(
    id: '5',
    name: 'Venue Booking',
    description: 'Premium wedding venues for your celebration',
    imageUrl: 'https://images.unsplash.com/photo-1519167758481-83f29da8c6a9?w=400',
    price: 5000.0,
    category: 'Venue',
  ),
  const ServiceModel(
    id: '6',
    name: 'Makeup & Styling',
    description: 'Professional makeup and hair styling services',
    imageUrl: 'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?w=400',
    price: 600.0,
    category: 'Beauty',
  ),
];
```

**Service Details:**
| ID | Name | Category | Price | Image Source |
|---|---|---|---|---|
| 1 | Wedding Photography | Photography | $1500 | Unsplash |
| 2 | Catering Services | Catering | $2500 | Unsplash |
| 3 | Floral Arrangements | Decoration | $800 | Unsplash |
| 4 | DJ & Music | Entertainment | $1200 | Unsplash |
| 5 | Venue Booking | Venue | $5000 | Unsplash |
| 6 | Makeup & Styling | Beauty | $600 | Unsplash |

**Categories:** Photography, Catering, Decoration, Entertainment, Venue, Beauty
**Price Range:** $600 - $5000

### 3.2 Mock Get All Services
**Lines:** 77-81
**Network Delay:** 800ms

```dart
Future<List<ServiceModel>> _mockGetServices() async {
  await Future.delayed(const Duration(milliseconds: 800));
  return List.from(_mockServices);
}
```

**API Endpoint:** `GET /api/v1/services`

**Expected API Response:**
```json
{
  "services": [
    {
      "id": "string",
      "name": "string",
      "description": "string",
      "image_url": "string",
      "price": 0,
      "category": "string",
      "provider_id": "string",
      "is_active": true
    }
  ]
}
```

### 3.3 Mock Get Service By ID
**Lines:** 100-107
**Network Delay:** 500ms

```dart
Future<ServiceModel?> _mockGetServiceById(String id) async {
  await Future.delayed(const Duration(milliseconds: 500));
  try {
    return _mockServices.firstWhere((service) => service.id == id);
  } catch (e) {
    return null;
  }
}
```

**API Endpoint:** `GET /api/v1/services/:id`

### 3.4 Mock Get Services By Category
**Lines:** 129-134
**Network Delay:** 500ms

```dart
Future<List<ServiceModel>> _mockGetServicesByCategory(String category) async {
  await Future.delayed(const Duration(milliseconds: 500));
  return _mockServices
      .where((service) => service.category == category)
      .toList();
}
```

**API Endpoint:** `GET /api/v1/services/category/:category`

### 3.5 Mock Get Categories
**Lines:** 153-156
**Network Delay:** 300ms

```dart
Future<List<String>> _mockGetCategories() async {
  await Future.delayed(const Duration(milliseconds: 300));
  return _mockServices.map((service) => service.category).toSet().toList();
}
```

**Returns:** `['Photography', 'Catering', 'Decoration', 'Entertainment', 'Venue', 'Beauty']`

**Note:** In real API, categories should be derived from services or have a dedicated endpoint

### 3.6 Mock Get Provider Services
**Lines:** 175-179
**Network Delay:** 500ms

```dart
Future<List<ServiceModel>> _mockGetProviderServices(String providerId) async {
  await Future.delayed(const Duration(milliseconds: 500));
  // For mock, return all services. In real implementation, filter by providerId
  return List.from(_mockServices);
}
```

**⚠️ Mock Behavior:** Returns ALL services (doesn't filter by provider)

**API Endpoint:** `GET /api/v1/provider/:providerId/services`

### 3.7 Mock Add Service
**Lines:** 198-205
**Network Delay:** 800ms

```dart
Future<ServiceModel> _mockAddService(ServiceModel service) async {
  await Future.delayed(const Duration(milliseconds: 800));
  final newService = service.copyWith(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
  );
  _mockServices.add(newService);
  return newService;
}
```

**Mock Behavior:** Generates ID from timestamp, adds to in-memory list

**API Endpoint:** `POST /api/v1/services`

**Expected API Request:**
```json
{
  "name": "string",
  "description": "string",
  "price": 0,
  "category": "string",
  "image": "file"
}
```

### 3.8 Mock Update Service
**Lines:** 226-234
**Network Delay:** 800ms

```dart
Future<ServiceModel> _mockUpdateService(ServiceModel service) async {
  await Future.delayed(const Duration(milliseconds: 800));
  final index = _mockServices.indexWhere((s) => s.id == service.id);
  if (index != -1) {
    _mockServices[index] = service;
    return service;
  }
  throw Exception('Service not found');
}
```

**API Endpoint:** `PUT /api/v1/services/:id`

### 3.9 Mock Delete Service
**Lines:** 255-258
**Network Delay:** 500ms

```dart
Future<void> _mockDeleteService(String serviceId) async {
  await Future.delayed(const Duration(milliseconds: 500));
  _mockServices.removeWhere((s) => s.id == serviceId);
}
```

**API Endpoint:** `DELETE /api/v1/services/:id`

### 3.10 Mock Toggle Service Status
**Lines:** 275-285
**Network Delay:** 500ms

```dart
Future<ServiceModel> _mockToggleServiceStatus(String serviceId) async {
  await Future.delayed(const Duration(milliseconds: 500));
  final index = _mockServices.indexWhere((s) => s.id == serviceId);
  if (index != -1) {
    final service = _mockServices[index];
    final updatedService = service.copyWith(isActive: !service.isActive);
    _mockServices[index] = updatedService;
    return updatedService;
  }
  throw Exception('Service not found');
}
```

**API Endpoint:** `PATCH /api/v1/provider/services/:id/toggle-status`

---

## 4. BOOKING REPOSITORY MOCK DATA

**File:** `lib/data/repositories/booking_repository.dart`

### 4.1 Mock Bookings List
**Lines:** 6-154
**Count:** 7 hardcoded bookings (all in Arabic)

```dart
final List<BookingModel> _mockBookings = [
  BookingModel(
    id: '1',
    serviceId: '1',
    serviceName: 'قاعة ريحا - الجنح الطائر',
    serviceImage: 'https://images.unsplash.com/photo-1519167758481-83f29da8c6a9?w=800',
    providerId: 'provider1',
    userId: 'user1',
    customerName: 'محمود احمد الحراز',
    customerEmail: 'mahmoud@example.com',
    customerPhone: '+20 100 123 4567',
    bookingDate: DateTime(2024, 11, 15, 19, 0),
    createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    status: BookingStatus.pending,
    totalAmount: 12000,
    paymentStatus: PaymentStatus.pending,
    eventType: 'قاعة افراح',
    guestCount: 800,
    eventLocation: 'القاهرة',
    specialRequests: 'نحتاج منصور طبليس من مواضع الفافي مع شاشة العرض',
  ),
  // ... 6 more bookings
];
```

**All 7 Mock Bookings:**

| ID | Customer Name | Status | Amount (EGP) | Guests | Payment | Service Type |
|---|---|---|---|---|---|---|
| 1 | محمود احمد الحراز | Pending | 12,000 | 800 | Pending | قاعة افراح |
| 2 | فاطمة محمد العلي | Pending | 12,000 | 800 | Pending | قاعة افراح |
| 3 | أحمد حسن السيد | Confirmed | 8,500 | 300 | Paid | Photography |
| 4 | سارة علي الشامي | Confirmed | 15,000 | 500 | Paid | Catering |
| 5 | خالد يوسف المصري | Completed | 12,000 | 700 | Paid | قاعة افراح |
| 6 | ليلى إبراهيم الحسيني | Completed | 6,000 | 400 | Paid | Decoration |
| 7 | عمر سعيد الأحمد | Cancelled | 12,000 | 600 | Refunded | قاعة افراح |

**Status Distribution:**
- ✅ Pending: 3 bookings
- ✅ Confirmed: 2 bookings
- ✅ Completed: 2 bookings
- ❌ Cancelled: 1 booking

**Common Fields:**
- **Email Domain:** All use `@example.com`
- **Phone Format:** Egyptian (+20 xxx xxx xxxx)
- **Location:** All in القاهرة (Cairo)
- **Date:** November 15, 2024

### 4.2 Mock Get Provider Bookings
**Lines:** 157-163
**Network Delay:** 500ms

```dart
Future<List<BookingModel>> getProviderBookings(String providerId) async {
  await Future.delayed(const Duration(milliseconds: 500));
  return _mockBookings
      .where((booking) => booking.providerId == providerId)
      .toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
}
```

**API Endpoint:** `GET /api/v1/provider/:providerId/bookings`

**Expected API Response:**
```json
{
  "bookings": [
    {
      "id": "string",
      "service_id": "string",
      "service_name": "string",
      "service_image": "string",
      "provider_id": "string",
      "user_id": "string",
      "customer_name": "string",
      "customer_email": "string",
      "customer_phone": "string",
      "booking_date": "2024-11-15T19:00:00Z",
      "created_at": "2024-11-09T10:00:00Z",
      "status": "pending|confirmed|completed|cancelled",
      "total_amount": 0,
      "payment_status": "pending|paid|refunded",
      "event_type": "string",
      "guest_count": 0,
      "event_location": "string",
      "notes": "string",
      "special_requests": "string"
    }
  ]
}
```

### 4.3 Mock Get Bookings By Status
**Lines:** 166-176
**Network Delay:** 500ms

**API Endpoint:** `GET /api/v1/provider/:providerId/bookings?status=:status`

### 4.4 Mock Get Booking By ID
**Lines:** 179-186
**Network Delay:** 300ms

**API Endpoint:** `GET /api/v1/bookings/:id`

### 4.5 Mock Update Booking Status
**Lines:** 189-204
**Network Delay:** 800ms

**API Endpoint:** `PATCH /api/v1/bookings/:id/status`

**Expected API Request:**
```json
{
  "status": "pending|confirmed|completed|cancelled"
}
```

### 4.6 Mock Get Bookings Count By Status
**Lines:** 207-230
**Network Delay:** 400ms

**API Endpoint:** `GET /api/v1/provider/:providerId/bookings/stats`

**Expected API Response:**
```json
{
  "stats": {
    "pending": 3,
    "confirmed": 2,
    "completed": 2,
    "cancelled": 1
  }
}
```

### 4.7 Mock Get Bookings By Date Range
**Lines:** 233-246
**Network Delay:** 500ms

**API Endpoint:** `GET /api/v1/provider/:providerId/bookings?start=:date&end=:date`

---

## 5. HARDCODED PROFILE DATA

### 5.1 User Edit Profile Screen
**File:** `lib/presentation/screens/user/user_edit_profile_screen.dart:38-39`

```dart
_phoneController.text = '+20 100 123 4567'; // TODO: Get from user model
_cityController.text = 'القاهرة'; // TODO: Get from user model
```

**Action Needed:** Add `phone` and `city` fields to UserModel

### 5.2 Provider Edit Profile Screen
**File:** `lib/presentation/screens/provider/provider_edit_profile_screen.dart:38-39`

```dart
_phoneController.text = '+20 100 123 4567'; // TODO: Get from user model
_cityController.text = 'القاهرة'; // TODO: Get from user model
```

**Action Needed:** Add `phone` and `city` fields to UserModel

### 5.3 Provider Profile Screen (Display)
**File:** `lib/presentation/screens/provider/provider_profile_screen_final.dart:169-180`

```dart
_buildInfoRow('M.Hossam22@Gmail.Com', 'البريد الإلكتروني'),
_buildInfoRow('+20 100 123 4567', 'رقم الهاتف'),
_buildInfoRow('القاهرة', 'المدينة'),
```

**Action Needed:** Fetch from AuthBloc user state instead of hardcoded values

---

## 6. API CONFIGURATION

### Placeholder API Base URL
**File:** `lib/data/services/api_constants.dart:4-5`

```dart
// Base URL - Update this when backend is ready
static const String baseUrl = 'https://api.wedly.example.com';
```

**⚠️ Action Required:** Replace with actual backend URL before API integration

---

## 7. DEMO/TEST CODE

### 7.1 Splash Screen Delay
**File:** `lib/presentation/screens/splash/splash_screen.dart:43`

```dart
await Future.delayed(const Duration(seconds: 3));
```

**Note:** Intentional UX delay (not mock data)

### 7.2 Success Dialog Delays
**Files:**
- `lib/presentation/screens/provider/provider_add_service_screen.dart:367`
- `lib/presentation/screens/provider/provider_edit_service_screen.dart:362`

```dart
Future.delayed(const Duration(seconds: 2), () {
```

**Note:** UX delay for showing success message (not mock data)

### 7.3 Demo Discount Display
**File:** `lib/presentation/screens/provider/provider_bookings_screen_new.dart:188`

```dart
showDiscount: index % 2 == 0, // Show discount on alternating cards for demo
```

**⚠️ Action Required:** Remove or replace with real discount logic from API

---

## 8. TODO COMMENTS

### 8.1 Social Login Placeholders
**Files:**
- `lib/presentation/screens/auth/login_screen.dart` (Lines 419, 429, 439)
- `lib/presentation/screens/auth/signup_screen.dart` (Lines 646, 656, 666)

```dart
// TODO: Implement Facebook login
// TODO: Implement Apple login
// TODO: Implement Google login
// TODO: Implement Facebook signup
// TODO: Implement Apple signup
// TODO: Implement Google signup
```

### 8.2 Profile Update TODOs
**Files:**
- `lib/presentation/screens/user/user_edit_profile_screen.dart` (Lines 55, 62)
- `lib/presentation/screens/provider/provider_edit_profile_screen.dart` (Lines 55, 62)

```dart
// TODO: Implement image selection handling
// TODO: Implement actual profile update via AuthBloc
```

### 8.3 Navigation TODOs
**Files:**
- `lib/presentation/screens/user/user_home_screen.dart` (Lines 35, 106, 129)
- `lib/presentation/screens/provider/provider_home_screen.dart` (Lines 35, 107)

```dart
// TODO: Implement search
// TODO: Filter by category
// TODO: Navigate to service details
```

### 8.4 Placeholder Screens
**File:** `lib/presentation/screens/user/user_navigation_wrapper.dart:21-22`

```dart
const Placeholder(), // TODO: Add bookings screen
const Placeholder(), // TODO: Add favorites screen
```

---

## 9. SUMMARY BY TYPE

### Network Delays (Future.delayed)
| Duration | Use Cases |
|---|---|
| 3000ms (3s) | Splash screen display |
| 2000ms (2s) | Success dialog delays (UX) |
| 1000ms (1s) | Auth login |
| 800ms | Get services, add service, update service, update booking status |
| 500ms | Get service by ID, get by category, get provider services, delete service, toggle service status, get provider bookings, get bookings by status, get bookings by date range, auth logout |
| 400ms | Get bookings count by status |
| 300ms | Get categories, get booking by ID |

### Mock Data Counts
| Type | Count | Location |
|---|---|---|
| Services | 6 | `service_repository.dart` |
| Bookings | 7 | `booking_repository.dart` |
| Categories | 6 | Derived from services |
| Users | Dynamic | Generated on login |

### Hardcoded User Data
| Field | Value | Occurrences |
|---|---|---|
| Phone | '+20 100 123 4567' | 3 screens |
| City | 'القاهرة' (Cairo) | 3 screens |
| Email | 'M.Hossam22@Gmail.Com' | 1 screen |
| Test Emails | @example.com domain | All bookings |

### External Resources
| Type | Count | Width | Purpose |
|---|---|---|---|
| Unsplash Service Images | 6 | 400px | Service cards |
| Unsplash Booking Images | 7 | 800px | Booking details |
| **Total** | **13** | - | - |

---

## 10. API ENDPOINTS TO IMPLEMENT

### Authentication Endpoints

```
POST   /api/v1/auth/register
POST   /api/v1/auth/login
POST   /api/v1/auth/logout
POST   /api/v1/auth/refresh
GET    /api/v1/auth/me
```

### Service Endpoints

```
GET    /api/v1/services
GET    /api/v1/services/:id
GET    /api/v1/services/category/:category
POST   /api/v1/services
PUT    /api/v1/services/:id
DELETE /api/v1/services/:id
PATCH  /api/v1/provider/services/:id/toggle-status
GET    /api/v1/provider/:providerId/services
```

### Booking Endpoints

```
GET    /api/v1/provider/:providerId/bookings
GET    /api/v1/provider/:providerId/bookings?status=:status
GET    /api/v1/provider/:providerId/bookings/stats
GET    /api/v1/provider/:providerId/bookings?start=:date&end=:date
GET    /api/v1/bookings/:id
PATCH  /api/v1/bookings/:id/status
GET    /api/v1/user/bookings
POST   /api/v1/bookings
```

### User Profile Endpoints

```
GET    /api/v1/user/profile
PUT    /api/v1/user/profile
POST   /api/v1/user/profile/image
```

### Social Authentication (Optional)

```
POST   /api/v1/auth/facebook
POST   /api/v1/auth/google
POST   /api/v1/auth/apple
```

---

## 11. API INTEGRATION STEPS

### Phase 1: Preparation
1. ✅ **Update UserModel** - Add `phone` and `city` fields to model
2. ✅ **Update API Base URL** - Replace placeholder in `api_constants.dart`
3. ✅ **Add Token Storage** - Implement `flutter_secure_storage` for tokens
4. ✅ **Add Interceptors** - Create Dio interceptors for auth headers
5. ✅ **Add Error Handling** - Create custom exception classes

### Phase 2: Authentication
6. ✅ **Implement Login API** - Replace `_mockLogin()` with real API call
7. ✅ **Implement Logout API** - Replace mock logout
8. ✅ **Implement Token Refresh** - Add automatic token refresh logic
9. ✅ **Test Auth Flow** - Verify login/logout works end-to-end

### Phase 3: Services
10. ✅ **Implement Get Services API** - Replace `_mockGetServices()`
11. ✅ **Implement Service CRUD** - Add/Update/Delete service APIs
12. ✅ **Add Image Upload** - Implement multipart file upload for service images
13. ✅ **Test Service Management** - Verify all service operations

### Phase 4: Bookings
14. ✅ **Implement Bookings API** - Replace all mock booking methods
15. ✅ **Add Booking Stats** - Implement statistics endpoint
16. ✅ **Test Booking Flow** - Verify booking creation and status updates

### Phase 5: User Profile
17. ✅ **Implement Profile APIs** - Get/Update profile endpoints
18. ✅ **Add Profile Image Upload** - Implement image upload
19. ✅ **Update Profile Screens** - Remove hardcoded data, use API data
20. ✅ **Test Profile Updates** - Verify profile edits work correctly

### Phase 6: Cleanup & Testing
21. ✅ **Remove Demo Code** - Delete alternating discount logic
22. ✅ **Update `_useMockData`** - Set to `false` in `injection_container.dart`
23. ✅ **Remove Mock Methods** - Clean up unused `_mock*()` methods
24. ✅ **End-to-End Testing** - Test entire app with real API
25. ✅ **Error Handling** - Verify all error scenarios are handled

### Phase 7: Optimization
26. ✅ **Add Caching** - Implement response caching where appropriate
27. ✅ **Add Pagination** - Implement pagination for services/bookings lists
28. ✅ **Add Loading States** - Improve UX with skeleton loaders
29. ✅ **Add Retry Logic** - Handle network failures gracefully
30. ✅ **Performance Testing** - Verify app performance with real data

---

## CRITICAL FILES TO UPDATE

When switching from mock to API:

1. **`lib/core/di/injection_container.dart`** - Set `_useMockData = false`
2. **`lib/data/services/api_constants.dart`** - Update base URL
3. **`lib/data/models/user_model.dart`** - Add phone and city fields
4. **`lib/data/repositories/auth_repository.dart`** - Implement real API calls
5. **`lib/data/repositories/service_repository.dart`** - Implement real API calls
6. **`lib/data/repositories/booking_repository.dart`** - Implement real API calls
7. **`lib/presentation/screens/provider/provider_profile_screen_final.dart`** - Remove hardcoded data
8. **`lib/presentation/screens/user/user_edit_profile_screen.dart`** - Remove hardcoded data
9. **`lib/presentation/screens/provider/provider_edit_profile_screen.dart`** - Remove hardcoded data

---

## NOTES

- ✅ All repository method signatures are designed to remain unchanged during API integration
- ✅ Mock data uses realistic Arabic names and Egyptian phone numbers
- ✅ Network delays simulate real-world latency for better UX testing
- ⚠️ Unsplash images are external dependencies - consider hosting images on own CDN
- ⚠️ Mock login accepts ANY credentials - ensure proper validation in real API
- ⚠️ Provider services filter is disabled in mock mode - returns all services

---

**End of Mock Data Inventory**
