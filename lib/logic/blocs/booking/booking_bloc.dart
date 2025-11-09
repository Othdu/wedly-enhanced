import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/booking_repository.dart';
import 'booking_event.dart';
import 'booking_state.dart';

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final BookingRepository bookingRepository;

  BookingBloc({required this.bookingRepository}) : super(BookingInitial()) {
    on<FetchProviderBookings>(_onFetchProviderBookings);
    on<FetchBookingsByStatus>(_onFetchBookingsByStatus);
    on<FetchBookingDetails>(_onFetchBookingDetails);
    on<UpdateBookingStatus>(_onUpdateBookingStatus);
    on<RefreshBookings>(_onRefreshBookings);
  }

  Future<void> _onFetchProviderBookings(
    FetchProviderBookings event,
    Emitter<BookingState> emit,
  ) async {
    emit(BookingLoading());
    try {
      final bookings = await bookingRepository.getProviderBookings(event.providerId);

      if (bookings.isEmpty) {
        emit(const BookingsEmpty('لا توجد حجوزات حتى الآن'));
      } else {
        emit(BookingsLoaded(bookings));
      }
    } catch (e) {
      emit(BookingError('فشل تحميل الحجوزات: ${e.toString()}'));
    }
  }

  Future<void> _onFetchBookingsByStatus(
    FetchBookingsByStatus event,
    Emitter<BookingState> emit,
  ) async {
    emit(BookingLoading());
    try {
      final bookings = await bookingRepository.getBookingsByStatus(
        event.providerId,
        event.status,
      );

      if (bookings.isEmpty) {
        emit(BookingsEmpty('لا توجد حجوزات بهذه الحالة'));
      } else {
        emit(BookingsLoaded(bookings));
      }
    } catch (e) {
      emit(BookingError('فشل تحميل الحجوزات: ${e.toString()}'));
    }
  }

  Future<void> _onFetchBookingDetails(
    FetchBookingDetails event,
    Emitter<BookingState> emit,
  ) async {
    emit(BookingLoading());
    try {
      final booking = await bookingRepository.getBookingById(event.bookingId);

      if (booking == null) {
        emit(const BookingError('لم يتم العثور على الحجز'));
      } else {
        emit(BookingDetailsLoaded(booking));
      }
    } catch (e) {
      emit(BookingError('فشل تحميل تفاصيل الحجز: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateBookingStatus(
    UpdateBookingStatus event,
    Emitter<BookingState> emit,
  ) async {
    try {
      final updatedBooking = await bookingRepository.updateBookingStatus(
        event.bookingId,
        event.newStatus,
      );

      String message;
      switch (event.newStatus.value) {
        case 'confirmed':
          message = 'تم تأكيد الحجز بنجاح';
          break;
        case 'cancelled':
          message = 'تم إلغاء الحجز';
          break;
        case 'completed':
          message = 'تم اكتمال الحجز';
          break;
        default:
          message = 'تم تحديث حالة الحجز';
      }

      emit(BookingStatusUpdated(updatedBooking, message));
    } catch (e) {
      emit(BookingError('فشل تحديث حالة الحجز: ${e.toString()}'));
    }
  }

  Future<void> _onRefreshBookings(
    RefreshBookings event,
    Emitter<BookingState> emit,
  ) async {
    try {
      final bookings = await bookingRepository.getProviderBookings(event.providerId);

      if (bookings.isEmpty) {
        emit(const BookingsEmpty('لا توجد حجوزات حتى الآن'));
      } else {
        emit(BookingsLoaded(bookings));
      }
    } catch (e) {
      emit(BookingError('فشل تحديث الحجوزات: ${e.toString()}'));
    }
  }
}
