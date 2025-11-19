import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wedly/data/models/countdown_model.dart';
import 'package:wedly/data/models/home_layout_model.dart';
import 'package:wedly/data/repositories/service_repository.dart';
import 'package:wedly/data/repositories/offer_repository.dart';
import 'package:wedly/logic/blocs/home/home_event.dart';
import 'package:wedly/logic/blocs/home/home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final ServiceRepository serviceRepository;
  final OfferRepository offerRepository;

  HomeBloc({
    required this.serviceRepository,
    required this.offerRepository,
  }) : super(const HomeInitial()) {
    on<HomeServicesRequested>(_onHomeServicesRequested);
    on<HomeCategoriesRequested>(_onHomeCategoriesRequested);
  }

  Future<void> _onHomeServicesRequested(
    HomeServicesRequested event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeLoading());
    try {
      // Fetch all data in parallel for better performance
      final results = await Future.wait([
        serviceRepository.getServices(),
        serviceRepository.getCategories(),
        serviceRepository.getCategoriesWithDetails(),
        offerRepository.getOffers(), // Use OfferRepository instead
        serviceRepository.getHomeLayout(),
        if (event.userId != null)
          serviceRepository.getUserCountdown(event.userId!)
        else
          Future.value(null),
      ]);

      final services = results[0] as List;
      final categories = results[1] as List<String>;
      final categoriesWithDetails = results[2] as List;
      final offers = results[3] as List;
      final layout = results[4] as HomeLayoutModel?;
      final countdown = results.length > 5 ? results[5] as CountdownModel? : null;

      emit(HomeLoaded(
        services: services.cast(),
        categories: categories,
        categoriesWithDetails: categoriesWithDetails.cast(),
        offers: offers.cast(),
        layout: layout,
        countdown: countdown,
      ));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }

  Future<void> _onHomeCategoriesRequested(
    HomeCategoriesRequested event,
    Emitter<HomeState> emit,
  ) async {
    try {
      final categories = await serviceRepository.getCategories();
      if (state is HomeLoaded) {
        final currentState = state as HomeLoaded;
        emit(HomeLoaded(
          services: currentState.services,
          categories: categories,
        ));
      }
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }
}

