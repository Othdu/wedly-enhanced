import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/di/injection_container.dart';
import '../../../data/models/service_model.dart';
import '../../../data/repositories/offer_repository.dart';
import '../../../data/repositories/service_repository.dart';
import '../../../logic/blocs/provider_service/provider_service_bloc.dart';
import '../../../logic/blocs/provider_service/provider_service_event.dart';
import '../../widgets/skeleton_image.dart';

class ProviderEditServiceScreen extends StatefulWidget {
  final ServiceModel service;

  const ProviderEditServiceScreen({super.key, required this.service});

  @override
  State<ProviderEditServiceScreen> createState() =>
      _ProviderEditServiceScreenState();
}

class _ProviderEditServiceScreenState extends State<ProviderEditServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _priceController;
  late TextEditingController _chairsController; // Optional for venue services
  final _morningPriceController = TextEditingController(); // Price for صباحي
  final _eveningPriceController = TextEditingController(); // Price for مسائي
  final _discountController = TextEditingController();

  String? _selectedTimeSlot; // 'morning' or 'evening'
  bool _hasOffer = false;
  DateTime? _offerExpiryDate;

  // OpenStreetMap variables for venue location
  final MapController _mapController = MapController();
  late LatLng _pickedLocation;

  @override
  void initState() {
    super.initState();
    // Pre-fill form with existing service data
    _priceController = TextEditingController(
      text: widget.service.price?.toString() ?? '0',
    );
    _chairsController = TextEditingController(
      text: widget.service.chairCount?.toString() ?? '',
    );
    // Pre-fill appointment prices from service data
    _morningPriceController.text = widget.service.morningPrice?.toString() ?? '';
    _eveningPriceController.text = widget.service.eveningPrice?.toString() ?? '';

    // Pre-fill offer data
    // Only show offer as active if there's actually a discount > 0
    _hasOffer = widget.service.hasOffer && (widget.service.discountPercentage ?? 0) > 0;
    _discountController.text =
        (widget.service.discountPercentage != null && widget.service.discountPercentage! > 0)
            ? widget.service.discountPercentage.toString()
            : '';
    _offerExpiryDate = widget.service.offerExpiryDate;

    // If offer is active but expiry date is missing, fetch it from offers API
    if (_hasOffer && _offerExpiryDate == null) {
      _loadOfferExpiryDate();
    }

    // Initialize location from service data (default to Cairo if not set)
    _pickedLocation = LatLng(
      widget.service.latitude ?? 30.0444,
      widget.service.longitude ?? 31.2357,
    );
  }

  /// Fetch the offer expiry date from the offers API
  Future<void> _loadOfferExpiryDate() async {
    try {
      final offerRepository = getIt<OfferRepository>();
      final offers = await offerRepository.getOffers();
      for (final offer in offers) {
        if (offer.serviceId == widget.service.id && offer.expiryDate != null) {
          if (mounted) {
            setState(() {
              _offerExpiryDate = offer.expiryDate;
            });
          }
          debugPrint('📅 Loaded offer expiry date from offers API: ${offer.expiryDate}');
          return;
        }
      }
      debugPrint('📅 No matching offer found with expiry date for service ${widget.service.id}');
    } catch (e) {
      debugPrint('⚠️ Could not load offer expiry date: $e');
    }
  }

  @override
  void dispose() {
    _priceController.dispose();
    _chairsController.dispose();
    _morningPriceController.dispose();
    _eveningPriceController.dispose();
    _discountController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppBar(
          automaticallyImplyLeading: false,
          elevation: 0,
          backgroundColor: Colors.transparent,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              color: Color(0xFFD4AF37),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
          ),
          title: const Text(
            "تعديل الخدمة",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: Navigator.of(context).pop,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // صور الخدمة - Service Images (Read-only)
            _buildSectionLabel('صور الخدمة'),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildReadOnlyImageDisplay(1),
                const SizedBox(width: 16),
                _buildReadOnlyImageDisplay(0),
              ],
            ),
            const SizedBox(height: 24),

            // اسم الخدمة - Service Name (Read-only)
            _buildSectionLabel('اسم الخدمة'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300, width: 1),
              ),
              child: Text(
                widget.service.name,
                textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 15, color: Colors.black54),
              ),
            ),
            const SizedBox(height: 20),

            // الفئة - Category (Read-only)
            _buildSectionLabel('الفئة'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300, width: 1),
              ),
              child: Text(
                widget.service.category,
                textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 15, color: Colors.black54),
              ),
            ),
            const SizedBox(height: 20),

            // السعر الافتراضي - Default Price
            _buildSectionLabel('السعر الابتدائي'),
            const SizedBox(height: 8),
            _buildNumberField(_priceController),
            const SizedBox(height: 24),

            // المواعيد - Appointments
            _buildSectionLabel('المواعيد'),
            const SizedBox(height: 12),

            // صباحي with price input
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
                  border: Border.all(color: Colors.grey.shade200, width: 1),
                ),
                child: Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    /// -------- زر الراديو --------
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

                    /// -------- خانة السعر --------
                    GestureDetector(
                      onTap: () {
                        // Stop propagation to allow text field interaction
                      },
                      child: SizedBox(
                        width: 140,
                        child: TextFormField(
                          controller: _morningPriceController,
                          textAlign: TextAlign.right,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'السعر',
                            hintStyle: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 13,
                            ),
                            suffixText: 'جنيه',
                            suffixStyle: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                                width: 1,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                                width: 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFFD4AF37),
                                width: 1.5,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'مطلوب';
                            }
                            if (double.tryParse(value) == null) {
                              return 'رقم غير صحيح';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),

                    const SizedBox(width: 16),

                    /// -------- النصوص --------
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
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
                          Text(
                            'من 12 ظهرًا حتى 7 مساءً',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // مسائي with price input
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
                  border: Border.all(color: Colors.grey.shade200, width: 1),
                ),
                child: Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    /// -------- زر الراديو --------
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

                    /// -------- خانة السعر --------
                    GestureDetector(
                      onTap: () {
                        // Stop propagation to allow text field interaction
                      },
                      child: SizedBox(
                        width: 140,
                        child: TextFormField(
                          controller: _eveningPriceController,
                          textAlign: TextAlign.right,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'السعر',
                            hintStyle: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 13,
                            ),
                            suffixText: 'جنيه',
                            suffixStyle: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                                width: 1,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                                width: 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFFD4AF37),
                                width: 1.5,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'مطلوب';
                            }
                            if (double.tryParse(value) == null) {
                              return 'رقم غير صحيح';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),

                    const SizedBox(width: 16),

                    /// -------- النصوص --------
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
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
                          Text(
                            'من 8 مساءً حتى 2 فجرًا',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // عدد الكراسي - Only for venue services (services with chairCount)
            if (widget.service.chairCount != null) ...[
              _buildSectionLabel('عدد الكراسي'),
              const SizedBox(height: 8),
              _buildNumberField(
                _chairsController,
                hintText: 'أدخل عدد الكراسي',
                isOptional: true,
                optionalErrorMessage: 'الرجاء إدخال عدد',
              ),
              const SizedBox(height: 24),

              // الموقع - Location Map
              _buildSectionLabel('الموقع'),
              const SizedBox(height: 12),
              _buildMapWidget(),
              const SizedBox(height: 24),
            ],

            // العرض - Offer Section
            _buildSectionLabel('العرض'),
            const SizedBox(height: 12),
            _buildOfferSection(),
            const SizedBox(height: 32),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'تعديل الخدمة',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFFD4AF37),
        ),
      ),
    );
  }

  Widget _buildReadOnlyImageDisplay(int index) {
    return Container(
      height: 145,
      decoration: BoxDecoration(
        color: const Color(0xFFE8E8E8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: SkeletonImage(
        imageUrl: widget.service.imageUrl, // Same image for both (mock data)
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        borderRadius: BorderRadius.circular(16),
        errorWidget: Center(
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.image_outlined,
              size: 36,
              color: Colors.grey.shade400,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNumberField(
    TextEditingController controller, {
    String? hintText,
    bool isOptional = false,
    String? optionalErrorMessage,
  }) {
    return TextFormField(
      controller: controller,
      textAlign: TextAlign.right,
      keyboardType: TextInputType.number,
      style: const TextStyle(fontSize: 15),
      decoration: InputDecoration(
        hintText: hintText ?? '.........',
        hintStyle: TextStyle(
          color: Colors.grey.shade300,
          fontSize: hintText != null ? 14 : 18,
          letterSpacing: hintText != null ? 0 : 3,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD4AF37), width: 2),
        ),
      ),
      validator: (value) {
        // Skip validation if optional and empty
        if (isOptional && (value == null || value.isEmpty)) {
          return null;
        }

        if (value == null || value.isEmpty) {
          return optionalErrorMessage ?? 'الرجاء إدخال السعر';
        }
        if (double.tryParse(value) == null) {
          return 'الرجاء إدخال رقم صحيح';
        }
        return null;
      },
    );
  }

  Widget _buildMapWidget() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // OpenStreetMap
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _pickedLocation,
                initialZoom: 14.0,
                minZoom: 5.0,
                maxZoom: 18.0,
                onTap: (tapPosition, point) {
                  setState(() {
                    _pickedLocation = point;
                  });
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.wedlyapp.services',
                  tileProvider: NetworkTileProvider(),
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _pickedLocation,
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
            ),
            // Instructions overlay
            Positioned(
              top: 10,
              right: 10,
              left: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'اضغط على الخريطة لتعديل الموقع',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            // Current location info
            Positioned(
              bottom: 10,
              right: 10,
              left: 10,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'الموقع: ${_pickedLocation.latitude.toStringAsFixed(5)}, ${_pickedLocation.longitude.toStringAsFixed(5)}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfferSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Enable/Disable Offer Toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Switch(
                value: _hasOffer,
                onChanged: (value) {
                  setState(() {
                    _hasOffer = value;
                  });
                },
                activeTrackColor: const Color(0xFFD4AF37),
                activeThumbColor: Colors.white,
              ),
              const Text(
                'تفعيل العرض',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),

          if (_hasOffer) ...[
            const SizedBox(height: 16),

            // Discount Percentage
            const Align(
              alignment: Alignment.centerRight,
              child: Text(
                'نسبة الخصم (%)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _discountController,
              textAlign: TextAlign.right,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 15),
              decoration: InputDecoration(
                hintText: 'مثال: 10',
                hintStyle: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 14,
                ),
                suffixText: '%',
                suffixStyle: const TextStyle(
                  color: Color(0xFFD4AF37),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: Color(0xFFD4AF37),
                    width: 2,
                  ),
                ),
              ),
              validator: (value) {
                if (_hasOffer && (value == null || value.isEmpty)) {
                  return 'الرجاء إدخال نسبة الخصم';
                }
                if (_hasOffer && value != null && double.tryParse(value) == null) {
                  return 'الرجاء إدخال رقم صحيح';
                }
                if (_hasOffer && value != null) {
                  final discount = double.parse(value);
                  if (discount < 0 || discount > 100) {
                    return 'النسبة يجب أن تكون بين 0 و 100';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Offer Expiry Date
            const Align(
              alignment: Alignment.centerRight,
              child: Text(
                'تاريخ انتهاء العرض',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _offerExpiryDate ?? DateTime.now().add(const Duration(days: 7)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.light(
                          primary: Color(0xFFD4AF37),
                          onPrimary: Colors.white,
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (date != null) {
                  setState(() {
                    _offerExpiryDate = date;
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.grey.shade300,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      color: Color(0xFFD4AF37),
                      size: 20,
                    ),
                    Text(
                      _offerExpiryDate != null
                          ? '${_offerExpiryDate!.year}/${_offerExpiryDate!.month}/${_offerExpiryDate!.day}'
                          : 'اختر التاريخ',
                      style: TextStyle(
                        fontSize: 15,
                        color: _offerExpiryDate != null
                            ? Colors.black87
                            : Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      // Validate offer fields if offer is enabled
      if (_hasOffer && _offerExpiryDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('الرجاء تحديد تاريخ انتهاء العرض'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (!mounted) return;

      // Create updated service model with new data (offers handled separately via API)
      final updatedService = widget.service.copyWith(
        price: double.tryParse(_priceController.text),
        morningPrice: _morningPriceController.text.isNotEmpty
            ? double.tryParse(_morningPriceController.text)
            : null,
        eveningPrice: _eveningPriceController.text.isNotEmpty
            ? double.tryParse(_eveningPriceController.text)
            : null,
        chairCount: _chairsController.text.isNotEmpty
            ? int.tryParse(_chairsController.text)
            : null,
        latitude: widget.service.chairCount != null ? _pickedLocation.latitude : null,
        longitude: widget.service.chairCount != null ? _pickedLocation.longitude : null,
        hasOffer: _hasOffer,
        isPendingApproval: false, // Updates are instant, no approval needed
      );

      // Handle offer via separate API calls
      final serviceRepository = getIt<ServiceRepository>();
      if (_hasOffer && _discountController.text.isNotEmpty && _offerExpiryDate != null) {
        // Submit/update offer
        try {
          await serviceRepository.submitServiceOffer(
            serviceId: widget.service.id,
            discountPercentage: double.parse(_discountController.text),
            offerExpiryDate: _offerExpiryDate!,
          );
          debugPrint('✅ Offer submitted successfully for service ${widget.service.id}');
        } catch (e) {
          debugPrint('❌ Error submitting offer: $e');
        }
      } else if (!_hasOffer && widget.service.hasOffer) {
        // Offer was turned OFF - remove it via API (sets discount to 0 AND deletes offer record)
        try {
          await serviceRepository.removeServiceOffer(widget.service.id);
          debugPrint('✅ Offer removed for service ${widget.service.id}');
        } catch (e) {
          debugPrint('❌ Error removing offer: $e');
        }
      }

      // Dispatch UpdateService event to BLoC
      if (mounted) {
        context.read<ProviderServiceBloc>().add(UpdateService(updatedService));
      }

      // Show success dialog
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: const EdgeInsets.all(40),
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
                'تم تحديث الخدمة بنجاح',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'تم حفظ جميع التعديلات وتحديث بيانات الخدمة',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      );

      // Wait 2 seconds before closing
      await Future.delayed(const Duration(seconds: 2));

      // Close dialog and navigate back if still mounted
      if (mounted) {
        Navigator.of(context).pop(); // Close dialog
        if (mounted) {
          Navigator.of(context).pop(true); // Go back to services with success flag
        }
      }
    }
  }
}
