import 'package:equatable/equatable.dart';

abstract class ServiceEvent extends Equatable {
  const ServiceEvent();

  @override
  List<Object?> get props => [];
}

class ServiceRequested extends ServiceEvent {
  final String serviceId;

  const ServiceRequested(this.serviceId);

  @override
  List<Object?> get props => [serviceId];
}

class ServicesByCategoryRequested extends ServiceEvent {
  final String category;

  const ServicesByCategoryRequested(this.category);

  @override
  List<Object?> get props => [category];
}

