import 'package:equatable/equatable.dart';

/// Base class for all banner events
abstract class BannerEvent extends Equatable {
  const BannerEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load all active banners
class BannersRequested extends BannerEvent {
  const BannersRequested();
}

/// Event to refresh banners
class BannersRefreshed extends BannerEvent {
  const BannersRefreshed();
}
