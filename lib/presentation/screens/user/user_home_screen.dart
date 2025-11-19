import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wedly/data/models/widget_config_model.dart';
import 'package:wedly/data/models/category_model.dart';
import 'package:wedly/data/models/offer_model.dart';
import 'package:wedly/logic/blocs/auth/auth_bloc.dart';
import 'package:wedly/logic/blocs/auth/auth_state.dart';
import 'package:wedly/logic/blocs/home/home_bloc.dart';
import 'package:wedly/logic/blocs/home/home_event.dart';
import 'package:wedly/logic/blocs/home/home_state.dart';
import 'package:wedly/logic/blocs/cart/cart_bloc.dart';
import 'package:wedly/logic/blocs/cart/cart_state.dart';
import 'package:wedly/logic/blocs/cart/cart_event.dart';
import 'package:wedly/presentation/widgets/widget_factory.dart';
import 'package:wedly/presentation/widgets/skeleton_loading.dart';
import 'package:wedly/presentation/screens/user/user_cart_screen.dart';
import 'package:wedly/routes/app_router.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  @override
  void initState() {
    super.initState();

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
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(homeState.message, textDirection: TextDirection.rtl),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      final authState = context.read<AuthBloc>().state;
                      String? userId;
                      if (authState is AuthAuthenticated) {
                        userId = authState.user.id;
                      }
                      context.read<HomeBloc>().add(
                        HomeServicesRequested(userId: userId),
                      );
                    },
                    child: const Text(
                      'إعادة المحاولة',
                      textDirection: TextDirection.rtl,
                    ),
                  ),
                ],
              ),
            );
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

                  // Dynamic widgets based on API layout configuration
                  ...(_buildDynamicWidgets(homeState)),

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
        String userName = 'محمد';
        String? userImageUrl;

        if (authState is AuthAuthenticated) {
          userName = authState.user.name.split(' ').first;
          userImageUrl = authState.user.profileImageUrl;
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
                                  child: Text(
                                    itemCount > 9 ? '9+' : '$itemCount',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
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

                // Notification button on FAR RIGHT (reversed)
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
              ],
            ),
          ),
        );
      },
    );
  }

  /// Build widgets dynamically from API layout configuration
  List<Widget> _buildDynamicWidgets(HomeLoaded state) {
    final widgets = <Widget>[];

    // If layout config is available from API, use it
    if (state.layout != null) {
      final visibleWidgets = state.layout!.visibleWidgets;

      for (final config in visibleWidgets) {
        final widget = WidgetFactory.buildWidget(
          config: config,
          countdown: state.countdown,
          offers: state.offers,
          categories: state.categoriesWithDetails,
          services: state.services,
          onTap: (item) {
            // Handle tap based on item type
            if (item is CategoryModel) {
              _handleCategoryTap(context, item);
            } else if (item is OfferModel) {
              _handleOfferTap(context, item);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    item.toString(),
                    textDirection: TextDirection.rtl,
                  ),
                ),
              );
            }
          },
          onSeeAllOffers: () {
            Navigator.pushNamed(context, AppRouter.offersList);
          },
        );

        if (widget != null) {
          widgets.add(SliverToBoxAdapter(child: widget));
        }
      }
    } else {
      // Fallback: Show default layout if no API config available
      widgets.addAll(_buildDefaultLayout(state));
    }

    return widgets;
  }

  /// Fallback default layout when no API config is available
  List<Widget> _buildDefaultLayout(HomeLoaded state) {
    final widgets = <Widget>[];

    // Countdown
    if (state.countdown != null) {
      final countdownWidget = WidgetFactory.buildWidget(
        config: const WidgetConfigModel(
          id: 'countdown_default',
          type: WidgetType.countdown,
          titleAr: 'العد التنازلي للفرح',
          isVisible: true,
          order: 1,
        ),
        countdown: state.countdown,
      );
      if (countdownWidget != null) {
        widgets.add(SliverToBoxAdapter(child: countdownWidget));
      }
    }

    // Offers
    if (state.offers.isNotEmpty) {
      final offersWidget = WidgetFactory.buildWidget(
        config: const WidgetConfigModel(
          id: 'offers_default',
          type: WidgetType.offers,
          titleAr: 'عروض الأسبوع',
          isVisible: true,
          order: 2,
        ),
        offers: state.offers,
        onTap: (offer) {
          _handleOfferTap(context, offer);
        },
        onSeeAllOffers: () {
          Navigator.pushNamed(context, AppRouter.offersList);
        },
      );
      if (offersWidget != null) {
        widgets.add(SliverToBoxAdapter(child: offersWidget));
      }
    }

    // Categories
    if (state.categoriesWithDetails.isNotEmpty) {
      final categoriesWidget = WidgetFactory.buildWidget(
        config: const WidgetConfigModel(
          id: 'categories_default',
          type: WidgetType.categories,
          titleAr: 'الخدمات',
          isVisible: true,
          order: 3,
        ),
        categories: state.categoriesWithDetails,
        onTap: (category) {
          // Navigate based on category
          _handleCategoryTap(context, category);
        },
      );
      if (categoriesWidget != null) {
        widgets.add(SliverToBoxAdapter(child: categoriesWidget));
      }
    }

    return widgets;
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

  /// Handle offer tap navigation based on service type
  void _handleOfferTap(BuildContext context, OfferModel offer) {
    // Navigate to appropriate booking screen based on service type
    switch (offer.serviceType.toLowerCase()) {
      case 'decoration':
        Navigator.pushNamed(
          context,
          AppRouter.decorationBooking,
          arguments: {'offer': offer},
        );
        break;
      case 'wedding_dress':
      case 'weddingdress':
        Navigator.pushNamed(
          context,
          AppRouter.weddingDressBooking,
          arguments: {'offer': offer},
        );
        break;
      case 'weddingplanner':
      case 'wedding_planner':
        Navigator.pushNamed(
          context,
          AppRouter.weddingPlannerBooking,
          arguments: {'offer': offer},
        );
        break;
      case 'photography':
      case 'catering':
      case 'beauty':
      case 'venue':
      default:
        // For other service types, show coming soon message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'صفحة الحجز لخدمة ${offer.titleAr} قريباً',
              textDirection: TextDirection.rtl,
            ),
            backgroundColor: const Color(0xFFD4AF37),
          ),
        );
    }
  }
}
