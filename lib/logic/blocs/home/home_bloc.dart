import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
      // Run ALL requests in parallel for speed, but handle errors individually
      // NOTE: Skipping layout - this endpoint doesn't exist on backend
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
        // 4: Countdown - try API first, fallback to calculating from bookings
        event.userId != null
            ? _getCountdownWithFallback(event.userId!)
            : Future.value(null),
      ]);

      final categoriesWithDetails = (results[0] as List).cast<CategoryModel>();
      final services = (results[1] as List).cast<ServiceModel>();
      final categories = (results[2] as List).cast<String>();
      final rawOffers = (results[3] as List).cast<OfferModel>();
      final countdown = results[4] as CountdownModel?;
      const HomeLayoutModel? layout = null; // Endpoint doesn't exist

      // Categories are critical - if empty, show error
      if (categoriesWithDetails.isEmpty) {
        emit(const HomeError(
          'عذراً، لم نتمكن من تحميل الخدمات.\nيرجى التحقق من اتصالك بالإنترنت والمحاولة مرة أخرى.',
        ));
        return;
      }

      // Filter out stale offers: cross-reference with services to remove
      // offers whose service has discount_percentage=0 or has_offer=false
      final offers = _filterActiveOffers(rawOffers, services);

      debugPrint('📊 HomeBloc Data Loaded:');
      debugPrint('   CategoriesWithDetails: ${categoriesWithDetails.length}');
      debugPrint('   Services: ${services.length}');
      debugPrint('   Offers: ${rawOffers.length} raw → ${offers.length} active');
      debugPrint('   Countdown: ${countdown != null ? "Loaded (${countdown.weddingDate})" : "None"}');

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
      // NOTE: Skipping layout - this endpoint doesn't exist on backend
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
        // Fetch countdown with fallback if userId provided
        event.userId != null
            ? _getCountdownWithFallback(event.userId!).catchError((e) {
                debugPrint('⚠️ Silent refresh: Failed to load countdown: $e');
                return currentState?.countdown;
              })
            : Future.value(currentState?.countdown),
      ]);

      final categoriesWithDetails = (results[0] as List).cast<CategoryModel>();
      final services = (results[1] as List).cast<ServiceModel>();
      final categories = (results[2] as List).cast<String>();
      final rawOffers = (results[3] as List).cast<OfferModel>();
      final countdown = results[4] as CountdownModel?;
      final layout = currentState?.layout; // Keep existing layout

      // Filter out stale offers
      final offers = _filterActiveOffers(rawOffers, services);

      debugPrint('🔄 HomeBloc: Silent refresh completed - ${categoriesWithDetails.length} categories, ${offers.length} active offers');

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

  /// Get countdown with fallback to calculating from bookings
  /// First tries API, then calculates from confirmed venue bookings
  /// If API returns a past date, falls back to bookings for auto-correction
  Future<CountdownModel?> _getCountdownWithFallback(String userId) async {
    try {
      // Try to get countdown from API first
      final apiCountdown = await serviceRepository.getUserCountdown(userId);
      if (apiCountdown != null) {
        debugPrint('📅 Countdown from API: ${apiCountdown.weddingDate}');

        // Check if the date is in the future
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

    // Fallback: Calculate countdown from confirmed venue bookings
    try {
      final bookings = await bookingRepository.getUserBookings(userId);
      debugPrint('📅 Found ${bookings.length} total bookings');

      // Filter for confirmed venue bookings
      // Venues are identified by having a timeSlot (morning/evening) - this is the most reliable indicator
      final venueBookings = bookings.where((booking) {
        final isConfirmed = booking.status == BookingStatus.confirmed;
        final isVenue = booking.timeSlot.isNotEmpty; // Only venues have morning/evening timeSlots

        if (isVenue) {
          debugPrint('📅 Found venue booking: ${booking.serviceName} - ${booking.bookingDate} - Status: ${booking.status.name} - timeSlot: ${booking.timeSlot}');
        }
        return isConfirmed && isVenue;
      }).toList();

      if (venueBookings.isEmpty) {
        debugPrint('📅 No confirmed venue bookings found');
        return null;
      }

      // Get the LATEST venue booking date as wedding date (users typically reschedule/book final venue later)
      venueBookings.sort((a, b) => a.bookingDate.compareTo(b.bookingDate));
      final weddingDate = venueBookings.last.bookingDate; // Changed from .first to .last

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

  /// Filter out stale offers by cross-referencing with actual service data.
  /// The offers API may still return offers for services that had their
  /// discount removed (discount_percentage set to 0).
  List<OfferModel> _filterActiveOffers(
    List<OfferModel> offers,
    List<ServiceModel> services,
  ) {
    // Build a lookup of services by ID
    final serviceMap = <String, ServiceModel>{};
    for (final service in services) {
      serviceMap[service.id] = service;
    }

    return offers.where((offer) {
      // Check 1: Offer's own validity (expiry, prices)
      if (!offer.isValid) {
        debugPrint('🚫 Filtering out invalid offer: ${offer.titleAr}');
        return false;
      }

      // Check 2: Cross-reference with service data
      if (offer.serviceId != null) {
        final service = serviceMap[offer.serviceId];
        if (service != null && !service.hasApprovedOffer) {
          debugPrint('🚫 Filtering out offer "${offer.titleAr}" - service ${offer.serviceId} has no active discount');
          return false;
        }
      }

      // Check 3: If offer has no discount (originalPrice == discountedPrice or both 0)
      if (offer.originalPrice > 0 && offer.discountedPrice >= offer.originalPrice) {
        debugPrint('🚫 Filtering out offer "${offer.titleAr}" - no actual discount');
        return false;
      }

      return true;
    }).toList();
  }
}

