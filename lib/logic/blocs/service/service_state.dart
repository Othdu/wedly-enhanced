import 'package:equatable/equatable.dart';
import 'package:wedly/data/models/service_model.dart';

abstract class ServiceState extends Equatable {
  const ServiceState();

  @override
  List<Object?> get props => [];
}

class ServiceInitial extends ServiceState {
  const ServiceInitial();
}

class ServiceLoading extends ServiceState {
  const ServiceLoading();
}

class ServiceLoaded extends ServiceState {
  final ServiceModel service;

  const ServiceLoaded(this.service);

  @override
  List<Object?> get props => [service];
}

class ServicesByCategoryLoaded extends ServiceState {
  final List<ServiceModel> services;

  const ServicesByCategoryLoaded(this.services);

  @override
  List<Object?> get props => [services];
}

class ServiceError extends ServiceState {
  final String message;

  const ServiceError(this.message);

  @override
  List<Object?> get props => [message];
}

