import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:wedly/data/models/service_model.dart';
import 'package:wedly/logic/blocs/auth/auth_bloc.dart';
import 'package:wedly/logic/blocs/auth/auth_state.dart';
import 'package:wedly/data/repositories/service_repository.dart';
import 'package:wedly/data/repositories/category_repository.dart';
import 'package:wedly/data/models/category_model.dart';
import 'package:wedly/core/di/injection_container.dart';
import 'package:wedly/data/services/api_exceptions.dart';

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

  // Venue-specific controllers
  final _chairsController = TextEditingController();
  final _morningPriceController = TextEditingController();
  final _eveningPriceController = TextEditingController();

  final _discountPercentageController = TextEditingController();

  final List<File> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();
  bool _isPickingImage = false;

  String? _selectedCategory;
  bool _hasOffer = false;

  // Category loading state
  List<CategoryModel> _categories = [];
  bool _isCategoriesLoading = true;
  String? _categoriesError;

  // Dynamic sections data structure
  // Each section has: {id, title, type (single/multiple), options: [{text, price}]}
  List<Map<String, dynamic>> _dynamicSections = [];

  // Venue decoration plans (radio button options)
  List<Map<String, dynamic>> _decorationPlans = [];

  // Google Maps variables
  LatLng _pickedLocation = const LatLng(30.0444, 31.2357);
  GoogleMapController? _mapController;
  final bool _useGoogleMaps = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    // Dynamic sections will be initialized when category is selected
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isCategoriesLoading = true;
      _categoriesError = null;
    });

    try {
      final categoryRepository = getIt<CategoryRepository>();
      final categories = await categoryRepository.getCategories();

      setState(() {
        _categories = categories;
        _isCategoriesLoading = false;
      });
    } catch (e) {
      setState(() {
        _isCategoriesLoading = false;
        _categoriesError = 'فشل التحميل. برجاء التحقق من الإنترنت والمحاولة مرة أخرى';
      });
    }
  }

  void _initializeDefaultSections() {
    if (_selectedCategory == null) return;

    print('🔄 Initializing sections for category: $_selectedCategory');

    setState(() {
      _dynamicSections.clear();
      _decorationPlans.clear();

      switch (_selectedCategory) {
        case 'تصوير فوتوغرافي':
          _initializePhotographySections();
          print(
            '✅ Photography sections initialized: ${_dynamicSections.length} sections',
          );
          break;
        case 'كوش وديكور':
          _initializeDecorationSections();
          print(
            '✅ Decoration sections initialized: ${_dynamicSections.length} sections',
          );
          break;
        case 'قاعات أفراح':
          _initializeVenueDecorationPlans();
          print(
            '✅ Venue decoration plans initialized: ${_decorationPlans.length} plans',
          );
          break;
        // For all other categories, use generic dynamic sections
        default:
          // Generic initialization for other categories
          print('ℹ️ Using generic dynamic sections for: $_selectedCategory');
          break;
      }
    });
  }

  void _initializePhotographySections() {
    // Pre-filled photography packages from booking screen
    _dynamicSections = [
      {
        'id': '1',
        'title': 'جلسة',
        'description': 'جلسة تصوير',
        'selectionType': 'single', // single or multiple
        'options': [
          {'text': 'البوم صغير 40×15 + بوستر 70×50 + 50 كارت', 'price': '5000'},
          {'text': 'البوم 45×30', 'price': '5500'},
          {'text': 'البوم 80×30', 'price': '6000'},
        ],
      },
      {
        'id': '2',
        'title': 'نصف يوم',
        'description': 'جلسة (مصورين 2)',
        'selectionType': 'single',
        'options': [
          {'text': 'البوم صغير 40×15 + بوستر 70×50 + 50 كارت', 'price': '7000'},
          {'text': 'البوم 45×30', 'price': '7500'},
          {'text': 'البوم 80×30', 'price': '8000'},
        ],
      },
      {
        'id': '3',
        'title': 'يوم كامل',
        'description': 'تجهيزات الزفاف\nجلسة تصوير\nحفلة (مصورين 2)',
        'selectionType': 'single',
        'options': [
          {'text': 'البوم صغير 40×15 + بوستر 70×50 + 50 كارت', 'price': '8500'},
          {'text': 'البوم 45×30', 'price': '9000'},
          {'text': 'البوم 80×30', 'price': '9500'},
        ],
      },
      {
        'id': '4',
        'title': 'بدون طباعة',
        'description': '',
        'selectionType': 'single',
        'options': [
          {'text': 'جلسة تصوير زفاف  ', 'price': '2800'},
          {'text': 'جلسة خطوبة أو كتب كتاب ', 'price': '2500'},
          {'text': 'حفلة (مصور واحد)  ', 'price': '1800'},
          {'text': 'حفلة (مصورين 2)  ', 'price': '2400'},
        ],
      },
    ];
  }

  void _initializeCarSections() {
    _dynamicSections = [
      {
        'id': '1',
        'title': 'الإضافات',
        'description': 'إضافات السيارة',
        'selectionType': 'multiple',
        'options': [
          {'text': 'تزيين فاخر للسيارة', 'price': '500'},
          {'text': 'سائق إضافي احتياطي', 'price': '300'},
          {'text': 'خدمة التصوير الفوتوغرافي', 'price': '800'},
          {'text': 'باقة ورد داخل السيارة', 'price': '200'},
        ],
      },
    ];
  }

  void _initializeWeddingDressSections() {
    _dynamicSections = [
      {
        'id': '1',
        'title': 'الأنواع المتاحة',
        'description': 'أنواع الفساتين',
        'selectionType': 'multiple',
        'options': [
          {'text': 'فساتين الأميرات', 'price': '0'},
          {'text': 'فساتين حورية البحر', 'price': '0'},
          {'text': 'فساتين مستقيمة (Sheath)', 'price': '0'},
          {'text': 'فساتين خصر عالي (Empire)', 'price': '0'},
          {'text': 'فساتين قصيرة', 'price': '0'},
        ],
      },
    ];
  }

  void _initializeDecorationSections() {
    _dynamicSections = [
      {
        'id': '1',
        'title': 'المكونات',
        'description': 'مكونات الديكور',
        'selectionType': 'multiple',
        'options': [
          {'text': 'ديكور كامل للمنصة', 'price': '0'},
          {'text': 'تنسيق الكراسي والطاولات', 'price': '0'},
          {'text': 'إضاءة احترافية', 'price': '0'},
          {'text': 'ورد طبيعي + تنسيق إضافي', 'price': '0'},
          {'text': 'خلفية مصممة (Backdrop)', 'price': '0'},
          {'text': 'ديكور طاولات', 'price': '0'},
          {'text': 'ضيافة بسيطة (اختياري)', 'price': '0'},
        ],
      },
    ];
  }

  void _initializeVenueDecorationPlans() {
    _decorationPlans = [
      {'text': 'ديكورة 1'},
      {'text': 'ديكورة 2'},
      {'text': 'ديكورة 3'},
      {'text': 'خالي'},
    ];
  }

  Future<void> _pickImage() async {
    if (_isPickingImage) return;
    if (_selectedImages.length >= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يمكنك اختيار صورة واحدة فقط')),
      );
      return;
    }

    setState(() => _isPickingImage = true);

    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() => _selectedImages.add(File(image.path)));
      }
    } finally {
      setState(() => _isPickingImage = false);
    }
  }

  void _removeImage(int index) {
    setState(() => _selectedImages.removeAt(index));
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
            // رفع الصورة - Upload Image Section
            Row(
              children: [
                const Text(
                  '*',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                _buildSectionLabel('رفع الصورة'),
              ],
            ),
            const SizedBox(height: 12),
            _buildImagePicker(0),
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

            // Offer Section
            _buildOfferSection(),
            const SizedBox(height: 32),

            // Submit Button
            _buildSubmitButton(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCategorySpecificFields() {
    if (_selectedCategory == null) {
      print('⚠️ No category selected, returning empty list');
      return [];
    }

    print('🔍 Building category-specific fields for: $_selectedCategory');
    print('🔍 Dynamic sections count: ${_dynamicSections.length}');
    print('🔍 Decoration plans count: ${_decorationPlans.length}');

    switch (_selectedCategory) {
      case 'قاعات أفراح':
        final fields = _buildVenueFields();
        print('✅ Built ${fields.length} venue fields');
        return fields;
      case 'تصوير فوتوغرافي':
      case 'كوش وديكور':
      case 'فرق موسيقية':
      case 'تجميل وميك أب':
      case 'تنظيم حفلات':
      case 'كيك وحلويات':
      case 'دي جي':
        final fields = _buildDynamicSectionFields();
        print('✅ Built ${fields.length} dynamic fields');
        return fields;
      default:
        print('⚠️ Unknown category: $_selectedCategory');
        return [];
    }
  }

  // VENUE FIELDS (Special case - fixed time slots, fixed chairs, dynamic decoration)
  List<Widget> _buildVenueFields() {
    return [
      // المواعيد - Fixed Time Slots with editable prices
      _buildSectionLabel('المواعيد'),
      const SizedBox(height: 12),
      _buildFixedTimeSlot(
        'صباحي',
        'من 12 ظهرًا حتى 7 مساءً',
        _morningPriceController,
      ),
      const SizedBox(height: 12),
      _buildFixedTimeSlot(
        'مسائي',
        'من 8 مساءً حتى 2 فجرًا',
        _eveningPriceController,
      ),
      const SizedBox(height: 24),

      // عدد الكراسي - Fixed Chair Count
      _buildSectionLabel('عدد الكراسي'),
      const SizedBox(height: 8),
      _buildNumberField(
        _chairsController,
        hintText: 'مثال: 400',
        isOptional: false,
      ),
      const SizedBox(height: 24),

      // البلان - Dynamic Decoration Plans with radio buttons
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(
              Icons.add_circle_outline,
              color: Color(0xFFD4AF37),
            ),
            onPressed: _addDecorationPlan,
          ),
          _buildSectionLabel('البلان'),
        ],
      ),
      const SizedBox(height: 12),
      ..._buildDecorationPlansList(),
      const SizedBox(height: 24),

      // الموقع - Location (only for venues)
      _buildSectionLabel('الموقع'),
      const SizedBox(height: 12),
      _buildMapWidget(),
      const SizedBox(height: 24),
    ];
  }

  // DYNAMIC SECTION FIELDS (Photography, Cars, Dresses, Decoration)
  List<Widget> _buildDynamicSectionFields() {
    return [
      // Add Section Button at top
      _buildAddSectionButton(),
      const SizedBox(height: 16),

      // All dynamic sections
      ..._dynamicSections.map((section) => _buildDynamicSection(section)),
    ];
  }

  Widget _buildAddSectionButton() {
    return GestureDetector(
      onTap: _showAddSectionDialog,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFD4AF37).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFD4AF37),
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline, color: Color(0xFFD4AF37), size: 28),
            SizedBox(width: 12),
            Text(
              'إضافة قسم جديد',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFFD4AF37),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDynamicSection(Map<String, dynamic> section) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Section Header with delete button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () => _confirmDeleteSection(section['id']),
              ),
              Expanded(
                child: Text(
                  section['title'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFD4AF37),
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),

          if (section['description'].toString().isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              section['description'],
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              textAlign: TextAlign.right,
            ),
          ],

          const SizedBox(height: 12),

          // Selection Type Toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'نوع الاختيار:',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
              ),
              const SizedBox(width: 12),
              _buildSelectionTypeToggle(section),
            ],
          ),

          const SizedBox(height: 16),

          // Options list
          ...List.generate(
            (section['options'] as List).length,
            (index) => _buildOptionItem(section, index),
          ),

          const SizedBox(height: 8),

          // Add Option Button
          TextButton.icon(
            onPressed: () => _showAddOptionDialog(section['id']),
            icon: const Icon(Icons.add, color: Color(0xFFD4AF37)),
            label: const Text(
              'إضافة خيار',
              style: TextStyle(color: Color(0xFFD4AF37)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionTypeToggle(Map<String, dynamic> section) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              section['selectionType'] = 'single';
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: section['selectionType'] == 'single'
                  ? const Color(0xFFD4AF37)
                  : Colors.grey.shade200,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
            ),
            child: Text(
              'اختيار واحد',
              style: TextStyle(
                fontSize: 12,
                color: section['selectionType'] == 'single'
                    ? Colors.white
                    : Colors.black54,
                fontWeight: section['selectionType'] == 'single'
                    ? FontWeight.w600
                    : FontWeight.normal,
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              section['selectionType'] = 'multiple';
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: section['selectionType'] == 'multiple'
                  ? const Color(0xFFD4AF37)
                  : Colors.grey.shade200,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                bottomLeft: Radius.circular(8),
              ),
            ),
            child: Text(
              'اختيار متعدد',
              style: TextStyle(
                fontSize: 12,
                color: section['selectionType'] == 'multiple'
                    ? Colors.white
                    : Colors.black54,
                fontWeight: section['selectionType'] == 'multiple'
                    ? FontWeight.w600
                    : FontWeight.normal,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOptionItem(Map<String, dynamic> section, int index) {
    final option = (section['options'] as List)[index];
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                onPressed: () => _confirmDeleteOption(section['id'], index),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: Color(0xFFD4AF37), size: 20),
                onPressed: () => _showEditOptionDialog(section['id'], index, option),
              ),
            ],
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  option['text'],
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 4),
                Text(
                  '${option['price']} جنيه',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.right,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildDecorationPlansList() {
    return _decorationPlans.asMap().entries.map((entry) {
      final index = entry.key;
      final plan = entry.value;
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(
                Icons.delete_outline,
                color: Colors.red,
                size: 20,
              ),
              onPressed: () => _confirmDeleteDecorationPlan(index),
            ),
            Expanded(
              child: Text(
                plan['text'],
                style: const TextStyle(fontSize: 14, color: Colors.black87),
                textAlign: TextAlign.right,
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFD4AF37), width: 2),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildFixedTimeSlot(
    String title,
    String timeRange,
    TextEditingController controller,
  ) {
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
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
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
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // DIALOGS
  void _showAddSectionDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة قسم جديد', textAlign: TextAlign.right),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              textAlign: TextAlign.right,
              decoration: const InputDecoration(
                labelText: 'عنوان القسم',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descController,
              textAlign: TextAlign.right,
              decoration: const InputDecoration(
                labelText: 'الوصف (اختياري)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                setState(() {
                  _dynamicSections.add({
                    'id': DateTime.now().millisecondsSinceEpoch.toString(),
                    'title': titleController.text,
                    'description': descController.text,
                    'selectionType': 'single',
                    'options': [],
                  });
                });
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4AF37),
            ),
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  void _showAddOptionDialog(String sectionId) {
    final textController = TextEditingController();
    final priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة خيار', textAlign: TextAlign.right),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: textController,
              textAlign: TextAlign.right,
              decoration: const InputDecoration(
                labelText: 'نص الخيار',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: priceController,
              textAlign: TextAlign.right,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'السعر',
                border: OutlineInputBorder(),
                suffixText: 'جنيه',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              if (textController.text.isNotEmpty &&
                  priceController.text.isNotEmpty) {
                setState(() {
                  final section = _dynamicSections.firstWhere(
                    (s) => s['id'] == sectionId,
                  );
                  (section['options'] as List).add({
                    'text': textController.text,
                    'price': priceController.text,
                  });
                });
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4AF37),
            ),
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  void _showEditOptionDialog(String sectionId, int optionIndex, Map<String, dynamic> option) {
    final textController = TextEditingController(text: option['text']);
    final priceController = TextEditingController(text: option['price']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تعديل الخيار', textAlign: TextAlign.right),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: textController,
              textAlign: TextAlign.right,
              decoration: const InputDecoration(
                labelText: 'نص الخيار',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: priceController,
              textAlign: TextAlign.right,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'السعر',
                border: OutlineInputBorder(),
                suffixText: 'جنيه',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              if (textController.text.isNotEmpty &&
                  priceController.text.isNotEmpty) {
                setState(() {
                  final section = _dynamicSections.firstWhere(
                    (s) => s['id'] == sectionId,
                  );
                  (section['options'] as List)[optionIndex] = {
                    'text': textController.text,
                    'price': priceController.text,
                  };
                });
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4AF37),
            ),
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  void _addDecorationPlan() {
    final textController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة بلان', textAlign: TextAlign.right),
        content: TextField(
          controller: textController,
          textAlign: TextAlign.right,
          decoration: const InputDecoration(
            labelText: 'اسم البلان',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              if (textController.text.isNotEmpty) {
                setState(() {
                  _decorationPlans.add({'text': textController.text});
                });
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4AF37),
            ),
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteSection(String sectionId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('هل أنت متأكد؟', textAlign: TextAlign.right),
        content: const Text(
          'سيتم حذف القسم بالكامل مع جميع الخيارات',
          textAlign: TextAlign.right,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _dynamicSections.removeWhere((s) => s['id'] == sectionId);
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteOption(String sectionId, int optionIndex) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('هل أنت متأكد؟', textAlign: TextAlign.right),
        content: const Text('سيتم حذف هذا الخيار', textAlign: TextAlign.right),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                final section = _dynamicSections.firstWhere(
                  (s) => s['id'] == sectionId,
                );
                (section['options'] as List).removeAt(optionIndex);
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteDecorationPlan(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('هل أنت متأكد؟', textAlign: TextAlign.right),
        content: const Text('سيتم حذف هذا البلان', textAlign: TextAlign.right),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _decorationPlans.removeAt(index);
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  // UI COMPONENTS
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
      enabled: true,
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
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'الرجاء إدخال اسم الخدمة';
        }
        return null;
      },
    );
  }

  Widget _buildNumberField(
    TextEditingController controller, {
    String? hintText,
    bool isOptional = false,
  }) {
    return TextFormField(
      controller: controller,
      enabled: true,
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
          return 'مطلوب';
        }
        if (value != null &&
            value.isNotEmpty &&
            double.tryParse(value) == null) {
          return 'الرجاء إدخال رقم صحيح';
        }
        return null;
      },
    );
  }

  Widget _buildCategoryDropdown() {
    // Show error state
    if (_categoriesError != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.shade200, width: 1),
            ),
            child: Column(
              children: [
                Icon(Icons.error_outline, color: Colors.red.shade700, size: 32),
                const SizedBox(height: 8),
                Text(
                  _categoriesError!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _loadCategories,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('إعادة المحاولة'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4AF37),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    // Show loading state
    if (_isCategoriesLoading) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFFD4AF37),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'جاري تحميل الفئات...',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    // Show dropdown with loaded categories
    return DropdownButtonFormField<String>(
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
      items: _categories.map((CategoryModel category) {
        return DropdownMenuItem<String>(
          value: category.nameAr,
          alignment: Alignment.centerRight,
          child: Text(
            category.nameAr,
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 15),
          ),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedCategory = newValue;
          _initializeDefaultSections();
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

    return GestureDetector(
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
            ? GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _pickedLocation,
                  zoom: 14,
                ),
                onMapCreated: (controller) => _mapController = controller,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                onCameraMove: (position) {
                  setState(() => _pickedLocation = position.target);
                },
                onTap: (LatLng location) {
                  setState(() => _pickedLocation = location);
                },
              )
            : Stack(
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
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildOfferSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _buildSectionLabel('عرض خاص (اختياري)'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text(
                    'هل تريد إضافة عرض خصم على هذه الخدمة؟',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
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
                      Icon(
                        Icons.info_outline,
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
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
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
    );
  }

  void _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      final authState = context.read<AuthBloc>().state;
      if (authState is! AuthAuthenticated) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('خطأ: يجب تسجيل الدخول أولاً')),
        );
        return;
      }

      // Client-side validation: Check if image is selected
      if (_selectedImages.isEmpty) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            contentPadding: const EdgeInsets.all(32),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.image_outlined,
                    color: Colors.orange,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'الصورة مطلوبة',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'يرجى اختيار صورة للخدمة قبل الإضافة',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4AF37),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('حسناً'),
                  ),
                ),
              ],
            ),
          ),
        );
        return;
      }

      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
        ),
      );

      try {
        final serviceRepository = getIt<ServiceRepository>();

        // Create the service with image file (will be uploaded as part of service creation)
        final newService = ServiceModel(
          id: '',
          name: _nameController.text.trim(),
          description: 'خدمة ${_nameController.text.trim()}',
          imageUrl: '', // Will be set by the backend after upload
          price: double.tryParse(_priceController.text),
          category: _selectedCategory!,
          providerId: authState.user.id,
          imageFile: _selectedImages.isNotEmpty ? _selectedImages[0] : null,
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
          isPendingApproval: false,
          hasOffer: _hasOffer,
          discountPercentage:
              _hasOffer && _discountPercentageController.text.isNotEmpty
              ? double.tryParse(_discountPercentageController.text)
              : null,
          offerApproved: false,
        );

        final createdService = await serviceRepository.addService(newService);
        final serviceId = createdService.id;

        // Step 3: Add dynamic sections and their options
        for (final section in _dynamicSections) {
          final sectionResponse = await serviceRepository.addDynamicSection(
            serviceId: serviceId,
            title: section['title'],
            description: section['description'] ?? '',
            selectionType: section['selectionType'],
          );

          final sectionId = sectionResponse['id']?.toString() ?? '';

          // Add options for this section
          final options = section['options'] as List;
          for (final option in options) {
            await serviceRepository.addDynamicSectionOption(
              serviceId: serviceId,
              sectionId: sectionId,
              text: option['text'],
              price: option['price'],
            );
          }
        }

        // Step 4: Add decoration plans for venues (as a special dynamic section)
        if (_selectedCategory == 'قاعات أفراح' && _decorationPlans.isNotEmpty) {
          final decorationSection = await serviceRepository.addDynamicSection(
            serviceId: serviceId,
            title: 'البلان',
            description: 'خطط الديكور المتاحة',
            selectionType: 'single',
          );

          final decorationSectionId = decorationSection['id']?.toString() ?? '';

          for (final plan in _decorationPlans) {
            await serviceRepository.addDynamicSectionOption(
              serviceId: serviceId,
              sectionId: decorationSectionId,
              text: plan['text'],
              price: '0', // Decoration plans don't have separate pricing
            );
          }
        }

        // Close loading dialog
        if (mounted) Navigator.of(context).pop();

        // Show success dialog
        if (mounted) {
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

          await Future.delayed(const Duration(seconds: 2));

          if (mounted) {
            Navigator.of(context).pop(); // Close success dialog
            if (context.mounted) {
              Navigator.of(context).pop(true); // Return to previous screen
            }
          }
        }
      } catch (e) {
        // Close loading dialog
        if (mounted) Navigator.of(context).pop();

        // Get user-friendly error message
        String errorTitle = 'فشل إضافة الخدمة';
        String errorMessage = 'حدث خطأ أثناء إضافة الخدمة';
        IconData errorIcon = Icons.error_outline;
        Color errorColor = Colors.red;

        if (e is NoInternetException) {
          errorTitle = 'لا توجد اتصال بالإنترنت';
          errorMessage = 'يرجى التحقق من اتصالك بالإنترنت والمحاولة مرة أخرى';
          errorIcon = Icons.wifi_off_rounded;
          errorColor = Colors.orange;
        } else if (e is TimeoutException) {
          errorTitle = 'انتهت مهلة الاتصال';
          errorMessage = 'الخادم يستغرق وقتاً طويلاً. يرجى المحاولة مرة أخرى';
          errorIcon = Icons.access_time_rounded;
          errorColor = Colors.orange;
        } else if (e is ServerException) {
          errorTitle = 'خطأ في الخادم';
          errorMessage = 'حدث خطأ في الخادم. يرجى المحاولة لاحقاً';
          errorIcon = Icons.dns_rounded;
          errorColor = Colors.red;
        } else if (e is ValidationException) {
          errorTitle = 'بيانات غير صحيحة';
          errorMessage = 'يرجى التحقق من البيانات المدخلة والمحاولة مرة أخرى';
          errorIcon = Icons.warning_amber_rounded;
          errorColor = Colors.amber;
        } else if (e is UnauthorizedException) {
          errorTitle = 'جلسة منتهية';
          errorMessage = 'انتهت صلاحية جلستك. يرجى تسجيل الدخول مرة أخرى';
          errorIcon = Icons.lock_outline_rounded;
          errorColor = Colors.orange;
        }

        // Show user-friendly error dialog
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              contentPadding: const EdgeInsets.all(32),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: errorColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      errorIcon,
                      color: errorColor,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    errorTitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    errorMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD4AF37),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('حسناً'),
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
