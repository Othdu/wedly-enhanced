import 'package:equatable/equatable.dart';
import 'package:wedly/data/models/banner_model.dart';

/// Base class for all banner states
abstract class BannerState extends Equatable {
  const BannerState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any banners are loaded
class BannerInitial extends BannerState {}

/// State when banners are being loaded
class BannerLoading extends BannerState {}

/// State when banners are successfully loaded
class BannerLoaded extends BannerState {
  final List<BannerModel> banners;

  const BannerLoaded({required this.banners});

  @override
  List<Object?> get props => [banners];
}

/// State when there's an error loading banners
class BannerError extends BannerState {
  final String message;

  const BannerError({required this.message});

  @override
  List<Object?> get props => [message];
}
