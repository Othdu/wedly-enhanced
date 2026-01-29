import 'dart:async';
import 'package:flutter/material.dart';
import 'package:wedly/data/models/countdown_model.dart';

/// Widget that displays a countdown timer for the wedding date
/// Elegant, soft design - reusable across different screens
class CountdownTimerWidget extends StatefulWidget {
  final CountdownModel countdown;
  final bool showWeeks;
  final bool showDays;
  final bool showHours;
  final bool showMinutes;
  final bool showSeconds;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;

  const CountdownTimerWidget({
    super.key,
    required this.countdown,
    this.showWeeks = false,
    this.showDays = true,
    this.showHours = true,
    this.showMinutes = true,
    this.showSeconds = true,
    this.margin,
    this.onTap,
  });

  @override
  State<CountdownTimerWidget> createState() => _CountdownTimerWidgetState();
}

class _CountdownTimerWidgetState extends State<CountdownTimerWidget>
    with SingleTickerProviderStateMixin {
  Timer? _timer;
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  // Soft elegant colors
  static const Color _cardBg = Color(0xFFFAF8F5);
  static const Color _accentColor = Color(0xFFB8860B); // Dark goldenrod
  static const Color _textPrimary = Color(0xFF3D3D3D);
  static const Color _textSecondary = Color(0xFF6B6B6B);
  static const Color _dividerColor = Color(0xFFE8E4DF);

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timeRemaining = widget.countdown.timeRemaining;
    final days = timeRemaining.inDays;
    final hours = timeRemaining.inHours % 24;
    final minutes = timeRemaining.inMinutes % 60;
    final seconds = timeRemaining.inSeconds % 60;
    final weeks = days ~/ 7;
    final remainingDays = days % 7;

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: widget.margin ?? const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _dividerColor,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: _dividerColor, width: 1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildRingsIcon(),
                  const SizedBox(width: 10),
                  Text(
                    widget.countdown.titleAr,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: _textPrimary,
                      letterSpacing: 0.5,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                  const SizedBox(width: 10),
                  _buildRingsIcon(),
                ],
              ),
            ),

            // Date display
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    color: _accentColor.withValues(alpha: 0.7),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatDate(widget.countdown.weddingDate),
                    style: const TextStyle(
                      fontSize: 14,
                      color: _textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Countdown boxes
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (widget.showSeconds)
                    _buildCountdownBox(seconds, 'ثانية'),
                  if (widget.showMinutes)
                    _buildCountdownBox(minutes, 'دقيقة'),
                  if (widget.showHours)
                    _buildCountdownBox(hours, 'ساعة'),
                  if (widget.showDays && !widget.showWeeks)
                    _buildCountdownBox(days, 'يوم', isMain: true),
                  if (widget.showDays && widget.showWeeks)
                    _buildCountdownBox(remainingDays, 'يوم'),
                  if (widget.showWeeks)
                    _buildCountdownBox(weeks, 'أسبوع', isMain: true),
                ],
              ),
            ),

            // Bottom message
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: _accentColor.withValues(alpha: 0.06),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ScaleTransition(
                    scale: _pulseAnimation,
                    child: Icon(
                      Icons.favorite,
                      color: _accentColor.withValues(alpha: 0.6),
                      size: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _getMotivationalMessage(days),
                    style: const TextStyle(
                      fontSize: 12,
                      color: _textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                  const SizedBox(width: 8),
                  ScaleTransition(
                    scale: _pulseAnimation,
                    child: Icon(
                      Icons.favorite,
                      color: _accentColor.withValues(alpha: 0.6),
                      size: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRingsIcon() {
    return SizedBox(
      width: 24,
      height: 20,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 2,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: _accentColor, width: 2),
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: 2,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: _accentColor, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountdownBox(int value, String label, {bool isMain = false}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: isMain ? 64 : 56,
          height: isMain ? 64 : 56,
          decoration: BoxDecoration(
            color: isMain ? _accentColor.withValues(alpha: 0.1) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isMain
                  ? _accentColor.withValues(alpha: 0.3)
                  : _dividerColor,
              width: isMain ? 1.5 : 1,
            ),
          ),
          child: Center(
            child: Text(
              value.toString().padLeft(2, '0'),
              style: TextStyle(
                fontSize: isMain ? 26 : 22,
                fontWeight: FontWeight.w700,
                color: isMain ? _accentColor : _textPrimary,
                height: 1,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isMain ? _accentColor : _textSecondary,
            fontWeight: FontWeight.w500,
          ),
          textDirection: TextDirection.rtl,
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _getMotivationalMessage(int days) {
    if (days == 0) {
      return 'اليوم هو يوم زفافك! مبروك!';
    } else if (days == 1) {
      return 'غداً يوم زفافك!';
    } else if (days <= 7) {
      return 'أيام قليلة وتبدأ حياتك الجديدة';
    } else if (days <= 30) {
      return 'قريباً ستبدأ أجمل رحلة';
    } else {
      return 'استمتع بفترة الخطوبة';
    }
  }
}
