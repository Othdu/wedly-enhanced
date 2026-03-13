import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart' show GoogleFonts;
import 'package:wedly/core/constants/app_colors.dart';
import 'package:wedly/core/constants/app_strings.dart';
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
  late final AnimationController _ringDrawController;
  late final AnimationController _logoController;
  late final AnimationController _taglineController;
  late final AnimationController _shimmerController;
  late final AnimationController _floatingController;
  late final AnimationController _progressController;

  late final Animation<double> _ringDraw;
  late final Animation<double> _ringScale;
  late final Animation<double> _logoFade;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoSlideY;
  late final Animation<double> _taglineFade;
  late final Animation<double> _taglineSlideY;
  late final Animation<double> _shimmer;
  late final Animation<double> _progressValue;

  late final List<_FloatingPetal> _petals;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _petals = List.generate(18, (_) => _FloatingPetal.random());
    _startSequence();
    _navigateToNextScreen();
  }

  void _initAnimations() {
    // Ring drawing animation
    _ringDrawController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _ringDraw = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ringDrawController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _ringScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _ringDrawController,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    // Logo
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _logoFade = CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
    );

    _logoScale = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOutBack),
      ),
    );

    _logoSlideY = Tween<double>(begin: 24.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic),
      ),
    );

    // Tagline
    _taglineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _taglineFade = CurvedAnimation(
      parent: _taglineController,
      curve: Curves.easeIn,
    );

    _taglineSlideY = Tween<double>(begin: 16.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _taglineController,
        curve: Curves.easeOutCubic,
      ),
    );

    // Shimmer across logo
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();

    _shimmer = Tween<double>(begin: -1.5, end: 2.5).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.linear),
    );

    // Floating petals
    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    // Progress bar
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
    );

    _progressValue = CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    );
  }

  Future<void> _startSequence() async {
    await Future.delayed(const Duration(milliseconds: 150));
    if (!mounted) return;
    _ringDrawController.forward();
    _progressController.forward();

    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    _logoController.forward();

    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    _taglineController.forward();
  }

  Future<void> _navigateToNextScreen() async {
    await Future.delayed(const Duration(milliseconds: 3800));
    if (!mounted || _hasNavigated) return;

    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted || _hasNavigated) return;

    _hasNavigated = true;

    final prefs = await AppPreferences.getInstance();
    if (!mounted) return;

    final isFirstLaunch = prefs.isFirstLaunch;
    final authState = context.read<AuthBloc>().state;

    debugPrint('🔍 SPLASH: Auth state type: ${authState.runtimeType}');
    if (authState is AuthAuthenticated) {
      debugPrint('🔍 SPLASH: User logged in - Role: ${authState.user.role}');
    }

    if (!mounted) return;

    Widget next;
    if (authState is AuthAuthenticated) {
      debugPrint(
          '✅ SPLASH: Navigating to ${authState.user.role == UserRole.provider ? "Provider" : "User"} home');
      next = authState.user.role == UserRole.provider
          ? const ProviderNavigationWrapper()
          : const UserNavigationWrapper();
    } else if (isFirstLaunch) {
      debugPrint('✅ SPLASH: First launch - navigating to onboarding');
      await prefs.setFirstLaunchCompleted();
      next = const OnboardingScreenNew();
    } else {
      debugPrint('✅ SPLASH: Not authenticated - navigating to login');
      next = const LoginScreen();
    }

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 900),
        pageBuilder: (_, __, ___) => next,
        transitionsBuilder: (_, anim, __, child) {
          final curved =
              CurvedAnimation(parent: anim, curve: Curves.easeInOut);
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
    _ringDrawController.dispose();
    _logoController.dispose();
    _taglineController.dispose();
    _shimmerController.dispose();
    _floatingController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {},
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFFFDF5), // warm cream top
                AppColors.white,
                Color(0xFFFFF8E7), // light gold tint bottom
              ],
              stops: [0.0, 0.4, 1.0],
            ),
          ),
          child: Stack(
            children: [
              // Decorative arcs in background
              _buildBackgroundArcs(size),
              // Floating petals
              ..._buildFloatingPetals(size),
              // Gold radial glow behind center
              _buildCenterGlow(size),
              // Main content
              _buildMainContent(),
              // Bottom progress
              _buildBottomProgress(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundArcs(Size size) {
    return CustomPaint(
      size: size,
      painter: _BackgroundArcsPainter(),
    );
  }

  Widget _buildCenterGlow(Size size) {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _ringDrawController,
        builder: (_, __) {
          final opacity = (_ringDrawController.value * 0.12).clamp(0.0, 0.12);
          return Center(
            child: Transform.translate(
              offset: const Offset(0, -30),
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.gold.withOpacity(opacity),
                      AppColors.gold.withOpacity(0.0),
                    ],
                  ),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          // Wedding rings
          AnimatedBuilder(
            animation: Listenable.merge([_ringDrawController, _shimmerController]),
            builder: (_, __) {
              return Transform.scale(
                scale: _ringScale.value,
                child: Opacity(
                  opacity: _ringDrawController.value.clamp(0.0, 1.0),
                  child: SizedBox(
                    width: 120,
                    height: 100,
                    child: CustomPaint(
                      painter: _WeddingRingsPainter(
                        drawProgress: _ringDraw.value,
                        shimmerValue: _shimmer.value,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 28),

          // Logo with shimmer
          AnimatedBuilder(
            animation: Listenable.merge([_logoController, _shimmerController]),
            builder: (_, __) {
              return FadeTransition(
                opacity: _logoFade,
                child: Transform.translate(
                  offset: Offset(0, _logoSlideY.value),
                  child: Transform.scale(
                    scale: _logoScale.value,
                    child: ShaderMask(
                      shaderCallback: (rect) {
                        return ui.Gradient.linear(
                          Offset(rect.width * _shimmer.value, 0),
                          Offset(rect.width * (_shimmer.value + 0.3), rect.height),
                          [
                            Colors.white.withOpacity(0.0),
                            Colors.white.withOpacity(0.4),
                            Colors.white.withOpacity(0.0),
                          ],
                          [0.0, 0.5, 1.0],
                        );
                      },
                      blendMode: BlendMode.plus,
                      child: _buildLogoText(),
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 8),

          // Decorative ornament
          AnimatedBuilder(
            animation: _logoController,
            builder: (_, __) {
              return FadeTransition(
                opacity: _logoFade,
                child: SizedBox(
                  width: 140,
                  height: 20,
                  child: CustomPaint(
                    painter: _OrnamentPainter(
                      progress: _logoController.value,
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 14),

          // Arabic tagline
          AnimatedBuilder(
            animation: _taglineController,
            builder: (_, __) {
              return FadeTransition(
                opacity: _taglineFade,
                child: Transform.translate(
                  offset: Offset(0, _taglineSlideY.value),
                  child: Text(
                    AppStrings.appTagline,
                    style: GoogleFonts.readexPro(
                      fontSize: 17,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLogoText() {
    return RichText(
      text: TextSpan(
        style: GoogleFonts.readexPro(
          fontSize: 56,
          fontWeight: FontWeight.w700,
          letterSpacing: 3,
          shadows: [
            Shadow(
              color: AppColors.gold.withOpacity(0.25),
              offset: const Offset(0, 3),
              blurRadius: 10,
            ),
          ],
        ),
        children: const [
          TextSpan(
            text: 'We',
            style: TextStyle(color: AppColors.black),
          ),
          TextSpan(
            text: 'dly',
            style: TextStyle(color: AppColors.gold),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFloatingPetals(Size size) {
    return _petals.map((petal) {
      return AnimatedBuilder(
        animation: _floatingController,
        builder: (_, __) {
          final t = _floatingController.value;
          final phase = petal.phase;

          // Gentle floating motion
          final floatY = math.sin(t * math.pi * 2 * petal.speed + phase) * 12;
          final floatX = math.cos(t * math.pi * 2 * petal.speed * 0.7 + phase) * 6;
          final rotation = math.sin(t * math.pi * 2 * 0.3 + phase) * 0.3;

          return Positioned(
            left: petal.x * size.width + floatX,
            top: petal.y * size.height + floatY,
            child: Transform.rotate(
              angle: rotation,
              child: Opacity(
                opacity: petal.opacity,
                child: CustomPaint(
                  size: Size(petal.size, petal.size),
                  painter: _PetalPainter(color: petal.color),
                ),
              ),
            ),
          );
        },
      );
    }).toList();
  }

  Widget _buildBottomProgress() {
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;
    final bottomOffset = math.max(55.0, bottomPadding + 24);

    return Positioned(
      bottom: bottomOffset,
      left: 0,
      right: 0,
      child: AnimatedBuilder(
        animation: _taglineController,
        builder: (_, __) {
          return FadeTransition(
            opacity: _taglineFade,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Elegant thin progress line
                  AnimatedBuilder(
                    animation: _progressValue,
                    builder: (_, __) {
                      return Container(
                        width: 100,
                        height: 2,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(1),
                          color: AppColors.gold.withOpacity(0.15),
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: FractionallySizedBox(
                            widthFactor: _progressValue.value,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(1),
                                gradient: const LinearGradient(
                                  colors: [
                                    AppColors.goldLight,
                                    AppColors.gold,
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Custom Painters ──

class _WeddingRingsPainter extends CustomPainter {
  final double drawProgress;
  final double shimmerValue;

  _WeddingRingsPainter({required this.drawProgress, required this.shimmerValue});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final ringRadius = size.width * 0.22;
    const strokeWidth = 3.2;
    final overlap = ringRadius * 0.4;

    final leftCenter = Offset(center.dx - overlap, center.dy);
    final rightCenter = Offset(center.dx + overlap, center.dy);

    final sweepAngle = math.pi * 2 * drawProgress;

    // Shadow behind rings
    final shadowPaint = Paint()
      ..color = AppColors.gold.withOpacity(0.08)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth + 6;

    if (drawProgress > 0.1) {
      canvas.drawCircle(leftCenter, ringRadius, shadowPaint);
      canvas.drawCircle(rightCenter, ringRadius, shadowPaint);
    }

    // Left ring
    final leftPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: 0,
        endAngle: math.pi * 2,
        colors: [
          AppColors.goldDark,
          AppColors.gold,
          AppColors.goldLight,
          AppColors.gold,
          AppColors.goldDark,
        ],
        stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
      ).createShader(Rect.fromCircle(center: leftCenter, radius: ringRadius));

    canvas.drawArc(
      Rect.fromCircle(center: leftCenter, radius: ringRadius),
      -math.pi / 2,
      sweepAngle,
      false,
      leftPaint,
    );

    // Right ring
    final rightPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: 0,
        endAngle: math.pi * 2,
        colors: [
          AppColors.goldLight,
          AppColors.gold,
          AppColors.goldDark,
          AppColors.gold,
          AppColors.goldLight,
        ],
        stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
      ).createShader(Rect.fromCircle(center: rightCenter, radius: ringRadius));

    canvas.drawArc(
      Rect.fromCircle(center: rightCenter, radius: ringRadius),
      -math.pi / 2,
      sweepAngle,
      false,
      rightPaint,
    );

    // Small heart at intersection when fully drawn
    if (drawProgress > 0.85) {
      final heartOpacity = ((drawProgress - 0.85) / 0.15).clamp(0.0, 1.0);
      _drawHeart(canvas, center, 7, heartOpacity);
    }
  }

  void _drawHeart(Canvas canvas, Offset center, double size, double opacity) {
    final paint = Paint()
      ..color = AppColors.gold.withOpacity(opacity * 0.9)
      ..style = PaintingStyle.fill;

    final path = Path();
    final x = center.dx;
    final y = center.dy - size * 0.2;

    path.moveTo(x, y + size * 0.6);
    path.cubicTo(x - size, y - size * 0.2, x - size * 0.5, y - size, x, y - size * 0.3);
    path.cubicTo(x + size * 0.5, y - size, x + size, y - size * 0.2, x, y + size * 0.6);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _WeddingRingsPainter old) =>
      old.drawProgress != drawProgress || old.shimmerValue != shimmerValue;
}

// Decorative ornament divider
class _OrnamentPainter extends CustomPainter {
  final double progress;

  _OrnamentPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final lineLength = size.width * 0.35 * progress;

    final linePaint = Paint()
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;

    // Left line with gradient fade
    linePaint.shader = ui.Gradient.linear(
      Offset(center.dx - lineLength, center.dy),
      Offset(center.dx - 8, center.dy),
      [AppColors.gold.withOpacity(0.0), AppColors.gold.withOpacity(0.6)],
    );
    canvas.drawLine(
      Offset(center.dx - lineLength, center.dy),
      Offset(center.dx - 8, center.dy),
      linePaint,
    );

    // Right line with gradient fade
    linePaint.shader = ui.Gradient.linear(
      Offset(center.dx + 8, center.dy),
      Offset(center.dx + lineLength, center.dy),
      [AppColors.gold.withOpacity(0.6), AppColors.gold.withOpacity(0.0)],
    );
    canvas.drawLine(
      Offset(center.dx + 8, center.dy),
      Offset(center.dx + lineLength, center.dy),
      linePaint,
    );

    // Center diamond
    if (progress > 0.5) {
      final diamondOpacity = ((progress - 0.5) / 0.5).clamp(0.0, 1.0);
      final diamondSize = 4.0;
      final diamondPaint = Paint()
        ..color = AppColors.gold.withOpacity(diamondOpacity * 0.7)
        ..style = PaintingStyle.fill;

      final path = Path()
        ..moveTo(center.dx, center.dy - diamondSize)
        ..lineTo(center.dx + diamondSize * 0.6, center.dy)
        ..lineTo(center.dx, center.dy + diamondSize)
        ..lineTo(center.dx - diamondSize * 0.6, center.dy)
        ..close();

      canvas.drawPath(path, diamondPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _OrnamentPainter old) => old.progress != progress;
}

// Subtle background arcs
class _BackgroundArcsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;

    // Top-right arc
    paint.color = AppColors.gold.withOpacity(0.06);
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(size.width * 0.85, size.height * 0.12),
        width: size.width * 0.7,
        height: size.width * 0.7,
      ),
      0,
      math.pi * 1.2,
      false,
      paint,
    );

    // Bottom-left arc
    paint.color = AppColors.gold.withOpacity(0.04);
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(size.width * 0.15, size.height * 0.88),
        width: size.width * 0.8,
        height: size.width * 0.8,
      ),
      math.pi * 0.8,
      math.pi * 1.0,
      false,
      paint,
    );

    // Center subtle circle
    paint.color = AppColors.gold.withOpacity(0.03);
    paint.strokeWidth = 0.4;
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.45),
      size.width * 0.55,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Small floating petal shape
class _PetalPainter extends CustomPainter {
  final Color color;

  _PetalPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Simple leaf/petal shape
    final path = Path()
      ..moveTo(center.dx, center.dy - r)
      ..quadraticBezierTo(center.dx + r * 0.8, center.dy, center.dx, center.dy + r)
      ..quadraticBezierTo(center.dx - r * 0.8, center.dy, center.dx, center.dy - r)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Floating petal data
class _FloatingPetal {
  final double x, y, size, opacity, phase, speed;
  final Color color;

  _FloatingPetal({
    required this.x,
    required this.y,
    required this.size,
    required this.opacity,
    required this.phase,
    required this.speed,
    required this.color,
  });

  static _FloatingPetal random() {
    final r = math.Random();
    final colors = [
      AppColors.gold.withOpacity(0.08),
      AppColors.goldLight.withOpacity(0.06),
      AppColors.goldDark.withOpacity(0.05),
      AppColors.gold.withOpacity(0.04),
    ];

    return _FloatingPetal(
      x: r.nextDouble(),
      y: r.nextDouble(),
      size: r.nextDouble() * 14 + 6,
      opacity: r.nextDouble() * 0.5 + 0.3,
      phase: r.nextDouble() * math.pi * 2,
      speed: r.nextDouble() * 0.5 + 0.3,
      color: colors[r.nextInt(colors.length)],
    );
  }
}
