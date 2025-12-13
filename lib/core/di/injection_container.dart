import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:wedly/data/repositories/auth_repository.dart';
import 'package:wedly/data/repositories/service_repository.dart';
import 'package:wedly/data/repositories/booking_repository.dart';
import 'package:wedly/data/repositories/cart_repository.dart';
import 'package:wedly/data/repositories/venue_repository.dart';
import 'package:wedly/data/repositories/review_repository.dart';
import 'package:wedly/data/repositories/offer_repository.dart';
import 'package:wedly/data/repositories/notification_repository.dart';
import 'package:wedly/data/repositories/address_repository.dart';
import 'package:wedly/data/repositories/banner_repository.dart';
import 'package:wedly/data/repositories/category_repository.dart';
import 'package:wedly/data/services/api_client.dart';
import 'package:wedly/data/services/token_manager.dart';
import 'package:wedly/data/services/image_upload_service.dart';
import 'package:wedly/logic/blocs/auth/auth_bloc.dart';
import 'package:wedly/logic/blocs/home/home_bloc.dart';
import 'package:wedly/logic/blocs/service/service_bloc.dart';
import 'package:wedly/logic/blocs/booking/booking_bloc.dart';
import 'package:wedly/logic/blocs/provider_service/provider_service_bloc.dart';
import 'package:wedly/logic/blocs/search/search_bloc.dart';
import 'package:wedly/logic/blocs/cart/cart_bloc.dart';
import 'package:wedly/logic/blocs/venue/venue_bloc.dart';
import 'package:wedly/logic/blocs/review/review_bloc.dart';
import 'package:wedly/logic/blocs/notification/notification_bloc.dart';
import 'package:wedly/logic/blocs/address/address_bloc.dart';
import 'package:wedly/logic/blocs/banner/banner_bloc.dart';

final getIt = GetIt.instance;

/// Set to true to use mock data, false to use real API
/// Change this when backend is ready
const bool _useMockData = false;

Future<void> setupDependencyInjection() async {
  // Core Services
  getIt.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );

  getIt.registerLazySingleton<TokenManager>(
    () => TokenManager(getIt<FlutterSecureStorage>()),
  );

  // API Client (only register if not using mock data)
  if (!_useMockData) {
    getIt.registerLazySingleton<ApiClient>(
      () => ApiClient(getIt<TokenManager>()),
    );

    // Image Upload Service (depends on ApiClient)
    getIt.registerLazySingleton<ImageUploadService>(
      () => ImageUploadService(getIt<ApiClient>()),
    );
  }

  // Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepository(
      apiClient: _useMockData ? null : getIt<ApiClient>(),
      tokenManager: _useMockData ? null : getIt<TokenManager>(),
      useMockData: _useMockData,
    ),
  );

  getIt.registerLazySingleton<ServiceRepository>(
    () => ServiceRepository(
      apiClient: _useMockData ? null : getIt<ApiClient>(),
      useMockData: _useMockData,
    ),
  );

  getIt.registerLazySingleton<BookingRepository>(
    () => BookingRepository(
      apiClient: _useMockData ? null : getIt<ApiClient>(),
      useMockData: _useMockData,
    ),
  );

  getIt.registerLazySingleton<CartRepository>(
    () => CartRepository(
      apiClient: _useMockData ? null : getIt<ApiClient>(),
      useMockData: _useMockData,
    ),
  );

  getIt.registerLazySingleton<VenueRepository>(
    () => VenueRepository(
      apiClient: _useMockData ? null : getIt<ApiClient>(),
      useMockData: _useMockData,
    ),
  );

  getIt.registerLazySingleton<ReviewRepository>(
    () => ReviewRepository(
      apiClient: _useMockData ? null : getIt<ApiClient>(),
      useMockData: _useMockData,
    ),
  );

  getIt.registerLazySingleton<OfferRepository>(
    () => OfferRepository(
      apiClient: _useMockData ? null : getIt<ApiClient>(),
      useMockData: _useMockData,
    ),
  );

  getIt.registerLazySingleton<NotificationRepository>(
    () => NotificationRepository(
      apiClient: _useMockData ? null : getIt<ApiClient>(),
      useMockData: _useMockData,
    ),
  );

  getIt.registerLazySingleton<AddressRepository>(
    () => AddressRepository(
      apiClient: _useMockData ? null : getIt<ApiClient>(),
      useMockData: _useMockData,
    ),
  );

  getIt.registerLazySingleton<BannerRepository>(
    () => BannerRepository(),
  );

  getIt.registerLazySingleton<CategoryRepository>(
    () => CategoryRepository(
      apiClient: _useMockData ? null : getIt<ApiClient>(),
      useMockData: _useMockData,
    ),
  );

  // BLoCs - registered as factories for new instances
  getIt.registerFactory<AuthBloc>(
    () => AuthBloc(authRepository: getIt<AuthRepository>()),
  );

  getIt.registerFactory<HomeBloc>(
    () => HomeBloc(
      serviceRepository: getIt<ServiceRepository>(),
      offerRepository: getIt<OfferRepository>(),
    ),
  );

  getIt.registerFactory<ServiceBloc>(
    () => ServiceBloc(serviceRepository: getIt<ServiceRepository>()),
  );

  getIt.registerFactory<BookingBloc>(
    () => BookingBloc(bookingRepository: getIt<BookingRepository>()),
  );

  getIt.registerFactory<ProviderServiceBloc>(
    () => ProviderServiceBloc(serviceRepository: getIt<ServiceRepository>()),
  );

  getIt.registerFactory<SearchBloc>(
    () => SearchBloc(serviceRepository: getIt<ServiceRepository>()),
  );

  getIt.registerFactory<CartBloc>(
    () => CartBloc(cartRepository: getIt<CartRepository>()),
  );

  getIt.registerFactory<VenueBloc>(
    () => VenueBloc(venueRepository: getIt<VenueRepository>()),
  );

  getIt.registerFactory<ReviewBloc>(
    () => ReviewBloc(reviewRepository: getIt<ReviewRepository>()),
  );

  getIt.registerFactory<NotificationBloc>(
    () => NotificationBloc(notificationRepository: getIt<NotificationRepository>()),
  );

  getIt.registerFactory<AddressBloc>(
    () => AddressBloc(addressRepository: getIt<AddressRepository>()),
  );

  getIt.registerFactory<BannerBloc>(
    () => BannerBloc(bannerRepository: getIt<BannerRepository>()),
  );
}

