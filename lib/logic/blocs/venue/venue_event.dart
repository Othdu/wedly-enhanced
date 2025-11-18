import 'package:equatable/equatable.dart';

/// Events for venue management
abstract class VenueEvent extends Equatable {
  const VenueEvent();

  @override
  List<Object?> get props => [];
}

/// Event to request all venues
class VenuesRequested extends VenueEvent {
  const VenuesRequested();
}

/// Event to request a specific venue by ID
class VenueDetailsRequested extends VenueEvent {
  final String venueId;

  const VenueDetailsRequested(this.venueId);

  @override
  List<Object?> get props => [venueId];
}
