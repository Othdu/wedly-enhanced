import 'package:equatable/equatable.dart';
import '../../../data/models/service_model.dart';

abstract class ProviderServiceState extends Equatable {
  const ProviderServiceState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class ProviderServiceInitial extends ProviderServiceState {}

/// Loading state
class ProviderServiceLoading extends ProviderServiceState {}

/// Services loaded successfully
class ProviderServicesLoaded extends ProviderServiceState {
  final List<ServiceModel> services;

  const ProviderServicesLoaded(this.services);

  @override
  List<Object?> get props => [services];
}

/// Service added successfully
class ServiceAdded extends ProviderServiceState {
  final ServiceModel service;
  final String message;

  const ServiceAdded(this.service, this.message);

  @override
  List<Object?> get props => [service, message];
}

/// Service updated successfully
class ServiceUpdated extends ProviderServiceState {
  final ServiceModel service;
  final String message;

  const ServiceUpdated(this.service, this.message);

  @override
  List<Object?> get props => [service, message];
}

/// Service deleted successfully
class ServiceDeleted extends ProviderServiceState {
  final String serviceId;
  final String message;

  const ServiceDeleted(this.serviceId, this.message);

  @override
  List<Object?> get props => [serviceId, message];
}

/// Service status toggled successfully
class ServiceStatusToggled extends ProviderServiceState {
  final ServiceModel service;
  final String message;

  const ServiceStatusToggled(this.service, this.message);

  @override
  List<Object?> get props => [service, message];
}

/// Error state
class ProviderServiceError extends ProviderServiceState {
  final String message;
  final dynamic error; // The actual error object for better error handling

  const ProviderServiceError(this.message, {this.error});

  @override
  List<Object?> get props => [message, error];
}

/// Empty state (no services found)
class ProviderServicesEmpty extends ProviderServiceState {
  final String message;

  const ProviderServicesEmpty(this.message);

  @override
  List<Object?> get props => [message];
}
