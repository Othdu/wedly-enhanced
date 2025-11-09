# API Integration Guide for Wedly

This guide explains how to switch from mock data to a real API backend.

## Current State

The app is currently configured to use **mock data** for development and testing. This allows you to:
- Test all features without a backend
- Develop UI independently
- Simulate network delays
- Demo the app easily

## Architecture Overview

### Data Flow
```
UI (Presentation) → BLoC (Logic) → Repository (Data) → API Client (Network)
```

### Key Components

1. **API Client** (`lib/data/services/api_client.dart`)
   - Handles all HTTP communication
   - Automatic token refresh
   - Error handling and retry logic
   - Request/response logging

2. **Repositories** (`lib/data/repositories/`)
   - `AuthRepository`: Authentication operations
   - `ServiceRepository`: Service data operations
   - Each has both mock and API implementations

3. **Token Manager** (`lib/data/services/token_manager.dart`)
   - Secure token storage using flutter_secure_storage
   - Access token and refresh token management

4. **API Constants** (`lib/data/services/api_constants.dart`)
   - Base URL configuration
   - All API endpoints
   - Timeout settings

## Switching to Real API

### Step 1: Update Base URL

Open `lib/data/services/api_constants.dart` and update the base URL:

```dart
static const String baseUrl = 'https://your-api-domain.com';
```

### Step 2: Enable API Mode

Open `lib/core/di/injection_container.dart` and change:

```dart
const bool _useMockData = true;  // Change to false
```

to:

```dart
const bool _useMockData = false;
```

### Step 3: Configure API Endpoints

Update endpoint paths in `lib/data/services/api_constants.dart` to match your backend:

```dart
// Example: If your login endpoint is /v1/auth/login
static const String login = '$apiVersion/auth/login';
```

### Step 4: Adjust Response Parsing

The app expects specific JSON response formats. Update `fromJson` methods in models if your API returns different formats:

#### Expected Auth Login Response
```json
{
  "access_token": "eyJhbGc...",
  "refresh_token": "eyJhbGc...",
  "user": {
    "id": "123",
    "email": "user@example.com",
    "name": "John Doe",
    "role": "user",
    "profile_image_url": "https://..."
  }
}
```

#### Expected Services List Response
```json
{
  "services": [
    {
      "id": "1",
      "name": "Wedding Photography",
      "description": "Professional photography...",
      "image_url": "https://...",
      "price": 1500.0,
      "category": "Photography",
      "is_active": true
    }
  ]
}
```

Or simply:
```json
[
  {
    "id": "1",
    "name": "Wedding Photography",
    ...
  }
]
```

### Step 5: Test API Integration

1. **Test Authentication**
   ```bash
   flutter run
   # Try logging in with real credentials
   ```

2. **Test Service Loading**
   - Navigate to home screen
   - Check if services load from API
   - Verify error handling

3. **Test Token Refresh**
   - Let access token expire
   - Verify automatic refresh works

## API Client Features

### Automatic Token Management

The API client automatically:
- Adds Bearer token to all requests
- Refreshes expired tokens
- Retries failed requests after refresh

### Error Handling

Custom exceptions for different error types:
- `NoInternetException`: No network connection
- `TimeoutException`: Request timeout
- `UnauthorizedException`: 401 errors
- `ServerException`: 5xx errors
- `ValidationException`: 422 validation errors

### Logging

In development, all requests and responses are logged using PrettyDioLogger.

**Production**: Disable logging by commenting out in `api_client.dart`:

```dart
// _dio.interceptors.add(PrettyDioLogger(...));
```

## Repository Pattern

Each repository has two implementations:

### Mock Implementation (Current)
```dart
Future<List<ServiceModel>> _mockGetServices() async {
  await Future.delayed(const Duration(milliseconds: 800));
  return List.from(_mockServices);
}
```

### API Implementation
```dart
Future<List<ServiceModel>> _apiGetServices() async {
  final response = await _apiClient!.get(ApiConstants.services);
  final List<dynamic> data = response.data['services'] ?? response.data;
  return data.map((json) => ServiceModel.fromJson(json)).toList();
}
```

## Testing Credentials (Mock Mode)

When using mock data:
- Any email format works
- Password must be 6+ characters
- Or click "Use Demo Credentials" button

## Backend Requirements

Your backend API should:

1. **Support JWT Authentication**
   - Access tokens (short-lived, e.g., 15 minutes)
   - Refresh tokens (long-lived, e.g., 7 days)

2. **Return Proper HTTP Status Codes**
   - 200: Success
   - 401: Unauthorized (triggers token refresh)
   - 422: Validation errors
   - 500: Server errors

3. **Accept/Return JSON**
   - Content-Type: application/json
   - Accept: application/json

4. **Support CORS** (if using web version)

## Advanced Configuration

### Custom Headers

Add custom headers in `api_client.dart`:

```dart
_dio.options = BaseOptions(
  baseUrl: ApiConstants.baseUrl,
  headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'X-Custom-Header': 'value',
  },
);
```

### Timeout Configuration

Adjust timeouts in `api_constants.dart`:

```dart
static const Duration connectionTimeout = Duration(seconds: 30);
static const Duration receiveTimeout = Duration(seconds: 30);
```

### Token Refresh Logic

Customize token refresh in `api_client.dart`:

```dart
Future<bool> _refreshToken() async {
  // Custom refresh logic here
}
```

## Troubleshooting

### Issue: "No Internet Connection" Error
- Check device internet connection
- Verify base URL is correct
- Check firewall/proxy settings

### Issue: "Unauthorized" Errors
- Verify token format matches backend expectations
- Check token expiration logic
- Ensure refresh token endpoint is correct

### Issue: JSON Parsing Errors
- Compare API response with expected format
- Update `fromJson` methods in models
- Check for null/optional fields

### Issue: CORS Errors (Web)
- Enable CORS on backend
- Add your domain to allowed origins
- Configure proper headers

## Migration Checklist

- [ ] Update base URL in api_constants.dart
- [ ] Set `_useMockData = false` in injection_container.dart
- [ ] Verify all API endpoints match backend
- [ ] Test login flow with real credentials
- [ ] Test service loading
- [ ] Test token refresh mechanism
- [ ] Test error handling
- [ ] Update fromJson methods if needed
- [ ] Disable debug logging for production
- [ ] Test on real device with network

## Support

For issues or questions:
1. Check this guide
2. Review CLAUDE.md for architecture details
3. Check API client logs for request/response details
4. Verify backend API is working (use Postman/cURL)

---

**Note**: Keep `_useMockData = true` during UI development. Switch to API mode only when backend is ready and tested.
