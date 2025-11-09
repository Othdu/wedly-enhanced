import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wedly/core/constants/app_strings.dart';
import 'package:wedly/core/utils/enums.dart';
import 'package:wedly/logic/blocs/auth/auth_bloc.dart';
import 'package:wedly/logic/blocs/auth/auth_event.dart';
import 'package:wedly/logic/blocs/auth/auth_state.dart';
import 'package:wedly/routes/app_router.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppStrings.userProfile,
          textDirection: TextDirection.rtl,
        ),
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthAuthenticated) {
            final user = state.user;
            final roleText = user.role == UserRole.user 
                ? AppStrings.user 
                : AppStrings.provider;
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const SizedBox(height: 24),
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    user.name[0].toUpperCase(),
                    style: const TextStyle(fontSize: 40, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(
                      AppStrings.name,
                      textDirection: TextDirection.rtl,
                    ),
                    subtitle: Text(
                      user.name,
                      textDirection: TextDirection.rtl,
                    ),
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.email),
                    title: Text(
                      AppStrings.email,
                      textDirection: TextDirection.rtl,
                    ),
                    subtitle: Text(
                      user.email,
                      textDirection: TextDirection.rtl,
                    ),
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.badge),
                    title: Text(
                      AppStrings.role,
                      textDirection: TextDirection.rtl,
                    ),
                    subtitle: Text(
                      roleText,
                      textDirection: TextDirection.rtl,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    context.read<AuthBloc>().add(const AuthLogoutRequested());
                    AppRouter.goToLogin(context);
                  },
                  icon: const Icon(Icons.logout),
                  label: Text(
                    AppStrings.logout,
                    textDirection: TextDirection.rtl,
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ],
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

