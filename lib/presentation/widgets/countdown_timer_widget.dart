import 'dart:async';
import 'package:flutter/material.dart';
import 'package:wedly/data/models/countdown_model.dart';

/// Widget that displays a countdown timer for the wedding date
/// Responsive and reusable across different screens
class CountdownTimerWidget extends StatefulWidget {
  final CountdownModel countdown;
  final bool showWeeks;
  final bool showDays;
  final bool showHours;
  final bool showSeconds;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final Color? accentColor;
  final bool compact;

  const CountdownTimerWidget({
    super.key,
    required this.countdown,
    this.showWeeks = true,
    this.showDays = true,
    this.showHours = true,
    this.showSeconds = true,
    this.padding,
    this.backgroundColor,
    this.accentColor,
    this.compact = false,
  });

  @override
  State<CountdownTimerWidget> createState() => _CountdownTimerWidgetState();
}

class _CountdownTimerWidgetState extends State<CountdownTimerWidget> {
  Timer? _timer;
  late CountdownModel _countdown;

  @override
  void initState() {
    super.initState();
    _countdown = widget.countdown;
    // Update every second
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          // Force rebuild to update countdown
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = widget.accentColor ?? const Color(0xFFD4AF37);
    final bgColor = widget.backgroundColor ?? Colors.white;
    final padding = widget.padding ?? const EdgeInsets.all(20);

    // Build list of visible time units
    final timeUnits = <Widget>[];
    if (widget.showWeeks) {
      timeUnits.add(
        _buildTimeUnit('أسابيع', 'Weeks', _countdown.weeksRemaining),
      );
    }
    if (widget.showDays) {
      timeUnits.add(_buildTimeUnit('أيام', 'Days', _countdown.daysRemaining));
    }
    if (widget.showHours) {
      timeUnits.add(
        _buildTimeUnit('ساعات', 'Hours', _countdown.hoursRemaining),
      );
    }
    if (widget.showSeconds) {
      timeUnits.add(
        _buildTimeUnit('ثواني', 'Seconds', _countdown.secondsRemaining),
      );
    }

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(widget.compact ? 12 : 16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _countdown.titleAr,
            style: TextStyle(
              fontSize: widget.compact ? 16 : 18,
              fontWeight: FontWeight.bold,
              color: accentColor,
            ),
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: widget.compact ? 12 : 16),
          LayoutBuilder(
            builder: (context, constraints) {
              // Responsive layout: use ListView on small screens, Row on larger screens
              final useScroll =
                  constraints.maxWidth < 300 || timeUnits.length > 4;

              if (useScroll) {
                return SizedBox(
                  height: widget.compact ? 60 : 70,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: timeUnits.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 16),
                    itemBuilder: (context, index) => timeUnits[index],
                  ),
                );
              }

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: timeUnits,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTimeUnit(String labelAr, String labelEn, int value) {
    final fontSize = widget.compact ? 20.0 : 24.0;
    final labelSize = widget.compact ? 11.0 : 12.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          labelAr,
          style: TextStyle(
            fontSize: labelSize,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
          textDirection: TextDirection.rtl,
        ),
        SizedBox(height: widget.compact ? 4 : 6),
        // Display current value only to avoid overflow
        Container(
          constraints: BoxConstraints(minHeight: widget.compact ? 30 : 36),
          child: Center(
            child: Text(
              value.toString().padLeft(2, '0'),
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
