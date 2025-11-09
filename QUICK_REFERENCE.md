# Wedly Quick Reference Card

## Quick Start

```bash
# Install dependencies
flutter pub get

# Run the app (mock data mode)
flutter run

# Build for production
flutter build apk         # Android
flutter build ios         # iOS (requires macOS)
flutter build web         # Web
```

## Test Credentials (Mock Mode)

- Any email format (e.g., `test@example.com`)
- Password: 6+ characters (e.g., `password123`)
- Or click "Use Demo Credentials" button

## Directory Structure

```
lib/
├── core/           → Theme, DI, Utils
├── data/           → Models, Repos, API
├── logic/          → BLoCs
├── presentation/   → Screens & Widgets
├── routes/         → Navigation
└── main.dart       → Entry point
```

## Key Files

| File | Purpose | When to Edit |
|------|---------|--------------|
| `lib/core/di/injection_container.dart` | DI setup, **Mock/API switch** | Switching modes |
| `lib/data/services/api_constants.dart` | **API endpoints & base URL** | Backend integration |
| `lib/data/services/api_client.dart` | HTTP client | Custom headers/logic |
| `lib/data/repositories/*.dart` | Data access | Add new API methods |
| `lib/logic/blocs/*/` | State management | New features/logic |

## Switch from Mock to API Mode

**File:** `lib/core/di/injection_container.dart`

```dart
// Line 15: Change from
const bool _useMockData = true;

// To
const bool _useMockData = false;
```

**Then update base URL in:** `lib/data/services/api_constants.dart`

```dart
static const String baseUrl = 'https://your-api.com';
```

## Common Commands

```bash
# Development
flutter run                      # Run in debug mode
flutter run --release            # Run in release mode
flutter hot reload              # Press 'r' in terminal

# Code Quality
flutter analyze                 # Check for issues
dart format .                   # Format code
flutter test                    # Run tests

# Dependencies
flutter pub get                 # Install dependencies
flutter pub upgrade             # Update dependencies
flutter pub outdated            # Check for updates

# Clean Build
flutter clean                   # Clean build files
flutter pub get                 # Reinstall
flutter run                     # Rebuild
```

## Project Architecture

```
UI → BLoC → Repository → API Client → Backend
     ↓         ↓           ↓
   Events   Mock/API    Token Manager
     ↓         ↓
   States   Models
```

## State Management Pattern

### Dispatch Event
```dart
context.read<AuthBloc>().add(
  AuthLoginRequested(email: email, password: password)
);
```

### Listen to State
```dart
BlocBuilder<AuthBloc, AuthState>(
  builder: (context, state) {
    if (state is AuthLoading) return LoadingSpinner();
    if (state is AuthAuthenticated) return HomePage();
    if (state is AuthError) return ErrorWidget(state.message);
    return LoginScreen();
  },
)
```

## Adding a New Feature

### 1. Create Model (if needed)
```dart
// lib/data/models/my_model.dart
class MyModel extends Equatable {
  final String id;
  final String name;

  const MyModel({required this.id, required this.name});

  factory MyModel.fromJson(Map<String, dynamic> json) => ...
  Map<String, dynamic> toJson() => ...
}
```

### 2. Add Repository Methods
```dart
// lib/data/repositories/my_repository.dart
class MyRepository {
  Future<List<MyModel>> getItems() async {
    if (useMockData) {
      return _mockGetItems();
    } else {
      return _apiGetItems();
    }
  }
}
```

### 3. Create BLoC
```dart
// lib/logic/blocs/my_feature/
// - my_event.dart
// - my_state.dart
// - my_bloc.dart

class MyBloc extends Bloc<MyEvent, MyState> {
  final MyRepository repository;

  MyBloc(this.repository) : super(MyInitial()) {
    on<LoadItems>(_onLoadItems);
  }

  Future<void> _onLoadItems(LoadItems event, Emitter emit) async {
    emit(MyLoading());
    try {
      final items = await repository.getItems();
      emit(MyLoaded(items));
    } catch (e) {
      emit(MyError(e.toString()));
    }
  }
}
```

### 4. Register in DI
```dart
// lib/core/di/injection_container.dart
getIt.registerFactory<MyBloc>(
  () => MyBloc(getIt<MyRepository>()),
);
```

### 5. Create UI
```dart
// lib/presentation/screens/my_screen.dart
BlocProvider(
  create: (_) => getIt<MyBloc>()..add(LoadItems()),
  child: MyScreen(),
)
```

## API Response Formats

### Login
```json
{
  "access_token": "eyJ...",
  "refresh_token": "eyJ...",
  "user": {
    "id": "123",
    "email": "user@example.com",
    "name": "John Doe",
    "role": "user"
  }
}
```

### Services List
```json
{
  "services": [
    {
      "id": "1",
      "name": "Photography",
      "description": "...",
      "image_url": "https://...",
      "price": 1500.0,
      "category": "Photography",
      "is_active": true
    }
  ]
}
```

## Error Handling

```dart
try {
  final result = await repository.method();
  emit(SuccessState(result));
} catch (e) {
  if (e is NoInternetException) {
    emit(ErrorState('No internet connection'));
  } else if (e is UnauthorizedException) {
    emit(ErrorState('Please login again'));
  } else {
    emit(ErrorState(e.toString()));
  }
}
```

## Navigation

```dart
// Push to screen
Navigator.of(context).push(
  MaterialPageRoute(builder: (_) => MyScreen()),
);

// Replace current screen
Navigator.of(context).pushReplacement(
  MaterialPageRoute(builder: (_) => MyScreen()),
);

// Clear stack and navigate
Navigator.of(context).pushAndRemoveUntil(
  MaterialPageRoute(builder: (_) => MyScreen()),
  (route) => false,
);

// Using AppRouter helpers
AppRouter.goToLogin(context);
AppRouter.goToUserHome(context);
AppRouter.goToProviderHome(context);
```

## Debugging Tips

### Check Auth State
```dart
final authState = context.read<AuthBloc>().state;
print('Current auth state: $authState');
```

### View API Logs
Look for `PrettyDioLogger` output in console showing:
- Request URL
- Headers
- Body
- Response data

### Check Stored Tokens
```dart
final tokenManager = getIt<TokenManager>();
final token = await tokenManager.getAccessToken();
print('Stored token: $token');
```

## File Naming Conventions

- Models: `my_model.dart`
- Repositories: `my_repository.dart`
- BLoCs: `my_bloc.dart`, `my_event.dart`, `my_state.dart`
- Screens: `my_screen.dart`
- Widgets: `my_widget.dart`

## Code Style

```dart
// Use const where possible
const Text('Hello');

// Use named parameters
MyWidget(
  title: 'Title',
  onTap: () {},
);

// Use arrow functions for simple returns
String getName() => user.name;

// Use meaningful variable names
final authenticatedUser = await repository.login();

// Add documentation
/// Logs in user with email and password.
/// Returns [UserModel] on success.
/// Throws [ApiException] on failure.
Future<UserModel> login({...});
```

## Performance Tips

- Use `const` constructors
- Avoid rebuilding entire trees (use BlocBuilder selectively)
- Use `ListView.builder` for long lists
- Cache images with `CachedNetworkImage`
- Implement pagination for large data sets

## Security Checklist

- [ ] Tokens stored securely (flutter_secure_storage)
- [ ] HTTPS for all API calls
- [ ] No sensitive data in logs (production)
- [ ] Input validation on forms
- [ ] Disable debug logging in release builds

## Useful Resources

- **CLAUDE.md** - Full project documentation
- **API_INTEGRATION_GUIDE.md** - Backend integration steps
- **IMPLEMENTATION_SUMMARY.md** - What's built
- **ARCHITECTURE_DIAGRAM.md** - Visual architecture
- **This file** - Quick reference

## Support

Run into issues? Check:
1. Flutter version: `flutter --version` (3.x required)
2. Dependencies: `flutter pub get`
3. Clean build: `flutter clean && flutter pub get`
4. Analyze code: `flutter analyze`
5. Check docs above

## Version Info

- Flutter: 3.x
- Dart: 3.x
- Architecture: Clean Architecture
- State Management: BLoC
- Networking: Dio
- DI: GetIt

---

**Happy Coding!** 🎉
