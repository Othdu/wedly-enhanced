import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:wedly/data/models/service_model.dart';
import 'package:wedly/logic/blocs/auth/auth_bloc.dart';
import 'package:wedly/logic/blocs/auth/auth_event.dart';
import 'package:wedly/logic/blocs/auth/auth_state.dart';
import 'package:wedly/data/repositories/auth_repository.dart';
import 'package:wedly/data/repositories/service_repository.dart';
import 'package:wedly/data/repositories/category_repository.dart';
import 'package:wedly/data/models/category_model.dart';
import 'package:wedly/core/di/injection_container.dart';
import 'package:wedly/data/services/api_exceptions.dart';
import 'package:wedly/core/utils/permission_helper.dart' as permission;

class ProviderAddServiceScreen extends StatefulWidget {
  const ProviderAddServiceScreen({super.key});

  @override
  State<ProviderAddServiceScreen> createState() =>
      _ProviderAddServiceScreenState();
}

class _ProviderAddServiceScreenState extends State<ProviderAddServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _chairsController = TextEditingController();
  final _morningPriceController = TextEditingController();
  final _eveningPriceController = TextEditingController();
  final _generalPriceController = TextEditingController();

  final List<File> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();
  bool _isPickingImage = false;

  String? _selectedCategory;

  List<CategoryModel> _categories = [];
  bool _isCategoriesLoading = true;
  String? _categoriesError;

  List<Map<String, dynamic>> _dynamicSections = [];

  LatLng _pickedLocation = LatLng(30.0444, 31.2357);
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(_AppLifecycleObserver());
    _loadCategories();
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
        _categoriesError =
            'فشل التحميل. برجاء التحقق من الإنترنت والمحاولة مرة أخرى';
      });
    }
  }

  void _initializeDefaultSections() {
    if (_selectedCategory == null) return;
    setState(() {
      _dynamicSections.clear();
      if (!_isVenueCategory(_selectedCategory!)) {
        _initializeGenericSections();
      }
    });
  }

  bool _isVenueCategory(String category) {
    final venueNames = ['قاعات أفراح', 'القاعات', 'قاعات', 'venue', 'venues'];
    return venueNames
        .any((name) => category.toLowerCase().contains(name.toLowerCase()));
  }

  void _initializeGenericSections() {
    _dynamicSections = [
      {
        'id': '1',
        'title': 'الباقات',
        'description': 'أضف باقات الخدمة المتاحة',
        'selectionType': 'single',
        'options': [],
      },
    ];
  }

  double _calculatePriceFromSections() {
    double? minPrice;
    for (final section in _dynamicSections) {
      final options = section['options'] as List;
      for (final option in options) {
        final priceStr = option['price']?.toString() ?? '0';
        final price = double.tryParse(priceStr) ?? 0;
        if (price > 0) {
          if (minPrice == null || price < minPrice) minPrice = price;
        }
      }
    }
    return minPrice ?? 0;
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
      final source =
          await permission.PermissionHelper.showImageSourceDialog(context);
      if (source == null || !mounted) {
        setState(() => _isPickingImage = false);
        return;
      }

      bool hasPermission = false;
      if (source == permission.ImageSource.camera) {
        hasPermission =
            await permission.PermissionHelper.requestCameraPermission(context);
      } else {
        hasPermission =
            await permission.PermissionHelper.requestStoragePermission(context);
      }

      if (!hasPermission || !mounted) {
        setState(() => _isPickingImage = false);
        return;
      }

      final imageSource = source == permission.ImageSource.camera
          ? ImageSource.camera
          : ImageSource.gallery;

      final XFile? image = await _picker.pickImage(source: imageSource);
      if (image != null && mounted) {
        setState(() => _selectedImages.add(File(image.path)));
      }
    } finally {
      if (mounted) setState(() => _isPickingImage = false);
    }
  }

  void _removeImage(int index) {
    setState(() => _selectedImages.removeAt(index));
  }

  // ID verification bottom sheet
  Future<bool> _showIdVerificationSheet() async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => const _IdVerificationSheet(),
    );
    return result == true;
  }

  void _showPendingApprovalDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
              child: const Icon(Icons.hourglass_top_rounded,
                  color: Colors.orange, size: 40),
            ),
            const SizedBox(height: 24),
            const Text(
              'مستنداتك قيد المراجعة',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
            ),
            const SizedBox(height: 8),
            const Text(
              'تم رفع مستنداتك بنجاح وهي الآن قيد المراجعة. '
              'سيتم إشعارك فور الموافقة عليها لتتمكن من إضافة خدماتك.',
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              style: TextStyle(fontSize: 14, color: Colors.black54, height: 1.5),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('حسناً'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _chairsController.dispose();
    _morningPriceController.dispose();
    _eveningPriceController.dispose();
    _generalPriceController.dispose();
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
            _buildSectionLabel('اسم الخدمة'),
            const SizedBox(height: 8),
            _buildTextField(_nameController),
            const SizedBox(height: 20),
            _buildSectionLabel('الفئة'),
            const SizedBox(height: 8),
            _buildCategoryDropdown(),
            const SizedBox(height: 20),
            ..._buildCategorySpecificFields(),
            const SizedBox(height: 32),
            _buildSubmitButton(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCategorySpecificFields() {
    if (_selectedCategory == null) return [];
    if (_isVenueCategory(_selectedCategory!)) return _buildVenueFields();
    return _buildDynamicSectionFields();
  }

  List<Widget> _buildVenueFields() {
    return [
      _buildSectionLabel('المواعيد'),
      const SizedBox(height: 12),
      _buildFixedTimeSlot('صباحي', 'من 12 ظهرًا حتى 7 مساءً',
          _morningPriceController),
      const SizedBox(height: 12),
      _buildFixedTimeSlot(
          'مسائي', 'من 8 مساءً حتى 2 فجرًا', _eveningPriceController),
      const SizedBox(height: 24),
      _buildSectionLabel('عدد الكراسي'),
      const SizedBox(height: 8),
      _buildNumberField(_chairsController,
          hintText: 'مثال: 400', isOptional: false),
      const SizedBox(height: 24),
      _buildSectionLabel('الموقع'),
      const SizedBox(height: 12),
      _buildMapWidget(),
      const SizedBox(height: 24),
    ];
  }

  List<Widget> _buildDynamicSectionFields() {
    return [
      _buildSectionLabel('السعر العام (اختياري)'),
      const SizedBox(height: 8),
      _buildOptionalPriceField(),
      const SizedBox(height: 8),
      Text(
        'يمكنك إضافة سعر عام للخدمة أو ترك الأسعار في الأقسام أدناه',
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey.shade600,
          fontStyle: FontStyle.italic,
        ),
        textAlign: TextAlign.right,
      ),
      const SizedBox(height: 24),
      _buildAddSectionButton(),
      const SizedBox(height: 16),
      ..._dynamicSections.map((section) => _buildDynamicSection(section)),
    ];
  }

  Widget _buildOptionalPriceField() {
    return TextFormField(
      controller: _generalPriceController,
      textAlign: TextAlign.right,
      keyboardType: TextInputType.number,
      style: const TextStyle(fontSize: 15),
      decoration: InputDecoration(
        hintText: 'أدخل السعر (اختياري)',
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        suffixText: 'جنيه',
        suffixStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
        if (value != null && value.isNotEmpty && double.tryParse(value) == null) {
          return 'الرجاء إدخال رقم صحيح';
        }
        return null;
      },
    );
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
          ...List.generate(
            (section['options'] as List).length,
            (index) => _buildOptionItem(section, index),
          ),
          const SizedBox(height: 8),
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
          onTap: () => setState(() => section['selectionType'] = 'single'),
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
          onTap: () => setState(() => section['selectionType'] = 'multiple'),
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
                icon: const Icon(Icons.delete_outline,
                    color: Colors.red, size: 20),
                onPressed: () => _confirmDeleteOption(section['id'], index),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined,
                    color: Color(0xFFD4AF37), size: 20),
                onPressed: () =>
                    _showEditOptionDialog(section['id'], index, option),
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
                hintStyle:
                    TextStyle(color: Colors.grey.shade400, fontSize: 13),
                suffixText: 'جنيه',
                suffixStyle:
                    TextStyle(color: Colors.grey.shade600, fontSize: 13),
                filled: true,
                fillColor: Colors.grey.shade50,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                      BorderSide(color: Colors.grey.shade300, width: 1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                      BorderSide(color: Colors.grey.shade300, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                      color: Color(0xFFD4AF37), width: 1.5),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return 'مطلوب';
                if (double.tryParse(value) == null) return 'رقم غير صحيح';
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
                  style:
                      TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

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
                backgroundColor: const Color(0xFFD4AF37)),
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
                  final section = _dynamicSections
                      .firstWhere((s) => s['id'] == sectionId);
                  (section['options'] as List).add({
                    'text': textController.text,
                    'price': priceController.text,
                  });
                });
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37)),
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  void _showEditOptionDialog(
      String sectionId, int optionIndex, Map<String, dynamic> option) {
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
                  final section = _dynamicSections
                      .firstWhere((s) => s['id'] == sectionId);
                  (section['options'] as List)[optionIndex] = {
                    'text': textController.text,
                    'price': priceController.text,
                  };
                });
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37)),
            child: const Text('حفظ'),
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
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.red),
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
        content:
            const Text('سيتم حذف هذا الخيار', textAlign: TextAlign.right),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                final section = _dynamicSections
                    .firstWhere((s) => s['id'] == sectionId);
                (section['options'] as List).removeAt(optionIndex);
              });
              Navigator.pop(context);
            },
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
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
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
        if (!isOptional && (value == null || value.isEmpty)) return 'مطلوب';
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
                Icon(Icons.error_outline,
                    color: Colors.red.shade700, size: 32),
                const SizedBox(height: 8),
                Text(
                  _categoriesError!,
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(color: Colors.red.shade700, fontSize: 14),
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
                        horizontal: 16, vertical: 8),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

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
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      isExpanded: true,
      alignment: Alignment.centerRight,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
        if (value == null || value.isEmpty) return 'الرجاء اختيار الفئة';
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
                        child: const Icon(Icons.close,
                            color: Colors.white, size: 16),
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
      height: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _pickedLocation,
                initialZoom: 14.0,
                minZoom: 5.0,
                maxZoom: 18.0,
                onTap: (tapPosition, point) {
                  setState(() => _pickedLocation = point);
                },
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
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
            Positioned(
              top: 10,
              right: 10,
              left: 10,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'اضغط على الخريطة لتحديد الموقع',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
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
                    Icon(Icons.location_on,
                        size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'الموقع: ${_pickedLocation.latitude.toStringAsFixed(5)}, ${_pickedLocation.longitude.toStringAsFixed(5)}',
                        style: TextStyle(
                            fontSize: 11, color: Colors.grey.shade700),
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
    if (!_formKey.currentState!.validate()) return;

    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('خطأ: يجب تسجيل الدخول أولاً')),
      );
      return;
    }

    if (_selectedImages.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                child: const Icon(Icons.image_outlined,
                    color: Colors.orange, size: 40),
              ),
              const SizedBox(height: 24),
              const Text(
                'الصورة مطلوبة',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
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
                        borderRadius: BorderRadius.circular(12)),
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

    final user = authState.user;
    final status = user.approvalStatus;

    if (status == 'pending') {
      if (!mounted) return;
      _showPendingApprovalDialog();
      return;
    } else if (status == 'rejected' || status == null) {
      if (!mounted) return;
      final uploaded = await _showIdVerificationSheet();
      if (!uploaded) return;
    }

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
      ),
    );

    try {
      final serviceRepository = getIt<ServiceRepository>();

      final isVenueCategory = _selectedCategory == 'قاعات أفراح' ||
          _selectedCategory == 'القاعات';

      final selectedCategoryModel = _categories.firstWhere(
        (cat) => cat.nameAr == _selectedCategory,
        orElse: () => _categories.first,
      );
      final categoryId = selectedCategoryModel.id;

      double? servicePrice;
      if (!isVenueCategory) {
        if (_generalPriceController.text.isNotEmpty) {
          servicePrice = double.tryParse(_generalPriceController.text);
        } else {
          servicePrice = _calculatePriceFromSections();
        }
      }

      final newService = ServiceModel(
        id: '',
        name: _nameController.text.trim(),
        description: 'خدمة ${_nameController.text.trim()}',
        imageUrl: '',
        category: categoryId,
        providerId: authState.user.id,
        imageFile: _selectedImages.isNotEmpty ? _selectedImages[0] : null,
        price: servicePrice,
        morningPrice: isVenueCategory && _morningPriceController.text.isNotEmpty
            ? double.tryParse(_morningPriceController.text)
            : null,
        eveningPrice: isVenueCategory && _eveningPriceController.text.isNotEmpty
            ? double.tryParse(_eveningPriceController.text)
            : null,
        chairCount: isVenueCategory && _chairsController.text.isNotEmpty
            ? int.tryParse(_chairsController.text)
            : null,
        latitude: isVenueCategory ? _pickedLocation.latitude : null,
        longitude: isVenueCategory ? _pickedLocation.longitude : null,
        isActive: true,
        isPendingApproval: false,
        hasOffer: false,
        discountPercentage: null,
        offerExpiryDate: null,
        offerApproved: false,
      );

      final createdService = await serviceRepository.addService(newService);
      final serviceId = createdService.id;

      for (final section in _dynamicSections) {
        final options = section['options'] as List;
        await serviceRepository.addDynamicSection(
          serviceId: serviceId,
          sectionName: section['title'],
          description: section['description'] ?? '',
          options: options
              .map((option) => {
                    'text': option['text'],
                    'price': option['price'],
                  })
              .toList(),
        );
      }

      if (mounted) Navigator.of(context).pop(); // close loading

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
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
                  child: const Icon(Icons.check_rounded,
                      color: Colors.white, size: 40),
                ),
                const SizedBox(height: 24),
                const Text(
                  'تم إضافة الخدمة بنجاح',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87),
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
          Navigator.of(context).pop();
          if (context.mounted) Navigator.of(context).pop(true);
        }
      }
    } catch (e) {
      if (mounted) Navigator.of(context).pop(); // close loading

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
        errorMessage =
            'يرجى التحقق من البيانات المدخلة والمحاولة مرة أخرى';
        errorIcon = Icons.warning_amber_rounded;
        errorColor = Colors.amber;
      } else if (e is UnauthorizedException) {
        errorTitle = 'جلسة منتهية';
        errorMessage = 'انتهت صلاحية جلستك. يرجى تسجيل الدخول مرة أخرى';
        errorIcon = Icons.lock_outline_rounded;
        errorColor = Colors.orange;
      }

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
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
                  child: Icon(errorIcon, color: errorColor, size: 40),
                ),
                const SizedBox(height: 24),
                Text(
                  errorTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87),
                ),
                const SizedBox(height: 8),
                Text(
                  errorMessage,
                  textAlign: TextAlign.center,
                  style:
                      const TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4AF37),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
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

// Dummy observer to avoid removing WidgetsBindingObserver usage
class _AppLifecycleObserver with WidgetsBindingObserver {}

class _IdVerificationSheet extends StatefulWidget {
  const _IdVerificationSheet();

  @override
  State<_IdVerificationSheet> createState() => _IdVerificationSheetState();
}

class _IdVerificationSheetState extends State<_IdVerificationSheet> {
  final ImagePicker _picker = ImagePicker();
  String? _idFrontPath;
  String? _idBackPath;
  String? _commercialRegisterPath;
  String? _taxCardPath;
  bool _isUploading = false;
  String? _errorMessage;

  bool get _requiredFieldsFilled => _idFrontPath != null && _idBackPath != null;

  Future<void> _pickImage(String field) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (image != null && mounted) {
        setState(() {
          switch (field) {
            case 'front':
              _idFrontPath = image.path;
            case 'back':
              _idBackPath = image.path;
            case 'commercial':
              _commercialRegisterPath = image.path;
            case 'tax':
              _taxCardPath = image.path;
          }
          _errorMessage = null;
        });
      }
    } catch (_) {}
  }

  Future<void> _uploadDocuments() async {
    if (!_requiredFieldsFilled) return;

    setState(() {
      _isUploading = true;
      _errorMessage = null;
    });

    try {
      final authRepository = getIt<AuthRepository>();
      await authRepository.uploadProviderDocuments(
        idFrontPath: _idFrontPath!,
        idBackPath: _idBackPath!,
        commercialRegisterPath: _commercialRegisterPath,
        taxCardPath: _taxCardPath,
      );

      if (mounted) {
        context.read<AuthBloc>().add(const AuthDocumentsUploaded());
        Navigator.pop(context, true);
      }
    } on NoInternetException {
      if (mounted) {
        setState(() {
          _isUploading = false;
          _errorMessage = 'لا يوجد اتصال بالإنترنت. يرجى المحاولة مرة أخرى';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUploading = false;
          _errorMessage = 'فشل رفع المستندات. يرجى المحاولة مرة أخرى';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          const Icon(Icons.verified_user_outlined,
              color: Color(0xFFD4AF37), size: 48),
          const SizedBox(height: 12),
          const Text(
            'التحقق من الهوية',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: 8),
          const Text(
            'لضمان أمان المستخدمين، نحتاج إلى رفع مستندات التحقق قبل نشر خدمتك.',
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
            style: TextStyle(fontSize: 13, color: Colors.grey, height: 1.5),
          ),
          const SizedBox(height: 24),
          _buildDocPickerRow(
            label: 'صورة البطاقة (الوجه) *',
            path: _idFrontPath,
            onTap: () => _pickImage('front'),
          ),
          const SizedBox(height: 12),
          _buildDocPickerRow(
            label: 'صورة البطاقة (الظهر) *',
            path: _idBackPath,
            onTap: () => _pickImage('back'),
          ),
          const SizedBox(height: 12),
          _buildDocPickerRow(
            label: 'السجل التجاري (اختياري)',
            path: _commercialRegisterPath,
            onTap: () => _pickImage('commercial'),
          ),
          const SizedBox(height: 12),
          _buildDocPickerRow(
            label: 'البطاقة الضريبية (اختياري)',
            path: _taxCardPath,
            onTap: () => _pickImage('tax'),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                textDirection: TextDirection.rtl,
                children: [
                  Icon(Icons.error_outline, color: Colors.red.shade700, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      textDirection: TextDirection.rtl,
                      style: TextStyle(fontSize: 13, color: Colors.red.shade700),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed:
                  (_requiredFieldsFilled && !_isUploading) ? _uploadDocuments : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade300,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: _isUploading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : const Text(
                      'رفع المستندات والمتابعة',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildDocPickerRow({
    required String label,
    required String? path,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: _isUploading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: path != null
              ? const Color(0xFFD4AF37).withValues(alpha: 0.1)
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                path != null ? const Color(0xFFD4AF37) : Colors.grey.shade300,
          ),
        ),
        child: Row(
          textDirection: TextDirection.rtl,
          children: [
            Icon(
              path != null
                  ? Icons.check_circle
                  : Icons.add_photo_alternate_outlined,
              color: path != null ? const Color(0xFFD4AF37) : Colors.grey,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                path != null ? 'تم الاختيار ✓' : label,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontSize: 14,
                  color: path != null
                      ? const Color(0xFF8B6914)
                      : Colors.grey[700],
                  fontWeight:
                      path != null ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}