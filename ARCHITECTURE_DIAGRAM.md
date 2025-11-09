# Wedly Architecture Diagram

## High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     PRESENTATION LAYER                       │
│                      (lib/presentation/)                     │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │   Auth       │  │    User      │  │   Provider   │      │
│  │   Screens    │  │   Screens    │  │   Screens    │      │
│  ├──────────────┤  ├──────────────┤  ├──────────────┤      │
│  │ • Login      │  │ • Home       │  │ • Dashboard  │      │
│  │ • Signup     │  │ • Profile    │  │ • Profile    │      │
│  │ • Role       │  │ • Nav        │  │ • Nav        │      │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘      │
│         │                 │                 │               │
│         └─────────────────┼─────────────────┘               │
│                           │                                 │
│                  ┌────────▼────────┐                        │
│                  │  Reusable       │                        │
│                  │  Widgets        │                        │
│                  │  • ServiceCard  │                        │
│                  └─────────────────┘                        │
└──────────────────────────┬──────────────────────────────────┘
                           │ BlocBuilder/BlocListener
                           │
┌──────────────────────────▼──────────────────────────────────┐
│                      LOGIC LAYER                             │
│                      (lib/logic/blocs/)                      │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌────────────────┐  ┌────────────────┐  ┌──────────────┐  │
│  │   AuthBloc     │  │   HomeBloc     │  │ ServiceBloc  │  │
│  ├────────────────┤  ├────────────────┤  ├──────────────┤  │
│  │ Events:        │  │ Events:        │  │ Events:      │  │
│  │ • Login        │  │ • LoadServices │  │ • Load       │  │
│  │ • Logout       │  │ • LoadCategory │  │ • Update     │  │
│  │ • CheckStatus  │  │                │  │              │  │
│  │                │  │ States:        │  │ States:      │  │
│  │ States:        │  │ • Initial      │  │ • Initial    │  │
│  │ • Initial      │  │ • Loading      │  │ • Loading    │  │
│  │ • Loading      │  │ • Loaded       │  │ • Loaded     │  │
│  │ • Auth'd       │  │ • Error        │  │ • Error      │  │
│  │ • Unauth'd     │  │                │  │              │  │
│  │ • Error        │  │                │  │              │  │
│  └───────┬────────┘  └───────┬────────┘  └──────┬───────┘  │
│          │                   │                   │          │
│          └───────────────────┼───────────────────┘          │
│                              │ Repository calls             │
└──────────────────────────────▼──────────────────────────────┘
                               │
┌──────────────────────────────▼──────────────────────────────┐
│                       DATA LAYER                             │
│                     (lib/data/)                              │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────────────────────────────────────────────────┐   │
│  │              REPOSITORIES                            │   │
│  ├──────────────────────────────────────────────────────┤   │
│  │                                                      │   │
│  │  ┌─────────────────────┐  ┌────────────────────┐   │   │
│  │  │  AuthRepository     │  │ ServiceRepository  │   │   │
│  │  ├─────────────────────┤  ├────────────────────┤   │   │
│  │  │ if useMockData:     │  │ if useMockData:    │   │   │
│  │  │   return mock()     │  │   return mock()    │   │   │
│  │  │ else:               │  │ else:              │   │   │
│  │  │   return api()      │  │   return api()     │   │   │
│  │  └──────────┬──────────┘  └─────────┬──────────┘   │   │
│  │             │                       │              │   │
│  │             └───────────┬───────────┘              │   │
│  └─────────────────────────┼──────────────────────────┘   │
│                            │                               │
│                   ┌────────▼────────┐                      │
│                   │    MODELS       │                      │
│                   ├─────────────────┤                      │
│                   │ • UserModel     │                      │
│                   │ • ServiceModel  │                      │
│                   │                 │                      │
│                   │ Features:       │                      │
│                   │ • fromJson()    │                      │
│                   │ • toJson()      │                      │
│                   │ • Equatable     │                      │
│                   │ • copyWith()    │                      │
│                   └─────────────────┘                      │
│                            │                               │
│       ┌────────────────────┼────────────────────┐          │
│       │                    │                    │          │
│  ┌────▼────┐         ┌─────▼─────┐      ┌──────▼──────┐   │
│  │  Mock   │         │ API Client│      │   Token     │   │
│  │  Data   │         │ (Dio)     │      │   Manager   │   │
│  ├─────────┤         ├───────────┤      ├─────────────┤   │
│  │ Hardcoded│        │• GET      │      │• Save Token │   │
│  │ Services │        │• POST     │      │• Get Token  │   │
│  │ with     │        │• PUT      │      │• Refresh    │   │
│  │ delays   │        │• PATCH    │      │• Clear      │   │
│  └─────────┘         │• DELETE   │      │             │   │
│                      │           │      │ Storage:    │   │
│                      │• Logging  │      │ Encrypted   │   │
│                      │• Refresh  │      └─────────────┘   │
│                      │• Retry    │                        │
│                      └─────┬─────┘                        │
│                            │                              │
│                    ┌───────▼────────┐                     │
│                    │ API Constants  │                     │
│                    ├────────────────┤                     │
│                    │• Base URL      │                     │
│                    │• Endpoints     │                     │
│                    │• Timeouts      │                     │
│                    └────────────────┘                     │
│                            │                              │
│                    ┌───────▼────────┐                     │
│                    │ API Exceptions │                     │
│                    ├────────────────┤                     │
│                    │• NoInternet    │                     │
│                    │• Timeout       │                     │
│                    │• Unauthorized  │                     │
│                    │• ServerError   │                     │
│                    │• etc.          │                     │
│                    └────────────────┘                     │
└─────────────────────────────────────────────────────────┘
                            │
                            ▼
                    ┌───────────────┐
                    │   Backend     │
                    │   API         │
                    │  (Future)     │
                    └───────────────┘
```

## Dependency Injection Flow

```
┌─────────────────────────────────────────────────┐
│         GetIt Container (Singleton)              │
│         (lib/core/di/injection_container.dart)  │
├─────────────────────────────────────────────────┤
│                                                  │
│  Initialization Order:                          │
│                                                  │
│  1. FlutterSecureStorage (Singleton)            │
│       │                                          │
│       ▼                                          │
│  2. TokenManager (Singleton)                    │
│       │                                          │
│       ▼                                          │
│  3. ApiClient (Singleton)                       │
│       │                                          │
│       ▼                                          │
│  4. Repositories (Singletons)                   │
│       ├─► AuthRepository                        │
│       └─► ServiceRepository                     │
│       │                                          │
│       ▼                                          │
│  5. BLoCs (Factories - new instance each time)  │
│       ├─► AuthBloc                              │
│       ├─► HomeBloc                              │
│       └─► ServiceBloc                           │
│                                                  │
│  Mode Switch: _useMockData flag                 │
│    true  → Repositories use mock data           │
│    false → Repositories use ApiClient           │
└─────────────────────────────────────────────────┘
```

## Data Flow Example: Loading Services

```
┌──────────────────────────────────────────────────────────┐
│ 1. User opens Home Screen                                │
└────────────────────────┬─────────────────────────────────┘
                         │
                         ▼
┌──────────────────────────────────────────────────────────┐
│ 2. UI dispatches HomeServicesRequested event             │
│    context.read<HomeBloc>().add(HomeServicesRequested()) │
└────────────────────────┬─────────────────────────────────┘
                         │
                         ▼
┌──────────────────────────────────────────────────────────┐
│ 3. HomeBloc receives event                               │
│    • Emits HomeLoading state                             │
│    • UI shows loading spinner                            │
└────────────────────────┬─────────────────────────────────┘
                         │
                         ▼
┌──────────────────────────────────────────────────────────┐
│ 4. HomeBloc calls ServiceRepository.getServices()        │
└────────────────────────┬─────────────────────────────────┘
                         │
                 ┌───────┴───────┐
                 │               │
         ┌───────▼──────┐  ┌─────▼──────────┐
         │ Mock Mode    │  │ API Mode       │
         │              │  │                │
         │ • Delay 800ms│  │ • ApiClient    │
         │ • Return     │  │   GET /services│
         │   hardcoded  │  │ • Parse JSON   │
         │   services   │  │ • Return models│
         └───────┬──────┘  └─────┬──────────┘
                 │               │
                 └───────┬───────┘
                         │
                         ▼
┌──────────────────────────────────────────────────────────┐
│ 5. HomeBloc receives List<ServiceModel>                  │
│    • Emits HomeLoaded(services, categories)              │
└────────────────────────┬─────────────────────────────────┘
                         │
                         ▼
┌──────────────────────────────────────────────────────────┐
│ 6. UI rebuilds with BlocBuilder                          │
│    • Loading spinner hides                               │
│    • ServiceCards display in grid                        │
│    • User sees wedding services                          │
└──────────────────────────────────────────────────────────┘
```

## Authentication Flow

```
┌──────────────────────────────────────────────────────────┐
│ 1. User enters credentials and taps Login                │
└────────────────────────┬─────────────────────────────────┘
                         │
                         ▼
┌──────────────────────────────────────────────────────────┐
│ 2. UI dispatches AuthLoginRequested event                │
│    • email: "user@example.com"                           │
│    • password: "password123"                             │
│    • role: UserRole.user                                 │
└────────────────────────┬─────────────────────────────────┘
                         │
                         ▼
┌──────────────────────────────────────────────────────────┐
│ 3. AuthBloc receives event                               │
│    • Emits AuthLoading state                             │
│    • UI shows loading indicator                          │
└────────────────────────┬─────────────────────────────────┘
                         │
                         ▼
┌──────────────────────────────────────────────────────────┐
│ 4. AuthBloc calls AuthRepository.login()                 │
└────────────────────────┬─────────────────────────────────┘
                         │
                 ┌───────┴───────┐
                 │               │
         ┌───────▼──────┐  ┌─────▼──────────────┐
         │ Mock Mode    │  │ API Mode           │
         │              │  │                    │
         │ • Delay 1s   │  │ • POST /auth/login │
         │ • Create mock│  │ • Receive tokens   │
         │   UserModel  │  │ • TokenManager     │
         │ • Always     │  │   saves tokens     │
         │   succeeds   │  │ • Parse UserModel  │
         └───────┬──────┘  └─────┬──────────────┘
                 │               │
                 └───────┬───────┘
                         │
                         ▼
┌──────────────────────────────────────────────────────────┐
│ 5. AuthBloc receives UserModel                           │
│    • Emits AuthAuthenticated(user)                       │
└────────────────────────┬─────────────────────────────────┘
                         │
                         ▼
┌──────────────────────────────────────────────────────────┐
│ 6. Main App (BlocBuilder) rebuilds                       │
│    • Detects AuthAuthenticated state                     │
│    • Navigates to Role Selector Screen                   │
└────────────────────────┬─────────────────────────────────┘
                         │
                         ▼
┌──────────────────────────────────────────────────────────┐
│ 7. User selects role                                     │
│    • User taps "Browse Services" (User mode)             │
│    • OR "Manage Services" (Provider mode)                │
└────────────────────────┬─────────────────────────────────┘
                         │
                 ┌───────┴───────┐
                 │               │
         ┌───────▼──────┐  ┌─────▼──────────┐
         │ User Mode    │  │ Provider Mode  │
         │              │  │                │
         │ Navigate to  │  │ Navigate to    │
         │ User         │  │ Provider       │
         │ Home         │  │ Dashboard      │
         └──────────────┘  └────────────────┘
```

## Error Handling Flow

```
┌──────────────────────────────────────────────────────────┐
│ API Request (e.g., GET /services)                        │
└────────────────────────┬─────────────────────────────────┘
                         │
                         ▼
                    Try/Catch
                         │
           ┌─────────────┼─────────────┐
           │ Success     │    Error    │
           ▼             ▼
    ┌──────────┐   ┌─────────────────┐
    │ Return   │   │ DioException?   │
    │ Data     │   └────────┬────────┘
    └──────────┘            │
                     ┌──────┴───────────────────────┐
                     │ _handleError()               │
                     │ Maps to custom exceptions:   │
                     ├──────────────────────────────┤
                     │ • Timeout → TimeoutException │
                     │ • No Internet → NoInternet...│
                     │ • 401 → Unauthorized...      │
                     │ • 403 → Forbidden...         │
                     │ • 404 → NotFound...          │
                     │ • 422 → Validation...        │
                     │ • 5xx → Server...            │
                     │ • Other → Unknown...         │
                     └──────┬───────────────────────┘
                            │
                            ▼
                  ┌──────────────────┐
                  │ BLoC catches     │
                  │ exception        │
                  │                  │
                  │ Emits Error      │
                  │ state with       │
                  │ message          │
                  └─────────┬────────┘
                            │
                            ▼
                  ┌──────────────────┐
                  │ UI shows         │
                  │ error message    │
                  │ to user          │
                  └──────────────────┘
```

## Token Refresh Flow

```
┌──────────────────────────────────────────────────────────┐
│ API Request with expired access token                    │
└────────────────────────┬─────────────────────────────────┘
                         │
                         ▼
┌──────────────────────────────────────────────────────────┐
│ Server returns 401 Unauthorized                          │
└────────────────────────┬─────────────────────────────────┘
                         │
                         ▼
┌──────────────────────────────────────────────────────────┐
│ ApiClient interceptor catches 401                        │
│ • Calls _refreshToken()                                  │
└────────────────────────┬─────────────────────────────────┘
                         │
                         ▼
┌──────────────────────────────────────────────────────────┐
│ POST /auth/refresh with refresh_token                    │
└────────────────────────┬─────────────────────────────────┘
                         │
                 ┌───────┴────────┐
                 │                │
         ┌───────▼──────┐  ┌──────▼─────────┐
         │ Success      │  │ Failure        │
         │              │  │                │
         │ • Get new    │  │ • Clear tokens │
         │   tokens     │  │ • Logout user  │
         │ • Save them  │  │ • Navigate to  │
         │ • Retry      │  │   login        │
         │   original   │  │                │
         │   request    │  │                │
         └───────┬──────┘  └────────────────┘
                 │
                 ▼
┌──────────────────────────────────────────────────────────┐
│ Original request succeeds with new token                 │
│ • User doesn't notice anything                           │
│ • Seamless experience                                    │
└──────────────────────────────────────────────────────────┘
```

## Navigation Tree

```
App Root (main.dart)
│
├── AppInitializer (BlocBuilder<AuthBloc>)
│   │
│   ├─[AuthInitial]──► SplashScreen
│   │
│   ├─[AuthLoading]──► Loading Spinner
│   │
│   ├─[AuthAuthenticated]──► RoleSelectorScreen
│   │                            │
│   │                            ├─[User Selected]──► UserNavigationWrapper
│   │                            │                        │
│   │                            │                        ├── UserHomeScreen (Tab 0)
│   │                            │                        │
│   │                            │                        └── UserProfileScreen (Tab 1)
│   │                            │
│   │                            └─[Provider Selected]──► ProviderNavigationWrapper
│   │                                                         │
│   │                                                         ├── ProviderDashboardScreen (Tab 0)
│   │                                                         │
│   │                                                         └── ProviderProfileScreen (Tab 1)
│   │
│   └─[AuthUnauthenticated]──► LoginScreen
│                                   │
│                                   └─[No account?]──► SignupScreen
│
└── onGenerateRoute handles named routes
```

## Summary

This architecture provides:
- **Clear separation** of concerns
- **Testable** components at every layer
- **Scalable** structure for growth
- **Flexible** mock/API switching
- **Maintainable** codebase with consistent patterns
- **Type-safe** data flow
- **Error resilient** with comprehensive exception handling

The app is ready for both development (mock mode) and production (API mode) use.
