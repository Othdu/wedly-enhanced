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
    Navigator.pop(context); // Close the filter bottom sheet
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
    Navigator.pop(context); // Close the filter bottom sheet
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
    // Temporary filter values for the modal
    String? tempCity = _selectedCity;
    double? tempMinPrice = _minPrice;
    double? tempMaxPrice = _maxPrice;
    double? tempRating = _selectedRating;
    bool tempHasOffer = _hasOfferOnly;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.85,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () {
                            setModalState(() {
                              tempCity = null;
                              tempMinPrice = null;
                              tempMaxPrice = null;
                              tempRating = null;
                              tempHasOffer = false;
                            });
                          },
                          child: const Text(
                            'مسح الكل',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                        const Text(
                          'الفلاتر',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // City filter
                    if (availableCities.isNotEmpty) ...[
                      const Text(
                        'المدينة',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButton<String>(
                          value: tempCity,
                          isExpanded: true,
                          underline: const SizedBox(),
                          hint: const Text('الكل'),
                          items: [
                            const DropdownMenuItem<String>(
                              value: null,
                              child: Text('الكل'),
                            ),
                            ...availableCities.map((city) => DropdownMenuItem<String>(
                                  value: city,
                                  child: Text(city),
                                )),
                          ],
                          onChanged: (value) {
                            setModalState(() {
                              tempCity = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Price range
                    const Text(
                      'نطاق السعر',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: 'من',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                            ),
                            controller: TextEditingController(
                              text: tempMinPrice?.toInt().toString() ?? '',
                            ),
                            onChanged: (value) {
                              tempMinPrice = double.tryParse(value);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: 'إلى',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                            ),
                            controller: TextEditingController(
                              text: tempMaxPrice?.toInt().toString() ?? '',
                            ),
                            onChanged: (value) {
                              tempMaxPrice = double.tryParse(value);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Rating filter
                    const Text(
                      'التقييم (الحد الأدنى)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [1, 2, 3, 4, 5].map((rating) {
                        final isSelected = tempRating == rating.toDouble();
                        return GestureDetector(
                          onTap: () {
                            setModalState(() {
                              tempRating = isSelected ? null : rating.toDouble();
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFFD4AF37)
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFFD4AF37)
                                    : Colors.grey.shade300,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.star,
                                  size: 16,
                                  color: isSelected ? Colors.white : Colors.amber,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '$rating+',
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : Colors.black87,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // Has offer toggle
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Switch(
                          value: tempHasOffer,
                          activeTrackColor: const Color(0xFFD4AF37).withValues(alpha: 0.5),
                          thumbColor: WidgetStateProperty.resolveWith((states) {
                            if (states.contains(WidgetState.selected)) {
                              return const Color(0xFFD4AF37);
                            }
                            return Colors.grey;
                          }),
                          onChanged: (value) {
                            setModalState(() {
                              tempHasOffer = value;
                            });
                          },
                        ),
                        const Text(
                          'العروض فقط',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Apply button
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectedCity = tempCity;
                          _minPrice = tempMinPrice;
                          _maxPrice = tempMaxPrice;
                          _selectedRating = tempRating;
                          _hasOfferOnly = tempHasOffer;
                        });
                        _applyFilters();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD4AF37),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'تطبيق الفلاتر',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
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
