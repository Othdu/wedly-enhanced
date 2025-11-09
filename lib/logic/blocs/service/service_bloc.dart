import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wedly/data/repositories/service_repository.dart';
import 'package:wedly/logic/blocs/service/service_event.dart';
import 'package:wedly/logic/blocs/service/service_state.dart';

class ServiceBloc extends Bloc<ServiceEvent, ServiceState> {
  final ServiceRepository serviceRepository;

  ServiceBloc({required this.serviceRepository}) : super(const ServiceInitial()) {
    on<ServiceRequested>(_onServiceRequested);
    on<ServicesByCategoryRequested>(_onServicesByCategoryRequested);
  }

  Future<void> _onServiceRequested(
    ServiceRequested event,
    Emitter<ServiceState> emit,
  ) async {
    emit(const ServiceLoading());
    try {
      final service = await serviceRepository.getServiceById(event.serviceId);
      if (service != null) {
        emit(ServiceLoaded(service));
      } else {
        emit(const ServiceError('Service not found'));
      }
    } catch (e) {
      emit(ServiceError(e.toString()));
    }
  }

  Future<void> _onServicesByCategoryRequested(
    ServicesByCategoryRequested event,
    Emitter<ServiceState> emit,
  ) async {
    emit(const ServiceLoading());
    try {
      final services = await serviceRepository.getServicesByCategory(event.category);
      emit(ServicesByCategoryLoaded(services));
    } catch (e) {
      emit(ServiceError(e.toString()));
    }
  }
}

