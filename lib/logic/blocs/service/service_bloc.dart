import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wedly/data/models/service_model.dart';
import 'package:wedly/data/repositories/service_repository.dart';
import 'package:wedly/logic/blocs/service/service_event.dart';
import 'package:wedly/logic/blocs/service/service_state.dart';

class ServiceBloc extends Bloc<ServiceEvent, ServiceState> {
  final ServiceRepository serviceRepository;

  ServiceBloc({required this.serviceRepository}) : super(const ServiceInitial()) {
    on<ServiceRequested>(_onServiceRequested);
    on<ServicesByCategoryRequested>(_onServicesByCategoryRequested);
    on<LoadMoreServicesRequested>(_onLoadMoreServicesRequested);
    on<CitiesRequested>(_onCitiesRequested);
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
      // Fetch cities for filter dropdown
      final cities = await serviceRepository.getCities();

      // Fetch services with filters
      final result = await serviceRepository.getServicesByCategoryWithFilters(
        event.category,
        city: event.city,
        minPrice: event.minPrice,
        maxPrice: event.maxPrice,
        rating: event.rating,
        hasOffer: event.hasOffer,
        page: event.page,
        limit: event.limit,
        sort: event.sort,
      );

      final services = result['services'] as List<ServiceModel>;
      final pagination = result['pagination'] as Map<String, dynamic>;
      final hasMore = result['hasMore'] as bool;

      emit(ServicesByCategoryLoaded(
        services: services,
        category: event.category,
        currentPage: pagination['current_page'] as int,
        totalPages: pagination['total_pages'] as int,
        totalItems: pagination['total_items'] as int,
        hasMore: hasMore,
        isLoadingMore: false,
        city: event.city,
        minPrice: event.minPrice,
        maxPrice: event.maxPrice,
        rating: event.rating,
        hasOffer: event.hasOffer,
        sort: event.sort,
        availableCities: cities,
      ));
    } catch (e) {
      emit(ServiceError(e.toString()));
    }
  }

  Future<void> _onLoadMoreServicesRequested(
    LoadMoreServicesRequested event,
    Emitter<ServiceState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ServicesByCategoryLoaded) return;
    if (!currentState.hasMore || currentState.isLoadingMore) return;

    // Emit loading more state
    emit(currentState.copyWith(isLoadingMore: true));

    try {
      final nextPage = currentState.currentPage + 1;

      final result = await serviceRepository.getServicesByCategoryWithFilters(
        currentState.category,
        city: currentState.city,
        minPrice: currentState.minPrice,
        maxPrice: currentState.maxPrice,
        rating: currentState.rating,
        hasOffer: currentState.hasOffer,
        page: nextPage,
        limit: 10,
        sort: currentState.sort,
      );

      final newServices = result['services'] as List<ServiceModel>;
      final pagination = result['pagination'] as Map<String, dynamic>;
      final hasMore = result['hasMore'] as bool;

      // Append new services to existing list
      final allServices = [...currentState.services, ...newServices];

      emit(currentState.copyWith(
        services: allServices,
        currentPage: pagination['current_page'] as int,
        totalPages: pagination['total_pages'] as int,
        totalItems: pagination['total_items'] as int,
        hasMore: hasMore,
        isLoadingMore: false,
      ));
    } catch (e) {
      // On error, just stop loading more
      emit(currentState.copyWith(isLoadingMore: false));
    }
  }

  Future<void> _onCitiesRequested(
    CitiesRequested event,
    Emitter<ServiceState> emit,
  ) async {
    try {
      final cities = await serviceRepository.getCities();
      emit(CitiesLoaded(cities));
    } catch (e) {
      emit(ServiceError(e.toString()));
    }
  }
}

