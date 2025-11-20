import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:wedly/data/models/service_model.dart';
import 'package:wedly/logic/blocs/provider_service/provider_service_bloc.dart';
import 'package:wedly/logic/blocs/provider_service/provider_service_event.dart';
import 'package:wedly/logic/blocs/auth/auth_bloc.dart';
import 'package:wedly/logic/blocs/auth/auth_state.dart';
import 'package:wedly/core/constants/app_constants.dart';

class ProviderAddServiceScreen extends StatefulWidget {
  const ProviderAddServiceScreen({super.key});

  @override
  State<ProviderAddServiceScreen> createState() =>
      _ProviderAddServiceScreenState();
}

class _ProviderAddServiceScreenState extends State<ProviderAddServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _chairsController =
      TextEditingController(); // Optional for venue services
  final _morningPriceController = TextEditingController(); // Price for صباحي
  final _eveningPriceController = TextEditingController(); // Price for مسائي
  final _discountPercentageController = TextEditingController(); // Discount percentage for offers

  final List<File> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();
  bool _isPickingImage = false; // Prevent multiple simultaneous picker calls

  String? _selectedCategory;
  bool _hasOffer = false; // Whether this service has an offer

  // Photography package selection
  String? _selectedPhotographyPackage;
  final Set<String> _selectedPhotographyOptions = {};

  // Car service fields
  final Set<String> _selectedCarAdditions = {};

  // Wedding Dress fields
  final Set<String> _selectedDressStyles = {};

  // Decoration fields
  final Set<String> _selectedDecorationComponents = {};

  // Dynamic sections list (for add/remove functionality)
  final List<Map<String, dynamic>> _customSections = [];

  // Google Maps variables
  LatLng _pickedLocation = const LatLng(
    30.0444,
    31.2357,
  ); // Cairo, Egypt default
  GoogleMapController? _mapController;
  final bool _useGoogleMaps = false; // Set to true when API key is configured

  Future<void> _pickImage() async {
    // Prevent multiple simultaneous calls
    if (_isPickingImage) return;

    if (_selectedImages.length >= 2) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('يمكنك اختيار صورتين فقط')));
      return;
    }

    setState(() {
      _isPickingImage = true;
    });

    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _selectedImages.add(File(image.path));
        });
      }
    } finally {
      setState(() {
        _isPickingImage = false;
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _chairsController.dispose();
    _morningPriceController.dispose();
    _eveningPriceController.dispose();
    _discountPercentageController.dispose();
    _mapController?.dispose();
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
            'اضافة خدمة جديدة',
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
            // رفع الصور - Upload Images Section
            _buildSectionLabel('رفع الصور'),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildImagePicker(1),
                const SizedBox(width: 16),
                _buildImagePicker(0),
              ],
            ),
            const SizedBox(height: 24),

            // اسم الخدمة - Service Name
            _buildSectionLabel('اسم الخدمة'),
            const SizedBox(height: 8),
            _buildTextField(_nameController),
            const SizedBox(height: 20),

            // الفئة - Category Dropdown
            _buildSectionLabel('الفئة'),
            const SizedBox(height: 8),
            _buildCategoryDropdown(),
            const SizedBox(height: 20),

            // السعر الافتراضي - Default Price
            _buildSectionLabel('السعر الافتراضي'),
            const SizedBox(height: 8),
            _buildNumberField(_priceController),
            const SizedBox(height: 24),

            // Dynamic Category-Specific Fields
            ..._buildCategorySpecificFields(),

            // الموقع - Location
            _buildSectionLabel('الموقع'),
            const SizedBox(height: 12),

            // Map container with Google Maps integration
            _buildMapWidget(),
            const SizedBox(height: 32),

            // Offer Section
            _buildSectionLabel('عرض خاص (اختياري)'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Has Offer Checkbox
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text(
                        'هل تريد إضافة عرض خصم على هذه الخدمة؟',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                      const SizedBox(width: 8),
                      Checkbox(
                        value: _hasOffer,
                        onChanged: (value) {
                          setState(() {
                            _hasOffer = value ?? false;
                            if (!_hasOffer) {
                              _discountPercentageController.clear();
                            }
                          });
                        },
                        activeColor: const Color(0xFFD4AF37),
                      ),
                    ],
                  ),

                  // Discount Percentage Field (only shown if hasOffer is true)
                  if (_hasOffer) ...[
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _discountPercentageController,
                      textAlign: TextAlign.right,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'نسبة الخصم',
                        hintText: 'مثال: 20',
                        suffixText: '%',
                        suffixStyle: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.grey.shade300,
                            width: 1,
                          ),
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
                        if (_hasOffer && (value == null || value.isEmpty)) {
                          return 'الرجاء إدخال نسبة الخصم';
                        }
                        if (_hasOffer && value != null && value.isNotEmpty) {
                          final discount = double.tryParse(value);
                          if (discount == null) {
                            return 'رقم غير صحيح';
                          }
                          if (discount <= 0 || discount > 100) {
                            return 'النسبة يجب أن تكون بين 1 و 100';
                          }
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline,
                            color: Colors.blue.shade700,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'العرض يحتاج موافقة الإدارة قبل ظهوره للعملاء',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue.shade700,
                              ),
                              textDirection: TextDirection.rtl,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
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
                  'إضافة الخدمة',
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

  List<Widget> _buildCategorySpecificFields() {
    if (_selectedCategory == null) return [];

    switch (_selectedCategory) {
      case 'قاعات أفراح': // Venues
        return _buildVenueFields();
      case 'التصوير الفوتوغرافي': // Photography
        return _buildPhotographyFields();
      case 'السيارات': // Cars
        return _buildCarFields();
      case 'فساتين الزفاف': // Wedding Dresses
        return _buildWeddingDressFields();
      case 'الديكور': // Decoration
        return _buildDecorationFields();
      case 'مكياج وتجميل': // Beauty/Makeup
        return _buildBeautyFields();
      case 'منظمو الأفراح': // Wedding Planners
        return _buildWeddingPlannerFields();
      case 'الفيديو': // Videography
        return _buildVideographyFields();
      default:
        return _buildDefaultFields();
    }
  }

  // Venue-specific fields (time slots, chair count, decoration options)
  List<Widget> _buildVenueFields() {
    return [
      // المواعيد - Time Slots
      _buildSectionLabel('المواعيد'),
      const SizedBox(height: 12),
      _buildTimeSlotCard('صباحي', 'من 12 ظهرًا حتى 7 مساءً', _morningPriceController),
      const SizedBox(height: 12),
      _buildTimeSlotCard('مسائي', 'من 8 مساءً حتى 2 فجرًا', _eveningPriceController),
      const SizedBox(height: 24),

      // عدد الكراسي - Chair Count
      _buildSectionLabel('عدد الكراسي'),
      const SizedBox(height: 8),
      _buildNumberField(
        _chairsController,
        hintText: 'أدخل عدد الكراسي',
        isOptional: true,
        optionalErrorMessage: 'الرجاء إدخال عدد',
      ),
      const SizedBox(height: 24),
    ];
  }

  // Photography-specific fields (package selection)
  List<Widget> _buildPhotographyFields() {
    return [
      _buildSectionLabel('اختر الباقة'),
      const SizedBox(height: 12),
      _buildPhotographyPackageSelection(),
      const SizedBox(height: 24),
    ];
  }

  // Car-specific fields (car details, additions)
  List<Widget> _buildCarFields() {
    return [
      _buildSectionLabel('الإضافات المتاحة'),
      const SizedBox(height: 12),
      _buildCarAdditionsSelection(),
      const SizedBox(height: 24),
    ];
  }

  // Wedding Dress-specific fields (dress styles)
  List<Widget> _buildWeddingDressFields() {
    return [
      _buildSectionLabel('أنواع الفساتين المتاحة'),
      const SizedBox(height: 12),
      _buildDressStylesSelection(),
      const SizedBox(height: 24),
    ];
  }

  // Decoration-specific fields (decoration components)
  List<Widget> _buildDecorationFields() {
    return [
      _buildSectionLabel('المكونات المتاحة'),
      const SizedBox(height: 12),
      _buildDecorationComponentsSelection(),
      const SizedBox(height: 24),
    ];
  }

  // Beauty/Makeup fields
  List<Widget> _buildBeautyFields() {
    return _buildDefaultFields();
  }

  // Wedding Planner fields
  List<Widget> _buildWeddingPlannerFields() {
    return _buildDefaultFields();
  }

  // Videography fields
  List<Widget> _buildVideographyFields() {
    return _buildDefaultFields();
  }

  // Default fields for categories without specific requirements
  List<Widget> _buildDefaultFields() {
    return [
      const SizedBox(height: 0), // Empty placeholder
    ];
  }

  Widget _buildTimeSlotCard(String title, String timeRange, TextEditingController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          SizedBox(
            width: 140,
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
                if (_selectedCategory == 'قاعات أفراح' && (value == null || value.isEmpty)) {
                  return 'مطلوب';
                }
                if (value != null && value.isNotEmpty && double.tryParse(value) == null) {
                  return 'رقم غير صحيح';
                }
                return null;
              },
            ),
          ),
          const SizedBox(width: 16),
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
                  timeRange,
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

  Widget _buildPhotographyPackageSelection() {
    const packages = [
      {'title': 'جلسة', 'description': 'جلسة تصوير قصيرة (1-2 ساعة)'},
      {'title': 'نصف يوم', 'description': 'تغطية نصف الحفل (4-5 ساعات)'},
      {'title': 'يوم كامل', 'description': 'تغطية كاملة من البداية للنهاية'},
      {'title': 'بدون طباعة', 'description': 'نسخة رقمية فقط'},
    ];

    return Column(
      children: [
        ...packages.map((package) {
          final isSelected = _selectedPhotographyPackage == package['title'];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedPhotographyPackage = package['title'];
                });
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFD4AF37).withValues(alpha: 0.1) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? const Color(0xFFD4AF37) : Colors.grey.shade200,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected ? const Color(0xFFD4AF37) : Colors.white,
                        border: Border.all(
                          color: isSelected ? const Color(0xFFD4AF37) : Colors.grey.shade300,
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, size: 16, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            package['title']!,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? const Color(0xFFD4AF37) : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            package['description']!,
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
          );
        }),
      ],
    );
  }

  Widget _buildCarAdditionsSelection() {
    const additions = [
      'تزيين فاخر للسيارة',
      'سائق إضافي احتياطي',
      'خدمة التصوير الفوتوغرافي',
      'باقة ورد داخل السيارة',
    ];

    return Column(
      children: additions.map((addition) {
        final isSelected = _selectedCarAdditions.contains(addition);
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: GestureDetector(
            onTap: () {
              setState(() {
                if (isSelected) {
                  _selectedCarAdditions.remove(addition);
                } else {
                  _selectedCarAdditions.add(addition);
                }
              });
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200, width: 1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: Text(
                      addition,
                      style: TextStyle(
                        fontSize: 15,
                        color: isSelected ? Colors.black87 : Colors.black54,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFD4AF37) : Colors.white,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: isSelected ? const Color(0xFFD4AF37) : Colors.grey.shade300,
                        width: 1.5,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, size: 14, color: Colors.white)
                        : null,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDressStylesSelection() {
    const styles = [
      'فساتين الأميرات',
      'فساتين حورية البحر',
      'فساتين مستقيمة (Sheath)',
      'فساتين خصر عالي (Empire)',
      'فساتين قصيرة',
    ];

    return Column(
      children: styles.map((style) {
        final isSelected = _selectedDressStyles.contains(style);
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: GestureDetector(
            onTap: () {
              setState(() {
                if (isSelected) {
                  _selectedDressStyles.remove(style);
                } else {
                  _selectedDressStyles.add(style);
                }
              });
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200, width: 1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: Text(
                      style,
                      style: TextStyle(
                        fontSize: 15,
                        color: isSelected ? Colors.black87 : Colors.black54,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFD4AF37) : Colors.white,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: isSelected ? const Color(0xFFD4AF37) : Colors.grey.shade300,
                        width: 1.5,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, size: 14, color: Colors.white)
                        : null,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDecorationComponentsSelection() {
    const components = [
      'ديكور كامل للمنصة',
      'تنسيق الكراسي والطاولات',
      'إضاءة احترافية',
      'ورد طبيعي + تنسيق إضافي',
      'خلفية مصممة (Backdrop)',
      'ديكور طاولات',
      'ضيافة بسيطة (اختياري)',
    ];

    return Column(
      children: components.map((component) {
        final isSelected = _selectedDecorationComponents.contains(component);
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: GestureDetector(
            onTap: () {
              setState(() {
                if (isSelected) {
                  _selectedDecorationComponents.remove(component);
                } else {
                  _selectedDecorationComponents.add(component);
                }
              });
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200, width: 1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: Text(
                      component,
                      style: TextStyle(
                        fontSize: 15,
                        color: isSelected ? Colors.black87 : Colors.black54,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFD4AF37) : Colors.white,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: isSelected ? const Color(0xFFD4AF37) : Colors.grey.shade300,
                        width: 1.5,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, size: 14, color: Colors.white)
                        : null,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
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

  Widget _buildTextField(TextEditingController controller) {
    return TextFormField(
      controller: controller,
      textAlign: TextAlign.right,
      style: const TextStyle(fontSize: 15),
      decoration: InputDecoration(
        hintText: '.........',
        hintStyle: TextStyle(
          color: Colors.grey.shade300,
          fontSize: 18,
          letterSpacing: 3,
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
        if (!isOptional && (value == null || value.isEmpty)) {
          return 'الرجاء إدخال السعر';
        }
        if (value != null &&
            value.isNotEmpty &&
            double.tryParse(value) == null) {
          return optionalErrorMessage ?? 'الرجاء إدخال رقم صحيح';
        }
        return null;
      },
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      // ignore: deprecated_member_use
      value: _selectedCategory,
      isExpanded: true,
      alignment: Alignment.centerRight,
      decoration: InputDecoration(
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
      hint: Text(
        'اختر الفئة',
        textAlign: TextAlign.right,
        style: TextStyle(color: Colors.grey.shade400, fontSize: 15),
      ),
      icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade600),
      items: AppConstants.serviceCategories.map((String category) {
        return DropdownMenuItem<String>(
          value: category,
          alignment: Alignment.centerRight,
          child: Text(
            category,
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 15),
          ),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedCategory = newValue;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'الرجاء اختيار الفئة';
        }
        return null;
      },
    );
  }

  Widget _buildImagePicker(int index) {
    final hasImage = index < _selectedImages.length;

    return Expanded(
      child: GestureDetector(
        onTap: hasImage ? null : _pickImage,
        child: Container(
          height: 145,
          decoration: BoxDecoration(
            color: const Color(0xFFE8E8E8),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade300, width: 1),
          ),
          child: hasImage
              ? Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(
                        _selectedImages[index],
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 8,
                      left: 8,
                      child: GestureDetector(
                        onTap: () => _removeImage(index),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.red.shade600,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : Center(
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.image_outlined,
                      size: 36,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildMapWidget() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: _useGoogleMaps
            ? Stack(
                children: [
                  GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: _pickedLocation,
                      zoom: 14,
                    ),
                    onMapCreated: (controller) {
                      _mapController = controller;
                    },
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    onCameraMove: (position) {
                      setState(() {
                        _pickedLocation = position.target;
                      });
                    },
                    onTap: (LatLng location) {
                      setState(() {
                        _pickedLocation = location;
                      });
                    },
                  ),
                  // Center pin marker
                  const Center(
                    child: Icon(Icons.location_on, size: 40, color: Colors.red),
                  ),
                  // Confirm button
                  Positioned(
                    bottom: 10,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'تم اختيار الموقع: ${_pickedLocation.latitude.toStringAsFixed(4)}, ${_pickedLocation.longitude.toStringAsFixed(4)}',
                                textAlign: TextAlign.right,
                              ),
                              backgroundColor: const Color(0xFFD4AF37),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD4AF37),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                        icon: const Icon(Icons.check, size: 20),
                        label: const Text(
                          'تأكيد الموقع',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : _buildMapPlaceholder(),
      ),
    );
  }

  Widget _buildMapPlaceholder() {
    return Stack(
      children: [
        Container(
          color: const Color(0xFFF5F5F5),
          child: Center(
            child: Icon(
              Icons.map_outlined,
              size: 60,
              color: Colors.grey.shade400,
            ),
          ),
        ),
        const Center(
          child: Icon(Icons.location_on, size: 36, color: Colors.red),
        ),
        Positioned(
          bottom: 10,
          left: 0,
          right: 0,
          child: Center(
            child: Text(
              'تكامل خرائط جوجل غير متاح',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }

  void _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      // Get current user (provider) ID from AuthBloc
      final authState = context.read<AuthBloc>().state;
      if (authState is! AuthAuthenticated) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('خطأ: يجب تسجيل الدخول أولاً')),
        );
        return;
      }

      // Create service model with form data
      final newService = ServiceModel(
        id: '', // Will be generated by backend/repository
        name: _nameController.text.trim(),
        description:
            'خدمة ${_nameController.text.trim()}', // TODO: Add description field to form
        imageUrl: '', // Will be set after image upload to backend
        price: double.tryParse(_priceController.text),
        category: _selectedCategory!,
        providerId: authState.user.id,
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
        isActive: true,
        isPendingApproval:
            false, // New services are immediately active (no approval needed for creation)
        // Offer fields
        hasOffer: _hasOffer,
        discountPercentage: _hasOffer && _discountPercentageController.text.isNotEmpty
            ? double.tryParse(_discountPercentageController.text)
            : null,
        offerApproved: false, // Offers need admin approval
        // TODO: Upload images to backend and get URLs
        // imageUrls: await _uploadImages(_selectedImages),
      );

      // Dispatch AddService event to BLoC
      context.read<ProviderServiceBloc>().add(AddService(newService));

      // Show success dialog
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
                'تم إضافة الخدمة بنجاح',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'ستظهر الخدمة في قائمة خدماتك وللعملاء',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.black54),
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
        if (context.mounted) {
          Navigator.of(
            context,
          ).pop(true); // Go back to services with success flag
        }
      }
    }
  }
}
