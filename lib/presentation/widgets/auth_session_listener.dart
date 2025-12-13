import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wedly/logic/blocs/auth/auth_bloc.dart';
import 'package:wedly/logic/blocs/auth/auth_state.dart';
import 'package:wedly/routes/app_router.dart';
import 'package:wedly/main.dart' show navigatorKey;

/// Global listener for auth state changes
/// Shows snackbar when session expires and navigates to login
class AuthSessionListener extends StatelessWidget {
  final Widget child;

  const AuthSessionListener({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) {
        // Only listen when going from authenticated to unauthenticated
        // and the previous state was authenticated (not initial/loading)
        final shouldListen = previous is AuthAuthenticated && current is AuthUnauthenticated;
        if (shouldListen) {
          print('🔔 AuthSessionListener: Detected session expiry, will logout');
        }
        return shouldListen;
      },
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          print('🔔 AuthSessionListener: Executing logout navigation');

          // Use a post-frame callback to ensure navigation happens after build
          WidgetsBinding.instance.addPostFrameCallback((_) {
            try {
              final navContext = navigatorKey.currentContext;

              if (navContext == null) {
                print('❌ AuthSessionListener: Navigator context is null');
                return;
              }

              // Show session expired message using the global navigator context
              ScaffoldMessenger.of(navContext).showSnackBar(
                const SnackBar(
                  content: Text('جلستك انتهت. يرجى تسجيل الدخول مرة أخرى.'),
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 3),
                ),
              );

              // Navigate to login screen using the global navigator
              navigatorKey.currentState?.pushNamedAndRemoveUntil(
                AppRouter.login,
                (route) => false, // Clear navigation stack
              );

              print('✅ AuthSessionListener: Navigation to login completed');
            } catch (e) {
              print('❌ AuthSessionListener: Navigation failed: $e');
            }
          });
        }
      },
      child: child,
    );
  }
}
