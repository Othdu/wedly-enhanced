import 'package:flutter/material.dart';
import '../../core/utils/enums.dart';

class StatusBadge extends StatelessWidget {
  final BookingStatus status;
  final double fontSize;
  final EdgeInsets padding;

  const StatusBadge({
    super.key,
    required this.status,
    this.fontSize = 12,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  });

  Color _getStatusColor() {
    switch (status) {
      case BookingStatus.pending:
        return Colors.orange;
      case BookingStatus.confirmed:
        return Colors.blue;
      case BookingStatus.completed:
        return Colors.green;
      case BookingStatus.cancelled:
        return Colors.red;
    }
  }

  Color _getStatusBackgroundColor() {
    switch (status) {
      case BookingStatus.pending:
        return Colors.orange.withValues(alpha: 0.1);
      case BookingStatus.confirmed:
        return Colors.blue.withValues(alpha: 0.1);
      case BookingStatus.completed:
        return Colors.green.withValues(alpha: 0.1);
      case BookingStatus.cancelled:
        return Colors.red.withValues(alpha: 0.1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: _getStatusBackgroundColor(),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _getStatusColor(),
          width: 1,
        ),
      ),
      child: Text(
        status.arabicLabel,
        style: TextStyle(
          color: _getStatusColor(),
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
