import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wedly/data/models/category_model.dart';
import 'package:wedly/data/models/service_model.dart';
import 'package:wedly/logic/blocs/service/service_bloc.dart';
import 'package:wedly/logic/blocs/service/service_event.dart';
import 'package:wedly/logic/blocs/service/service_state.dart';
import 'package:wedly/presentation/widgets/category_service_card.dart';
import 'package:wedly/presentation/widgets/skeleton_loading.dart';
import 'package:wedly/routes/app_router.dart';

/// Generic screen for displaying services filtered by category
/// Used for all categories except venues (قاعات الأفراح)
/// Shows services with rating and price information
class CategoryServicesListScreen extends StatefulWidget {
  final CategoryModel category;

  const CategoryServicesListScreen({super.key, required this.category});

  @override
  State<CategoryServicesListScreen> createState() =>
      _CategoryServicesListScreenState();
}

class _CategoryServicesListScreenState
    extends State<CategoryServicesListScreen> {
  // Filter values
  String? _selectedCity;
  double? _minPrice;
  double? _maxPrice;
  double? _selectedRating;
  bool _hasOfferOnly = false;

  // Track if filters have been applied
  bool get _hasActiveFilters =>
      _selectedCity != null ||
      _minPrice != null ||
      _maxPrice != null ||
      _selectedRating != null ||
      _hasOfferOnly;

  @override
  void initState() {
    super.initState();
    // Request services for this category when screen loads
    _loadServices();
  }

  void _loadServices({int page = 1}) {
    context.read<ServiceBloc>().add(
      ServicesByCategoryRequested(
        widget.category.id,
        city: _selectedCity,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
        rating: _selectedRating,
        hasOffer: _hasOfferOnly ? true : null,
        page: page,
      ),
    );
  }

  void _applyFilters() {
    _loadServices();
    // Note: Navigator.pop is handled by the filter widget itself
  }

  void _clearFilters() {
    setState(() {
      _selectedCity = null;
      _minPrice = null;
      _maxPrice = null;
      _selectedRating = null;
      _hasOfferOnly = false;
    });
    _loadServices();
    // Note: Navigator.pop is handled by the filter widget itself
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          // Custom App Bar with golden background and filter button
          _buildAppBar(context),

          // Services List
          Expanded(
            child: BlocBuilder<ServiceBloc, ServiceState>(
              builder: (context, state) {
                if (state is ServiceLoading) {
                  return _buildLoadingSkeleton();
                }

                if (state is ServiceError) {
                  return _buildErrorState(state.message);
                }

                if (state is ServicesByCategoryLoaded) {
                  if (state.services.isEmpty) {
                    return _buildEmptyState();
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      _loadServices();
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      // Add 1 for "Load More" button if hasMore
                      itemCount: state.services.length + (state.hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        // Load More button at the end
                        if (index == state.services.length) {
                          return _buildLoadMoreButton(state);
                        }

                        final service = state.services[index];
                        return CategoryServiceCard(
                          service: service,
                          onTap: () {
                            _navigateToServiceDetails(context, service);
                          },
                        );
                      },
                    ),
                  );
                }

                return _buildEmptyState();
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Build "Load More" button
  Widget _buildLoadMoreButton(ServicesByCategoryLoaded state) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: state.isLoadingMore
            ? const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD4AF37)),
              )
            : ElevatedButton(
                onPressed: () {
                  context.read<ServiceBloc>().add(const LoadMoreServicesRequested());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'تحميل المزيد',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
      ),
    );
  }

  /// Show filter bottom sheet
  void _showFilterBottomSheet(List<String> availableCities) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _FilterBottomSheet(
        initialCity: _selectedCity,
        initialMinPrice: _minPrice,
        initialMaxPrice: _maxPrice,
        initialRating: _selectedRating,
        initialHasOffer: _hasOfferOnly,
        availableCities: availableCities,
        onApply: (city, minPrice, maxPrice, rating, hasOffer) {
          setState(() {
            _selectedCity = city;
            _minPrice = minPrice;
            _maxPrice = maxPrice;
            _selectedRating = rating;
            _hasOfferOnly = hasOffer;
          });
          _applyFilters();
        },
        onClear: () {
          setState(() {
            _selectedCity = null;
            _minPrice = null;
            _maxPrice = null;
            _selectedRating = null;
            _hasOfferOnly = false;
          });
          _loadServices();
          Navigator.pop(context);
        },
      ),
    );
  }

  // OLD HELPER METHODS - No longer needed with dynamic booking screen
  // Kept as comments for reference

  /*
  /// Check if a service is a photographer service
  bool _isPhotographerService(ServiceModel service) {
    // Check service category
    final serviceCategory = service.category.toLowerCase();

    // Check current category being viewed
    final currentCategoryName = widget.category.name.toLowerCase();
    final currentCategoryNameAr = widget.category.nameAr.toLowerCase();

    // List of photographer category identifiers
    final photographerCategories = [
      'photography',
      'مصورين',
      'تصوير فوتوغرافي',
      'مصور',
    ];

    // Check if service category matches
    final serviceMatches = photographerCategories.any(
      (photographerCategory) =>
          serviceCategory.contains(photographerCategory.toLowerCase()),
    );

    // Check if current category matches
    final categoryMatches = photographerCategories.any(
      (photographerCategory) =>
          currentCategoryName.contains(photographerCategory.toLowerCase()) ||
          currentCategoryNameAr.contains(photographerCategory.toLowerCase()),
    );

    return serviceMatches || categoryMatches;
  }

  /// Check if a service is a videographer service
  bool _isVideographerService(ServiceModel service) {
    // Check service category
    final serviceCategory = service.category.toLowerCase();

    // Check current category being viewed
    final currentCategoryName = widget.category.name.toLowerCase();
    final currentCategoryNameAr = widget.category.nameAr.toLowerCase();

    // List of videographer category identifiers
    final videographerCategories = [
      'videography',
      'فيديوغراف',
      'فيديو',
      'تصوير فيديو',
    ];

    // Check if service category matches
    final serviceMatches = videographerCategories.any(
      (videographerCategory) =>
          serviceCategory.contains(videographerCategory.toLowerCase()),
    );

    // Check if current category matches
    final categoryMatches = videographerCategories.any(
      (videographerCategory) =>
          currentCategoryName.contains(videographerCategory.toLowerCase()) ||
          currentCategoryNameAr.contains(videographerCategory.toLowerCase()),
    );

    return serviceMatches || categoryMatches;
  }

  /// Check if a service is a makeup artist service
  bool _isMakeupArtistService(ServiceModel service) {
    // Check service category
    final serviceCategory = service.category.toLowerCase().trim();

    // Check current category being viewed
    final currentCategoryName = widget.category.name.toLowerCase().trim();
    final currentCategoryNameAr = widget.category.nameAr.toLowerCase().trim();

    // Direct check for exact matches first (most common cases)
    if (serviceCategory == 'beauty' ||
        currentCategoryName == 'beauty' ||
        currentCategoryNameAr.contains('كوافير') ||
        currentCategoryNameAr.contains('ميكب') ||
        currentCategoryNameAr.contains('تجميل')) {
      return true;
    }

    // List of makeup artist category identifiers
    final makeupArtistCategories = [
      'beauty',
      'كوافير وميكب',
      'تجميل وميك أب',
      'ميكب',
      'كوافير',
      'تجميل',
      'makeup',
      'hair',
    ];

    // Check if service category exactly matches or contains any makeup category
    final serviceMatches = makeupArtistCategories.any((makeupCategory) {
      final lowerCategory = makeupCategory.toLowerCase().trim();
      return serviceCategory == lowerCategory ||
          serviceCategory.contains(lowerCategory) ||
          lowerCategory.contains(serviceCategory);
    });

    // Check if current category matches
    final categoryMatches = makeupArtistCategories.any((makeupCategory) {
      final lowerCategory = makeupCategory.toLowerCase().trim();
      return currentCategoryName == lowerCategory ||
          currentCategoryName.contains(lowerCategory) ||
          currentCategoryNameAr.contains(lowerCategory) ||
          lowerCategory.contains(currentCategoryName) ||
          lowerCategory.contains(currentCategoryNameAr);
    });

    return serviceMatches || categoryMatches;
  }

  /// Check if a service is a wedding car service
  bool _isCarService(ServiceModel service) {
    // Check service category
    final serviceCategory = service.category.toLowerCase().trim();

    // Check current category being viewed
    final currentCategoryName = widget.category.name.toLowerCase().trim();
    final currentCategoryNameAr = widget.category.nameAr.toLowerCase().trim();

    // List of car/transportation category identifiers
    final carCategories = [
      'cars',
      'سيارات',
      'سيارات الزفاف',
      'سيارات زفاف',
      'نقل',
      'transportation',
      'wedding cars',
      'catering', // Temporary backward compatibility
    ];

    // Check if service category matches
    final serviceMatches = carCategories.any((carCategory) {
      final lowerCategory = carCategory.toLowerCase().trim();
      return serviceCategory == lowerCategory ||
          serviceCategory.contains(lowerCategory) ||
          lowerCategory.contains(serviceCategory);
    });

    // Check if current category matches
    final categoryMatches = carCategories.any((carCategory) {
      final lowerCategory = carCategory.toLowerCase().trim();
      return currentCategoryName == lowerCategory ||
          currentCategoryName.contains(lowerCategory) ||
          currentCategoryNameAr.contains(lowerCategory) ||
          lowerCategory.contains(currentCategoryName) ||
          lowerCategory.contains(currentCategoryNameAr);
    });

    return serviceMatches || categoryMatches;
  }

  /// Check if a service is a wedding dress service
  bool _isWeddingDressService(ServiceModel service) {
    // Check service category
    final serviceCategory = service.category.toLowerCase().trim();

    // Check current category being viewed
    final currentCategoryName = widget.category.name.toLowerCase().trim();
    final currentCategoryNameAr = widget.category.nameAr.toLowerCase().trim();

    // List of wedding dress category identifiers
    final weddingDressCategories = [
      'wedding dress',
      'فساتين',
      'فساتين الزفاف',
      'فساتين زفاف',
      'فستان',
      'dresses',
      'bridal',
      'عروس',
    ];

    // Check if service category matches
    final serviceMatches = weddingDressCategories.any((dressCategory) {
      final lowerCategory = dressCategory.toLowerCase().trim();
      return serviceCategory == lowerCategory ||
          serviceCategory.contains(lowerCategory) ||
          lowerCategory.contains(serviceCategory);
    });

    // Check if current category matches
    final categoryMatches = weddingDressCategories.any((dressCategory) {
      final lowerCategory = dressCategory.toLowerCase().trim();
      return currentCategoryName == lowerCategory ||
          currentCategoryName.contains(lowerCategory) ||
          currentCategoryNameAr.contains(lowerCategory) ||
          lowerCategory.contains(currentCategoryName) ||
          lowerCategory.contains(currentCategoryNameAr);
    });

    return serviceMatches || categoryMatches;
  }

  /// Check if a service is a decoration service
  bool _isDecorationService(ServiceModel service) {
    // Check service category
    final serviceCategory = service.category.toLowerCase().trim();

    // Check current category being viewed
    final currentCategoryName = widget.category.name.toLowerCase().trim();
    final currentCategoryNameAr = widget.category.nameAr.toLowerCase().trim();

    // List of decoration category identifiers
    final decorationCategories = [
      'decoration',
      'ديكور',
      'الديكور',
      'الديكور والزينة',
      'ديكور والزينة',
      'زينة',
      'تزيين',
      'decor',
    ];

    // Check if service category matches
    final serviceMatches = decorationCategories.any((decorCategory) {
      final lowerCategory = decorCategory.toLowerCase().trim();
      return serviceCategory == lowerCategory ||
          serviceCategory.contains(lowerCategory) ||
          lowerCategory.contains(serviceCategory);
    });

    // Check if current category matches
    final categoryMatches = decorationCategories.any((decorCategory) {
      final lowerCategory = decorCategory.toLowerCase().trim();
      return currentCategoryName == lowerCategory ||
          currentCategoryName.contains(lowerCategory) ||
          currentCategoryNameAr.contains(lowerCategory) ||
          lowerCategory.contains(currentCategoryName) ||
          lowerCategory.contains(currentCategoryNameAr);
    });

    return serviceMatches || categoryMatches;
  }

  /// Check if a service is a wedding planner service
  bool _isWeddingPlannerService(ServiceModel service) {
    // Check service category
    final serviceCategory = service.category.toLowerCase().trim();

    // Check current category being viewed
    final currentCategoryName = widget.category.name.toLowerCase().trim();
    final currentCategoryNameAr = widget.category.nameAr.toLowerCase().trim();

    // List of wedding planner category identifiers
    final weddingPlannerCategories = [
      'wedding organizers',
      'منظمين الأفراح',
      'منظم أفراح',
      'تنظيم أفراح',
      'wedding planners',
      'event planners',
      'organizers',
    ];

    // Check if service category matches
    final serviceMatches = weddingPlannerCategories.any((plannerCategory) {
      final lowerCategory = plannerCategory.toLowerCase().trim();
      return serviceCategory == lowerCategory ||
          serviceCategory.contains(lowerCategory) ||
          lowerCategory.contains(serviceCategory);
    });

    // Check if current category matches
    final categoryMatches = weddingPlannerCategories.any((plannerCategory) {
      final lowerCategory = plannerCategory.toLowerCase().trim();
      return currentCategoryName == lowerCategory ||
          currentCategoryName.contains(lowerCategory) ||
          currentCategoryNameAr.contains(lowerCategory) ||
          lowerCategory.contains(currentCategoryName) ||
          lowerCategory.contains(currentCategoryNameAr);
    });

    return serviceMatches || categoryMatches;
  }
  */

  /// Navigate to appropriate service details/booking screen
  void _navigateToServiceDetails(BuildContext context, ServiceModel service) {
    // Check for venue first (venues have chair_count)
    if (service.chairCount != null && service.chairCount! > 0) {
      // This is a venue service - navigate to venue details
      Navigator.pushNamed(
        context,
        AppRouter.venueDetails,
        arguments: {'venue': service.toVenueModel()},
      );
    } else {
      // All other services use the dynamic booking screen
      Navigator.pushNamed(
        context,
        AppRouter.dynamicServiceBooking,
        arguments: {'service': service},
      );
    }

    // OLD LOGIC - Replaced with dynamic screen
    // else if (_isPhotographerService(service)) {
    //   Navigator.pushNamed(context, AppRouter.photographerBooking, arguments: {'service': service});
    // } else if (_isVideographerService(service)) {
    //   Navigator.pushNamed(context, AppRouter.videographerBooking, arguments: {'service': service});
    // } else if (_isMakeupArtistService(service)) {
    //   Navigator.pushNamed(context, AppRouter.makeupArtistBooking, arguments: {'service': service});
    // } else if (_isCarService(service)) {
    //   Navigator.pushNamed(context, AppRouter.carBooking, arguments: {'service': service});
    // } else if (_isWeddingDressService(service)) {
    //   Navigator.pushNamed(context, AppRouter.weddingDressBooking, arguments: {'service': service});
    // } else if (_isDecorationService(service)) {
    //   Navigator.pushNamed(context, AppRouter.decorationBooking, arguments: {'service': service});
    // } else if (_isWeddingPlannerService(service)) {
    //   Navigator.pushNamed(context, AppRouter.weddingPlannerBooking, arguments: {'service': service});
    // }
  }

  /// Custom app bar with golden gradient background and filter button
  Widget _buildAppBar(BuildContext context) {
    return Container(
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
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Row(
        children: [
          // Back button on the left (since Arabic is RTL)
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
              size: 24,
            ),
            padding: EdgeInsets.zero,
          ),

          const Spacer(),

          // Category name in center
          Text(
            widget.category.nameAr,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textDirection: TextDirection.rtl,
          ),

          const Spacer(),

          // Filter button with badge if filters are active
          BlocBuilder<ServiceBloc, ServiceState>(
            builder: (context, state) {
              final cities = state is ServicesByCategoryLoaded
                  ? state.availableCities
                  : <String>[];

              return Stack(
                children: [
                  IconButton(
                    onPressed: () => _showFilterBottomSheet(cities),
                    icon: const Icon(
                      Icons.filter_list,
                      color: Colors.white,
                      size: 24,
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  // Show badge if filters are active
                  if (_hasActiveFilters)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  /// Loading skeleton
  Widget _buildLoadingSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          height: 350,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: SkeletonLoading.shimmer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Image skeleton
                Container(
                  height: 200,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                ),
                // Content skeleton
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Container(height: 16, color: Colors.white),
                      const SizedBox(height: 12),
                      Container(height: 14, color: Colors.white),
                      const SizedBox(height: 16),
                      Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Error state
  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            message,
            textDirection: TextDirection.rtl,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<ServiceBloc>().add(
                ServicesByCategoryRequested(widget.category.id),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4AF37),
              foregroundColor: Colors.white,
            ),
            child: const Text(
              'إعادة المحاولة',
              textDirection: TextDirection.rtl,
            ),
          ),
        ],
      ),
    );
  }

  /// Empty state
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'لا توجد خدمات في هذا القسم حالياً',
            textDirection: TextDirection.rtl,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}

/// Optimized filter bottom sheet with proper controller management
class _FilterBottomSheet extends StatefulWidget {
  final String? initialCity;
  final double? initialMinPrice;
  final double? initialMaxPrice;
  final double? initialRating;
  final bool initialHasOffer;
  final List<String> availableCities;
  final Function(String?, double?, double?, double?, bool) onApply;
  final VoidCallback onClear;

  const _FilterBottomSheet({
    required this.initialCity,
    required this.initialMinPrice,
    required this.initialMaxPrice,
    required this.initialRating,
    required this.initialHasOffer,
    required this.availableCities,
    required this.onApply,
    required this.onClear,
  });

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  late TextEditingController _minPriceController;
  late TextEditingController _maxPriceController;
  late String? _selectedCity;
  late double? _selectedRating;
  late bool _hasOfferOnly;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with current values
    _minPriceController = TextEditingController(
      text: widget.initialMinPrice?.toInt().toString() ?? '',
    );
    _maxPriceController = TextEditingController(
      text: widget.initialMaxPrice?.toInt().toString() ?? '',
    );
    _selectedCity = widget.initialCity;
    _selectedRating = widget.initialRating;
    _hasOfferOnly = widget.initialHasOffer;
  }

  @override
  void dispose() {
    // Properly dispose controllers to prevent memory leaks
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  void _clearAll() {
    setState(() {
      _selectedCity = null;
      _minPriceController.clear();
      _maxPriceController.clear();
      _selectedRating = null;
      _hasOfferOnly = false;
    });
  }

  void _apply() {
    final minPrice = double.tryParse(_minPriceController.text);
    final maxPrice = double.tryParse(_maxPriceController.text);
    widget.onApply(_selectedCity, minPrice, maxPrice, _selectedRating, _hasOfferOnly);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Modern drag handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header with gradient
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  const Color(0xFFD4AF37).withValues(alpha: 0.1),
                  const Color(0xFFD4AF37).withValues(alpha: 0.05),
                ],
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Close button
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, size: 20),
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(),
                  ),
                ),
                // Title with icon
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4AF37).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.tune,
                        color: Color(0xFFD4AF37),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'الفلاتر',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                // Clear all button
                TextButton.icon(
                  onPressed: _clearAll,
                  icon: const Icon(Icons.clear_all, size: 16),
                  label: const Text('مسح الكل'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red.shade400,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ),
          ),

          // Scrollable content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // City filter card
                  if (widget.availableCities.isNotEmpty) ...[
                    _buildFilterSection(
                      icon: Icons.location_city,
                      title: 'المدينة',
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.3)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: DropdownButton<String>(
                          value: _selectedCity,
                          isExpanded: true,
                          underline: const SizedBox(),
                          hint: const Text('اختر المدينة'),
                          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFFD4AF37)),
                          items: [
                            const DropdownMenuItem<String>(
                              value: null,
                              child: Text('الكل'),
                            ),
                            ...widget.availableCities.map(
                              (city) => DropdownMenuItem<String>(
                                value: city,
                                child: Text(city),
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedCity = value;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Price range card
                  _buildFilterSection(
                    icon: Icons.payments_outlined,
                    title: 'نطاق السعر',
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildPriceField(
                            controller: _minPriceController,
                            hint: 'من',
                            icon: Icons.arrow_upward,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD4AF37).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.remove,
                              size: 16,
                              color: Color(0xFFD4AF37),
                            ),
                          ),
                        ),
                        Expanded(
                          child: _buildPriceField(
                            controller: _maxPriceController,
                            hint: 'إلى',
                            icon: Icons.arrow_downward,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Rating filter card
                  _buildFilterSection(
                    icon: Icons.star_rounded,
                    title: 'التقييم',
                    subtitle: 'الحد الأدنى',
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      alignment: WrapAlignment.center,
                      children: [1, 2, 3, 4, 5].map((rating) {
                        final isSelected = _selectedRating == rating.toDouble();
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedRating = isSelected ? null : rating.toDouble();
                                });
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  gradient: isSelected
                                      ? const LinearGradient(
                                          colors: [Color(0xFFD4AF37), Color(0xFFB8941E)],
                                        )
                                      : null,
                                  color: isSelected ? null : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFFD4AF37)
                                        : Colors.grey.shade300,
                                    width: isSelected ? 2 : 1,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.star_rounded,
                                      size: 18,
                                      color: isSelected ? Colors.white : const Color(0xFFD4AF37),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '$rating+',
                                      style: TextStyle(
                                        color: isSelected ? Colors.white : Colors.black87,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Offers toggle card
                  _buildFilterSection(
                    icon: Icons.local_offer,
                    title: 'العروض الخاصة',
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _hasOfferOnly
                            ? const Color(0xFFD4AF37).withValues(alpha: 0.1)
                            : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _hasOfferOnly
                              ? const Color(0xFFD4AF37).withValues(alpha: 0.3)
                              : Colors.grey.shade300,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'العروض فقط',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: _hasOfferOnly ? const Color(0xFFD4AF37) : Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'عرض الخدمات التي تحتوي على عروض خاصة',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Switch(
                            value: _hasOfferOnly,
                            activeTrackColor: const Color(0xFFD4AF37).withValues(alpha: 0.5),
                            thumbColor: WidgetStateProperty.resolveWith((states) {
                              if (states.contains(WidgetState.selected)) {
                                return const Color(0xFFD4AF37);
                              }
                              return Colors.grey.shade400;
                            }),
                            onChanged: (value) {
                              setState(() {
                                _hasOfferOnly = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Apply button with gradient
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFD4AF37), Color(0xFFB8941E)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFD4AF37).withValues(alpha: 0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _apply,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          alignment: Alignment.center,
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: Colors.white,
                                size: 22,
                              ),
                              SizedBox(width: 12),
                              Text(
                                'تطبيق الفلاتر',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build consistent filter sections
  Widget _buildFilterSection({
    required IconData icon,
    required String title,
    String? subtitle,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFD4AF37).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: const Color(0xFFD4AF37),
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(width: 6),
              Text(
                '($subtitle)',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  // Helper method to build price input fields
  Widget _buildPriceField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => FocusScope.of(context).unfocus(),
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: Colors.grey.shade400,
            fontWeight: FontWeight.normal,
          ),
          prefixIcon: Icon(
            icon,
            size: 16,
            color: const Color(0xFFD4AF37),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}
