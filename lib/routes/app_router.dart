import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wedly/logic/blocs/auth/auth_bloc.dart';
import 'package:wedly/logic/blocs/auth/auth_state.dart';
import 'package:wedly/presentation/screens/auth/login_screen.dart';
import 'package:wedly/presentation/screens/auth/role_selector_screen.dart';
import 'package:wedly/presentation/screens/provider/provider_navigation_wrapper.dart';
import 'package:wedly/presentation/screens/user/user_navigation_wrapper.dart';

class AppRouter {
  static const String login = '/login';
  static const String roleSelector = '/role-selector';
  static const String userHome = '/user';
  static const String providerHome = '/provider';

  static void goToLogin(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  static void goToRoleSelector(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const RoleSelectorScreen()),
    );
  }

  static void goToUserHome(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const UserNavigationWrapper()),
      (route) => false,
    );
  }

  static void goToProviderHome(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const ProviderNavigationWrapper()),
      (route) => false,
    );
  }

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case roleSelector:
        return MaterialPageRoute(
          builder: (_) => const RoleSelectorScreen(),
        );
      case userHome:
        return MaterialPageRoute(
          builder: (_) => const UserNavigationWrapper(),
        );
      case providerHome:
        return MaterialPageRoute(
          builder: (_) => const ProviderNavigationWrapper(),
        );
      default:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
    }
  }

  static Widget getInitialRoute(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          // Check role and navigate accordingly
          // For now, show role selector
          return const RoleSelectorScreen();
        }
        return const LoginScreen();
      },
    );
  }
}

