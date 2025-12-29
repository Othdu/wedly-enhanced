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
  final String? city;
  final double? minPrice;
  final double? maxPrice;
  final double? rating;
  final bool? hasOffer;
  final int page;
  final int limit;
  final String? sort;

  const ServicesByCategoryRequested(
    this.category, {
    this.city,
    this.minPrice,
    this.maxPrice,
    this.rating,
    this.hasOffer,
    this.page = 1,
    this.limit = 10,
    this.sort,
  });

  @override
  List<Object?> get props => [
        category,
        city,
        minPrice,
        maxPrice,
        rating,
        hasOffer,
        page,
        limit,
        sort,
      ];
}

/// Event to load more services (pagination)
class LoadMoreServicesRequested extends ServiceEvent {
  const LoadMoreServicesRequested();
}

/// Event to fetch available cities from API
class CitiesRequested extends ServiceEvent {
  const CitiesRequested();
}

