import 'package:flutter/material.dart';
import 'package:wedly/core/constants/app_colors.dart';
import 'package:wedly/core/utils/app_preferences.dart';
import 'package:wedly/presentation/screens/onboarding/onboarding_screen_new.dart';
import 'package:wedly/presentation/screens/auth/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
    _navigateToNextScreen();
  }

  void _initializeAnimation() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _controller.forward();
  }

  void _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    // Check if this is first launch
    final prefs = await AppPreferences.getInstance();
    if (!mounted) return;

    final isFirstLaunch = prefs.isFirstLaunch;

    if (isFirstLaunch) {
      // First time - show onboarding
      await prefs.setFirstLaunchCompleted();
      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const OnboardingScreenNew(),
        ),
      );
    } else {
      // Not first time - go directly to login
      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gold,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RichText(
                text: const TextSpan(
                  style: TextStyle(
                    fontSize: 56,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                  children: [
                    TextSpan(
                      text: 'We',
                      style: TextStyle(color: AppColors.black),
                    ),
                    TextSpan(
                      text: 'dly',
                      style: TextStyle(color: AppColors.white),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your Wedding, Our Passion',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.black.withValues(alpha: 0.7),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

