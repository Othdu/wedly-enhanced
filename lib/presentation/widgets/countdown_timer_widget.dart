import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:wedly/data/models/countdown_model.dart';

extension ColorWithValuesCompat on Color {
  Color withValues({double? alpha, double? red, double? green, double? blue}) {
    final int a =
        alpha == null ? this.alpha : (alpha.clamp(0.0, 1.0) * 255).round();
    final int r =
        red == null ? this.red : (red.clamp(0.0, 1.0) * 255).round();
    final int g =
        green == null ? this.green : (green.clamp(0.0, 1.0) * 255).round();
    final int b =
        blue == null ? this.blue : (blue.clamp(0.0, 1.0) * 255).round();
    return Color.fromARGB(a, r, g, b);
  }
}

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
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  static const Color _goldPrimary = Color(0xFFD4AF37);
  static const Color _goldLight = Color(0xFFE8D48A);
  static const Color _goldDark = Color(0xFFB8860B);
  static const Color _textDark = Color(0xFF2D2D2D);
  static const Color _textMuted = Color(0xFF6B6B6B);

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timeRemaining = widget.countdown.timeRemaining;
    final totalDays = timeRemaining.inDays;
    final hours = timeRemaining.inHours % 24;
    final minutes = timeRemaining.inMinutes % 60;
    final seconds = timeRemaining.inSeconds % 60;
    final weeks = totalDays ~/ 7;
    final remainingDays = totalDays % 7;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          margin: widget.margin ?? const EdgeInsets.only(top: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFDF8),
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 18,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(18, 28, 18, 18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: _goldPrimary.withValues(alpha: 0.35), width: 1.4),
            ),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _goldPrimary.withValues(alpha: 0.18), width: 1.0),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeaderClassic(),
                  const SizedBox(height: 16),
                  _buildDateBadgeClassic(),
                  const SizedBox(height: 20),
                  _buildCountdownRow(
                    weeks: weeks,
                    days: widget.showWeeks ? remainingDays : totalDays,
                    hours: hours,
                    minutes: minutes,
                    seconds: seconds,
                  ),
                  const SizedBox(height: 16),
                  _buildDaysRemainingClassic(totalDays),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderClassic() {
    final w = MediaQuery.of(context).size.width;
    final titleSize = (w * 0.052).clamp(14.0, 22.0);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _pulseAnimation,
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _goldPrimary.withValues(alpha: 0.18),
                  border: Border.all(color: _goldPrimary.withValues(alpha: 0.35)),
                ),
                child: Icon(Icons.favorite, color: _goldDark, size: 20),
              ),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  widget.countdown.titleAr,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textHeightBehavior: const TextHeightBehavior(
                    applyHeightToFirstAscent: false,
                    applyHeightToLastDescent: false,
                  ),
                  style: TextStyle(
                    fontSize: titleSize,
                    fontWeight: FontWeight.w900,
                    color: _goldDark,
                    height: 1.25,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          width: 92,
          height: 2,
          decoration: BoxDecoration(
            color: _goldPrimary.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  Widget _buildDateBadgeClassic() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF8),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _goldPrimary.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.calendar_month_rounded, color: _goldDark, size: 20),
          const SizedBox(width: 10),
          Text(
            _formatDate(widget.countdown.weddingDate),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: _textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountdownRow({
    required int weeks,
    required int days,
    required int hours,
    required int minutes,
    required int seconds,
  }) {
    final List<Widget> timeUnits = [];

    if (widget.showWeeks) {
      timeUnits.add(Expanded(child: _buildTimeUnitClassic(weeks, 'أسبوع', highlight: true)));
    }
    if (widget.showDays) {
      timeUnits.add(
        Expanded(
          child: _buildTimeUnitClassic(
            days,
            'يوم',
            highlight: !widget.showWeeks,
          ),
        ),
      );
    }
    if (widget.showHours) {
      timeUnits.add(Expanded(child: _buildTimeUnitClassic(hours, 'ساعة')));
    }
    if (widget.showMinutes) {
      timeUnits.add(Expanded(child: _buildTimeUnitClassic(minutes, 'دقيقة')));
    }
    if (widget.showSeconds) {
      timeUnits.add(Expanded(child: _buildTimeUnitClassic(seconds, 'ثانية')));
    }

    return Row(children: timeUnits);
  }

  Widget _buildTimeUnitClassic(int value, String label, {bool highlight = false}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final box = (w - 8).clamp(36.0, 78.0);
        final numSize = (box * 0.42).clamp(16.0, 34.0);
        final labelSize = (box * 0.18).clamp(9.0, 14.0);

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: box,
              height: box,
              decoration: BoxDecoration(
                color: highlight ? const Color(0xFFFFF6D9) : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: highlight
                      ? _goldPrimary.withValues(alpha: 0.45)
                      : _goldPrimary.withValues(alpha: 0.18),
                  width: highlight ? 1.6 : 1.1,
                ),
              ),
              child: Center(
                child: Text(
                  value.toString().padLeft(2, '0'),
                  style: TextStyle(
                    fontSize: numSize,
                    fontWeight: FontWeight.w900,
                    color: _textDark,
                    height: 1,
                    fontFeatures: const [ui.FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: labelSize,
                fontWeight: FontWeight.w700,
                color: highlight ? _goldDark : _textMuted,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDaysRemainingClassic(int totalDays) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _goldPrimary.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.timer_outlined, color: _goldDark, size: 18),
          const SizedBox(width: 10),
          Text(
            'باقي $totalDays يوم على الزفاف',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: _goldDark,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
