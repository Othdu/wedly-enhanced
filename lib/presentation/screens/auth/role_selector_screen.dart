import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wedly/core/constants/app_strings.dart';
import 'package:wedly/core/utils/enums.dart';
import 'package:wedly/logic/blocs/auth/auth_bloc.dart';
import 'package:wedly/logic/blocs/auth/auth_event.dart';
import 'package:wedly/logic/blocs/auth/auth_state.dart';
import 'package:wedly/routes/app_router.dart';

class RoleSelectorScreen extends StatelessWidget {
  const RoleSelectorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! AuthAuthenticated) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = state.user;
        final roleText = user.role == UserRole.user 
            ? AppStrings.user 
            : AppStrings.provider;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              AppStrings.selectRole,
              textDirection: TextDirection.rtl,
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () {
                  context.read<AuthBloc>().add(const AuthLogoutRequested());
                },
              ),
            ],
          ),
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Spacer(),
                            Text(
                              '${AppStrings.welcome}، ${user.name}!',
                              style: Theme.of(context).textTheme.headlineMedium,
                              textAlign: TextAlign.center,
                              textDirection: TextDirection.rtl,
                            ),
                            const SizedBox(height: 48),
                            Text(
                              '${AppStrings.currentRole}: $roleText',
                              style: Theme.of(context).textTheme.titleLarge,
                              textDirection: TextDirection.rtl,
                            ),
                            const SizedBox(height: 48),
                            ElevatedButton.icon(
                              onPressed: () {
                                context.read<AuthBloc>().add(
                                      const AuthRoleChanged(UserRole.user),
                                    );
                                AppRouter.goToUserHome(context);
                              },
                              icon: const Icon(Icons.person),
                              label: Text(
                                AppStrings.continueAsUser,
                                textDirection: TextDirection.rtl,
                              ),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 16,
                                ),
                                minimumSize: const Size(200, 50),
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () {
                                context.read<AuthBloc>().add(
                                      const AuthRoleChanged(UserRole.provider),
                                    );
                                AppRouter.goToProviderHome(context);
                              },
                              icon: const Icon(Icons.business),
                              label: Text(
                                AppStrings.continueAsProvider,
                                textDirection: TextDirection.rtl,
                              ),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 16,
                                ),
                                minimumSize: const Size(200, 50),
                              ),
                            ),
                            const Spacer(),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

