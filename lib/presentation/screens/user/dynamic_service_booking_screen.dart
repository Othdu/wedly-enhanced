import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wedly/data/models/service_model.dart';
import 'package:wedly/data/models/cart_item_model.dart';
import 'package:wedly/data/repositories/service_repository.dart';
import 'package:wedly/logic/blocs/cart/cart_bloc.dart';
import 'package:wedly/logic/blocs/cart/cart_event.dart';
import 'package:wedly/core/di/injection_container.dart';

/// Dynamic service booking screen that adapts its UI based on service structure from API
/// Handles services with dynamic sections (single/multiple choice options)
/// Does NOT handle venues (those use venue_booking_screen.dart)
class DynamicServiceBookingScreen extends StatefulWidget {
  final ServiceModel service;

  const DynamicServiceBookingScreen({super.key, required this.service});

  @override
  State<DynamicServiceBookingScreen> createState() =>
      _DynamicServiceBookingScreenState();
}

class _DynamicServiceBookingScreenState
    extends State<DynamicServiceBookingScreen> {
  DateTime? _selectedDate;
  DateTime _displayedMonth = DateTime.now();

  // Track selected options for each section
  // Map<sectionId, Set<optionIndex>> for multiple selection
  // Map<sectionId, int> for single selection
  final Map<String, dynamic> _selectedOptions = {};

  bool _isLoadingSections = false;
  bool _hasLoadingError = false;
  List<Map<String, dynamic>>? _dynamicSections;
  List<Map<String, dynamic>>? _packages;

  // Booked dates for the calendar (non-venue services: any booking blocks the day)
  Set<String> _bookedDates = {};
  bool _isLoadingDates = false;

  @override
  void initState() {
    super.initState();
    _loadServiceData();
    _fetchBookedDates();
  }

  /// Fetch booked dates for the current displayed month
  /// For non-venue services, any booking (morning or evening) blocks the entire day
  Future<void> _fetchBookedDates() async {
    setState(() {
      _isLoadingDates = true;
    });

    try {
      final serviceRepository = getIt<ServiceRepository>();
      final monthStr = '${_displayedMonth.year}-${_displayedMonth.month.toString().padLeft(2, '0')}';

      // Don't pass timeSlot - we want ALL bookings for this service
      // Any booking (morning or evening) will block the entire day
      final result = await serviceRepository.getServiceAvailableDates(
        widget.service.id,
        monthStr,
        // No timeSlot parameter - get all bookings
      );

      final bookedDates = (result['booked_dates'] as List<dynamic>?)
          ?.map((d) => d.toString())
          .toSet() ?? {};

      setState(() {
        _bookedDates = bookedDates;
        _isLoadingDates = false;
      });
    } catch (e) {
      debugPrint('Error fetching booked dates: $e');
      setState(() {
        _isLoadingDates = false;
      });
    }
  }

  /// Check if a date is booked
  bool _isDateBooked(DateTime date) {
    final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return _bookedDates.contains(dateStr);
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadServiceData() async {
    // If service already has dynamic sections, use them
    if (widget.service.dynamicSections != null &&
        widget.service.dynamicSections!.isNotEmpty) {
      _dynamicSections = widget.service.dynamicSections;
      _initializeSelections();
      return;
    }

    // Otherwise, fetch from API (for non-venue services)
    if (widget.service.chairCount == null) {
      setState(() => _isLoadingSections = true);

      try {
        final serviceRepository = getIt<ServiceRepository>();

        // Fetch dynamic sections and packages
        final sections = await serviceRepository.getDynamicSections(widget.service.id);
        final packages = await serviceRepository.getServicePackages(widget.service.id);

        setState(() {
          _dynamicSections = sections;
          _packages = packages;
          _isLoadingSections = false;
        });

        _initializeSelections();
      } catch (e) {
        setState(() {
          _isLoadingSections = false;
          _hasLoadingError = true;
        });
      }
    }
  }

  void _initializeSelections() {
    // Initialize selection maps based on section types
    if (_dynamicSections != null) {
      for (final section in _dynamicSections!) {
        final sectionId = section['id']?.toString() ?? '';
        final selectionType = section['selectionType'] ??
                            section['selection_type'] ?? 'single';

        if (selectionType == 'multiple') {
          _selectedOptions[sectionId] = <int>{};
        } else {
          _selectedOptions[sectionId] = null; // null means nothing selected yet
        }
      }
    }
  }

  /// Calculate total price based on selected options only (no base price)
  double _calculateTotalPrice() {
    double total = 0.0;

    if (_dynamicSections != null) {
      for (final section in _dynamicSections!) {
        final sectionId = section['id']?.toString() ?? '';
        final selectionType = section['selectionType'] ?? section['selection_type'] ?? 'single';
        final options = section['options'] as List? ?? [];

        if (selectionType == 'multiple') {
          // Add prices for all selected options in this section
          final selectedIndices = _selectedOptions[sectionId] as Set<int>? ?? {};
          for (final index in selectedIndices) {
            if (index < options.length) {
              final optionPrice =
                  double.tryParse(options[index]['price']?.toString() ?? '0') ??
                      0.0;
              total += optionPrice;
            }
          }
        } else {
          // Add price for single selected option
          final selectedIndex = _selectedOptions[sectionId] as int?;
          if (selectedIndex != null && selectedIndex < options.length) {
            final optionPrice =
                double.tryParse(options[selectedIndex]['price']?.toString() ?? '0') ??
                    0.0;
            total += optionPrice;
          }
        }
      }
    }

    return total;
  }

  /// Check if all required sections have selections
  bool _hasRequiredSelections() {
    if (_dynamicSections == null || _dynamicSections!.isEmpty) {
      return true; // No sections means no requirements
    }

    // Check if at least one option is selected in each section
    for (final section in _dynamicSections!) {
      final sectionId = section['id']?.toString() ?? '';
      final selectionType = section['selectionType'] ?? section['selection_type'] ?? 'single';

      if (selectionType == 'multiple') {
        final selectedIndices = _selectedOptions[sectionId] as Set<int>? ?? {};
        if (selectedIndices.isEmpty) {
          return false; // No options selected in this multiple-choice section
        }
      } else {
        final selectedIndex = _selectedOptions[sectionId] as int?;
        if (selectedIndex == null) {
          return false; // No option selected in this single-choice section
        }
      }
    }

    return true;
  }

  void _handleBooking() {
    // Validate that selections are made
    if (!_hasRequiredSelections()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'الرجاء اختيار خيار واحد على الأقل من كل قسم',
            textDirection: TextDirection.rtl,
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Validate that date is selected
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'الرجاء اختيار تاريخ الحجز',
            textDirection: TextDirection.rtl,
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }


    // Build selected options details for cart
    final selectedDetails = _buildSelectedDetailsText();
    final totalPrice = _calculateTotalPrice();

    // Format date (guaranteed to be non-null at this point)
    final formattedDate = '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}';

    // Get selected section and option IDs for booking API
    final selectedSectionId = _getSelectedSectionId();
    final selectedOptionIds = _getSelectedOptionIds();

    // Create cart item with timeSlot="morning" for non-venue services
    final cartItem = CartItemModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      service: widget.service,
      date: formattedDate,
      time: selectedDetails.isNotEmpty ? selectedDetails : 'الخيارات الأساسية',
      servicePrice: totalPrice,
      addedAt: DateTime.now(),
      timeSlot: 'morning', // Default to morning for non-venue services
      selectedSectionId: selectedSectionId,
      selectedOptionIds: selectedOptionIds,
    );

    // Add to cart
    context.read<CartBloc>().add(CartItemAdded(item: cartItem));

    // Show success dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        contentPadding: const EdgeInsets.all(32),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFFD4AF37),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'تمت الإضافة للسلة',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'تم إضافة ${widget.service.name} إلى سلة المشتريات',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.black54),
              textDirection: TextDirection.rtl,
            ),
          ],
        ),
      ),
    );

    // Navigate back to home after 1.5 seconds
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        Navigator.of(context).pop(); // Close dialog
        Navigator.of(context).pop(); // Go back to home
      }
    });
  }

  /// Extract selected section ID (first section with selections)
  String? _getSelectedSectionId() {
    if (_dynamicSections == null || _dynamicSections!.isEmpty) return null;

    for (final section in _dynamicSections!) {
      final sectionId = section['id']?.toString() ?? '';
      final selectionType = section['selectionType'] ?? section['selection_type'] ?? 'single';

      if (selectionType == 'multiple') {
        final selectedIndices = _selectedOptions[sectionId] as Set<int>? ?? {};
        if (selectedIndices.isNotEmpty) {
          return sectionId;
        }
      } else {
        final selectedIndex = _selectedOptions[sectionId] as int?;
        if (selectedIndex != null) {
          return sectionId;
        }
      }
    }
    return null;
  }

  /// Extract all selected option IDs from all sections
  List<String>? _getSelectedOptionIds() {
    if (_dynamicSections == null || _dynamicSections!.isEmpty) return null;

    final List<String> optionIds = [];

    for (final section in _dynamicSections!) {
      final sectionId = section['id']?.toString() ?? '';
      final selectionType = section['selectionType'] ?? section['selection_type'] ?? 'single';
      final options = section['options'] as List? ?? [];

      if (selectionType == 'multiple') {
        final selectedIndices = _selectedOptions[sectionId] as Set<int>? ?? {};
        for (final index in selectedIndices) {
          if (index < options.length) {
            final optionId = options[index]['id']?.toString() ?? options[index]['_id']?.toString();
            if (optionId != null && optionId.isNotEmpty) {
              optionIds.add(optionId);
            }
          }
        }
      } else {
        final selectedIndex = _selectedOptions[sectionId] as int?;
        if (selectedIndex != null && selectedIndex < options.length) {
          final optionId = options[selectedIndex]['id']?.toString() ?? options[selectedIndex]['_id']?.toString();
          if (optionId != null && optionId.isNotEmpty) {
            optionIds.add(optionId);
          }
        }
      }
    }

    return optionIds.isNotEmpty ? optionIds : null;
  }

  String _buildSelectedDetailsText() {
    final List<String> details = [];

    if (_dynamicSections != null) {
      for (final section in _dynamicSections!) {
        final sectionTitle = section['title'] ?? section['section_name'] ?? '';
        final selectionType = section['selectionType'] ?? section['selection_type'] ?? 'single';
        final sectionId = section['id']?.toString() ?? '';
        final options = section['options'] as List? ?? [];

        if (selectionType == 'multiple') {
          final selectedIndices = _selectedOptions[sectionId] as Set<int>? ?? {};
          final selectedTexts = selectedIndices
              .where((index) => index < options.length)
              .map((index) => options[index]['text']?.toString() ??
                             options[index]['name']?.toString() ??
                             options[index]['option_text']?.toString() ?? '')
              .toList();

          if (selectedTexts.isNotEmpty) {
            details.add('$sectionTitle: ${selectedTexts.join(', ')}');
          }
        } else {
          final selectedIndex = _selectedOptions[sectionId] as int?;
          if (selectedIndex != null && selectedIndex < options.length) {
            final selectedText = options[selectedIndex]['text']?.toString() ??
                                options[selectedIndex]['name']?.toString() ??
                                options[selectedIndex]['option_text']?.toString() ?? '';
            details.add('$sectionTitle: $selectedText');
          }
        }
      }
    }

    return details.join('\n');
  }

  @override
  Widget build(BuildContext context) {
    final hasDynamicSections = _dynamicSections != null && _dynamicSections!.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: CustomScrollView(
        slivers: [
          // App Bar with service image
          _buildSliverAppBar(context),

          // Content
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),

                // Service name badge
                _buildServiceBadge(),

                const SizedBox(height: 24),

                // Dynamic Sections (if any)
                if (_isLoadingSections)
                  const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD4AF37)),
                      ),
                    ),
                  )
                else if (_hasLoadingError)
                  _buildErrorRetrySection()
                else if (hasDynamicSections)
                  _buildDynamicSectionsPackages()
                else
                  // No sections - just show base price info
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.grey.shade200,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: Color(0xFFD4AF37),
                            size: 40,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'هذه الخدمة لا تحتوي على خيارات إضافية',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                            textDirection: TextDirection.rtl,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'سيتم حجز الخدمة بالسعر الأساسي',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                            textDirection: TextDirection.rtl,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 24),

                // Calendar Section
                _buildCalendarSection(),
                const SizedBox(height: 24),

                // Booking Button (shown after selections made)
                if (_hasRequiredSelections() || (_dynamicSections == null || _dynamicSections!.isEmpty)) ...[
                  _buildPriceSummary(),
                  const SizedBox(height: 16),
                  _buildBookingButton(context),
                  const SizedBox(height: 32),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 250,
      pinned: true,
      backgroundColor: Colors.white,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              widget.service.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.category, size: 80, color: Colors.grey),
                );
              },
            ),
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.5),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceBadge() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
      decoration: BoxDecoration(
        color: const Color(0xFFD4AF37),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Text(
        widget.service.description,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildErrorRetrySection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.red.shade200,
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red.shade400,
              size: 48,
            ),
            const SizedBox(height: 16),
            const Text(
              'فشل تحميل تفاصيل الخدمة',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'حدث خطأ أثناء تحميل الخيارات المتاحة',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _hasLoadingError = false;
                  });
                  _loadServiceData();
                },
                icon: const Icon(Icons.refresh),
                label: const Text(
                  'إعادة المحاولة',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDynamicSectionsPackages() {
    return Column(
      children: _dynamicSections!.map((section) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildSectionPackageCard(section),
        );
      }).toList(),
    );
  }

  Widget _buildSectionPackageCard(Map<String, dynamic> section) {
    final sectionId = section['id']?.toString() ?? '';
    final sectionTitle = section['title'] ?? section['section_name'] ?? '';
    final sectionDescription = section['description'] ?? '';
    final selectionType = section['selectionType'] ?? section['selection_type'] ?? 'single';
    final options = section['options'] as List? ?? [];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          Text(
            sectionTitle,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFFD4AF37),
            ),
            textAlign: TextAlign.left,
          ),

          // Section Description (if exists)
          if (sectionDescription.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              sectionDescription,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.left,
            ),
          ],

          const SizedBox(height: 12),

          // Selection type indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFD4AF37).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  selectionType == 'multiple'
                      ? Icons.check_box_outlined
                      : Icons.radio_button_checked,
                  size: 16,
                  color: const Color(0xFFD4AF37),
                ),
                const SizedBox(width: 6),
                Text(
                  selectionType == 'multiple'
                      ? 'يمكن اختيار أكثر من خيار'
                      : 'اختر خياراً واحداً',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFFD4AF37),
                    fontWeight: FontWeight.w600,
                  ),
                  textDirection: TextDirection.ltr,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Options with checkboxes/radio buttons
          ...List.generate(options.length, (index) {
            return _buildOptionItem(
              sectionId: sectionId,
              selectionType: selectionType,
              optionIndex: index,
              option: options[index],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildOptionItem({
    required String sectionId,
    required String selectionType,
    required int optionIndex,
    required Map<String, dynamic> option,
  }) {
    // Handle multiple possible field names for option text from API
    final optionText = option['text']?.toString() ??
                       option['name']?.toString() ??
                       option['option_text']?.toString() ?? '';
    final optionPrice = double.tryParse(option['price']?.toString() ?? '0') ?? 0.0;

    bool isSelected;
    if (selectionType == 'multiple') {
      final selectedIndices = _selectedOptions[sectionId] as Set<int>? ?? {};
      isSelected = selectedIndices.contains(optionIndex);
    } else {
      isSelected = _selectedOptions[sectionId] == optionIndex;
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          if (selectionType == 'multiple') {
            final selectedIndices =
                _selectedOptions[sectionId] as Set<int>? ?? <int>{};
            if (isSelected) {
              selectedIndices.remove(optionIndex);
            } else {
              selectedIndices.add(optionIndex);
            }
            _selectedOptions[sectionId] = selectedIndices;
          } else {
            _selectedOptions[sectionId] = optionIndex;
          }
        });
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Checkbox for multiple selection, styled indicator for single
            Container(
              width: 20,
              height: 20,
              margin: const EdgeInsets.only(top: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFD4AF37)
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFD4AF37)
                      : Colors.grey.shade400,
                  width: 1.5,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      size: 14,
                      color: Colors.white,
                    )
                  : null,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    optionText,
                    style: TextStyle(
                      fontSize: 15,
                      color: isSelected
                          ? Colors.black87
                          : Colors.black87,
                      height: 1.5,
                      fontWeight: isSelected
                          ? FontWeight.w500
                          : FontWeight.normal,
                    ),
                    textAlign: TextAlign.left,
                  ),
                  if (optionPrice > 0) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFD4AF37).withValues(alpha: 0.15)
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFFD4AF37).withValues(alpha: 0.4)
                              : Colors.grey.shade300,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        '+${optionPrice.toInt()} جنيه',
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected
                              ? const Color(0xFFD4AF37)
                              : Colors.grey[700],
                          fontWeight: FontWeight.bold,
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: _selectedDate == null
            ? Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.3), width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: _selectedDate == null
                ? const Color(0xFFD4AF37).withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Section title with required indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Text(
                'اختر موعد الحجز',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFD4AF37),
                ),
                textAlign: TextAlign.left,
              ),
              if (_selectedDate == null)
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4AF37).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'مطلوب',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFD4AF37),
                    ),
                  ),
                ),
            ],
          ),

          // Selected date display (if date is selected)
          if (_selectedDate != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFD4AF37).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Color(0xFFD4AF37),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'التاريخ المختار: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFD4AF37),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Month/Year Header with navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () {
                  setState(() {
                    _displayedMonth = DateTime(
                      _displayedMonth.year,
                      _displayedMonth.month + 1,
                    );
                  });
                  _fetchBookedDates(); // Fetch dates for new month
                },
                color: const Color(0xFFD4AF37),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isLoadingDates)
                    const Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD4AF37)),
                        ),
                      ),
                    ),
                  Text(
                    '${_getMonthName(_displayedMonth.month)} ${_displayedMonth.year}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () {
                  setState(() {
                    _displayedMonth = DateTime(
                      _displayedMonth.year,
                      _displayedMonth.month - 1,
                    );
                  });
                  _fetchBookedDates(); // Fetch dates for new month
                },
                color: const Color(0xFFD4AF37),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Weekday headers (LTR: Sun to Sat)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children:
                [
                      'أحد',
                      'اثنين',
                      'ثلاثاء',
                      'أربعاء',
                      'خميس',
                      'جمعة',
                      'سبت',
                    ]
                    .map(
                      (day) => SizedBox(
                        width: 44,
                        child: Center(
                          child: Text(
                            day,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
          ),

          const SizedBox(height: 12),

          // Calendar grid
          _buildCalendarGrid(),

          const SizedBox(height: 16),

          // Calendar legend
          
        ],
      ),
    );
  }


  Widget _buildLegendItem({
    required Color color,
    required String label,
    bool hasStrikethrough = false,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
          child: hasStrikethrough
              ? Center(
                  child: Text(
                    '—',
                    style: TextStyle(
                      color: Colors.red.shade400,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : null,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarGrid() {
    final firstDayOfMonth = DateTime(
      _displayedMonth.year,
      _displayedMonth.month,
      1,
    );
    final lastDayOfMonth = DateTime(
      _displayedMonth.year,
      _displayedMonth.month + 1,
      0,
    );

    // Calculate empty spaces before first day
    // Dart weekday: 1=Monday, 7=Sunday
    // Our calendar starts with Sunday (index 0)
    // So: Sunday(7)->0, Monday(1)->1, Tuesday(2)->2, ..., Saturday(6)->6
    int firstWeekday = firstDayOfMonth.weekday % 7;
    final daysInMonth = lastDayOfMonth.day;

    List<Widget> dayWidgets = [];

    // Add empty spaces
    for (int i = 0; i < firstWeekday; i++) {
      dayWidgets.add(const SizedBox(width: 40, height: 40));
    }

    // Add day widgets
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_displayedMonth.year, _displayedMonth.month, day);
      final isSelected =
          _selectedDate != null &&
          _selectedDate!.year == date.year &&
          _selectedDate!.month == date.month &&
          _selectedDate!.day == date.day;

      final isToday =
          DateTime.now().year == date.year &&
          DateTime.now().month == date.month &&
          DateTime.now().day == date.day;

      final isPast = date.isBefore(
        DateTime.now().subtract(const Duration(days: 1)),
      );

      final isBooked = _isDateBooked(date);
      final isDisabled = isPast || isBooked;

      dayWidgets.add(
        GestureDetector(
          onTap: isDisabled
              ? null
              : () {
                  setState(() {
                    _selectedDate = date;
                  });
                },
          child: Container(
            width: 40,
            height: 40,
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFFD4AF37)
                  : isBooked
                      ? Colors.red.withValues(alpha: 0.1)
                      : (isToday
                            ? const Color(0xFFD4AF37).withValues(alpha: 0.1)
                            : Colors.transparent),
              borderRadius: BorderRadius.circular(8),
              border: isBooked && !isSelected
                  ? Border.all(color: Colors.red.withValues(alpha: 0.3))
                  : null,
            ),
            child: Center(
              child: Text(
                day.toString(),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isPast
                      ? Colors.grey.shade300
                      : isBooked
                          ? Colors.red.shade300
                          : (isSelected
                                ? Colors.white
                                : (isToday
                                      ? const Color(0xFFD4AF37)
                                      : Colors.black87)),
                  decoration: isBooked ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
          ),
        ),
      );
    }

    // Arrange in rows of 7
    List<Widget> rows = [];
    for (int i = 0; i < dayWidgets.length; i += 7) {
      rows.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: dayWidgets.sublist(
            i,
            i + 7 > dayWidgets.length ? dayWidgets.length : i + 7,
          ),
        ),
      );
    }

    return Column(children: rows);
  }

  String _getMonthName(int month) {
    const monthNames = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];
    return monthNames[month - 1];
  }

  Widget _buildPriceSummary() {
    final totalPrice = _calculateTotalPrice();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD4AF37), width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4AF37).withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          const Text(
            'ملخص السعر',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFFD4AF37),
            ),
            textAlign: TextAlign.left,
          ),
          const SizedBox(height: 16),

          // Selected options breakdown
          if (_dynamicSections != null && _dynamicSections!.isNotEmpty) ...[
            const Text(
              'الخيارات المختارة:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 8),
            ..._buildSelectedOptionsPriceBreakdown(),
            const SizedBox(height: 12),
            const Divider(thickness: 2),
            const SizedBox(height: 12),
          ],

          // Total price
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'الإجمالي',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                '${totalPrice.toStringAsFixed(0)} جنيه',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFD4AF37),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build price breakdown for selected options
  List<Widget> _buildSelectedOptionsPriceBreakdown() {
    final List<Widget> breakdown = [];

    if (_dynamicSections != null) {
      for (final section in _dynamicSections!) {
        final sectionId = section['id']?.toString() ?? '';
        final sectionTitle = section['title'] ?? section['section_name'] ?? '';
        final selectionType = section['selectionType'] ?? section['selection_type'] ?? 'single';
        final options = section['options'] as List? ?? [];

        if (selectionType == 'multiple') {
          final selectedIndices = _selectedOptions[sectionId] as Set<int>? ?? {};
          for (final index in selectedIndices) {
            if (index < options.length) {
              // Handle multiple possible field names for option text from API
              final optionText = options[index]['text']?.toString() ??
                                 options[index]['name']?.toString() ??
                                 options[index]['option_text']?.toString() ?? '';
              final optionPrice = double.tryParse(options[index]['price']?.toString() ?? '0') ?? 0.0;
              if (optionPrice > 0) {
                breakdown.add(
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '$sectionTitle: $optionText',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                            textAlign: TextAlign.left,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '${optionPrice.toStringAsFixed(0)} جنيه',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
            }
          }
        } else {
          final selectedIndex = _selectedOptions[sectionId] as int?;
          if (selectedIndex != null && selectedIndex < options.length) {
            // Handle multiple possible field names for option text from API
            final optionText = options[selectedIndex]['text']?.toString() ??
                               options[selectedIndex]['name']?.toString() ??
                               options[selectedIndex]['option_text']?.toString() ?? '';
            final optionPrice = double.tryParse(options[selectedIndex]['price']?.toString() ?? '0') ?? 0.0;
            if (optionPrice > 0) {
              breakdown.add(
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '$sectionTitle: $optionText',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                          textAlign: TextAlign.left,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${optionPrice.toStringAsFixed(0)} جنيه',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
          }
        }
      }
    }

    return breakdown;
  }

  Widget _buildBookingButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: _handleBooking,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFD4AF37),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: const Text(
            'إضافة إلى السلة',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
