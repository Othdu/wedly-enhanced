import 'package:flutter/material.dart';
import 'package:wedly/data/models/service_model.dart';
import 'package:wedly/data/models/offer_model.dart';

/// Wedding planner booking screen with date selection and personal info
/// Shows service details, allows date selection and collects user information
/// Can accept either a service or an offer
class WeddingPlannerBookingScreen extends StatefulWidget {
  final ServiceModel? service;
  final OfferModel? offer;

  const WeddingPlannerBookingScreen({
    super.key,
    this.service,
    this.offer,
  }) : assert(service != null || offer != null,
            'Either service or offer must be provided');

  @override
  State<WeddingPlannerBookingScreen> createState() =>
      _WeddingPlannerBookingScreenState();
}

class _WeddingPlannerBookingScreenState
    extends State<WeddingPlannerBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  DateTime? _selectedDate;
  DateTime _displayedMonth = DateTime.now();

  // Selected additions (optional extras)
  final Set<String> _selectedAdditions = {};

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

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // Static package data for wedding planner
  static const Map<String, Map<String, dynamic>> _packages = {
    'details': {
      'title': 'تفاصيل الباقة',
      'items': [
        'نوع الخدمة : تنظيم وتنسيق حفلات زفاف كاملة',
        'الخدمات المتاحة : تنظيم - تنسيق - إدارة',
      ],
    },
    'services': {
      'title': 'الخدمات المتاحة',
      'items': [
        'تنسيق حفلات زفاف كاملة',
        'إدارة يوم الفرح بالكامل',
        'تنسيق مع الموردين والمكياج والموسيقى',
        'إعداد جدول الحفل والبرنامج الزمني',
      ],
    },
    'components': {
      'title': 'المكونات',
      'items': [
        'اجتماعات تخطيط شاملة',
        'إدارة الميزانية والمصاريف',
        'حجز وتنسيق جميع الموردين',
        'تصميم ثيمات وديكورات مخصصة',
        'إدارة قائمة الضيوف والدعوات',
        'إشراف كامل يوم الحفل',
      ],
    },
    'price': {
      'title': 'السعر',
      'items': [
        'السعر يبدأ من 9,000 جنيه',
        'يشمل: إدارة + تنظيم + تنسيق + إشراف فريق العمل',
      ],
    },
    'additions': {
      'title': 'الإضافات',
      'items': [
        'ديكور خاص',
        'خدمة ضيافة',
        'جلسة تصوير قبل الحدث',
        'تجهيز كوشة مخصصة',
      ],
    },
    'timing': {
      'title': 'الوقت والتجهيز',
      'items': [
        'مدة التخطيط: من أسبوع إلى شهر',
        'مدة التغطية: حتى نهاية الحفل',
        'الحجز المسبق: قبل الموعد بـ 3 أيام على الأقل',
      ],
    },
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: CustomScrollView(
        slivers: [
          // App Bar with wedding planner image
          _buildSliverAppBar(context),

          // Content
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),

                // Wedding planner name badge
                _buildWeddingPlannerBadge(),

                const SizedBox(height: 24),

                // Package sections
                _buildPackagesSection(),

                const SizedBox(height: 24),

                // Calendar Section
                _buildCalendarSection(),
                const SizedBox(height: 24),

                // Personal Information Form (shown after date selection)
                if (_selectedDate != null) ...[
                  _buildPersonalInfoSection(),
                  const SizedBox(height: 24),
                ],

                // Booking Button (shown after date selection)
                if (_selectedDate != null) ...[
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
              _imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.event_note,
                      size: 80, color: Colors.grey),
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

  Widget _buildWeddingPlannerBadge() {
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
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildPackagesSection() {
    return Column(
      children: [
        _buildPackageCard('details', isInteractive: false),
        const SizedBox(height: 16),
        _buildPackageCard('services', isInteractive: false),
        const SizedBox(height: 16),
        _buildPackageCard('components', isInteractive: false),
        const SizedBox(height: 16),
        _buildPackageCard('price', isInteractive: false),
        const SizedBox(height: 16),
        _buildPackageCard('additions', isInteractive: true),
        const SizedBox(height: 16),
        _buildPackageCard('timing', isInteractive: false),
      ],
    );
  }

  Widget _buildPackageCard(String packageKey, {required bool isInteractive}) {
    final package = _packages[packageKey]!;
    final items = package['items'] as List<dynamic>;

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
          // Package title
          Text(
            package['title'] as String,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFFD4AF37),
            ),
            textAlign: TextAlign.right,
          ),

          const SizedBox(height: 16),

          // Items with bullet points or checkboxes
          ...items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final itemKey = '$packageKey-$index';
            final isSelected = _selectedAdditions.contains(itemKey);

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: isInteractive
                  ? GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedAdditions.remove(itemKey);
                          } else {
                            _selectedAdditions.add(itemKey);
                          }
                        });
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Checkbox for interactive items
                          Container(
                            width: 20,
                            height: 20,
                            margin: const EdgeInsets.only(top: 2),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFFD4AF37)
                                  : Colors.grey[10],
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
                            child: Text(
                              item.toString(),
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
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Static bullet point for non-interactive items
                        Container(
                          width: 20,
                          height: 20,
                          margin: const EdgeInsets.only(top: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item.toString(),
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.black87,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
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
            children: [
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
      final isSelected = _selectedDate != null &&
          _selectedDate!.year == date.year &&
          _selectedDate!.month == date.month &&
          _selectedDate!.day == date.day;

      final isToday = DateTime.now().year == date.year &&
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
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFFD4AF37),
              ),
              textAlign: TextAlign.right,
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
    // TODO: Replace with actual prices from API
    const double basePrice = 9000.0;
    const Map<String, double> additionPrices = {
      'ديكور خاص': 1500.0,
      'خدمة ضيافة': 2000.0,
      'جلسة تصوير قبل الحدث': 1000.0,
      'تجهيز كوشة مخصصة': 1800.0,
    };

    // Calculate total from selected additions
    double additionsTotal = 0.0;
    for (final additionKey in _selectedAdditions) {
      // Extract the item text from the package
      final parts = additionKey.split('-');
      if (parts.length == 2) {
        final packageKey = parts[0];
        final index = int.tryParse(parts[1]) ?? -1;
        if (packageKey == 'additions' && index >= 0) {
          final items = _packages['additions']!['items'] as List<dynamic>;
          if (index < items.length) {
            final itemText = items[index] as String;
            additionsTotal += additionPrices[itemText] ?? 0.0;
          }
        }
      }
    }

    final double totalPrice = basePrice + additionsTotal;

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

          // Base price
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'السعر الأساسي',
                style: TextStyle(fontSize: 15, color: Colors.black87),
                textAlign: TextAlign.right,
              ),
              Text(
                '${basePrice.toStringAsFixed(0)} جنيه',
                style: const TextStyle(fontSize: 15, color: Colors.black87),
              ),
            ],
          ),

          // Selected additions
          if (_selectedAdditions.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            const Text(
              'الإضافات المختارة:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 8),
            ..._selectedAdditions.map((additionKey) {
              // Extract the item text from the package
              final parts = additionKey.split('-');
              String itemText = '';
              double price = 0.0;

              if (parts.length == 2) {
                final packageKey = parts[0];
                final index = int.tryParse(parts[1]) ?? -1;
                if (packageKey == 'additions' && index >= 0) {
                  final items = _packages['additions']!['items'] as List<dynamic>;
                  if (index < items.length) {
                    itemText = items[index] as String;
                    price = additionPrices[itemText] ?? 0.0;
                  }
                }
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        itemText,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                    Text(
                      '+${price.toStringAsFixed(0)} جنيه',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
              );
            }),
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

  Widget _buildBookingButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              // Build additions text
              final List<String> additionTexts = [];
              for (final additionKey in _selectedAdditions) {
                final parts = additionKey.split('-');
                if (parts.length == 2) {
                  final packageKey = parts[0];
                  final index = int.tryParse(parts[1]) ?? -1;
                  if (packageKey == 'additions' && index >= 0) {
                    final items =
                        _packages['additions']!['items'] as List<dynamic>;
                    if (index < items.length) {
                      additionTexts.add(items[index] as String);
                    }
                  }
                }
              }

              final additionsText = additionTexts.isEmpty
                  ? ''
                  : '\nالإضافات: ${additionTexts.join('، ')}';

              // TODO: Implement booking functionality
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'تم حجز موعد في ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}$additionsText',
                  ),
                  duration: const Duration(seconds: 3),
                  backgroundColor: const Color(0xFFD4AF37),
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
            'تأكيد الحجز',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
