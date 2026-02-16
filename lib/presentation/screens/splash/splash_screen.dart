import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wedly/core/constants/app_colors.dart';
import 'package:wedly/core/utils/app_preferences.dart';
import 'package:wedly/core/utils/enums.dart';
import 'package:wedly/logic/blocs/auth/auth_bloc.dart';
import 'package:wedly/logic/blocs/auth/auth_state.dart';
import 'package:wedly/presentation/screens/onboarding/onboarding_screen_new.dart';
import 'package:wedly/presentation/screens/auth/login_screen.dart';
import 'package:wedly/presentation/screens/user/user_navigation_wrapper.dart';
import 'package:wedly/presentation/screens/provider/provider_navigation_wrapper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _logoController;
  late final AnimationController _textController;
  late final AnimationController _particleController;
  late final AnimationController _rippleController;
  late final AnimationController _shimmerController;
  late final AnimationController _zoomController;

  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<double> _logoRotation;
  late final Animation<double> _letterSpacing;
  late final Animation<Offset> _textSlide;
  late final Animation<double> _textFade;
  late final Animation<double> _textScale;
  late final Animation<double> _rippleAnimation;
  late final Animation<double> _shimmerAnimation;
  late final Animation<double> _zoomAnimation;

  late final List<_Particle> _particles;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _initParticles();
    _startAnimations();
    _navigateToNextScreen();
  }

  void _initAnimations() {
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _zoomController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..forward();

    _logoFade = CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
    );

    _logoScale = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.1, 0.8, curve: Curves.elasticOut),
      ),
    );

    _logoRotation = Tween<double>(begin: -0.1, end: 0.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack),
    );

    _letterSpacing = Tween<double>(begin: -2, end: 1).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutExpo),
    );

    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.8),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeOutBack));

    _textFade = CurvedAnimation(parent: _textController, curve: Curves.easeIn);
    _textScale = Tween<double>(begin: 0.85, end: 1.0)
        .animate(CurvedAnimation(parent: _textController, curve: Curves.easeOut));

    _rippleAnimation = CurvedAnimation(
      parent: _rippleController,
      curve: Curves.easeOutQuad,
    );

    _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0)
        .animate(CurvedAnimation(parent: _shimmerController, curve: Curves.linear));

    _zoomAnimation = Tween<double>(begin: 1.0, end: 1.08)
        .animate(CurvedAnimation(parent: _zoomController, curve: Curves.easeInOut));
  }

  void _initParticles() {
    _particles = List.generate(20, (_) => _Particle.random());
  }

  Future<void> _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _logoController.forward();
    _rippleController.forward();
    await Future.delayed(const Duration(milliseconds: 900));
    _textController.forward();
  }

  Future<void> _navigateToNextScreen() async {
    // Wait for animations to complete
    await Future.delayed(const Duration(milliseconds: 3800));
    if (!mounted || _hasNavigated) return;

    // Give extra time for AuthBloc to load from SharedPreferences
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted || _hasNavigated) return;

    _hasNavigated = true;

    final prefs = await AppPreferences.getInstance();
    if (!mounted) return;

    final isFirstLaunch = prefs.isFirstLaunch;
    final authState = context.read<AuthBloc>().state;

    // Debug: Print auth state
    debugPrint('🔍 SPLASH: Auth state type: ${authState.runtimeType}');
    if (authState is AuthAuthenticated) {
      debugPrint('🔍 SPLASH: User logged in - Role: ${authState.user.role}');
    }

    if (!mounted) return;

    Widget next;
    if (authState is AuthAuthenticated) {
      // User is logged in - go to their home screen
      debugPrint('✅ SPLASH: Navigating to ${authState.user.role == UserRole.provider ? "Provider" : "User"} home');
      next = authState.user.role == UserRole.provider
          ? const ProviderNavigationWrapper()
          : const UserNavigationWrapper();
    } else if (isFirstLaunch) {
      // First time launching app
      debugPrint('✅ SPLASH: First launch - navigating to onboarding');
      await prefs.setFirstLaunchCompleted();
      next = const OnboardingScreenNew();
    } else {
      // Not logged in - go to login
      debugPrint('✅ SPLASH: Not authenticated - navigating to login');
      next = const LoginScreen();
    }

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 900),
        pageBuilder: (_, __, ___) => next,
        transitionsBuilder: (_, anim, __, child) {
          final curved = CurvedAnimation(parent: anim, curve: Curves.easeInOut);
          return FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              scale: Tween(begin: 1.05, end: 1.0).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _particleController.dispose();
    _rippleController.dispose();
    _shimmerController.dispose();
    _zoomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        // This ensures we react when auth state changes
        // The navigation will happen in _navigateToNextScreen after delay
      },
      child: AnimatedBuilder(
        animation: _zoomAnimation,
        builder: (context, _) {
          return Scaffold(
            body: Transform.scale(
              scale: _zoomAnimation.value,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFFFE082), // soft highlight
                      Color(0xFFD4AF37), // royal gold base
                      Color(0xFFC7A12B), // shadow depth
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    ..._buildParticles(size),
                    _buildRippleEffect(),
                    _buildMainContent(),
                    _buildBottomProgress(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMainContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _logoController,
            builder: (_, __) {
              return Transform.rotate(
                angle: _logoRotation.value,
                child: FadeTransition(
                  opacity: _logoFade,
                  child: ScaleTransition(
                    scale: _logoScale,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        ShaderMask(
                          shaderCallback: (rect) {
                            return LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white.withOpacity(0.0),
                                Colors.white.withOpacity(0.5),
                                Colors.white.withOpacity(0.0),
                              ],
                              stops: [
                                _shimmerAnimation.value - 0.3,
                                _shimmerAnimation.value,
                                _shimmerAnimation.value + 0.3,
                              ].map((e) => e.clamp(0.0, 1.0)).toList(),
                            ).createShader(rect);
                          },
                          blendMode: BlendMode.plus,
                          child: _buildLogo(),
                        ),
                        _buildLogo(),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 18),
          FadeTransition(
            opacity: _textFade,
            child: SlideTransition(
              position: _textSlide,
              child: ScaleTransition(
                scale: _textScale,
                child: Text(
                  'Your Wedding, Our Passion',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black.withOpacity(0.7),
                    letterSpacing: 1.1,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return AnimatedBuilder(
      animation: _letterSpacing,
      builder: (_, __) {
        return RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: 56,
              fontWeight: FontWeight.bold,
              letterSpacing: _letterSpacing.value,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.15),
                  offset: const Offset(2, 2),
                  blurRadius: 6,
                ),
              ],
            ),
            children: const [
              TextSpan(text: 'We', style: TextStyle(color: AppColors.black)),
              TextSpan(text: 'dly', style: TextStyle(color: Colors.white)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRippleEffect() {
    return AnimatedBuilder(
      animation: _rippleAnimation,
      builder: (_, __) {
        final value = _rippleAnimation.value;
        return Center(
          child: Container(
            width: 250 * value,
            height: 250 * value,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity((1.0 - value) * 0.4),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.15 * (1 - value)),
                  blurRadius: 12,
                  spreadRadius: 4,
                )
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildParticles(Size size) {
    return _particles.map((p) {
      return AnimatedBuilder(
        animation: _particleController,
        builder: (_, __) {
          final t = _particleController.value;
          final offsetY = (p.y - t) * size.height * 1.2;
          final driftX = math.sin(t * math.pi * 2 + p.phase) * 10;
          return Positioned(
            left: p.x * size.width + driftX,
            top: offsetY % size.height,
            child: Opacity(
              opacity: p.opacity * (1.0 - t),
              child: Container(
                width: p.size,
                height: p.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.4),
                ),
              ),
            ),
          );
        },
      );
    }).toList();
  }

  Widget _buildBottomProgress() {
    // Account for safe area (home indicator on iPhone X+)
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;
    final bottomOffset = math.max(60.0, bottomPadding + 20);

    return Positioned(
      bottom: bottomOffset,
      left: 0,
      right: 0,
      child: FadeTransition(
        opacity: _textFade,
        child: Center(
          child: Container(
            width: 50,
            height: 3,
            child: LinearProgressIndicator(
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                Colors.white.withOpacity(0.6),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Particle {
  final double x, y, size, opacity, phase;
  _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.opacity,
    required this.phase,
  });

  static _Particle random() {
    final r = math.Random();
    return _Particle(
      x: r.nextDouble(),
      y: r.nextDouble() + 1,
      size: r.nextDouble() * 4 + 2,
      opacity: r.nextDouble() * 0.6 + 0.3,
      phase: r.nextDouble() * 2 * math.pi,
    );
  }
}
