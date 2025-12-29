import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../logic/blocs/auth/auth_bloc.dart';
import '../../../logic/blocs/auth/auth_state.dart';
import '../../../logic/blocs/provider_service/provider_service_bloc.dart';
import '../../../logic/blocs/provider_service/provider_service_event.dart';
import '../../../logic/blocs/provider_service/provider_service_state.dart';
import '../../../routes/app_router.dart';
import '../../widgets/provider_service_card.dart';
import '../../widgets/error_view.dart';

class ProviderServicesScreen extends StatefulWidget {
  const ProviderServicesScreen({super.key});

  @override
  State<ProviderServicesScreen> createState() => _ProviderServicesScreenState();
}

class _ProviderServicesScreenState extends State<ProviderServicesScreen> {
  String? _providerId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated) {
        _providerId = authState.user.id;
        context.read<ProviderServiceBloc>().add(
          FetchProviderServices(_providerId!),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.greyBackground,
      body: BlocConsumer<ProviderServiceBloc, ProviderServiceState>(
        listener: (context, state) {
          if (state is ServiceAdded) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            // Refresh services list
            if (_providerId != null) {
              context.read<ProviderServiceBloc>().add(
                RefreshProviderServices(_providerId!),
              );
            }
          }

          if (state is ServiceUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            // Refresh services list
            if (_providerId != null) {
              context.read<ProviderServiceBloc>().add(
                RefreshProviderServices(_providerId!),
              );
            }
          }

          if (state is ServiceDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            // Refresh services list
            if (_providerId != null) {
              context.read<ProviderServiceBloc>().add(
                RefreshProviderServices(_providerId!),
              );
            }
          }

          if (state is ProviderServiceError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ProviderServiceLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
            );
          }

          if (state is ProviderServiceError) {
            return ErrorView(
              error: state.error,
              onRetry: () {
                if (_providerId != null) {
                  context.read<ProviderServiceBloc>().add(
                    FetchProviderServices(_providerId!),
                  );
                }
              },
            );
          }

          if (state is ProviderServicesEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_busy, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final result = await Navigator.pushNamed(
                        context,
                        AppRouter.providerAddService,
                      );
                      // Refresh services list if a service was added
                      if (result == true && mounted) {
                        final authState = context.read<AuthBloc>().state;
                        if (authState is AuthAuthenticated) {
                          context.read<ProviderServiceBloc>().add(
                            FetchProviderServices(authState.user.id),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.add, color: Colors.white, size: 20),
                    label: const Text(
                      ' خدمة',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4AF37), // gold color
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          30,
                        ), // rounded button
                      ),
                      elevation: 0, // flat look
                    ),
                  ),
                ],
              ),
            );
          }

          if (state is ProviderServicesLoaded) {
            final services = state.services;

            return SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  // Add Service Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Directionality(
                        textDirection: TextDirection
                            .ltr, // forces icon to appear on the left
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final result = await Navigator.pushNamed(
                              context,
                              AppRouter.providerAddService,
                            );
                            // Refresh services list if a service was added
                            if (result == true && mounted) {
                              final authState = context.read<AuthBloc>().state;
                              if (authState is AuthAuthenticated) {
                                context.read<ProviderServiceBloc>().add(
                                  FetchProviderServices(authState.user.id),
                                );
                              }
                            }
                          },
                          icon: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 20,
                          ),
                          label: const Text(
                            'إضافة خدمة',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(
                              0xFFD4AF37,
                            ), // matches #D4AF37
                            padding: const EdgeInsets.symmetric(
                              horizontal: 30,
                              vertical: 15,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                1000,
                              ), // fully circular / pill shape
                            ),
                            elevation: 0, // flat, no shadow
                            minimumSize: const Size(0, 0),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                  // Services Grid
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async {
                        if (_providerId != null) {
                          context.read<ProviderServiceBloc>().add(
                            RefreshProviderServices(_providerId!),
                          );
                        }
                      },
                      color: Colors.white,
                      child: GridView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.68,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                        itemCount: services.length,
                        itemBuilder: (context, index) {
                          final service = services[index];
                          return ProviderServiceCard(
                            service: service,
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('قريباً: تفاصيل الخدمة'),
                                ),
                              );
                            },
                            onEdit: () async {
                              // Route to different screens based on whether it's a venue
                              final isVenue = service.chairCount != null;
                              final routeName = isVenue
                                  ? AppRouter.providerEditVenueService
                                  : AppRouter.providerEditGeneralService;

                              final result = await Navigator.pushNamed(
                                context,
                                routeName,
                                arguments: {'service': service},
                              );
                              // Refresh services list if service was edited
                              if (result == true && mounted) {
                                final authState = context
                                    .read<AuthBloc>()
                                    .state;
                                if (authState is AuthAuthenticated) {
                                  context.read<ProviderServiceBloc>().add(
                                    FetchProviderServices(authState.user.id),
                                  );
                                }
                              }
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
