import 'package:flutter/material.dart';
import 'package:wedly/data/models/service_model.dart';
import 'package:wedly/presentation/widgets/booking_success_dialog.dart';

/// Makeup artist booking screen with date selection and personal info
/// Shows service details, allows date selection and collects user information
class MakeupArtistBookingScreen extends StatefulWidget {
  final ServiceModel service;

  const MakeupArtistBookingScreen({super.key, required this.service});

  @override
  State<MakeupArtistBookingScreen> createState() =>
      _MakeupArtistBookingScreenState();
}

class _MakeupArtistBookingScreenState extends State<MakeupArtistBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  DateTime? _selectedDate;
  DateTime _displayedMonth = DateTime.now();

  // Selected additions (optional extras)
  final Set<String> _selectedAdditions = {};

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // Static package data for makeup artist
  static const Map<String, Map<String, dynamic>> _packages = {
    'details': {
      'title': 'تفاصيل الباقة',
      'items': [
        'نوع الخدمة : تجهيز ومكياج عرائس كامل',
        'الخدمات المتاحة : مكياج - تسريحة شعر',
      ],
    },
    'styles': {
      'title': 'الستايلات المتوفرة',
      'items': [
        'Soft Glam',
        'Classic Look',
        'Natural Glow',
        'Full Bridal Look',
      ],
    },
    'components': {
      'title': 'المكونات',
      'items': [
        'مكياج كامل للوجه',
        'تسريحة شعر حسب الاختيار',
        'تركيب رموش + تثبيت نهائي',
        'رفة فاونديشن للجسم (اختياري)',
        'جلسة تجريبية قبل يوم الفرح',
      ],
    },
    'price': {
      'title': 'السعر',
      'items': ['السعر يبدأ من 2,500 جنيه', 'يشمل: مكياج + شعر + مثبت + رموش'],
    },
    'additions': {
      'title': 'الإضافات',
      'items': [
        'خدمة منزلية (Home Service)',
        'عناية بالبشرة قبل الإيفانت',
        'جلسة تصوير خاصة أثناء التحضير',
      ],
    },
    'timing': {
      'title': 'الوقت والتجهيز',
      'items': [
        'مدة الجلسة: 2 - 3 ساعات',
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
          // App Bar with makeup artist image
          _buildSliverAppBar(context),

          // Content
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),

                // Makeup artist name badge
                _buildMakeupArtistBadge(),

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
              widget.service.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.face, size: 80, color: Colors.grey),
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

  Widget _buildMakeupArtistBadge() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
      decoration: BoxDecoration(
        color: const Color(0xFFD4AF37),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Text(
        widget.service.name,
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
        _buildPackageCard('styles', isInteractive: false),
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
    const double basePrice = 2500.0;
    const Map<String, double> additionPrices = {
      'خدمة منزلية (Home Service)': 300.0,
      'عناية بالبشرة قبل الإيفانت': 500.0,
      'جلسة تصوير خاصة أثناء التحضير': 800.0,
    };

    // Calculate total from selected additions
    double additionsTotal = 0.0;
    for (final addition in _selectedAdditions) {
      additionsTotal += additionPrices[addition] ?? 0.0;
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
            textAlign: TextAlign.left,
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
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 8),
            ..._selectedAdditions.map((addition) {
              final price = additionPrices[addition] ?? 0.0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      addition,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),

                    Expanded(
                      child: Text(
                        '+${price.toStringAsFixed(0)} جنيه',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),

                        textAlign: TextAlign.left,
                      ),
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
              Text(
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
              // Build additions list
              final List<String> additionsList = [];
              if (_selectedAdditions.isNotEmpty) {
                additionsList.addAll(_selectedAdditions.map((key) {
                  final parts = key.split('-');
                  final packageKey = parts[0];
                  final index = int.parse(parts[1]);
                  final items = _packages[packageKey]!['items'] as List<dynamic>;
                  return items[index].toString();
                }));
              }

              // Calculate total price
              const double basePrice = 2500.0;
              const Map<String, double> additionPrices = {
                'خدمة منزلية (Home Service)': 300.0,
                'عناية بالبشرة قبل الإيفانت': 500.0,
                'جلسة تصوير خاصة أثناء التحضير': 800.0,
              };

              double additionsTotal = 0.0;
              for (final addition in _selectedAdditions) {
                final parts = addition.split('-');
                if (parts.length == 2) {
                  final packageKey = parts[0];
                  final index = int.parse(parts[1]);
                  if (packageKey == 'additions') {
                    final items = _packages['additions']!['items'] as List<dynamic>;
                    final additionText = items[index].toString();
                    additionsTotal += additionPrices[additionText] ?? 0.0;
                  }
                }
              }
              final double totalPrice = basePrice + additionsTotal;

              // Format date
              final formattedDate = '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}';

              // Show success dialog
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => BookingSuccessDialog(
                  serviceName: widget.service.name,
                  date: formattedDate,
                  additions: additionsList.isNotEmpty ? additionsList : null,
                  totalPrice: totalPrice,
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