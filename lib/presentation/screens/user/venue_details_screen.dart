import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wedly/data/models/venue_model.dart';
import 'package:wedly/data/models/review_model.dart';
import 'package:wedly/presentation/widgets/skeleton_image.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:wedly/logic/blocs/auth/auth_bloc.dart';
import 'package:wedly/logic/blocs/auth/auth_state.dart';
import 'package:wedly/logic/blocs/review/review_bloc.dart';
import 'package:wedly/logic/blocs/review/review_event.dart';
import 'package:wedly/logic/blocs/review/review_state.dart';
import 'package:wedly/presentation/widgets/review_bottom_sheet.dart';
import 'package:wedly/routes/app_router.dart';
import 'package:wedly/core/utils/city_translator.dart';
import 'package:url_launcher/url_launcher.dart';

/// Venue details screen matching the screenshot design
/// Shows venue image, name, features, pricing, location, and reviews
class VenueDetailsScreen extends StatefulWidget {
  final VenueModel venue;

  const VenueDetailsScreen({super.key, required this.venue});

  @override
  State<VenueDetailsScreen> createState() => _VenueDetailsScreenState();
}

class _VenueDetailsScreenState extends State<VenueDetailsScreen> {
  final MapController _mapController = MapController();

  // User selections
  String? _selectedTimeSlot; // 'morning' or 'evening'

  @override
  void initState() {
    super.initState();
    // Request venue reviews when screen loads
    context.read<ReviewBloc>().add(VenueReviewsRequested(widget.venue.id));
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  /// Open location in external maps app (Google Maps, Apple Maps, etc.)
  Future<void> _openInMaps() async {
    if (widget.venue.latitude == null || widget.venue.longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الموقع غير متوفر', textAlign: TextAlign.center),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final lat = widget.venue.latitude!;
    final lng = widget.venue.longitude!;
    final label = Uri.encodeComponent(widget.venue.name);

    // Try Google Maps first, then fallback to generic geo URI
    final googleMapsUrl = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );
    final geoUrl = Uri.parse('geo:$lat,$lng?q=$lat,$lng($label)');

    try {
      if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(geoUrl)) {
        await launchUrl(geoUrl, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('لا يمكن فتح الخريطة', textAlign: TextAlign.center),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('حدث خطأ أثناء فتح الخريطة', textAlign: TextAlign.center),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // App Bar with Image
          _buildSliverAppBar(),

          // Content
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Venue Header Card (Gold)
                _buildVenueHeaderCard(),

                const SizedBox(height: 60),

                // المواقيت Section with radio buttons
                _buildTimeSlotsSection(),

                const SizedBox(height: 16),

                // عدد الكراسي Section
                _buildChairsSection(),

                const SizedBox(height: 24),

                // Location Section
                _buildLocationSection(),

                const SizedBox(height: 24),

                // Reviews Section
                _buildReviewsSection(),

                const SizedBox(height: 24),

                // Reserve Button
                _buildReserveButton(),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 250,
      pinned: true,
      backgroundColor: const Color(0xFFD4AF37),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            SkeletonImage(
              imageUrl: widget.venue.imageUrl,
              fit: BoxFit.cover,
              errorWidget: const Center(
                child: Icon(Icons.villa, size: 80, color: Colors.white54),
              ),
            ),
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.3),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVenueHeaderCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFD4AF37),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          // Venue Name
          Text(
            widget.venue.name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),

          // المواقيت label only (no stars)
        ],
      ),
    );
  }

  Widget _buildTimeSlotsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'المواقيت المتاحة',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFFD4AF37),
            ),
          ),
          const SizedBox(height: 12),

          // صباحي option - selectable
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedTimeSlot = 'morning';
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _selectedTimeSlot == 'morning'
                      ? const Color(0xFFD4AF37)
                      : Colors.grey.shade200,
                  width: _selectedTimeSlot == 'morning' ? 2 : 1,
                ),
              ),
              child: Row(
                textDirection: TextDirection.rtl,
                children: [
                  Icon(
                    Icons.wb_sunny_outlined,
                    color: _selectedTimeSlot == 'morning'
                        ? const Color(0xFFD4AF37)
                        : Colors.grey.shade600,
                    size: 22,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'صباحي',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: _selectedTimeSlot == 'morning'
                                ? const Color(0xFFD4AF37)
                                : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          textDirection: TextDirection.rtl,
                          children: [
                            Text(
                              'من 12 ظهراً الى 7 مساءاً',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const Spacer(),
                            // Show discounted price if available
                            if (widget.venue.hasApprovedOffer &&
                                widget.venue.discountedMorningPrice != null)
                              Row(
                                children: [
                                  Text(
                                    'تبدأ من ${widget.venue.discountedMorningPrice!.toInt()} جنيه',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFD4AF37),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Builder(
                                    builder: (context) {
                                      final scaleFactor = (MediaQuery.of(context).size.width / 375).clamp(0.9, 1.3);
                                      return Text(
                                        '${widget.venue.morningPrice!.toInt()}',
                                        style: TextStyle(
                                          fontSize: (12 * scaleFactor).clamp(11.0, 15.0),
                                          color: Colors.grey.shade500,
                                          decoration: TextDecoration.lineThrough,
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              )
                            else
                              Text(
                                widget.venue.morningPrice != null
                                    ? 'تبدأ من ${widget.venue.morningPrice!.toInt()} جنيه'
                                    : 'السعر غير متاح',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.black87,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // مسائي option - selectable
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedTimeSlot = 'evening';
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _selectedTimeSlot == 'evening'
                      ? const Color(0xFFD4AF37)
                      : Colors.grey.shade200,
                  width: _selectedTimeSlot == 'evening' ? 2 : 1,
                ),
              ),
              child: Row(
                textDirection: TextDirection.rtl,
                children: [
                  Icon(
                    Icons.nightlight_outlined,
                    color: _selectedTimeSlot == 'evening'
                        ? const Color(0xFFD4AF37)
                        : Colors.grey.shade600,
                    size: 22,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'مسائي',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: _selectedTimeSlot == 'evening'
                                ? const Color(0xFFD4AF37)
                                : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          textDirection: TextDirection.rtl,
                          children: [
                            Text(
                              'من 8 مساءاً الى 2 فجراً',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const Spacer(),
                            // Show discounted price if available
                            if (widget.venue.hasApprovedOffer &&
                                widget.venue.discountedEveningPrice != null)
                              Row(
                                children: [
                                  Text(
                                    'تبدأ من ${widget.venue.discountedEveningPrice!.toInt()} جنيه',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFD4AF37),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Builder(
                                    builder: (context) {
                                      final scaleFactor = (MediaQuery.of(context).size.width / 375).clamp(0.9, 1.3);
                                      return Text(
                                        '${widget.venue.eveningPrice!.toInt()}',
                                        style: TextStyle(
                                          fontSize: (12 * scaleFactor).clamp(11.0, 15.0),
                                          color: Colors.grey.shade500,
                                          decoration: TextDecoration.lineThrough,
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              )
                            else
                              Text(
                                widget.venue.eveningPrice != null
                                    ? 'تبدأ من ${widget.venue.eveningPrice!.toInt()} جنيه'
                                    : 'السعر غير متاح',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.black87,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChairsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          textDirection: TextDirection.rtl,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'عدد الكراسي',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'من ${widget.venue.capacity ~/ 2} الى ${widget.venue.capacity}',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'الموقع',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFFD4AF37),
            ),
          ),
          const SizedBox(height: 12),

          // Map Container - Tappable to open in external maps
          GestureDetector(
            onTap: _openInMaps,
            child: Stack(
              children: [
                Container(
                  height: 250,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: widget.venue.latitude != null && widget.venue.longitude != null
                        ? FlutterMap(
                            mapController: _mapController,
                            options: MapOptions(
                              initialCenter: LatLng(
                                widget.venue.latitude!,
                                widget.venue.longitude!,
                              ),
                              initialZoom: 14.0,
                              minZoom: 5.0,
                              maxZoom: 18.0,
                              interactionOptions: const InteractionOptions(
                                flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                              ),
                              onTap: (_, __) => _openInMaps(),
                            ),
                            children: [
                              TileLayer(
                                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName: 'com.wedly.app',
                                tileProvider: NetworkTileProvider(),
                              ),
                              MarkerLayer(
                                markers: [
                                  Marker(
                                    point: LatLng(
                                      widget.venue.latitude!,
                                      widget.venue.longitude!,
                                    ),
                                    width: 40,
                                    height: 40,
                                    child: const Icon(
                                      Icons.location_on,
                                      size: 40,
                                      color: Color(0xFFD4AF37),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          )
                        : _buildMapPlaceholder(),
                  ),
                ),
                // "Open in Maps" button overlay
                if (widget.venue.latitude != null && widget.venue.longitude != null)
                  Positioned(
                    bottom: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.open_in_new,
                            size: 16,
                            color: Color(0xFFD4AF37),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'فتح في الخريطة',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFD4AF37),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Address
          if (widget.venue.address != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              textDirection: TextDirection.rtl,
              children: [
                Icon(Icons.location_on, color: Colors.grey.shade600, size: 18),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    CityTranslator.translate(widget.venue.address!),
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildMapPlaceholder() {
    return Stack(
      children: [
        Container(
          color: const Color(0xFFF5F5F5),
          child: Center(
            child: Icon(
              Icons.map_outlined,
              size: 60,
              color: Colors.grey.shade400,
            ),
          ),
        ),
        Center(
          child: Icon(Icons.location_on, size: 36, color: Colors.red.shade400),
        ),
        Positioned(
          bottom: 10,
          left: 0,
          right: 0,
          child: Center(
            child: Text(
              'الموقع غير متوفر',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewsSection() {
    return BlocBuilder<ReviewBloc, ReviewState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Header with rating
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                textDirection: TextDirection.ltr,
                children: [
                  // Overall rating from BLoC state or venue
                  if (state is ReviewsLoaded)
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: Color(0xFFFFB400),
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          state.averageRating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(${state.totalReviews})',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    )
                  else
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: Color(0xFFFFB400),
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.venue.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(${widget.venue.reviewCount})',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  const Spacer(),
                  const Text(
                    'آراء العملاء',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFD4AF37),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Reviews content based on state
            if (state is ReviewsLoading)
              _buildReviewsLoading()
            else if (state is ReviewsLoaded)
              ...state.reviews.map((review) => _buildReviewCard(review))
            else if (state is ReviewsEmpty)
              _buildReviewsEmpty(state.message)
            else if (state is ReviewError)
              _buildReviewsError(state.message)
            else
              _buildReviewsEmpty('جاري تحميل التقييمات...'),
          ],
        );
      },
    );
  }

  Widget _buildReviewsLoading() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
      child: Center(
        child: Column(
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD4AF37)),
            ),
            const SizedBox(height: 16),
            Text(
              'جاري تحميل التقييمات...',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewsEmpty(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.star_border, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewsError(String message) {
    // Show a friendly "no reviews yet" message instead of error
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.rate_review_outlined, size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(
              'لا توجد تقييمات بعد',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'كن أول من يقيم هذه القاعة',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewCard(ReviewModel review) {
    // Check if this review belongs to the current user
    final authState = context.read<AuthBloc>().state;
    final isCurrentUserReview = authState is AuthAuthenticated &&
        authState.user.id == review.userId;

    return GestureDetector(
      onTap: isCurrentUserReview ? () => _showEditReviewSheet(review) : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12, left: 16, right: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isCurrentUserReview
              ? const Color(0xFFFFF8E7) // Light gold for user's review
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isCurrentUserReview
                ? const Color(0xFFD4AF37)
                : Colors.grey.shade200,
            width: isCurrentUserReview ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // "Your review" badge + Rating stars
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              textDirection: TextDirection.rtl,
              children: [
                // User's review badge
                if (isCurrentUserReview)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4AF37),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.edit, color: Colors.white, size: 12),
                        const SizedBox(width: 4),
                        Builder(
                          builder: (context) {
                            final scaleFactor = (MediaQuery.of(context).size.width / 375).clamp(0.9, 1.3);
                            return Text(
                              'تقييمك - اضغط للتعديل',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: (12 * scaleFactor).clamp(11.0, 15.0),
                                fontWeight: FontWeight.w600,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  )
                else
                  const SizedBox.shrink(),

                // Rating stars
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(5, (index) {
                    return Icon(
                      index < review.rating ? Icons.star : Icons.star_border,
                      color: const Color(0xFFFFB400),
                      size: 18,
                    );
                  }),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Review comment
            if (review.comment.isNotEmpty)
              Text(
                review.comment,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  height: 1.5,
                ),
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.right,
              ),
            if (review.comment.isNotEmpty)
              const SizedBox(height: 12),

            // User info
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              textDirection: TextDirection.rtl,
              children: [
                // User avatar
                CircleAvatar(
                  radius: 18,
                  backgroundColor: const Color(0xFFD4AF37),
                  backgroundImage: review.userImageUrl != null
                      ? NetworkImage(review.userImageUrl!)
                      : null,
                  child: review.userImageUrl == null
                      ? Text(
                          review.userName.isNotEmpty ? review.userName[0] : '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 8),

                // User name
                Text(
                  isCurrentUserReview ? 'أنت' : review.userName,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isCurrentUserReview
                        ? const Color(0xFFD4AF37)
                        : const Color(0xFFD4AF37),
                  ),
                  textDirection: TextDirection.rtl,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showEditReviewSheet(ReviewModel review) {
    ReviewBottomSheet.showEdit(
      context: context,
      targetId: widget.venue.id,
      targetType: 'venue',
      serviceName: widget.venue.name,
      reviewId: review.id,
      existingRating: review.rating,
      existingComment: review.comment,
      onReviewSubmitted: () {
        // Refresh reviews after edit
        context.read<ReviewBloc>().add(VenueReviewsRequested(widget.venue.id));
      },
    );
  }

  Widget _buildReserveButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: () {
            // Validate selections
            if (_selectedTimeSlot == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'الرجاء اختيار الموعد (صباحي أو مسائي)',
                    textAlign: TextAlign.center,
                  ),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }

            // Navigate to booking screen with selections
            debugPrint('Navigating to venue booking with timeSlot: $_selectedTimeSlot');
            Navigator.pushNamed(
              context,
              AppRouter.venueBooking,
              arguments: {
                'venue': widget.venue,
                'timeSlot': _selectedTimeSlot!,
              },
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFD4AF37),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: const Text(
            'احجز الآن',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
