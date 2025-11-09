import 'package:equatable/equatable.dart';
import '../../../data/models/service_model.dart';

abstract class ProviderServiceEvent extends Equatable {
  const ProviderServiceEvent();

  @override
  List<Object?> get props => [];
}

/// Event to fetch provider's services
class FetchProviderServices extends ProviderServiceEvent {
  final String providerId;

  const FetchProviderServices(this.providerId);

  @override
  List<Object?> get props => [providerId];
}

/// Event to add a new service
class AddService extends ProviderServiceEvent {
  final ServiceModel service;

  const AddService(this.service);

  @override
  List<Object?> get props => [service];
}

/// Event to update an existing service
class UpdateService extends ProviderServiceEvent {
  final ServiceModel service;

  const UpdateService(this.service);

  @override
  List<Object?> get props => [service];
}

/// Event to delete a service
class DeleteService extends ProviderServiceEvent {
  final String serviceId;

  const DeleteService(this.serviceId);

  @override
  List<Object?> get props => [serviceId];
}

/// Event to toggle service active status
class ToggleServiceStatus extends ProviderServiceEvent {
  final String serviceId;

  const ToggleServiceStatus(this.serviceId);

  @override
  List<Object?> get props => [serviceId];
}

/// Event to refresh provider services
class RefreshProviderServices extends ProviderServiceEvent {
  final String providerId;

  const RefreshProviderServices(this.providerId);

  @override
  List<Object?> get props => [providerId];
}
