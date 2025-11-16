import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/service_model.dart';
import '../../../logic/blocs/provider_service/provider_service_bloc.dart';
import '../../../logic/blocs/provider_service/provider_service_event.dart';

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

  String? _selectedCategory;
  String? _selectedTimeSlot; // 'morning' or 'evening'

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
    _selectedCategory = widget.service.category; // Set current category
    // Pre-fill appointment prices from service data
    _morningPriceController.text = widget.service.morningPrice?.toString() ?? '';
    _eveningPriceController.text = widget.service.eveningPrice?.toString() ?? '';
  }

  @override
  void dispose() {
    _priceController.dispose();
    _chairsController.dispose();
    _morningPriceController.dispose();
    _eveningPriceController.dispose();
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

            // عدد الكراسي - Only for قاعات أفراح category
            if (_selectedCategory == 'قاعات أفراح') ...[
              _buildSectionLabel('عدد الكراسي'),
              const SizedBox(height: 8),
              _buildNumberField(
                _chairsController,
                hintText: 'أدخل عدد الكراسي',
                isOptional: true,
                optionalErrorMessage: 'الرجاء إدخال عدد',
              ),
              const SizedBox(height: 32),
            ],

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
    return Expanded(
      child: Container(
        height: 145,
        decoration: BoxDecoration(
          color: const Color(0xFFE8E8E8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300, width: 1),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.network(
            widget.service.imageUrl, // Same image for both (mock data)
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Center(
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
              );
            },
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

  void _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      if (!mounted) return;

      // Create updated service model with new data
      // IMPORTANT: Edits require admin approval, so set isPendingApproval = true
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
        isPendingApproval: true, // Service edits need admin approval
      );

      // Dispatch UpdateService event to BLoC
      context.read<ProviderServiceBloc>().add(UpdateService(updatedService));

      // Show success dialog with admin approval message
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
                  Icons.schedule_rounded,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'تم إرسال التعديلات للمراجعة',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'سيتم مراجعة التعديلات من قبل الإدارة وإشعارك بالنتيجة',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Colors.orange,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'ستظهر علامة "تحت المراجعة" على الخدمة',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );

      // Wait 3 seconds before closing (longer to read the message)
      await Future.delayed(const Duration(seconds: 3));

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
