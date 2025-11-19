import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wedly/data/models/venue_model.dart';
import 'package:wedly/data/models/review_model.dart';
import 'package:wedly/presentation/widgets/skeleton_image.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:wedly/logic/blocs/review/review_bloc.dart';
import 'package:wedly/logic/blocs/review/review_event.dart';
import 'package:wedly/logic/blocs/review/review_state.dart';
import 'package:wedly/presentation/screens/user/venue_booking_screen.dart';

/// Venue details screen matching the screenshot design
/// Shows venue image, name, features, pricing, location, and reviews
class VenueDetailsScreen extends StatefulWidget {
  final VenueModel venue;

  const VenueDetailsScreen({super.key, required this.venue});

  @override
  State<VenueDetailsScreen> createState() => _VenueDetailsScreenState();
}

class _VenueDetailsScreenState extends State<VenueDetailsScreen> {
  GoogleMapController? _mapController;
  final bool _useGoogleMaps = false; // Set to true when API key is configured

  // User selections
  String? _selectedTimeSlot; // 'morning' or 'evening'
  String? _selectedDecoration; // 'ديكور1', 'ديكور2', 'ديكورة', 'خالي'

  @override
  void initState() {
    super.initState();
    // Request venue reviews when screen loads
    context.read<ReviewBloc>().add(VenueReviewsRequested(widget.venue.id));
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
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

                const SizedBox(height: 16),

                // الديان Section with radio buttons
                _buildDecorationSection(),

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
          // صباحي option with radio button
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
                  // Radio button
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _selectedTimeSlot == 'morning'
                            ? const Color(0xFFD4AF37)
                            : Colors.grey.shade400,
                        width: 2,
                      ),
                    ),
                    child: _selectedTimeSlot == 'morning'
                        ? Center(
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: Color(0xFFD4AF37),
                                shape: BoxShape.circle,
                              ),
                            ),
                          )
                        : null,
                  ),

                  const SizedBox(width: 16),

                  // Price and time info
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
                            Text(
                              'تبدأ من ${widget.venue.pricePerPerson.toInt()} جنيه',
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

          // مسائي option with radio button
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
                  // Radio button
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _selectedTimeSlot == 'evening'
                            ? const Color(0xFFD4AF37)
                            : Colors.grey.shade400,
                        width: 2,
                      ),
                    ),
                    child: _selectedTimeSlot == 'evening'
                        ? Center(
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: Color(0xFFD4AF37),
                                shape: BoxShape.circle,
                              ),
                            ),
                          )
                        : null,
                  ),

                  const SizedBox(width: 16),

                  // Price and time info
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
                            Text(
                              'تبدأ من ${(widget.venue.pricePerPerson * 1.25).toInt()} جنيه',
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

  Widget _buildDecorationSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'البلان',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFFD4AF37),
            ),
          ),
          const SizedBox(height: 12),

          // Radio buttons row
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            textDirection: TextDirection.ltr,
            children: [
              _buildDecorationOption('خالي'),
              const SizedBox(width: 16),
              _buildDecorationOption('ديكورة'),
              const SizedBox(width: 16),
              _buildDecorationOption('ديكور2'),
              const SizedBox(width: 16),
              _buildDecorationOption('ديكور1'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDecorationOption(String option) {
    final isSelected = _selectedDecoration == option;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDecoration = option;
        });
      },
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected
                    ? const Color(0xFFD4AF37)
                    : Colors.grey.shade400,
                width: 2,
              ),
            ),
            child: isSelected
                ? Center(
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFFD4AF37),
                        shape: BoxShape.circle,
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 6),
          Text(
            option,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isSelected ? const Color(0xFFD4AF37) : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
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

          // Map Container
          Container(
            height: 180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: _useGoogleMaps && widget.venue.latitude != null
                  ? GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: LatLng(
                          widget.venue.latitude!,
                          widget.venue.longitude!,
                        ),
                        zoom: 14,
                      ),
                      onMapCreated: (controller) {
                        _mapController = controller;
                      },
                      markers: {
                        Marker(
                          markerId: const MarkerId('venue_location'),
                          position: LatLng(
                            widget.venue.latitude!,
                            widget.venue.longitude!,
                          ),
                        ),
                      },
                      zoomControlsEnabled: false,
                      myLocationButtonEnabled: false,
                    )
                  : _buildMapPlaceholder(),
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
                Text(
                  widget.venue.address!,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
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
              'تكامل خرائط جوجل غير متاح',
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.read<ReviewBloc>().add(
                  VenueReviewsRequested(widget.venue.id),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                foregroundColor: Colors.white,
              ),
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewCard(ReviewModel review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12, left: 16, right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Rating stars
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: List.generate(5, (index) {
              return Icon(
                index < review.rating ? Icons.star : Icons.star_border,
                color: const Color(0xFFFFB400),
                size: 18,
              );
            }),
          ),
          const SizedBox(height: 12),

          // Review comment
          Text(
            review.comment,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.5,
            ),
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.right,
          ),
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
                        review.userName[0],
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
                review.userName,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFD4AF37),
                ),
                textDirection: TextDirection.rtl,
              ),
            ],
          ),
        ],
      ),
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

            if (_selectedDecoration == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'الرجاء اختيار نوع الديكور',
                    textAlign: TextAlign.center,
                  ),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }

            // Navigate to booking screen with selections
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => VenueBookingScreen(
                  venue: widget.venue,
                  timeSlot: _selectedTimeSlot!,
                  decoration: _selectedDecoration!,
                ),
              ),
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
