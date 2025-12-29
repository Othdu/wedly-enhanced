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
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final bool hasMore;
  final bool isLoadingMore;
  // Current filter values for "Load More" to use
  final String category;
  final String? city;
  final double? minPrice;
  final double? maxPrice;
  final double? rating;
  final bool? hasOffer;
  final String? sort;
  // Available cities for filter dropdown
  final List<String> availableCities;

  const ServicesByCategoryLoaded({
    required this.services,
    required this.category,
    this.currentPage = 1,
    this.totalPages = 1,
    this.totalItems = 0,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.city,
    this.minPrice,
    this.maxPrice,
    this.rating,
    this.hasOffer,
    this.sort,
    this.availableCities = const [],
  });

  /// Create a copy with updated values
  ServicesByCategoryLoaded copyWith({
    List<ServiceModel>? services,
    String? category,
    int? currentPage,
    int? totalPages,
    int? totalItems,
    bool? hasMore,
    bool? isLoadingMore,
    String? city,
    double? minPrice,
    double? maxPrice,
    double? rating,
    bool? hasOffer,
    String? sort,
    List<String>? availableCities,
  }) {
    return ServicesByCategoryLoaded(
      services: services ?? this.services,
      category: category ?? this.category,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalItems: totalItems ?? this.totalItems,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      city: city ?? this.city,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      rating: rating ?? this.rating,
      hasOffer: hasOffer ?? this.hasOffer,
      sort: sort ?? this.sort,
      availableCities: availableCities ?? this.availableCities,
    );
  }

  @override
  List<Object?> get props => [
        services,
        currentPage,
        totalPages,
        totalItems,
        hasMore,
        isLoadingMore,
        category,
        city,
        minPrice,
        maxPrice,
        rating,
        hasOffer,
        sort,
        availableCities,
      ];
}

/// State when cities are loaded
class CitiesLoaded extends ServiceState {
  final List<String> cities;

  const CitiesLoaded(this.cities);

  @override
  List<Object?> get props => [cities];
}

class ServiceError extends ServiceState {
  final String message;

  const ServiceError(this.message);

  @override
  List<Object?> get props => [message];
}

