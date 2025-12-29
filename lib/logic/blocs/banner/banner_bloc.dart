import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wedly/data/repositories/banner_repository.dart';
import 'banner_event.dart';
import 'banner_state.dart';

/// BLoC for managing banner state
class BannerBloc extends Bloc<BannerEvent, BannerState> {
  final BannerRepository bannerRepository;

  BannerBloc({required this.bannerRepository}) : super(BannerInitial()) {
    on<BannersRequested>(_onBannersRequested);
    on<BannersRefreshed>(_onBannersRefreshed);
  }

  /// Handle loading banners
  Future<void> _onBannersRequested(
    BannersRequested event,
    Emitter<BannerState> emit,
  ) async {
    print('🎯 BannerBloc: Loading banners...');
    emit(BannerLoading());

    try {
      final banners = await bannerRepository.getBanners();
      print('✅ BannerBloc: Received ${banners.length} active banners');

      for (var banner in banners) {
        print('  - Banner ID: ${banner.id}, Image: ${banner.imageUrl}');
      }

      emit(BannerLoaded(banners: banners));
    } catch (e) {
      print('❌ BannerBloc: Error loading banners: $e');
      emit(const BannerError(
        message: 'فشل تحميل العروض. يرجى المحاولة مرة أخرى.',
      ));
    }
  }

  /// Handle refreshing banners
  Future<void> _onBannersRefreshed(
    BannersRefreshed event,
    Emitter<BannerState> emit,
  ) async {
    // Don't show loading state on refresh
    try {
      final banners = await bannerRepository.getBanners();

      emit(BannerLoaded(banners: banners));
    } catch (e) {
      // Keep current state if refresh fails
      if (state is BannerLoaded) {
        emit(state);
      } else {
        emit(const BannerError(
          message: 'فشل تحديث العروض. يرجى المحاولة مرة أخرى.',
        ));
      }
    }
  }
}
