import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wedly/core/utils/error_handler.dart';
import 'package:wedly/data/models/countdown_model.dart';
import 'package:wedly/data/models/home_layout_model.dart';
import 'package:wedly/data/models/service_model.dart';
import 'package:wedly/data/models/category_model.dart';
import 'package:wedly/data/models/offer_model.dart';
import 'package:wedly/data/repositories/service_repository.dart';
import 'package:wedly/data/repositories/offer_repository.dart';
import 'package:wedly/data/repositories/booking_repository.dart';
import 'package:wedly/core/utils/enums.dart';
import 'package:wedly/logic/blocs/home/home_event.dart';
import 'package:wedly/logic/blocs/home/home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final ServiceRepository serviceRepository;
  final OfferRepository offerRepository;
  final BookingRepository bookingRepository;

  HomeBloc({
    required this.serviceRepository,
    required this.offerRepository,
    required this.bookingRepository,
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
      // Public endpoints — work for both guests and logged-in users
      final results = await Future.wait([
        // 0: Categories (public endpoint, no auth needed)
        serviceRepository.getCategoriesWithDetails().catchError((e) {
          debugPrint('⚠️ Failed to load categories: $e');
          return <CategoryModel>[];
        }),
        // 1: Services (public endpoint, no auth needed)
        serviceRepository.getServices().catchError((e) {
          debugPrint('⚠️ Failed to load services: $e');
          return <ServiceModel>[];
        }),
        // 2: Category names (public endpoint, no auth needed)
        serviceRepository.getCategories().catchError((e) {
          debugPrint('⚠️ Failed to load category names: $e');
          return <String>[];
        }),
        // 3: Offers (public endpoint, no auth needed)
        offerRepository.getOffers().catchError((e) {
          debugPrint('⚠️ Failed to load offers: $e');
          return <OfferModel>[];
        }),
        // 4: Countdown — only for logged-in users, guests always get null
        event.userId != null
            ? _getCountdownWithFallback(event.userId!).catchError((e) {
                debugPrint('⚠️ Failed to load countdown: $e');
                return null;
              })
            : Future<CountdownModel?>.value(null),
      ]);

      final categoriesWithDetails = (results[0] as List).cast<CategoryModel>();
      final services = (results[1] as List).cast<ServiceModel>();
      final categories = (results[2] as List).cast<String>();
      final rawOffers = (results[3] as List).cast<OfferModel>();
      final countdown = results[4] as CountdownModel?;
      const HomeLayoutModel? layout = null;

      final offers = _filterActiveOffers(rawOffers, services);

      debugPrint('📊 HomeBloc Data Loaded:');
      debugPrint('   CategoriesWithDetails: ${categoriesWithDetails.length}');
      debugPrint('   Services: ${services.length}');
      debugPrint('   Offers: ${rawOffers.length} raw → ${offers.length} active');
      debugPrint('   Countdown: ${countdown != null ? "Loaded" : "None (guest or no booking)"}');
      debugPrint('   Guest mode: ${event.userId == null}');

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
      // Only show error for non-auth errors
      // If it's an auth/401 error in guest mode, still show empty home
      final eStr = e.toString().toLowerCase();
      final isAuthError = eStr.contains('401') ||
          eStr.contains('unauthorized') ||
          eStr.contains('unauthenticated');

      if (isAuthError && event.userId == null) {
        // Guest hit an auth-protected endpoint — show empty home instead of error
        debugPrint('⚠️ Auth error in guest mode — showing empty home instead of error');
        emit(const HomeLoaded(
          services: [],
          categories: [],
          categoriesWithDetails: [],
          offers: [],
        ));
      } else {
        emit(const HomeError(
          'عذراً، لم نتمكن من تحميل البيانات.\nيرجى التحقق من اتصالك بالإنترنت والمحاولة مرة أخرى.',
        ));
      }
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
      emit(HomeError(ErrorHandler.getUserFriendlyMessage(e)));
    }
  }

  Future<void> _onSilentRefreshHome(
    SilentRefreshHome event,
    Emitter<HomeState> emit,
  ) async {
    try {
      debugPrint('🔄 HomeBloc: Silent refresh started');

      // Don't silent refresh for guests — no point
      if (event.userId == null) {
        debugPrint('🔄 HomeBloc: Skipping silent refresh for guest');
        return;
      }

      final currentState = state is HomeLoaded ? state as HomeLoaded : null;

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
        _getCountdownWithFallback(event.userId!).catchError((e) {
          debugPrint('⚠️ Silent refresh: Failed to load countdown: $e');
          return currentState?.countdown;
        }),
      ]);

      final categoriesWithDetails = (results[0] as List).cast<CategoryModel>();
      final services = (results[1] as List).cast<ServiceModel>();
      final categories = (results[2] as List).cast<String>();
      final rawOffers = (results[3] as List).cast<OfferModel>();
      final countdown = results[4] as CountdownModel?;
      final layout = currentState?.layout;

      final offers = _filterActiveOffers(rawOffers, services);

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
      debugPrint('🔄 HomeBloc: Silent refresh error (ignored): $e');
      // Keep current state on silent refresh failure
    }
  }

  Future<CountdownModel?> _getCountdownWithFallback(String userId) async {
    try {
      final apiCountdown = await serviceRepository.getUserCountdown(userId);
      if (apiCountdown != null) {
        debugPrint('📅 Countdown from API: ${apiCountdown.weddingDate}');
        final now = DateTime.now();
        if (apiCountdown.weddingDate.isAfter(now)) {
          debugPrint('📅 API date is valid (in future), using it!');
          return apiCountdown;
        } else {
          debugPrint('📅 API date is in the past, falling back to bookings...');
        }
      } else {
        debugPrint('📅 API returned null, calculating from bookings...');
      }
    } catch (e) {
      debugPrint('📅 API countdown failed: $e, calculating from bookings...');
    }

    try {
      final bookings = await bookingRepository.getUserBookings(userId);
      debugPrint('📅 Found ${bookings.length} total bookings');

      final venueBookings = bookings.where((booking) {
        final isConfirmed = booking.status == BookingStatus.confirmed;
        final isVenue = booking.timeSlot.isNotEmpty;
        if (isVenue) {
          debugPrint('📅 Found venue booking: ${booking.serviceName} - ${booking.bookingDate} - Status: ${booking.status.name}');
        }
        return isConfirmed && isVenue;
      }).toList();

      if (venueBookings.isEmpty) {
        debugPrint('📅 No confirmed venue bookings found');
        return null;
      }

      venueBookings.sort((a, b) => a.bookingDate.compareTo(b.bookingDate));
      final weddingDate = venueBookings.last.bookingDate;

      debugPrint('📅 Wedding date calculated from LATEST booking: $weddingDate');

      return CountdownModel(
        userId: userId,
        weddingDate: weddingDate,
        title: 'Wedding Countdown',
        titleAr: 'العد التنازلي للفرح',
      );
    } catch (e) {
      debugPrint('❌ Failed to calculate countdown from bookings: $e');
      return null;
    }
  }

  List<OfferModel> _filterActiveOffers(
    List<OfferModel> offers,
    List<ServiceModel> services,
  ) {
    final serviceMap = <String, ServiceModel>{};
    for (final service in services) {
      serviceMap[service.id] = service;
    }

    return offers.where((offer) {
      if (!offer.isValid) {
        debugPrint('🚫 Filtering out invalid offer: ${offer.titleAr}');
        return false;
      }

      if (offer.serviceId != null) {
        final service = serviceMap[offer.serviceId];
        if (service != null && !service.hasApprovedOffer) {
          debugPrint('🚫 Filtering out offer "${offer.titleAr}" - service has no active discount');
          return false;
        }
      }

      if (offer.originalPrice > 0 && offer.discountedPrice >= offer.originalPrice) {
        debugPrint('🚫 Filtering out offer "${offer.titleAr}" - no actual discount');
        return false;
      }

      return true;
    }).toList();
  }
}