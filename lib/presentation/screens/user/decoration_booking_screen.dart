import 'package:flutter/material.dart';
import 'package:wedly/data/models/service_model.dart';
import 'package:wedly/data/models/offer_model.dart';

/// Decoration booking screen with date selection and personal info
/// Shows service details, allows date selection and collects user information
/// Can accept either a service or an offer
class DecorationBookingScreen extends StatefulWidget {
  final ServiceModel? service;
  final OfferModel? offer;

  const DecorationBookingScreen({
    super.key,
    this.service,
    this.offer,
  }) : assert(service != null || offer != null,
            'Either service or offer must be provided');

  @override
  State<DecorationBookingScreen> createState() =>
      _DecorationBookingScreenState();
}

class _DecorationBookingScreenState extends State<DecorationBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  DateTime? _selectedDate;
  DateTime _displayedMonth = DateTime.now();

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

  // Static package data for decoration
  static const Map<String, Map<String, dynamic>> _packages = {
    'details': {
      'title': 'تفاصيل الباقة',
      'items': [
        'نوع الخدمة: ديكور قاعة الفرح',
        'الخدمات المتاحة: ديكور - زينة - إضاءة',
      ],
    },
    'styles': {
      'title': 'قاعة البدرام',
      'items': [
        'نوع القاعة: قاعة مكيفة مع ديكور فاخر',
        'السعة: تتسع لعدد كبير من الضيوف',
      ],
    },
    'components': {
      'title': 'المكونات',
      'items': [
        'ديكور كامل للمنصة',
        'تنسيق الكراسي والطاولات',
        'إضاءة احترافية',
        'ورد طبيعي + تنسيق إضافي',
        'خلفية مصممة (Backdrop)',
        'ديكور طاولات',
        'ضيافة بسيطة (اختياري)',
      ],
    },
    'price': {
      'title': 'السعر',
      'items': [
        'السعر يبدأ من 8500 جنيه',
        'يشمل: تركيب + نقل + فك',
        'الإضافات: إضاءة ليزر / كشافات / حروف ضوئية',
      ],
    },
    'timing': {
      'title': 'الوقت والتجهيز',
      'items': [
        'وقت التنفيذ: 3 - 5 ساعات',
        'مدة الحجز: حسب موعد القاعة',
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
          // App Bar with decoration image
          _buildSliverAppBar(context),

          // Content
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),

                // Decoration name badge
                _buildDecorationBadge(),

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
                  child: const Icon(Icons.celebration, size: 80, color: Colors.grey),
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

  Widget _buildDecorationBadge() {
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
        _buildPackageCard('styles', isInteractive: false),
        const SizedBox(height: 16),
        _buildPackageCard('components', isInteractive: false),
        const SizedBox(height: 16),
        _buildPackageCard('price', isInteractive: false),
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

          // Items with bullet points
          ...items.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Static bullet point
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
    const double totalPrice = 8500.0;

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
              // TODO: Implement booking functionality
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'تم حجز موعد في ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
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
