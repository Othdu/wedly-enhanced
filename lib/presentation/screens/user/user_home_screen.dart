import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wedly/data/models/category_model.dart';
import 'package:wedly/logic/blocs/auth/auth_bloc.dart';
import 'package:wedly/logic/blocs/auth/auth_state.dart';
import 'package:wedly/logic/blocs/home/home_bloc.dart';
import 'package:wedly/logic/blocs/home/home_event.dart';
import 'package:wedly/logic/blocs/home/home_state.dart';
import 'package:wedly/logic/blocs/cart/cart_bloc.dart';
import 'package:wedly/logic/blocs/cart/cart_state.dart';
import 'package:wedly/logic/blocs/cart/cart_event.dart';
import 'package:wedly/logic/blocs/notification/notification_bloc.dart';
import 'package:wedly/logic/blocs/notification/notification_state.dart';
import 'package:wedly/logic/blocs/notification/notification_event.dart';
import 'package:wedly/logic/blocs/banner/banner_bloc.dart';
import 'package:wedly/logic/blocs/banner/banner_state.dart';
import 'package:wedly/logic/blocs/banner/banner_event.dart';
import 'package:wedly/presentation/widgets/skeleton_loading.dart';
import 'package:wedly/presentation/widgets/banners_carousel_widget.dart';
import 'package:wedly/presentation/widgets/countdown_timer_widget.dart';
import 'package:wedly/presentation/widgets/categories_grid_widget.dart';
import 'package:wedly/presentation/screens/user/user_cart_screen.dart';
import 'package:wedly/routes/app_router.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen>
    with WidgetsBindingObserver {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    final authState = context.read<AuthBloc>().state;
    String? userId;

    if (authState is AuthAuthenticated) {
      userId = authState.user.id;
    }

    context.read<HomeBloc>().add(HomeServicesRequested(userId: userId));

    // Load cart items
    if (userId != null) {
      context.read<CartBloc>().add(CartItemsRequested(userId: userId));
    }

    // Load notifications
    if (userId != null) {
      context.read<NotificationBloc>().add(NotificationsRequested(userId: userId));
    }

    // Load banners
    context.read<BannerBloc>().add(const BannersRequested());

    // Start periodic background refresh
    _startPeriodicRefresh();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Refresh when app comes back to foreground - use silent refresh
    if (state == AppLifecycleState.resumed) {
      _loadDataInBackground();
    }
  }

  void _startPeriodicRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _loadDataInBackground();
    });
  }

  void _loadDataInBackground() {
    // Silent refresh - only update data, don't show loading indicator
    if (mounted) {
      final authState = context.read<AuthBloc>().state;
      String? userId;
      if (authState is AuthAuthenticated) {
        userId = authState.user.id;
      }
      context.read<HomeBloc>().add(SilentRefreshHome(userId: userId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, homeState) {
          if (homeState is HomeLoading) {
            return SkeletonLoading.homeScreen();
          }

          if (homeState is HomeError) {
            return _buildErrorView(context, homeState.message);
          }

          if (homeState is HomeLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                final authState = context.read<AuthBloc>().state;
                String? userId;
                if (authState is AuthAuthenticated) {
                  userId = authState.user.id;
                }
                context.read<HomeBloc>().add(
                  HomeServicesRequested(userId: userId),
                );
              },
              child: CustomScrollView(
                slivers: [
                  // Custom App Bar with user info
                  _buildAppBar(context),

                  // Countdown (only shows if user has booked venue and date is in future)
                  if (homeState.countdown != null &&
                      homeState.countdown!.timeRemaining.inSeconds > 0)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Builder(
                          builder: (context) {
                            final totalDays = homeState.countdown!.timeRemaining.inDays;

                            // Smart display based on time remaining:
                            // >= 7 days: Weeks, Days, Hours
                            // 1-6 days: Days, Hours, Minutes
                            // < 1 day: Hours, Minutes, Seconds
                            if (totalDays >= 7) {
                              return CountdownTimerWidget(
                                countdown: homeState.countdown!,
                                showWeeks: true,
                                showDays: true,
                                showHours: true,
                                showMinutes: false,
                                showSeconds: false,
                              );
                            } else if (totalDays >= 1) {
                              return CountdownTimerWidget(
                                countdown: homeState.countdown!,
                                showWeeks: false,
                                showDays: true,
                                showHours: true,
                                showMinutes: true,
                                showSeconds: false,
                              );
                            } else {
                              return CountdownTimerWidget(
                                countdown: homeState.countdown!,
                                showWeeks: false,
                                showDays: false,
                                showHours: true,
                                showMinutes: true,
                                showSeconds: true,
                              );
                            }
                          },
                        ),
                      ),
                    ),

                  // Banners Section - HARDCODED STRUCTURE
                  SliverToBoxAdapter(
                    child: BlocBuilder<BannerBloc, BannerState>(
                      builder: (context, bannerState) {
                        debugPrint('🖼️ BannerBlocBuilder: State = ${bannerState.runtimeType}');
                        if (bannerState is BannerLoaded) {
                          debugPrint('🖼️ BannerBlocBuilder: Loaded ${bannerState.banners.length} banners');
                        }
                        if (bannerState is BannerError) {
                          debugPrint('🖼️ BannerBlocBuilder: Error = ${bannerState.message}');
                        }
                        if (bannerState is BannerLoaded && bannerState.banners.isNotEmpty) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title: عروضنا
                              const Padding(
                                padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
                                child: Text(
                                  'عروضنا',
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Color(0xFFD4AF37),
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textDirection: TextDirection.rtl,
                                ),
                              ),
                              // Banners Carousel
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: BannersCarouselWidget(
                                  banners: bannerState.banners,
                                  autoplay: true,
                                  autoplayDuration: const Duration(seconds: 4),
                                  showIndicators: true,
                                ),
                              ),
                            ],
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),

                  // Categories Section - HARDCODED STRUCTURE (always visible)
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title: الخدمات
                        const Padding(
                          padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
                          child: Text(
                            'الخدمات',
                            style: TextStyle(
                              fontSize: 20,
                              color: Color(0xFFD4AF37),
                              fontWeight: FontWeight.bold,
                            ),
                            textDirection: TextDirection.rtl,
                          ),
                        ),
                        // Categories Grid or Empty State
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: homeState.categoriesWithDetails.isEmpty
                              ? Container(
                                  padding: const EdgeInsets.all(48),
                                  child: Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.category_outlined,
                                          size: 48,
                                          color: Colors.grey[400],
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'لا توجد فئات متاحة حالياً',
                                          textDirection: TextDirection.rtl,
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : CategoriesGridWidget(
                                  categories: homeState.categoriesWithDetails,
                                  onCategoryTap: (category) => _handleCategoryTap(context, category),
                                  crossAxisCount: 2,
                                  aspectRatio: 1.2,
                                  spacing: 12.0,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                ),
                        ),
                      ],
                    ),
                  ),

                  // Bottom padding
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ],
              ),
            );
          }

          return const Center(
            child: Text('لا توجد بيانات', textDirection: TextDirection.rtl),
          );
        },
      ),
    );
  }

  // ----------------------------------------------------------------------
  // FIXED APP BAR
  // ----------------------------------------------------------------------
  Widget _buildAppBar(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        debugPrint('🏠 UserHomeScreen: Building app bar');
        debugPrint('🔐 AuthState type: ${authState.runtimeType}');

        String userName = 'محمد';
        String? userImageUrl;

        if (authState is AuthAuthenticated) {
          userName = authState.user.name.split(' ').first;
          userImageUrl = authState.user.profileImageUrl;
          debugPrint('👤 Authenticated user: $userName (full: ${authState.user.name})');
        } else {
          debugPrint('⚠️ Not authenticated - using default name');
        }

        return SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 50, 16, 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFFD4AF37).withValues(alpha: 0.8),
                  const Color(0xFFB8941E).withValues(alpha: 0.9),
                ],
              ),
            ),
            child: Row(
              children: [
                // Profile on the FAR LEFT (reversed)
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.white,
                  backgroundImage: userImageUrl != null
                      ? NetworkImage(userImageUrl)
                      : null,
                  child: userImageUrl == null
                      ? const Icon(
                          Icons.person,
                          size: 36,
                          color: Color(0xFFD4AF37),
                        )
                      : null,
                ),

                const SizedBox(width: 16),

                // Text in the CENTER
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start, // moved to left
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'أهلاً بك $userName!',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'جاهز تبدأ رحلة تحضيرات زفافك مع Wedly؟',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                        textDirection: TextDirection.rtl,
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // Cart button with badge
                BlocBuilder<CartBloc, CartState>(
                  builder: (context, cartState) {
                    int itemCount = 0;
                    if (cartState is CartLoaded) {
                      itemCount = cartState.items.length;
                    }

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const UserCartScreen(),
                          ),
                        );
                      },
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.shopping_cart_outlined,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          if (itemCount > 0)
                            Positioned(
                              top: -4,
                              right: -4,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 20,
                                  minHeight: 20,
                                ),
                                child: Center(
                                  child: Builder(
                                    builder: (context) {
                                      final scaleFactor = (MediaQuery.of(context).size.width / 375).clamp(0.9, 1.3);
                                      return Text(
                                        itemCount > 9 ? '9+' : '$itemCount',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: (11 * scaleFactor).clamp(10.0, 13.0),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(width: 8),

                // Notification button with badge on FAR RIGHT (reversed)
                BlocBuilder<NotificationBloc, NotificationState>(
                  builder: (context, notificationState) {
                    int unreadCount = 0;
                    if (notificationState is NotificationLoaded) {
                      unreadCount = notificationState.unreadCount;
                    }

                    return GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, AppRouter.notificationsList);
                      },
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.notifications_outlined,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          if (unreadCount > 0)
                            Positioned(
                              top: -4,
                              right: -4,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 20,
                                  minHeight: 20,
                                ),
                                child: Center(
                                  child: Builder(
                                    builder: (context) {
                                      final scaleFactor = (MediaQuery.of(context).size.width / 375).clamp(0.9, 1.3);
                                      return Text(
                                        unreadCount > 9 ? '9+' : '$unreadCount',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: (11 * scaleFactor).clamp(10.0, 13.0),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Build error view with retry button
  Widget _buildErrorView(BuildContext context, String message) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFD4AF37).withValues(alpha: 0.1),
            const Color(0xFFF5F5F5),
          ],
        ),
      ),
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Error icon
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.wifi_off_rounded,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                ),
                const SizedBox(height: 32),
                // Error message
                Text(
                  message,
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 32),
                // Retry button
                ElevatedButton.icon(
                  onPressed: () {
                    final authState = context.read<AuthBloc>().state;
                    String? userId;
                    if (authState is AuthAuthenticated) {
                      userId = authState.user.id;
                    }
                    context.read<HomeBloc>().add(HomeServicesRequested(userId: userId));
                    context.read<BannerBloc>().add(const BannersRequested());
                  },
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text(
                    'إعادة المحاولة',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4AF37),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Handle category tap navigation
  void _handleCategoryTap(BuildContext context, CategoryModel category) {
    // Check if it's the venues category (قاعات الأفراح)
    // Venues have a dedicated screen with VenueModel
    if (category.nameAr == 'قاعات الأفراح' || category.name == 'Venues') {
      Navigator.pushNamed(context, AppRouter.venuesList);
    } else {
      // All other categories use the generic CategoryServicesListScreen
      Navigator.pushNamed(
        context,
        AppRouter.categoryServices,
        arguments: {'category': category},
      );
    }
  }
}
