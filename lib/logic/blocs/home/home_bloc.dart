import 'package:flutter/foundation.dart';
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
    on<SilentRefreshHome>(_onSilentRefreshHome);
  }

  Future<void> _onHomeServicesRequested(
    HomeServicesRequested event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeLoading());
    try {
      // Run ALL requests in parallel for speed, but handle errors individually
      // NOTE: Skipping layout and countdown - these endpoints don't exist on backend
      final results = await Future.wait([
        // 0: Categories (critical)
        serviceRepository.getCategoriesWithDetails().catchError((e) {
          debugPrint('⚠️ Failed to load categories: $e');
          return <CategoryModel>[];
        }),
        // 1: Services (optional)
        serviceRepository.getServices().catchError((e) {
          debugPrint('⚠️ Failed to load services: $e');
          return <ServiceModel>[];
        }),
        // 2: Category names (optional)
        serviceRepository.getCategories().catchError((e) {
          debugPrint('⚠️ Failed to load category names: $e');
          return <String>[];
        }),
        // 3: Offers (optional)
        offerRepository.getOffers().catchError((e) {
          debugPrint('⚠️ Failed to load offers: $e');
          return <OfferModel>[];
        }),
      ]);

      final categoriesWithDetails = (results[0] as List).cast<CategoryModel>();
      final services = (results[1] as List).cast<ServiceModel>();
      final categories = (results[2] as List).cast<String>();
      final offers = (results[3] as List).cast<OfferModel>();
      const HomeLayoutModel? layout = null; // Endpoint doesn't exist
      const CountdownModel? countdown = null; // Endpoint doesn't exist

      // Categories are critical - if empty, show error
      if (categoriesWithDetails.isEmpty) {
        emit(const HomeError(
          'عذراً، لم نتمكن من تحميل الخدمات.\nيرجى التحقق من اتصالك بالإنترنت والمحاولة مرة أخرى.',
        ));
        return;
      }

      debugPrint('📊 HomeBloc Data Loaded:');
      debugPrint('   CategoriesWithDetails: ${categoriesWithDetails.length}');
      debugPrint('   Services: ${services.length}');
      debugPrint('   Offers: ${offers.length}');

      emit(HomeLoaded(
        services: services,
        categories: categories,
        categoriesWithDetails: categoriesWithDetails,
        offers: offers,
        layout: layout,
        countdown: countdown,
      ));
    } catch (e) {
      debugPrint('⚠️ HomeBloc Error: $e');

      emit(const HomeError(
        'عذراً، لم نتمكن من تحميل البيانات.\nيرجى التحقق من اتصالك بالإنترنت والمحاولة مرة أخرى.',
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

  /// Silent refresh - updates data without showing loading indicator
  Future<void> _onSilentRefreshHome(
    SilentRefreshHome event,
    Emitter<HomeState> emit,
  ) async {
    // Don't emit loading state - silent refresh in background
    try {
      debugPrint('🔄 HomeBloc: Silent refresh started');

      final currentState = state is HomeLoaded ? state as HomeLoaded : null;

      // Run ALL requests in parallel, fallback to current data on error
      // NOTE: Skipping layout and countdown - these endpoints don't exist on backend
      final results = await Future.wait([
        serviceRepository.getCategoriesWithDetails().catchError((e) {
          return currentState?.categoriesWithDetails ?? <CategoryModel>[];
        }),
        serviceRepository.getServices().catchError((e) {
          return currentState?.services ?? <ServiceModel>[];
        }),
        serviceRepository.getCategories().catchError((e) {
          return currentState?.categories ?? <String>[];
        }),
        offerRepository.getOffers().catchError((e) {
          return currentState?.offers ?? <OfferModel>[];
        }),
      ]);

      final categoriesWithDetails = (results[0] as List).cast<CategoryModel>();
      final services = (results[1] as List).cast<ServiceModel>();
      final categories = (results[2] as List).cast<String>();
      final offers = (results[3] as List).cast<OfferModel>();
      final layout = currentState?.layout; // Keep existing layout
      final countdown = currentState?.countdown; // Keep existing countdown

      debugPrint('🔄 HomeBloc: Silent refresh completed - ${categoriesWithDetails.length} categories');

      emit(HomeLoaded(
        services: services,
        categories: categories,
        categoriesWithDetails: categoriesWithDetails,
        offers: offers,
        layout: layout,
        countdown: countdown,
      ));
    } catch (e) {
      // Silently fail - don't show error to user during background refresh
      debugPrint('🔄 HomeBloc: Silent refresh error (ignored): $e');
      // Keep current state - don't emit error
    }
  }
}

