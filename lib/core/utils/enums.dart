enum UserRole {
  user,
  provider;

  String get value {
    switch (this) {
      case UserRole.user:
        return 'user';
      case UserRole.provider:
        return 'provider';
    }
  }

  static UserRole fromString(String value) {
    switch (value) {
      case 'user':
        return UserRole.user;
      case 'provider':
        return UserRole.provider;
      default:
        return UserRole.user;
    }
  }
}

enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
}

enum Gender {
  male,
  female;

  String get value {
    switch (this) {
      case Gender.male:
        return 'male';
      case Gender.female:
        return 'female';
    }
  }

  String get arabicLabel {
    switch (this) {
      case Gender.male:
        return 'ذكر';
      case Gender.female:
        return 'أنثى';
    }
  }

  static Gender fromString(String value) {
    switch (value.toLowerCase()) {
      case 'male':
      case 'ذكر':
        return Gender.male;
      case 'female':
      case 'أنثى':
        return Gender.female;
      default:
        return Gender.male;
    }
  }
}

enum BookingStatus {
  pending,
  confirmed,
  cancelled,
  completed;

  String get value {
    switch (this) {
      case BookingStatus.pending:
        return 'pending';
      case BookingStatus.confirmed:
        return 'confirmed';
      case BookingStatus.cancelled:
        return 'cancelled';
      case BookingStatus.completed:
        return 'completed';
    }
  }

  String get arabicLabel {
    switch (this) {
      case BookingStatus.pending:
        return 'جديد';
      case BookingStatus.confirmed:
        return 'مؤكد';
      case BookingStatus.cancelled:
        return 'ملغي';
      case BookingStatus.completed:
        return 'مكتمل';
    }
  }

  static BookingStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'pending':
        return BookingStatus.pending;
      case 'confirmed':
        return BookingStatus.confirmed;
      case 'cancelled':
        return BookingStatus.cancelled;
      case 'completed':
        return BookingStatus.completed;
      default:
        return BookingStatus.pending;
    }
  }
}

enum PaymentStatus {
  pending,
  paid,
  refunded;

  String get value {
    switch (this) {
      case PaymentStatus.pending:
        return 'pending';
      case PaymentStatus.paid:
        return 'paid';
      case PaymentStatus.refunded:
        return 'refunded';
    }
  }

  String get arabicLabel {
    switch (this) {
      case PaymentStatus.pending:
        return 'قيد الانتظار';
      case PaymentStatus.paid:
        return 'مدفوع';
      case PaymentStatus.refunded:
        return 'مسترد';
    }
  }

  static PaymentStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'pending':
        return PaymentStatus.pending;
      case 'paid':
        return PaymentStatus.paid;
      case 'refunded':
        return PaymentStatus.refunded;
      default:
        return PaymentStatus.pending;
    }
  }
}

