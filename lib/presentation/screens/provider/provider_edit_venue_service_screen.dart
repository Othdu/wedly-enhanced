import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../data/models/service_model.dart';
import '../../../data/repositories/category_repository.dart';
import '../../../data/repositories/offer_repository.dart';
import '../../../data/repositories/service_repository.dart';
import '../../../logic/blocs/provider_service/provider_service_bloc.dart';
import '../../../logic/blocs/provider_service/provider_service_event.dart';
import '../../../logic/blocs/provider_service/provider_service_state.dart';
import '../../../core/utils/category_helper.dart';
import '../../../core/di/injection_container.dart';
import '../../widgets/skeleton_image.dart';

class ProviderEditVenueServiceScreen extends StatefulWidget {
  final ServiceModel service;

  const ProviderEditVenueServiceScreen({super.key, required this.service});

  @override
  State<ProviderEditVenueServiceScreen> createState() =>
      _ProviderEditVenueServiceScreenState();
}

class _ProviderEditVenueServiceScreenState
    extends State<ProviderEditVenueServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _chairsController;
  final _morningPriceController = TextEditingController();
  final _eveningPriceController = TextEditingController();
  final _discountController = TextEditingController();

  bool _hasOffer = false;
  DateTime? _offerExpiryDate;

  // OpenStreetMap variables
  final MapController _mapController = MapController();
  late LatLng _pickedLocation;

  @override
  void initState() {
    super.initState();
    // Pre-fill form with existing service data
    _chairsController = TextEditingController(
      text: widget.service.chairCount?.toString() ?? '',
    );
    _morningPriceController.text =
        widget.service.morningPrice?.toString() ?? '';
    _eveningPriceController.text =
        widget.service.eveningPrice?.toString() ?? '';

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

    // Load categories for display
    _loadCategories();
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

  Future<void> _loadCategories() async {
    final categoryRepository = getIt<CategoryRepository>();
    await CategoryHelper.loadCategories(categoryRepository);
    if (mounted) {
      setState(() {}); // Refresh UI after categories are loaded
    }
  }

  @override
  void dispose() {
    _chairsController.dispose();
    _morningPriceController.dispose();
    _eveningPriceController.dispose();
    _discountController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProviderServiceBloc, ProviderServiceState>(
      listener: (context, state) {
        if (state is ServiceUpdated) {
          // Show success dialog
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: Color(0xFFD4AF37),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle_rounded,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'تم تحديث القاعة بنجاح',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'تم حفظ جميع التعديلات وتحديث بيانات القاعة',
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
            ),
          );
          // Close dialog and navigate back after 2 seconds
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              Navigator.of(context).pop(); // Close dialog
              if (mounted) {
                Navigator.of(context).pop(true); // Go back to services
              }
            }
          });
        } else if (state is ProviderServiceError) {
          // Show error dialog
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
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
            "تعديل القاعة",
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
            // صورة القاعة
            _buildSectionLabel('صورة القاعة'),
            const SizedBox(height: 12),
            _buildReadOnlyImageDisplay(0),
            const SizedBox(height: 24),

            // اسم القاعة
            _buildSectionLabel('اسم القاعة'),
            const SizedBox(height: 8),
            _buildReadOnlyField(widget.service.name),
            const SizedBox(height: 20),

            // الفئة
            _buildSectionLabel('الفئة'),
            const SizedBox(height: 8),
            _buildReadOnlyField(CategoryHelper.getCategoryArabicName(widget.service.category)),
            const SizedBox(height: 20),

            // المواعيد
            _buildSectionLabel('المواعيد'),
            const SizedBox(height: 12),
            _buildTimeSlotCard('morning', 'صباحي', 'من 12 ظهرًا حتى 7 مساءً',
                _morningPriceController),
            const SizedBox(height: 12),
            _buildTimeSlotCard('evening', 'مسائي', 'من 8 مساءً حتى 2 فجرًا',
                _eveningPriceController),
            const SizedBox(height: 24),

            // عدد الكراسي
            _buildSectionLabel('عدد الكراسي'),
            const SizedBox(height: 8),
            _buildNumberField(
              _chairsController,
              hintText: 'أدخل عدد الكراسي',
              isOptional: false,
            ),
            const SizedBox(height: 24),

            // الموقع - Location Map
            _buildSectionLabel('الموقع'),
            const SizedBox(height: 12),
            _buildMapWidget(),
            const SizedBox(height: 24),

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
                  'تعديل القاعة',
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
        imageUrl: widget.service.imageUrl,
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

  Widget _buildReadOnlyField(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Text(
        text,
        textAlign: TextAlign.right,
        style: const TextStyle(fontSize: 15, color: Colors.black54),
      ),
    );
  }

  Widget _buildNumberField(
    TextEditingController controller, {
    String? hintText,
    bool isOptional = false,
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
        if (isOptional && (value == null || value.isEmpty)) {
          return null;
        }
        if (value == null || value.isEmpty) {
          return 'الرجاء إدخال القيمة';
        }
        if (double.tryParse(value) == null) {
          return 'الرجاء إدخال رقم صحيح';
        }
        return null;
      },
    );
  }

  Widget _buildTimeSlotCard(
    String slot,
    String title,
    String subtitle,
    TextEditingController controller,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          // Price field
          SizedBox(
            width: 160,
            child: TextFormField(
              controller: controller,
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
          const SizedBox(width: 16),
          // Text labels
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Enable/Disable Offer Toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              
              const Text(
                'تفعيل العرض',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),Switch(
                value: _hasOffer,
                onChanged: (value) {
                  setState(() {
                    _hasOffer = value;
                  });
                },
                activeTrackColor: const Color(0xFFD4AF37),
                activeThumbColor: Colors.white,
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
                  initialDate: _offerExpiryDate ??
                      DateTime.now().add(const Duration(days: 7)),
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

      // Create updated service model with venue-specific fields (offers handled separately)
      final updatedService = widget.service.copyWith(
        morningPrice: _morningPriceController.text.isNotEmpty
            ? double.tryParse(_morningPriceController.text)
            : null,
        eveningPrice: _eveningPriceController.text.isNotEmpty
            ? double.tryParse(_eveningPriceController.text)
            : null,
        chairCount: _chairsController.text.isNotEmpty
            ? int.tryParse(_chairsController.text)
            : null,
        latitude: _pickedLocation.latitude,
        longitude: _pickedLocation.longitude,
        hasOffer: _hasOffer,
        isPendingApproval: false, // Updates are instant, no approval needed
      );

      // Handle offer via separate PATCH API
      final serviceRepository = getIt<ServiceRepository>();
      if (_hasOffer && _discountController.text.isNotEmpty && _offerExpiryDate != null) {
        // Submit/update offer
        try {
          await serviceRepository.submitServiceOffer(
            serviceId: widget.service.id,
            discountPercentage: double.parse(_discountController.text),
            offerExpiryDate: _offerExpiryDate!,
          );
          debugPrint('✅ Offer submitted successfully for venue ${widget.service.id}');
        } catch (e) {
          debugPrint('❌ Error submitting offer: $e');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('فشل تقديم العرض: $e'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 5),
              ),
            );
          }
        }
      } else if (!_hasOffer && widget.service.hasOffer) {
        // Offer was turned OFF - remove it via API
        try {
          await serviceRepository.removeServiceOffer(widget.service.id);
          debugPrint('✅ Offer removed for venue ${widget.service.id}');
        } catch (e) {
          debugPrint('❌ Error removing offer: $e');
        }
      }

      // Dispatch UpdateService event to BLoC
      // The BlocListener will handle showing the success dialog
      if (mounted) {
        context.read<ProviderServiceBloc>().add(UpdateService(updatedService));
      }
    }
  }
}
