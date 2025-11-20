import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wedly/core/constants/app_strings.dart';
import 'package:wedly/logic/blocs/auth/auth_bloc.dart';
import 'package:wedly/logic/blocs/auth/auth_event.dart';
import 'package:wedly/logic/blocs/auth/auth_state.dart';
import 'package:wedly/logic/blocs/notification/notification_bloc.dart';
import 'package:wedly/logic/blocs/notification/notification_state.dart';
import 'package:wedly/presentation/widgets/profile_picture_widget.dart';
import 'package:wedly/routes/app_router.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          // Navigate to login screen when user logs out
          if (state is AuthUnauthenticated) {
            Navigator.of(
              context,
            ).pushNamedAndRemoveUntil('/login', (route) => false);
          }
        },
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthAuthenticated) {
              final user = state.user;
              return SingleChildScrollView(
                child: Column(
                  children: [
                    // Header Section with Profile Picture and Name
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.only(
                        top: MediaQuery.of(context).padding.top + 24,
                        bottom: 32,
                      ),
                      decoration: const BoxDecoration(color: Color(0xFFF5F5F5)),
                      child: Column(
                        children: [
                          // Profile Picture
                          ProfilePictureWidget(
                            profileImageUrl: user.profileImageUrl,
                            size: 120,
                            isEditable: false,
                            showEditIcon: false,
                          ),
                          const SizedBox(height: 16),
                          // Welcome Text
                          Text(
                            AppStrings.welcome2,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                            textDirection: TextDirection.rtl,
                          ),
                          const SizedBox(height: 4),
                          // User Name
                          Text(
                            user.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            textDirection: TextDirection.rtl,
                          ),
                        ],
                      ),
                    ),

                    // Profile Management Section
                    _buildSection(
                      context,
                      title: AppStrings.profileManagement,
                      items: [
                        _buildMenuItem(
                          context,
                          icon: Icons.person_outline,
                          title: AppStrings.editProfile,
                          onTap: () {
                            Navigator.of(
                              context,
                            ).pushNamed('/user-edit-profile');
                          },
                        ),
                        _buildMenuItem(
                          context,
                          icon: Icons.lock_outline,
                          title: AppStrings.changePassword,
                          onTap: () {
                            Navigator.of(
                              context,
                            ).pushNamed('/user-change-password');
                          },
                        ),
                        _buildMenuItem(
                          context,
                          icon: Icons.location_on_outlined,
                          title: AppStrings.address,
                          onTap: () {
                            Navigator.of(
                              context,
                            ).pushNamed('/user-address');
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Settings Section
                    _buildSection(
                      context,
                      title: AppStrings.settings,
                      items: [
                        BlocBuilder<NotificationBloc, NotificationState>(
                          builder: (context, notificationState) {
                            int unreadCount = 0;
                            if (notificationState is NotificationLoaded) {
                              unreadCount = notificationState.unreadCount;
                            }

                            return _buildMenuItem(
                              context,
                              icon: Icons.notifications_outlined,
                              title: AppStrings.notifications,
                              onTap: () {
                                Navigator.pushNamed(context, AppRouter.notificationsList);
                              },
                              badge: unreadCount > 0 ? unreadCount : null,
                            );
                          },
                        ),
                        _buildMenuItem(
                          context,
                          icon: Icons.article_outlined,
                          title: AppStrings.termsAndConditions,
                          onTap: () {
                            // TODO: Navigate to terms and conditions
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'الشروط والأحكام - قريباً',
                                  textDirection: TextDirection.rtl,
                                ),
                              ),
                            );
                          },
                        ),
                        _buildMenuItem(
                          context,
                          icon: Icons.help_outline,
                          title: AppStrings.helpAndSupport,
                          onTap: () {
                            // TODO: Navigate to help and support
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'المساعدة والدعم - قريباً',
                                  textDirection: TextDirection.rtl,
                                ),
                              ),
                            );
                          },
                        ),
                        _buildMenuItem(
                          context,
                          icon: Icons.logout,
                          title: AppStrings.logout,
                          onTap: () {
                            _showLogoutDialog(context);
                          },
                          isDestructive: true,
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> items,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              right: 8,
              left: 8,
              top: 12,
              bottom: 12,
            ),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFD4AF37),
                ),
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.right,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(children: items),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
    int? badge,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade200, width: 1),
          ),
        ),
        child: Row(
          children: [
            // Icon on the left (for RTL, this appears on left side)
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  icon,
                  size: 24,
                  color: isDestructive ? Colors.red.shade600 : Colors.grey.shade700,
                ),
                if (badge != null && badge > 0)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Center(
                        child: Text(
                          badge > 9 ? '9+' : '$badge',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            // Title
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: isDestructive ? Colors.red.shade600 : Colors.black87,
              ),
              textDirection: TextDirection.rtl,
            ),
            const Spacer(),
            // Arrow Icon on the right
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: isDestructive ? Colors.red.shade400 : Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.logout, color: Color(0xFFD4AF37), size: 60),
              const SizedBox(height: 16),
              const Text(
                'هل تريد تسجيل الخروج؟',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Color(0xFFD4AF37)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'إلغاء',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFD4AF37),
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                        context.read<AuthBloc>().add(
                          const AuthLogoutRequested(),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD4AF37),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'تسجيل الخروج',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
