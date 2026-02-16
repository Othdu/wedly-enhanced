import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

class ProviderEditGeneralServiceScreen extends StatefulWidget {
  final ServiceModel service;

  const ProviderEditGeneralServiceScreen({super.key, required this.service});

  @override
  State<ProviderEditGeneralServiceScreen> createState() =>
      _ProviderEditGeneralServiceScreenState();
}

class _ProviderEditGeneralServiceScreenState
    extends State<ProviderEditGeneralServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _priceController = TextEditingController();
  final _discountController = TextEditingController();

  bool _hasOffer = false;
  DateTime? _offerExpiryDate;
  bool _isLoading = false;
  bool _isSaving = false;

  // Dynamic sections data
  List<Map<String, dynamic>> _dynamicSections = [];

  // Track changes for API updates
  final List<Map<String, dynamic>> _sectionsToAdd = [];
  final List<String> _sectionsToDelete = [];
  final Map<String, Map<String, dynamic>> _sectionsToUpdate = {};
  final Map<String, List<Map<String, dynamic>>> _optionsToAdd = {};
  final Map<String, List<String>> _optionsToDelete = {};
  final Map<String, Map<String, Map<String, dynamic>>> _optionsToUpdate = {};

  @override
  void initState() {
    super.initState();
    // Pre-fill price
    _priceController.text = widget.service.price?.toString() ?? '';

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

    // Load categories for display
    _loadCategories();

    // Load dynamic sections
    _loadDynamicSections();
  }

  /// Fetch the offer expiry date from the offers API
  /// The service API may not return offer_expiry_date, but the offers API does
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

  Future<void> _loadDynamicSections() async {
    setState(() => _isLoading = true);

    try {
      // First try to get from service model
      if (widget.service.dynamicSections != null &&
          widget.service.dynamicSections!.isNotEmpty) {
        setState(() {
          _dynamicSections = widget.service.dynamicSections!.map((s) {
            // Normalize the section structure (handle both 'id' and '_id' from API)
            return {
              'id': s['id']?.toString() ?? s['_id']?.toString() ?? '',
              'title': s['section_name'] ?? s['title'] ?? '',
              'description': s['description'] ?? '',
              'options': (s['options'] as List?)?.map((o) {
                return {
                  'id': o['id']?.toString() ?? o['_id']?.toString() ?? '',
                  'text': o['text'] ?? '',
                  'price': o['price']?.toString() ?? '0',
                };
              }).toList() ?? [],
            };
          }).toList();
          _isLoading = false;
        });
        return;
      }

      // Otherwise fetch from API
      final serviceRepository = getIt<ServiceRepository>();
      final sections = await serviceRepository.getDynamicSections(widget.service.id);

      if (mounted) {
        setState(() {
          _dynamicSections = sections.map((s) {
            // Normalize the section structure
            return {
              'id': s['id']?.toString() ?? s['_id']?.toString() ?? '',
              'title': s['section_name'] ?? s['title'] ?? '',
              'description': s['description'] ?? '',
              'options': (s['options'] as List?)?.map((o) => {
                'id': o['id']?.toString() ?? o['_id']?.toString() ?? '',
                'text': o['text'] ?? '',
                'price': o['price']?.toString() ?? '0',
              }).toList() ?? [],
            };
          }).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في تحميل الأقسام: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _priceController.dispose();
    _discountController.dispose();
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
          setState(() => _isSaving = false);
          // Show error message
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
      body: _isLoading
        ? const Center(
            child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
          )
        : Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // صورة الخدمة
            _buildSectionLabel('صورة الخدمة'),
            const SizedBox(height: 12),
            _buildReadOnlyImageDisplay(0),
            const SizedBox(height: 24),

            // اسم الخدمة
            _buildSectionLabel('اسم الخدمة'),
            const SizedBox(height: 8),
            _buildReadOnlyField(widget.service.name),
            const SizedBox(height: 20),

            // الفئة
            _buildSectionLabel('الفئة'),
            const SizedBox(height: 8),
            _buildReadOnlyField(CategoryHelper.getCategoryArabicName(widget.service.category)),
            const SizedBox(height: 20),

            // السعر - Price Section
            _buildSectionLabel('السعر'),
            const SizedBox(height: 8),
            _buildPriceField(),
            const SizedBox(height: 24),

            // الأقسام الديناميكية - Dynamic Sections
            _buildDynamicSectionsHeader(),
            const SizedBox(height: 12),
            ..._buildDynamicSectionsList(),
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
                onPressed: _isSaving ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: _isSaving
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
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

  Widget _buildPriceField() {
    return TextFormField(
      controller: _priceController,
      textAlign: TextAlign.right,
      keyboardType: TextInputType.number,
      style: const TextStyle(fontSize: 15),
      decoration: InputDecoration(
        hintText: 'أدخل السعر',
        hintStyle: TextStyle(
          color: Colors.grey.shade400,
          fontSize: 14,
        ),
        suffixText: 'جنيه',
        suffixStyle: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 14,
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
        if (value != null && value.isNotEmpty && double.tryParse(value) == null) {
          return 'الرجاء إدخال رقم صحيح';
        }
        return null;
      },
    );
  }

  Widget _buildDynamicSectionsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [_buildSectionLabel('أقسام التسعير'),
        IconButton(
          icon: const Icon(
            Icons.add_circle_outline,
            color: Color(0xFFD4AF37),
            size: 28,
          ),
          onPressed: _showAddSectionDialog,
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  List<Widget> _buildDynamicSectionsList() {
    if (_dynamicSections.isEmpty) {
      return [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200, width: 1),
          ),
          child: Column(
            children: [
              Icon(
                Icons.category_outlined,
                size: 48,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 12),
              Text(
                'لا توجد أقسام تسعير',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'اضغط على + لإضافة قسم جديد',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade400,
                ),
              ),
            ],
          ),
        ),
      ];
    }

    return _dynamicSections.map((section) => _buildDynamicSection(section)).toList();
  }

  Widget _buildDynamicSection(Map<String, dynamic> section) {
    final sectionId = section['id']?.toString() ?? '';
    final isNewSection = sectionId.isEmpty || sectionId.startsWith('new_');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isNewSection ? const Color(0xFFD4AF37).withValues(alpha: 0.5) : Colors.grey.shade200,
          width: isNewSection ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Section Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red, size: 22),
                    onPressed: () => _confirmDeleteSection(section),
                    tooltip: 'حذف القسم',
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: Color(0xFFD4AF37), size: 22),
                    onPressed: () => _showEditSectionDialog(section),
                    tooltip: 'تعديل القسم',
                  ),
                ],
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      section['title'] ?? 'قسم بدون عنوان',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFD4AF37),
                      ),
                      textAlign: TextAlign.right,
                    ),
                    if ((section['description'] ?? '').toString().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        section['description'],
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                        textAlign: TextAlign.right,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // Options list
          if ((section['options'] as List?)?.isNotEmpty ?? false)
            ...List.generate(
              (section['options'] as List).length,
              (index) => _buildOptionItem(section, index),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'لا توجد خيارات في هذا القسم',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade400,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),

          const SizedBox(height: 8),

          // Add Option Button
          TextButton.icon(
            onPressed: () => _showAddOptionDialog(section),
            icon: const Icon(Icons.add, color: Color(0xFFD4AF37), size: 20),
            label: const Text(
              'إضافة خيار',
              style: TextStyle(color: Color(0xFFD4AF37), fontSize: 14),
            ),
          ),
        ],
      ),
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
                onPressed: () => _confirmDeleteOption(section, index),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: Color(0xFFD4AF37), size: 20),
                onPressed: () => _showEditOptionDialog(section, index, option),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ],
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  option['text'] ?? '',
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 4),
                Text(
                  '${option['price'] ?? '0'} جنيه',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFFD4AF37),
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

  // Dialog methods
  void _showAddSectionDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('إضافة قسم جديد', textAlign: TextAlign.right),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                labelText: 'عنوان القسم *',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descController,
              textAlign: TextAlign.right,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'الوصف (اختياري)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
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
                final newSection = {
                  'id': 'new_${DateTime.now().millisecondsSinceEpoch}',
                  'title': titleController.text,
                  'description': descController.text,
                  'options': <Map<String, dynamic>>[],
                };
                setState(() {
                  _dynamicSections.add(newSection);
                  _sectionsToAdd.add(newSection);
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

  void _showEditSectionDialog(Map<String, dynamic> section) {
    final titleController = TextEditingController(text: section['title']);
    final descController = TextEditingController(text: section['description']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('تعديل القسم', textAlign: TextAlign.right),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                labelText: 'عنوان القسم *',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descController,
              textAlign: TextAlign.right,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'الوصف (اختياري)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
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
                  section['title'] = titleController.text;
                  section['description'] = descController.text;

                  // Track update if it's an existing section
                  final sectionId = section['id']?.toString() ?? '';
                  if (sectionId.isNotEmpty && !sectionId.startsWith('new_')) {
                    _sectionsToUpdate[sectionId] = {
                      'section_name': titleController.text,
                      'description': descController.text,
                    };
                  }
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

  void _confirmDeleteSection(Map<String, dynamic> section) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('حذف القسم', textAlign: TextAlign.right),
        content: const Text(
          'هل أنت متأكد من حذف هذا القسم؟ سيتم حذف جميع الخيارات الموجودة فيه.',
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
                final sectionId = section['id']?.toString() ?? '';
                _dynamicSections.remove(section);

                // Track deletion if it's an existing section
                if (sectionId.isNotEmpty && !sectionId.startsWith('new_')) {
                  _sectionsToDelete.add(sectionId);
                }
                // Remove from add list if it was newly added
                _sectionsToAdd.removeWhere((s) => s['id'] == sectionId);
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

  void _showAddOptionDialog(Map<String, dynamic> section) {
    final textController = TextEditingController();
    final priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('إضافة خيار', textAlign: TextAlign.right),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: textController,
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                labelText: 'نص الخيار *',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: priceController,
              textAlign: TextAlign.right,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'السعر *',
                suffixText: 'جنيه',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
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
              if (textController.text.isNotEmpty && priceController.text.isNotEmpty) {
                final sectionId = section['id']?.toString() ?? '';
                final newOption = {
                  'id': 'new_${DateTime.now().millisecondsSinceEpoch}',
                  'text': textController.text,
                  'price': priceController.text,
                };

                setState(() {
                  (section['options'] as List).add(newOption);

                  // Track addition if section is existing
                  if (sectionId.isNotEmpty && !sectionId.startsWith('new_')) {
                    _optionsToAdd[sectionId] ??= [];
                    _optionsToAdd[sectionId]!.add(newOption);
                  }
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

  void _showEditOptionDialog(Map<String, dynamic> section, int index, Map<String, dynamic> option) {
    final textController = TextEditingController(text: option['text']);
    final priceController = TextEditingController(text: option['price']?.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('تعديل الخيار', textAlign: TextAlign.right),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: textController,
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                labelText: 'نص الخيار *',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: priceController,
              textAlign: TextAlign.right,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'السعر *',
                suffixText: 'جنيه',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
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
              if (textController.text.isNotEmpty && priceController.text.isNotEmpty) {
                final sectionId = section['id']?.toString() ?? '';
                final optionId = option['id']?.toString() ?? '';

                setState(() {
                  option['text'] = textController.text;
                  option['price'] = priceController.text;

                  // Track update if both section and option are existing
                  if (sectionId.isNotEmpty && !sectionId.startsWith('new_') &&
                      optionId.isNotEmpty && !optionId.startsWith('new_')) {
                    _optionsToUpdate[sectionId] ??= {};
                    _optionsToUpdate[sectionId]![optionId] = {
                      'text': textController.text,
                      'price': priceController.text,
                    };
                  }
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

  void _confirmDeleteOption(Map<String, dynamic> section, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('حذف الخيار', textAlign: TextAlign.right),
        content: const Text(
          'هل أنت متأكد من حذف هذا الخيار؟',
          textAlign: TextAlign.right,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              final sectionId = section['id']?.toString() ?? '';
              final option = (section['options'] as List)[index];
              final optionId = option['id']?.toString() ?? '';

              setState(() {
                (section['options'] as List).removeAt(index);

                // Track deletion if both section and option are existing
                if (sectionId.isNotEmpty && !sectionId.startsWith('new_') &&
                    optionId.isNotEmpty && !optionId.startsWith('new_')) {
                  _optionsToDelete[sectionId] ??= [];
                  _optionsToDelete[sectionId]!.add(optionId);
                }
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

      setState(() => _isSaving = true);

      try {
        final serviceRepository = getIt<ServiceRepository>();
        final serviceId = widget.service.id;

        // 1. Delete sections marked for deletion (ignore 404 errors - already deleted)
        for (final sectionId in _sectionsToDelete) {
          try {
            await serviceRepository.deleteDynamicSection(
              serviceId: serviceId,
              sectionId: sectionId,
            );
          } catch (e) {
            // Ignore 404 errors for delete operations (already deleted)
            debugPrint('Warning: Could not delete section $sectionId: $e');
          }
        }

        // 2. Delete options marked for deletion (ignore 404 errors - already deleted)
        for (final entry in _optionsToDelete.entries) {
          final sectionId = entry.key;
          for (final optionId in entry.value) {
            try {
              await serviceRepository.deleteSectionOption(
                serviceId: serviceId,
                sectionId: sectionId,
                optionId: optionId,
              );
            } catch (e) {
              // Ignore 404 errors for delete operations (already deleted)
              debugPrint('Warning: Could not delete option $optionId: $e');
            }
          }
        }

        // 3. Update existing sections (continue on error)
        for (final entry in _sectionsToUpdate.entries) {
          try {
            await serviceRepository.updateDynamicSection(
              serviceId: serviceId,
              sectionId: entry.key,
              sectionName: entry.value['section_name'],
              description: entry.value['description'],
            );
          } catch (e) {
            debugPrint('Warning: Could not update section ${entry.key}: $e');
          }
        }

        // 4. Update existing options (continue on error)
        for (final sectionEntry in _optionsToUpdate.entries) {
          final sectionId = sectionEntry.key;
          for (final optionEntry in sectionEntry.value.entries) {
            try {
              await serviceRepository.updateSectionOption(
                serviceId: serviceId,
                sectionId: sectionId,
                optionId: optionEntry.key,
                text: optionEntry.value['text'],
                price: optionEntry.value['price'],
              );
            } catch (e) {
              debugPrint('Warning: Could not update option ${optionEntry.key}: $e');
            }
          }
        }

        // 5. Add new sections with their options
        for (final section in _sectionsToAdd) {
          try {
            await serviceRepository.addDynamicSection(
              serviceId: serviceId,
              sectionName: section['title'],
              description: section['description'] ?? '',
              options: (section['options'] as List).map((o) => {
                'text': o['text'],
                'price': o['price'],
              }).toList(),
            );
          } catch (e) {
            debugPrint('Warning: Could not add section ${section['title']}: $e');
          }
        }

        // 6. Add new options to existing sections
        for (final entry in _optionsToAdd.entries) {
          final sectionId = entry.key;
          for (final option in entry.value) {
            try {
              await serviceRepository.addDynamicSectionOption(
                serviceId: serviceId,
                sectionId: sectionId,
                text: option['text'],
                price: option['price'],
              );
            } catch (e) {
              debugPrint('Warning: Could not add option to section $sectionId: $e');
            }
          }
        }

        // 7. Update the service itself (price only - offers handled separately)
        final updatedService = widget.service.copyWith(
          price: _priceController.text.isNotEmpty
              ? double.tryParse(_priceController.text)
              : null,
          hasOffer: _hasOffer,
          isPendingApproval: false,
        );

        // 8. Handle offer via separate PATCH API
        if (_hasOffer && _discountController.text.isNotEmpty && _offerExpiryDate != null) {
          // Submit/update offer
          try {
            await serviceRepository.submitServiceOffer(
              serviceId: serviceId,
              discountPercentage: double.parse(_discountController.text),
              offerExpiryDate: _offerExpiryDate!,
            );
            debugPrint('✅ Offer submitted successfully for service $serviceId');
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
            await serviceRepository.removeServiceOffer(serviceId);
            debugPrint('✅ Offer removed for service $serviceId');
          } catch (e) {
            debugPrint('❌ Error removing offer: $e');
          }
        }

        // Dispatch UpdateService event to BLoC
        if (mounted) {
          context.read<ProviderServiceBloc>().add(UpdateService(updatedService));
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isSaving = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('حدث خطأ: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
