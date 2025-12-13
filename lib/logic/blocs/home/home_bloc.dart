import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wedly/data/models/countdown_model.dart';
import 'package:wedly/data/models/home_layout_model.dart';
import 'package:wedly/data/models/service_model.dart';
import 'package:wedly/data/models/category_model.dart';
import 'package:wedly/data/models/offer_model.dart';
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
      // Repositories have internal fallback to mock data
      final results = await Future.wait([
        serviceRepository.getServices(),
        serviceRepository.getCategories(),
        serviceRepository.getCategoriesWithDetails(),
        offerRepository.getOffers(),
        serviceRepository.getHomeLayout(),
        if (event.userId != null)
          serviceRepository.getUserCountdown(event.userId!)
        else
          Future.value(null),
      ]);

      // Safely cast results with type checking
      final services = (results[0] as List).cast<ServiceModel>();
      final categories = (results[1] as List).cast<String>();
      final categoriesWithDetails = (results[2] as List).cast<CategoryModel>();
      final offers = (results[3] as List).cast<OfferModel>();
      final layout = results[4] as HomeLayoutModel?;
      final countdown = results.length > 5 ? results[5] as CountdownModel? : null;

      print('📊 HomeBloc Data Loaded:');
      print('   Services: ${services.length}');
      print('   Categories: ${categories.length}');
      print('   CategoriesWithDetails: ${categoriesWithDetails.length}');
      print('   Offers: ${offers.length}');

      emit(HomeLoaded(
        services: services,
        categories: categories,
        categoriesWithDetails: categoriesWithDetails,
        offers: offers,
        layout: layout,
        countdown: countdown,
      ));
    } catch (e) {
      // This should rarely happen now since repositories have fallback
      // But if it does, we still show the UI structure
      print('⚠️ HomeBloc Error: $e');

      // Emit loaded state with empty data - repositories should have handled fallback
      emit(const HomeLoaded(
        services: [],
        categories: [],
        categoriesWithDetails: [],
        offers: [],
        layout: null,
        countdown: null,
      ));
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

