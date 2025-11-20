import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wedly/data/models/service_model.dart';
import 'package:wedly/logic/blocs/home/home_bloc.dart';
import 'package:wedly/logic/blocs/home/home_state.dart';
import 'package:wedly/logic/blocs/home/home_event.dart';
import 'package:wedly/logic/blocs/auth/auth_bloc.dart';
import 'package:wedly/logic/blocs/auth/auth_state.dart';
import 'package:wedly/presentation/widgets/skeleton_image.dart';
import 'package:wedly/routes/app_router.dart';

/// Screen that displays all available offers in a list view
class OffersListScreen extends StatefulWidget {
  const OffersListScreen({super.key});

  @override
  State<OffersListScreen> createState() => _OffersListScreenState();
}

class _OffersListScreenState extends State<OffersListScreen> {
  @override
  void initState() {
    super.initState();
    // Refresh offers when screen opens
    final authState = context.read<AuthBloc>().state;
    String? userId;
    if (authState is AuthAuthenticated) {
      userId = authState.user.id;
    }
    context.read<HomeBloc>().add(HomeServicesRequested(userId: userId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Light background
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AppBar(
          title: const Text(
            'عروض الأسبوع',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            textDirection: TextDirection.rtl,
          ),
          centerTitle: true,
          backgroundColor: const Color(0xFFD4AF37),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
          ),
        ),
      ),
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state is HomeLoading) {
            return _buildLoadingSkeleton();
          }

          if (state is HomeError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.center,
                  ),
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

          if (state is HomeLoaded) {
            // Filter services that have approved offers
            final servicesWithOffers = state.services
                .where((service) => service.hasApprovedOffer)
                .toList();

            if (servicesWithOffers.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.local_offer_outlined,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'لا توجد عروض متاحة حالياً',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                  ],
                ),
              );
            }

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
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: servicesWithOffers.length,
                itemBuilder: (context, index) {
                  return _buildOfferCard(servicesWithOffers[index]);
                },
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

  // --- REDESIGNED WIDGET ---
  Widget _buildOfferCard(ServiceModel service) {
    final discountText = service.discountPercentage != null
        ? 'خصم ${service.discountPercentage!.toInt()}%'
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Image & Badge Section
          Stack(
            children: [
              SkeletonImage(
                imageUrl: service.imageUrl,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              // White Pill Discount Badge (Top Right)
              if (discountText != null)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Text(
                      discountText,
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                  ),
                ),
            ],
          ),

          // 2. Info Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  service.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(height: 8),

                // Row: Rating (Left) vs Category (Right)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Rating Star (Left)
                    if (service.rating != null)
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            color: Color(0xFFD4AF37),
                            size: 18,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            service.rating!.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '(${service.reviewCount ?? 0})',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(width: 8),
                    // Category (Right)
                    Expanded(
                      child: Text(
                        service.category,
                        textAlign: TextAlign.right,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Price Row (Right Aligned)
                // Combines Current and Old price in one line
                if (service.price != null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      // Old Price (Strikethrough)
                      Text(
                        '${service.price!.toInt()} جنيه',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[500],
                          decoration: TextDecoration.lineThrough,
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                      const SizedBox(width: 8),
                      // New Price (Bold)
                      Text(
                        '${service.finalPrice!.toInt()} جنيه',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                    ],
                  ),

                const SizedBox(height: 16),

                // 3. Buttons Row (Side by Side)
                Row(
                  children: [
                    // Book Now Button
                    Expanded(
                      flex: 6,
                      child: SizedBox(
                        height: 55,
                        child: ElevatedButton(
                          onPressed: () => _handleOfferBooking(service),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD4AF37),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'احجز الآن',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            textDirection: TextDirection.rtl,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 4,
                      child: SizedBox(
                        height: 45,
                        child: OutlinedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'مشاركة العرض قريباً',
                                  textDirection: TextDirection.rtl,
                                ),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.grey[800],
                          ),
                          child: const Text(
                            'مشاركة',
                            style: TextStyle(fontWeight: FontWeight.bold),
                            textDirection: TextDirection.rtl,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Handle offer booking navigation based on service category
  void _handleOfferBooking(ServiceModel service) {
    // Navigate to appropriate booking screen based on service category
    final category = service.category.toLowerCase();

    String? routeName;

    // Map categories to their booking routes
    switch (category) {
      case 'decoration':
        routeName = AppRouter.decorationBooking;
        break;
      case 'wedding dresses':
      case 'weddingdress':
        routeName = AppRouter.weddingDressBooking;
        break;
      case 'wedding organizers':
      case 'weddingplanner':
      case 'wedding_planner':
        routeName = AppRouter.weddingPlannerBooking;
        break;
      case 'photography':
      case 'photographer':
        routeName = AppRouter.photographerBooking;
        break;
      case 'entertainment':
      case 'videography':
      case 'videographer':
        routeName = AppRouter.videographerBooking;
        break;
      case 'beauty':
      case 'makeup':
      case 'makeupartist':
      case 'makeup_artist':
        routeName = AppRouter.makeupArtistBooking;
        break;
      case 'venues':
      case 'venue':
      case 'قاعات':
      case 'hall':
        routeName = AppRouter.venueBooking;
        break;
      case 'cars':
      case 'car':
      case 'transportation':
        routeName = AppRouter.carBooking;
        break;
      case 'catering':
      case 'food':
        // TODO: Create catering booking screen
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'صفحة حجز الطعام قريباً - ${service.name}',
              textDirection: TextDirection.rtl,
            ),
            backgroundColor: const Color(0xFFD4AF37),
          ),
        );
        return;
      default:
        // Show coming soon message for unsupported service types
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'صفحة الحجز لخدمة ${service.name} قريباً',
              textDirection: TextDirection.rtl,
            ),
            backgroundColor: const Color(0xFFD4AF37),
          ),
        );
        return;
    }

    // Navigate to the booking screen with service data
    Navigator.pushNamed(
      context,
      routeName,
      arguments: {'service': service},
    );
  }

  Widget _buildLoadingSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Image skeleton
              Container(
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Title skeleton
                    Container(
                      height: 18,
                      width: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Rating and provider row skeleton
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          height: 16,
                          width: 80,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        Container(
                          height: 16,
                          width: 120,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Price skeleton
                    Container(
                      height: 20,
                      width: 150,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Buttons skeleton
                    Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: Container(
                            height: 45,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 6,
                          child: Container(
                            height: 45,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
