import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wedly/data/models/venue_model.dart';
import 'package:wedly/data/models/service_model.dart';
import 'package:wedly/data/models/cart_item_model.dart';
import 'package:wedly/data/repositories/service_repository.dart';
import 'package:wedly/logic/blocs/cart/cart_bloc.dart';
import 'package:wedly/logic/blocs/cart/cart_event.dart';
import 'package:wedly/core/di/injection_container.dart';

/// Venue booking confirmation screen matching the screenshot design
/// Shows booking summary receipt, calendar date picker, and personal info form
class VenueBookingScreen extends StatefulWidget {
  final VenueModel venue;
  final String timeSlot; // 'morning' or 'evening'

  const VenueBookingScreen({
    super.key,
    required this.venue,
    required this.timeSlot,
  });

  @override
  State<VenueBookingScreen> createState() => _VenueBookingScreenState();
}

class _VenueBookingScreenState extends State<VenueBookingScreen> {
  // Selected date
  DateTime? _selectedDate;

  // Current displayed month
  DateTime _displayedMonth = DateTime.now();

  // Booked dates from API
  Set<String> _bookedDates = {};
  bool _isLoadingDates = false;

  @override
  void initState() {
    super.initState();
    debugPrint('VenueBookingScreen initialized with timeSlot: ${widget.timeSlot}');
    _fetchBookedDates();
  }

  /// Fetch booked dates for the current displayed month
  Future<void> _fetchBookedDates() async {
    setState(() {
      _isLoadingDates = true;
    });

    try {
      final serviceRepository = getIt<ServiceRepository>();
      final monthStr = '${_displayedMonth.year}-${_displayedMonth.month.toString().padLeft(2, '0')}';

      debugPrint('Fetching booked dates for venue: ${widget.venue.id}, month: $monthStr, timeSlot: ${widget.timeSlot}');

      final result = await serviceRepository.getServiceAvailableDates(
        widget.venue.id,
        monthStr,
        timeSlot: widget.timeSlot,
      );

      debugPrint('API result: $result');

      final bookedDates = (result['booked_dates'] as List<dynamic>?)
          ?.map((d) => d.toString())
          .toSet() ?? {};

      debugPrint('Parsed booked dates: $bookedDates');

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

  String get _timeSlotText {
    if (widget.timeSlot == 'morning') {
      return 'صباحي';
    } else {
      return 'مسائي';
    }
  }

  double get _totalPrice {
    // Use API-provided prices only - NO local calculations
    double basePrice;

    if (widget.timeSlot == 'morning' && widget.venue.morningPrice != null) {
      basePrice = widget.venue.morningPrice!;
    } else if (widget.timeSlot == 'evening' && widget.venue.eveningPrice != null) {
      basePrice = widget.venue.eveningPrice!;
    } else {
      // TODO: Backend must provide morning_price and evening_price in venue API
      // Fallback to 0 if API doesn't provide prices (should not calculate locally)
      basePrice = 0;
    }

    return basePrice;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'تأكيد الحجز',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),

            // Venue Image and Header Card
            _buildVenueHeaderCard(),

            const SizedBox(height: 24),

            // Details Receipt Section
            _buildDetailsSection(),

            const SizedBox(height: 24),

            // Calendar Section
            _buildCalendarSection(),

            const SizedBox(height: 24),

            // Confirm Booking Button
            _buildConfirmButton(),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildVenueHeaderCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
          // Venue Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Image.network(
              widget.venue.imageUrl,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 180,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.villa, size: 60, color: Colors.grey),
                );
              },
            ),
          ),

          // Venue Info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Venue name and rating
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        widget.venue.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            widget.venue.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.star,
                            color: Color(0xFFFFB400),
                            size: 18,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 16),

                // Price
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_totalPrice.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} جنيه',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFD4AF37),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'السعة : ${widget.venue.capacity} فرد',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
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

  Widget _buildDetailsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Text(
            'التفاصيل',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFFD4AF37),
            ),
          ),
          const SizedBox(height: 16),

          // Time slot detail
          _buildDetailRow(
            icon: Icons.wb_sunny_outlined,
            label: 'الموعد',
            value: _timeSlotText,
          ),

          const SizedBox(height: 12),

          // Capacity detail
          _buildDetailRow(
            icon: Icons.event_seat_outlined,
            label: 'عدد الكراسي',
            value: '${widget.venue.capacity}',
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFD4AF37).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: const Color(0xFFD4AF37), size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
        ),
      ],
    );
  }

  Widget _buildCalendarSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
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
          // Section title
          const Text(
            'اختر موعد الحجز',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFFD4AF37),
            ),
            textAlign: TextAlign.right,
          ),
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

          // Weekday headers (RTL: Sat to Sun)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children:
                [
                      'الأحد',
                      'الإثنين',
                      'الثلاثاء',
                      'الأربعاء',
                      'الخميس',
                      'الجمعة',
                      'السبت',
                    ]
                    .map(
                      (day) => SizedBox(
                        width: 40,
                        child: Center(
                          child: Text(
                            day,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList()
                    .reversed
                    .toList(),
          ),

          const SizedBox(height: 12),

          // Calendar grid
          _buildCalendarGrid(),

          const SizedBox(height: 16),

          // Calendar legend
          _buildCalendarLegend(),
        ],
      ),
    );
  }

  Widget _buildCalendarLegend() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildLegendItem(
            color: const Color(0xFFD4AF37),
            label: 'المحدد',
          ),
          _buildLegendItem(
            color: Colors.red.withValues(alpha: 0.3),
            label: 'محجوز',
            hasStrikethrough: true,
          ),
          _buildLegendItem(
            color: Colors.grey.shade300,
            label: 'ماضي',
          ),
          _buildLegendItem(
            color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
            label: 'اليوم',
          ),
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

    int firstWeekday = (7 - firstDayOfMonth.weekday % 7) % 7;
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

  /// Shows a styled error dialog with icon
  void _showErrorDialog({
    required String title,
    required String message,
    required IconData icon,
  }) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(icon, color: Colors.orange, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: const TextStyle(fontSize: 15, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'حسناً',
                style: TextStyle(color: Color(0xFFD4AF37)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: () {
            if (_selectedDate == null) {
              _showErrorDialog(
                title: 'لم يتم اختيار تاريخ',
                message: 'الرجاء اختيار تاريخ الحجز من التقويم',
                icon: Icons.calendar_today,
              );
              return;
            }

            // Check if selected date is in the past
            final now = DateTime.now();
            final today = DateTime(now.year, now.month, now.day);
            final selectedDay = DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day);

            if (selectedDay.isBefore(today)) {
              _showErrorDialog(
                title: 'تاريخ غير صالح',
                message: 'لا يمكنك حجز تاريخ في الماضي. الرجاء اختيار تاريخ في المستقبل.',
                icon: Icons.event_busy,
              );
              return;
            }

            // Check if selected date is booked
            if (_isDateBooked(_selectedDate!)) {
              _showErrorDialog(
                title: 'الموعد محجوز',
                message: 'هذا التاريخ محجوز بالفعل. الرجاء اختيار تاريخ آخر.',
                icon: Icons.block,
              );
              return;
            }

            // Convert venue to service model for cart
            final venueAsService = ServiceModel(
              id: widget.venue.id,
              name: widget.venue.name,
              description: widget.venue.description,
              imageUrl: widget.venue.imageUrl,
              price: _totalPrice,
              category: 'قاعة أفراح',
              providerId: widget.venue.providerId,
              imageUrls: widget.venue.imageUrls,
              chairCount: widget.venue.capacity,
              address: widget.venue.address,
              latitude: widget.venue.latitude,
              longitude: widget.venue.longitude,
              rating: widget.venue.rating,
              reviewCount: widget.venue.reviewCount,
            );

            // Format date as DD/MM/YYYY for proper parsing in payment confirmation
            final formattedDate = '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}';

            // Create cart item with timeSlot for booking API
            debugPrint('🎯 VenueBookingScreen - Creating cart item');
            debugPrint('🎯 widget.timeSlot value: "${widget.timeSlot}"');
            debugPrint('🎯 widget.timeSlot isEmpty: ${widget.timeSlot.isEmpty}');
            debugPrint('🎯 widget.timeSlot == "evening": ${widget.timeSlot == "evening"}');
            debugPrint('🎯 widget.timeSlot == "morning": ${widget.timeSlot == "morning"}');

            final cartItem = CartItemModel(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              service: venueAsService,
              date: formattedDate,
              time: _timeSlotText,
              servicePrice: _totalPrice,
              addedAt: DateTime.now(),
              timeSlot: widget.timeSlot, // "morning" or "evening" for venue booking API
            );
            debugPrint('🎯 Cart item created with timeSlot: "${cartItem.timeSlot}"');
            debugPrint('🎯 Cart item toJson: ${cartItem.toJson()}');

            // Add to cart
            context.read<CartBloc>().add(CartItemAdded(item: cartItem));

            // Show success message and navigate to cart
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'تمت الإضافة إلى السلة بنجاح!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'تم إضافة ${widget.venue.name} إلى السلة الخاصة بك.',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'بمكانك المتابعة لإتمام الحجز أو إضافة خدمات أخرى',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Close dialog
                            Navigator.of(context).pop(); // Go back to details
                            Navigator.of(
                              context,
                            ).pop(); // Go back to venues list

                            // Go back to home screen (navigation wrapper)
                            // This will show the bottom nav with updated cart badge
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD4AF37),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text(
                            'تم',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
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
            'أضف إلى السلة',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
