import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wedly/core/di/injection_container.dart';
import 'package:wedly/core/services/connectivity_service.dart';
import 'package:wedly/core/theme/app_theme.dart';
import 'package:wedly/logic/blocs/auth/auth_bloc.dart';
import 'package:wedly/logic/blocs/home/home_bloc.dart';
import 'package:wedly/logic/blocs/cart/cart_bloc.dart';
import 'package:wedly/logic/blocs/booking/booking_bloc.dart';
import 'package:wedly/logic/blocs/review/review_bloc.dart';
import 'package:wedly/logic/blocs/banner/banner_bloc.dart';
import 'package:wedly/presentation/screens/splash/splash_screen.dart';
import 'package:wedly/presentation/widgets/auth_session_listener.dart';
import 'package:wedly/routes/app_router.dart';

/// Global navigator key for navigation from anywhere in the app
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Setup dependency injection
  await setupDependencyInjection();

  // Initialize connectivity service
  await ConnectivityService().initialize();

  runApp(const WedlyApp());
}

class WedlyApp extends StatelessWidget {
  const WedlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (context) => getIt<AuthBloc>()),
        BlocProvider<HomeBloc>(create: (context) => getIt<HomeBloc>()),
        BlocProvider<CartBloc>(create: (context) => getIt<CartBloc>()),
        BlocProvider<BookingBloc>(create: (context) => getIt<BookingBloc>()),
        BlocProvider<ReviewBloc>(create: (context) => getIt<ReviewBloc>()),
        BlocProvider<BannerBloc>(create: (context) => getIt<BannerBloc>()),
      ],
      child: AuthSessionListener(
        child: MaterialApp(
          navigatorKey: navigatorKey,
          title: 'Wedly',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.light,
          locale: const Locale('ar', 'SA'), // Arabic locale
          supportedLocales: const [Locale('ar', 'SA'), Locale('en', 'US')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const AppInitializer(),
          onGenerateRoute: AppRouter.onGenerateRoute,
        ),
      ),
    );
  }
}

class AppInitializer extends StatelessWidget {
  const AppInitializer({super.key});

  @override
  Widget build(BuildContext context) {
    // Always start with splash screen - it handles navigation to onboarding
    return const SplashScreen();
  }
}
