import 'package:equatable/equatable.dart';
import '../../../data/models/booking_model.dart';

abstract class BookingState extends Equatable {
  const BookingState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class BookingInitial extends BookingState {}

/// Loading state
class BookingLoading extends BookingState {}

/// Bookings loaded successfully
class BookingsLoaded extends BookingState {
  final List<BookingModel> bookings;

  const BookingsLoaded(this.bookings);

  @override
  List<Object?> get props => [bookings];
}

/// Single booking details loaded
class BookingDetailsLoaded extends BookingState {
  final BookingModel booking;

  const BookingDetailsLoaded(this.booking);

  @override
  List<Object?> get props => [booking];
}

/// Booking status updated successfully
class BookingStatusUpdated extends BookingState {
  final BookingModel updatedBooking;
  final String message;

  const BookingStatusUpdated(this.updatedBooking, this.message);

  @override
  List<Object?> get props => [updatedBooking, message];
}

/// Error state
class BookingError extends BookingState {
  final String message;

  const BookingError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Empty state (no bookings found)
class BookingsEmpty extends BookingState {
  final String message;

  const BookingsEmpty(this.message);

  @override
  List<Object?> get props => [message];
}
