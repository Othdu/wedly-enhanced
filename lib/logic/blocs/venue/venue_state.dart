import 'package:equatable/equatable.dart';
import 'package:wedly/data/models/venue_model.dart';

/// States for venue management
abstract class VenueState extends Equatable {
  const VenueState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class VenueInitial extends VenueState {
  const VenueInitial();
}

/// Loading venues
class VenuesLoading extends VenueState {
  const VenuesLoading();
}

/// Venues loaded successfully
class VenuesLoaded extends VenueState {
  final List<VenueModel> venues;

  const VenuesLoaded(this.venues);

  @override
  List<Object?> get props => [venues];
}

/// Loading single venue details
class VenueDetailsLoading extends VenueState {
  const VenueDetailsLoading();
}

/// Single venue details loaded
class VenueDetailsLoaded extends VenueState {
  final VenueModel venue;

  const VenueDetailsLoaded(this.venue);

  @override
  List<Object?> get props => [venue];
}

/// Error state
class VenueError extends VenueState {
  final String message;

  const VenueError(this.message);

  @override
  List<Object?> get props => [message];
}
