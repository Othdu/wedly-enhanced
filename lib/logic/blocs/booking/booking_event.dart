import 'package:equatable/equatable.dart';
import '../../../core/utils/enums.dart';

abstract class BookingEvent extends Equatable {
  const BookingEvent();

  @override
  List<Object?> get props => [];
}

/// Event to fetch all bookings for a provider
class FetchProviderBookings extends BookingEvent {
  final String providerId;

  const FetchProviderBookings(this.providerId);

  @override
  List<Object?> get props => [providerId];
}

/// Event to fetch all bookings for a user
class FetchUserBookings extends BookingEvent {
  final String userId;

  const FetchUserBookings(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Event to fetch bookings by status
class FetchBookingsByStatus extends BookingEvent {
  final String providerId;
  final BookingStatus status;

  const FetchBookingsByStatus(this.providerId, this.status);

  @override
  List<Object?> get props => [providerId, status];
}

/// Event to fetch a single booking by ID
class FetchBookingDetails extends BookingEvent {
  final String bookingId;

  const FetchBookingDetails(this.bookingId);

  @override
  List<Object?> get props => [bookingId];
}

/// Event to update booking status
class UpdateBookingStatus extends BookingEvent {
  final String bookingId;
  final BookingStatus newStatus;

  const UpdateBookingStatus(this.bookingId, this.newStatus);

  @override
  List<Object?> get props => [bookingId, newStatus];
}

/// Event to refresh bookings
class RefreshBookings extends BookingEvent {
  final String providerId;

  const RefreshBookings(this.providerId);

  @override
  List<Object?> get props => [providerId];
}
