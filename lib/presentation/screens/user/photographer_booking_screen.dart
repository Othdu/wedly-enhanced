
import 'package:flutter/material.dart';
import 'package:wedly/data/models/service_model.dart';
import 'package:wedly/data/models/offer_model.dart';
import 'package:wedly/presentation/widgets/booking_success_dialog.dart';

/// Photographer booking screen with package-based pricing
/// User selects one package, then one option within that package
/// Can accept either a service or an offer
class PhotographerBookingScreen extends StatefulWidget {
  final ServiceModel? service;
  final OfferModel? offer;

  const PhotographerBookingScreen({super.key, this.service, this.offer})
    : assert(
        service != null || offer != null,
        'Either service or offer must be provided',
      );

  @override
  State<PhotographerBookingScreen> createState() =>
      _PhotographerBookingScreenState();
}

class _PhotographerBookingScreenState extends State<PhotographerBookingScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  // Selected date
  DateTime? _selectedDate;

  // Current displayed month
  DateTime _displayedMonth = DateTime.now();

  // Package selection
  String? _selectedPackage; // 'session', 'half_day', 'full_day', 'no_print'
  String? _selectedOption; // The specific pricing option within the package

  // Helper getters to work with both service and offer
  String get _title {
    if (widget.offer != null) {
      return widget.offer!.titleAr;
    }
    return widget.service!.name;
  }

  String get _imageUrl {
    if (widget.offer != null) {
      return widget.offer!.imageUrl;
    }
    return widget.service!.imageUrl;
  }

  bool get _isOffer => widget.offer != null;

  // Hardcoded packages for photographer (will come from backend later)
  final Map<String, List<Map<String, dynamic>>> _packages = {
    'session': [
      {
        'title': 'جلسة تصوير',
        'description': 'مدة التصوير: ساعتين',
        'options': [
          {'size': 'البوم صغير 40×15 + بوستر 70×50 + 50 كارت', 'price': 5000},
          {'size': 'البوم 45×30', 'price': 5500},
          {'size': 'البوم 80×30', 'price': 6000},
        ],
      },
    ],
    'half_day': [
      {
        'title': 'نصف يوم',
        'description': 'جلسة (مصورين 2)',
        'options': [
          {'size': 'البوم صغير 40×15 + بوستر 70×50 + 50 كارت', 'price': 7000},
          {'size': 'البوم 45×30', 'price': 7500},
          {'size': 'البوم 80×30', 'price': 8000},
        ],
      },
    ],
    'full_day': [
      {
        'title': 'يوم كامل',
        'description': 'تجهيزات الزفاف\nجلسة تصوير\nحفلة (مصورين 2)',
        'options': [
          {'size': 'البوم صغير 40×15 + بوستر 70×50 + 50 كارت', 'price': 8500},
          {'size': 'البوم 45×30', 'price': 9000},
          {'size': 'البوم 80×30', 'price': 9500},
        ],
      },
    ],
    'no_print': [
      {
        'title': 'بدون طباعة',
        'description': '',
        'options': [
          {'size': 'جلسة تصوير زفاف  ', 'price': 2800},
          {'size': 'جلسة خطوبة أو كتب كتاب ', 'price': 2500},
          {'size': 'حفلة (مصور واحد)  ', 'price': 1800},
          {'size': 'حفلة (مصورين 2)  ', 'price': 2400},
        ],
      },
    ],
  };

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: CustomScrollView(
        slivers: [
          // App Bar with photographer image
          _buildSliverAppBar(),

          // Content
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),

                // Photographer name badge
                _buildPhotographerBadge(),

                const SizedBox(height: 24),

                // Package sections
                _buildPackagesSection(),

                const SizedBox(height: 24),

                // Calendar Section (shown after package selection)
                if (_selectedPackage != null && _selectedOption != null) ...[
                  _buildCalendarSection(),
                  const SizedBox(height: 24),
                ],

                // Personal Information Form (shown after date selection)
                if (_selectedDate != null) ...[
                  _buildPersonalInfoSection(),
                  const SizedBox(height: 24),
                ],

                // Booking Button (shown after date selection)
                if (_selectedDate != null) ...[
                  _buildPriceSummary(),
                  const SizedBox(height: 16),
                  _buildBookingButton(),
                  const SizedBox(height: 32),
                ],
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
              _imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey.shade300,
                  child: const Icon(
                    Icons.camera_alt,
                    size: 80,
                    color: Colors.grey,
                  ),
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

  Widget _buildPhotographerBadge() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
      decoration: BoxDecoration(
        color: const Color(0xFFD4AF37),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Text(
        _title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildPackagesSection() {
    return Column(
      children: [
        _buildPackageCard('session', "السيشن"),
        const SizedBox(height: 16),
        _buildPackageCard('half_day', "نصف يوم"),
        const SizedBox(height: 16),
        _buildPackageCard('full_day', "يوم كامل"),
        const SizedBox(height: 16),
        _buildPackageCard('no_print', "بدون طباعة"),
      ],
    );
  }

  Widget _buildPackageCard(String packageKey, String packageTitle) {
    final package = _packages[packageKey]![0];
    final isSelected = _selectedPackage == packageKey;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? const Color(0xFFD4AF37) : Colors.grey.shade200,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          if (isSelected)
            BoxShadow(
              color: const Color(0xFFD4AF37).withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Package title
          Text(
            packageTitle,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFFD4AF37),
            ),
          ),

          if (package['description'] != null &&
              package['description'].toString().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              package['description'],
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
              textAlign: TextAlign.right,
            ),
          ],

          const SizedBox(height: 16),

          // Options
          ...List.generate(package['options'].length, (index) {
            final option = package['options'][index];
            final optionKey = '$packageKey-$index';
            final isOptionSelected = _selectedOption == optionKey;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedPackage = packageKey;
                    _selectedOption = optionKey;
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  textDirection: TextDirection.rtl,
                  children: [
                    Expanded(
                      child: Row(
                        textDirection: TextDirection.rtl,
                        children: [
                          // Radio button
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isOptionSelected
                                    ? const Color(0xFFD4AF37)
                                    : Colors.grey.shade400,
                                width: 2,
                              ),
                            ),
                            child: isOptionSelected
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
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              option['size'],
                              style: TextStyle(
                                fontSize: 13,
                                color: isOptionSelected
                                    ? Colors.black87
                                    : Colors.grey.shade700,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${option['price']} جنيه',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isOptionSelected
                            ? const Color(0xFFD4AF37)
                            : Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
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
                },
                color: const Color(0xFFD4AF37),
              ),
              Text(
                '${_getMonthName(_displayedMonth.month)} ${_displayedMonth.year}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
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
        ],
      ),
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

      dayWidgets.add(
        GestureDetector(
          onTap: isPast
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
                  : (isToday
                        ? const Color(0xFFD4AF37).withValues(alpha: 0.1)
                        : Colors.transparent),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                day.toString(),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isPast
                      ? Colors.grey.shade300
                      : (isSelected
                            ? Colors.white
                            : (isToday
                                  ? const Color(0xFFD4AF37)
                                  : Colors.black87)),
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

  Widget _buildPersonalInfoSection() {
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
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'المعلومات الشخصية',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFFD4AF37),
              ),
            ),
            const SizedBox(height: 20),

            // Full Name Field
            TextFormField(
              controller: _nameController,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                labelText: 'الاسم الكامل',
                labelStyle: const TextStyle(color: Color(0xFFD4AF37)),
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFFD4AF37),
                    width: 2,
                  ),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال الاسم الكامل';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Email Field
            TextFormField(
              controller: _emailController,
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.left,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'البريد الإلكتروني',
                labelStyle: const TextStyle(color: Color(0xFFD4AF37)),
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFFD4AF37),
                    width: 2,
                  ),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال البريد الإلكتروني';
                }
                if (!value.contains('@')) {
                  return 'الرجاء إدخال بريد إلكتروني صحيح';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Phone Field
            TextFormField(
              controller: _phoneController,
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.left,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'رقم الهاتف',
                labelStyle: const TextStyle(color: Color(0xFFD4AF37)),
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFFD4AF37),
                    width: 2,
                  ),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال رقم الهاتف';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceSummary() {
    // Get selected package and option price
    double originalPrice = 0.0;
    double finalPrice = 0.0;
    String selectedPackageTitle = '';
    String selectedOptionTitle = '';
    bool hasDiscount = false;
    double? discountPercentage;

    if (_selectedPackage != null && _selectedOption != null) {
      final package = _packages[_selectedPackage]![0];
      final optionIndex = int.parse(_selectedOption!.split('-')[1]);
      final option = package['options'][optionIndex];

      originalPrice = (option['price'] as int).toDouble();
      selectedPackageTitle = _getPackageTitle(_selectedPackage!);
      selectedOptionTitle = option['size'];

      // Check if service has an approved offer
      if (widget.service != null &&
          widget.service!.hasApprovedOffer &&
          widget.service!.discountPercentage != null) {
        hasDiscount = true;
        discountPercentage = widget.service!.discountPercentage;
        finalPrice = originalPrice * (1 - discountPercentage! / 100);
      } else {
        finalPrice = originalPrice;
      }
    }

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
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 16),

          // Selected package
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  selectedPackageTitle,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Selected option with price
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  selectedOptionTitle,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                  textAlign: TextAlign.right,
                ),
              ),
              Text(
                '${originalPrice.toStringAsFixed(0)} جنيه',
                style: TextStyle(
                  fontSize: 14,
                  color: hasDiscount ? Colors.grey.shade500 : Colors.black87,
                  decoration: hasDiscount ? TextDecoration.lineThrough : null,
                ),
              ),
            ],
          ),

          // Discount row (if applicable)
          if (hasDiscount) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'خصم ${discountPercentage!.toInt()}%',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.right,
                ),
                Text(
                  '- ${(originalPrice - finalPrice).toStringAsFixed(0)} جنيه',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 12),
          const Divider(thickness: 2),
          const SizedBox(height: 12),

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
                '${finalPrice.toStringAsFixed(0)} جنيه',
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

  String _getPackageTitle(String packageKey) {
    switch (packageKey) {
      case 'session':
        return 'السيشن';
      case 'half_day':
        return 'نصف يوم';
      case 'full_day':
        return 'يوم كامل';
      case 'no_print':
        return 'بدون طباعة';
      default:
        return '';
    }
  }

  Widget _buildBookingButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              // Build booking summary data
              final packageTitle = _getPackageTitle(_selectedPackage!);
              final package = _packages[_selectedPackage]![0];
              final optionIndex = int.parse(_selectedOption!.split('-')[1]);
              final option = package['options'][optionIndex];
              final price = (option['price'] as int).toDouble();

              // Format date
              final formattedDate = '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}';

              // Show success dialog
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => BookingSuccessDialog(
                  serviceName: _title,
                  date: formattedDate,
                  packageName: packageTitle,
                  selectedOption: option['size'],
                  totalPrice: price,
                ),
              );
            }
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
            'إضافة إلى السلة',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
