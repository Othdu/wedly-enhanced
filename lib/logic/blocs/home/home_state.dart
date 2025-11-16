import 'package:equatable/equatable.dart';
import 'package:wedly/data/models/service_model.dart';
import 'package:wedly/data/models/category_model.dart';
import 'package:wedly/data/models/countdown_model.dart';
import 'package:wedly/data/models/offer_model.dart';
import 'package:wedly/data/models/home_layout_model.dart';

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
  final List<CategoryModel> categoriesWithDetails;
  final CountdownModel? countdown;
  final List<OfferModel> offers;
  final HomeLayoutModel? layout;

  const HomeLoaded({
    required this.services,
    required this.categories,
    this.categoriesWithDetails = const [],
    this.countdown,
    this.offers = const [],
    this.layout,
  });

  @override
  List<Object?> get props => [services, categories, categoriesWithDetails, countdown, offers, layout];

  HomeLoaded copyWith({
    List<ServiceModel>? services,
    List<String>? categories,
    List<CategoryModel>? categoriesWithDetails,
    CountdownModel? countdown,
    List<OfferModel>? offers,
    HomeLayoutModel? layout,
  }) {
    return HomeLoaded(
      services: services ?? this.services,
      categories: categories ?? this.categories,
      categoriesWithDetails: categoriesWithDetails ?? this.categoriesWithDetails,
      countdown: countdown ?? this.countdown,
      offers: offers ?? this.offers,
      layout: layout ?? this.layout,
    );
  }
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}

