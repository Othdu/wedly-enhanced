# API Integration Prompt

**Use this prompt when you're ready to integrate real APIs into the Wedly Flutter app:**

---

I'm ready to integrate real APIs into my Wedly Flutter app. The app currently uses mock data repositories and I need to replace them with actual API calls.

## Current Architecture Context

The app uses **clean architecture with BLoC pattern**:

- **Data Layer**: Models and Repositories in `lib/data/`
- **Logic Layer**: BLoCs in `lib/logic/blocs/`
- **Presentation Layer**: Screens and widgets in `lib/presentation/`
- **Dependency Injection**: GetIt setup in `lib/core/di/injection_container.dart`

## Mock Repositories to Replace

### 1. AuthRepository (`lib/data/repositories/auth_repository.dart`)
Currently has mock methods:
- `login(email, password, role)` - Returns `Future<UserModel>`
- `logout()` - Returns `Future<void>`
- `getCurrentUser()` - Returns `UserModel?`
- `isAuthenticated()` - Returns `bool`
- `setUserRole(role)` - For testing, can be removed

**Expected API Integration:**
- Login endpoint: `POST /auth/login` (or similar)
- Should return user data with token
- Store auth token securely (use `flutter_secure_storage` or similar)
- Handle token refresh if needed

### 2. ServiceRepository (`lib/data/repositories/service_repository.dart`)
Currently has mock methods:
- `getServices()` - Returns `Future<List<ServiceModel>>`
- `getServiceById(id)` - Returns `Future<ServiceModel?>`
- `getServicesByCategory(category)` - Returns `Future<List<ServiceModel>>`
- `getCategories()` - Returns `Future<List<String>>`

**Expected API Integration:**
- Get all services: `GET /services` (or similar)
- Get service by ID: `GET /services/:id`
- Get services by category: `GET /services?category=:category`
- Get categories: `GET /categories` (or extract from services)

## Data Models

### UserModel (`lib/data/models/user_model.dart`)
```dart
- id: String
- email: String
- name: String
- role: UserRole (enum: user, provider)
- profileImageUrl: String?
```

### ServiceModel (`lib/data/models/service_model.dart`)
```dart
- id: String
- name: String
- description: String
- imageUrl: String
- price: double?
- category: String
- isActive: bool
```

## API Details Needed

Please provide:
1. **Base URL**: `https://api.wedly.com` (or your actual base URL)
2. **Authentication**: 
   - How tokens are sent (Header? Which header name?)
   - Token format (Bearer token? JWT?)
3. **API Endpoints**: Exact endpoints for:
   - Login/Authentication
   - Get services
   - Get service by ID
   - Get services by category
   - Get categories
4. **Request/Response Format**: JSON structure examples
5. **Error Handling**: How errors are returned (status codes, error message format)
6. **Additional Requirements**:
   - Token refresh mechanism?
   - Pagination for services?
   - Image upload endpoints?
   - Any other endpoints needed?

## Requirements

1. **Add HTTP Package**: Use `dio` or `http` package for API calls
2. **Add JSON Serialization**: Use `json_annotation` and `json_serializable` for models
3. **Error Handling**: Create custom exceptions and handle them in BLoCs
4. **Token Management**: Store and manage auth tokens securely
5. **Network Interceptor**: Add interceptors for:
   - Adding auth token to requests
   - Handling 401 errors (logout)
   - Logging requests/responses (for debugging)
6. **Keep Repository Interface**: Maintain the same repository method signatures so BLoCs don't need changes
7. **Loading States**: Ensure loading states work correctly with real network delays
8. **Offline Handling**: Consider adding offline support (optional, can be added later)

## What Should NOT Change

- **BLoC layer**: Should work without modifications
- **Presentation layer**: Screens and widgets should work as-is
- **Repository method signatures**: Keep the same return types and parameters
- **Dependency injection setup**: Keep GetIt structure

## Additional Notes

- The app currently uses mock delays (`Future.delayed`) to simulate network calls
- All repositories are registered as singletons in GetIt
- BLoCs are registered as factories (new instance per use)
- The app supports both User and Provider roles

---

**When you're ready, provide this prompt along with your API documentation/endpoints, and I'll integrate everything seamlessly!**

