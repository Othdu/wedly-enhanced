import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Represents different types of notifications in the app
enum NotificationType {
  booking,      // الحجوزات
  offer,        // العروض
  reminder,     // التذكيرات
  update,       // التحديثات
  cancellation, // الإلغاء
}

/// Model class for user notifications
///
/// Ready for API integration - map JSON response to this model
class NotificationModel extends Equatable {
  final String id;
  final String titleAr;
  final String messageAr;
  final NotificationType type;
  final DateTime createdAt;
  final bool isRead;
  final String? relatedId; // ID of related booking/offer/service
  final String? imageUrl;

  const NotificationModel({
    required this.id,
    required this.titleAr,
    required this.messageAr,
    required this.type,
    required this.createdAt,
    this.isRead = false,
    this.relatedId,
    this.imageUrl,
  });

  /// Create from API JSON response
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      titleAr: json['title_ar'] as String,
      messageAr: json['message_ar'] as String,
      type: _typeFromString(json['type'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      isRead: json['is_read'] as bool? ?? false,
      relatedId: json['related_id'] as String?,
      imageUrl: json['image_url'] as String?,
    );
  }

  /// Convert to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title_ar': titleAr,
      'message_ar': messageAr,
      'type': _typeToString(type),
      'created_at': createdAt.toIso8601String(),
      'is_read': isRead,
      'related_id': relatedId,
      'image_url': imageUrl,
    };
  }

  /// Create a copy with updated fields
  NotificationModel copyWith({
    String? id,
    String? titleAr,
    String? messageAr,
    NotificationType? type,
    DateTime? createdAt,
    bool? isRead,
    String? relatedId,
    String? imageUrl,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      titleAr: titleAr ?? this.titleAr,
      messageAr: messageAr ?? this.messageAr,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      relatedId: relatedId ?? this.relatedId,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  /// Get time ago string in Arabic
  String getTimeAgoAr() {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return 'منذ ${difference.inDays} ${difference.inDays == 1 ? 'يوم' : 'أيام'}';
    } else if (difference.inHours > 0) {
      return 'منذ ${difference.inHours} ${difference.inHours == 1 ? 'ساعة' : 'ساعات'}';
    } else if (difference.inMinutes > 0) {
      return 'منذ ${difference.inMinutes} ${difference.inMinutes == 1 ? 'دقيقة' : 'دقائق'}';
    } else {
      return 'الآن';
    }
  }

  /// Get notification type label in Arabic
  String getTypeLabelAr() {
    switch (type) {
      case NotificationType.booking:
        return 'الحجوزات';
      case NotificationType.offer:
        return 'العروض';
      case NotificationType.reminder:
        return 'التذكيرات';
      case NotificationType.update:
        return 'التحديثات';
      case NotificationType.cancellation:
        return 'تم الإلغاء';
    }
  }

  /// Get notification type color
  Color getTypeColor() {
    switch (type) {
      case NotificationType.booking:
        return const Color(0xFF4CAF50); // Green
      case NotificationType.offer:
        return const Color(0xFFFF9800); // Orange
      case NotificationType.reminder:
        return const Color(0xFF2196F3); // Blue
      case NotificationType.update:
        return const Color(0xFF9C27B0); // Purple
      case NotificationType.cancellation:
        return const Color(0xFFF44336); // Red
    }
  }

  /// Convert string to NotificationType enum
  static NotificationType _typeFromString(String type) {
    switch (type.toLowerCase()) {
      case 'booking':
        return NotificationType.booking;
      case 'offer':
        return NotificationType.offer;
      case 'reminder':
        return NotificationType.reminder;
      case 'update':
        return NotificationType.update;
      case 'cancellation':
        return NotificationType.cancellation;
      default:
        return NotificationType.booking;
    }
  }

  /// Convert NotificationType enum to string
  static String _typeToString(NotificationType type) {
    switch (type) {
      case NotificationType.booking:
        return 'booking';
      case NotificationType.offer:
        return 'offer';
      case NotificationType.reminder:
        return 'reminder';
      case NotificationType.update:
        return 'update';
      case NotificationType.cancellation:
        return 'cancellation';
    }
  }

  @override
  List<Object?> get props => [
        id,
        titleAr,
        messageAr,
        type,
        createdAt,
        isRead,
        relatedId,
        imageUrl,
      ];
}
