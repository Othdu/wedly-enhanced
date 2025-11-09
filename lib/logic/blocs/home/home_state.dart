import 'package:equatable/equatable.dart';
import 'package:wedly/data/models/service_model.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeLoaded extends HomeState {
  final List<ServiceModel> services;
  final List<String> categories;

  const HomeLoaded({
    required this.services,
    required this.categories,
  });

  @override
  List<Object?> get props => [services, categories];
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}

