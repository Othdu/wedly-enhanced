import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wedly/core/constants/app_strings.dart';
import 'package:wedly/logic/blocs/auth/auth_bloc.dart';
import 'package:wedly/logic/blocs/auth/auth_event.dart';
import 'package:wedly/logic/blocs/auth/auth_state.dart';
import 'package:wedly/presentation/widgets/profile_picture_widget.dart';

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
                            // TODO: Navigate to change password screen
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'تغيير كلمة المرور - قريباً',
                                  textDirection: TextDirection.rtl,
                                ),
                              ),
                            );
                          },
                        ),
                        _buildMenuItem(
                          context,
                          icon: Icons.location_on_outlined,
                          title: AppStrings.address,
                          onTap: () {
                            // TODO: Navigate to address screen
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'العنوان - قريباً',
                                  textDirection: TextDirection.rtl,
                                ),
                              ),
                            );
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
                        _buildMenuItem(
                          context,
                          icon: Icons.notifications_outlined,
                          title: AppStrings.notifications,
                          onTap: () {
                            // TODO: Navigate to notifications settings
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'الإشعارات - قريباً',
                                  textDirection: TextDirection.rtl,
                                ),
                              ),
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
            Icon(
              icon,
              size: 24,
              color: isDestructive ? Colors.red.shade600 : Colors.grey.shade700,
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
