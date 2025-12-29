import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wedly/data/repositories/venue_repository.dart';
import 'package:wedly/logic/blocs/venue/venue_event.dart';
import 'package:wedly/logic/blocs/venue/venue_state.dart';

/// BLoC for managing venue data
/// Handles fetching venues list and individual venue details
class VenueBloc extends Bloc<VenueEvent, VenueState> {
  final VenueRepository venueRepository;

  VenueBloc({required this.venueRepository}) : super(const VenueInitial()) {
    on<VenuesRequested>(_onVenuesRequested);
    on<VenueDetailsRequested>(_onVenueDetailsRequested);
  }

  /// Handle fetching all venues
  Future<void> _onVenuesRequested(
    VenuesRequested event,
    Emitter<VenueState> emit,
  ) async {
    emit(const VenuesLoading());

    try {
      final venues = await venueRepository.getVenues();
      emit(VenuesLoaded(venues));
    } catch (e) {
      emit(VenueError('فشل في تحميل القاعات: ${e.toString()}'));
    }
  }

  /// Handle fetching single venue details
  Future<void> _onVenueDetailsRequested(
    VenueDetailsRequested event,
    Emitter<VenueState> emit,
  ) async {
    emit(const VenueDetailsLoading());

    try {
      final venue = await venueRepository.getVenueById(event.venueId);

      if (venue != null) {
        emit(VenueDetailsLoaded(venue));
      } else {
        emit(const VenueError('القاعة غير موجودة'));
      }
    } catch (e) {
      emit(VenueError('فشل في تحميل تفاصيل القاعة: ${e.toString()}'));
    }
  }
}
