import 'package:equatable/equatable.dart';

/// Model representing a wedding countdown timer
class CountdownModel extends Equatable {
  final String userId;
  final DateTime weddingDate;
  final String title;
  final String titleAr;

  const CountdownModel({
    required this.userId,
    required this.weddingDate,
    this.title = 'Wedding Countdown',
    this.titleAr = 'العد التنازلي للفرح',
  });

  /// Calculate time remaining until wedding
  Duration get timeRemaining {
    final now = DateTime.now();
    if (weddingDate.isBefore(now)) {
      return Duration.zero;
    }
    return weddingDate.difference(now);
  }

  /// Get weeks remaining
  int get weeksRemaining => timeRemaining.inDays ~/ 7;

  /// Get days remaining (excluding weeks)
  int get daysRemaining => timeRemaining.inDays % 7;

  /// Get hours remaining (excluding days)
  int get hoursRemaining => timeRemaining.inHours % 24;

  /// Get minutes remaining (excluding hours)
  int get minutesRemaining => timeRemaining.inMinutes % 60;

  /// Get seconds remaining (excluding minutes)
  int get secondsRemaining => timeRemaining.inSeconds % 60;

  @override
  List<Object?> get props => [userId, weddingDate, title, titleAr];

  CountdownModel copyWith({
    String? userId,
    DateTime? weddingDate,
    String? title,
    String? titleAr,
  }) {
    return CountdownModel(
      userId: userId ?? this.userId,
      weddingDate: weddingDate ?? this.weddingDate,
      title: title ?? this.title,
      titleAr: titleAr ?? this.titleAr,
    );
  }

  // JSON serialization
  factory CountdownModel.fromJson(Map<String, dynamic> json) {
    return CountdownModel(
      userId: json['user_id'] as String? ?? '',
      weddingDate: json['wedding_date'] != null
          ? DateTime.parse(json['wedding_date'] as String)
          : DateTime.now().add(const Duration(days: 180)),
      title: json['title'] as String? ?? 'Wedding Countdown',
      titleAr: json['title_ar'] as String? ?? 'العد التنازلي للفرح',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'wedding_date': weddingDate.toIso8601String(),
      'title': title,
      'title_ar': titleAr,
    };
  }
}
