import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wedly/core/constants/app_colors.dart';
import 'package:wedly/logic/blocs/review/review_bloc.dart';
import 'package:wedly/logic/blocs/review/review_event.dart';
import 'package:wedly/logic/blocs/review/review_state.dart';

/// Bottom sheet widget for submitting, editing, and deleting reviews
/// Used ONLY in completed bookings to allow users to rate services/venues
/// Reviews cannot be submitted for confirmed bookings - only completed ones
class ReviewBottomSheet extends StatefulWidget {
  final String targetId; // Service or Venue ID
  final String targetType; // 'service' or 'venue'
  final String serviceName;
  final VoidCallback? onReviewSubmitted;

  // Edit mode fields
  final bool isEditMode;
  final String? reviewId;
  final double? existingRating;
  final String? existingComment;

  const ReviewBottomSheet({
    super.key,
    required this.targetId,
    required this.targetType,
    required this.serviceName,
    this.onReviewSubmitted,
    this.isEditMode = false,
    this.reviewId,
    this.existingRating,
    this.existingComment,
  });

  /// Show the review bottom sheet for creating a new review
  static Future<bool?> show({
    required BuildContext context,
    required String targetId,
    required String targetType,
    required String serviceName,
    VoidCallback? onReviewSubmitted,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ReviewBottomSheet(
        targetId: targetId,
        targetType: targetType,
        serviceName: serviceName,
        onReviewSubmitted: onReviewSubmitted,
      ),
    );
  }

  /// Show the review bottom sheet for editing an existing review
  static Future<bool?> showEdit({
    required BuildContext context,
    required String targetId,
    required String targetType,
    required String serviceName,
    required String reviewId,
    required double existingRating,
    required String existingComment,
    VoidCallback? onReviewSubmitted,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ReviewBottomSheet(
        targetId: targetId,
        targetType: targetType,
        serviceName: serviceName,
        onReviewSubmitted: onReviewSubmitted,
        isEditMode: true,
        reviewId: reviewId,
        existingRating: existingRating,
        existingComment: existingComment,
      ),
    );
  }

  @override
  State<ReviewBottomSheet> createState() => _ReviewBottomSheetState();
}

class _ReviewBottomSheetState extends State<ReviewBottomSheet> {
  late double _rating;
  late TextEditingController _commentController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _rating = widget.existingRating ?? 0;
    _commentController = TextEditingController(text: widget.existingComment ?? '');
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submitReview() {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء اختيار تقييم'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Comment is optional, no form validation needed

    if (widget.isEditMode && widget.reviewId != null) {
      // Update existing review
      context.read<ReviewBloc>().add(
            ReviewUpdated(
              reviewId: widget.reviewId!,
              rating: _rating,
              comment: _commentController.text.trim(),
            ),
          );
    } else {
      // Create new review
      context.read<ReviewBloc>().add(
            ReviewSubmitted(
              targetId: widget.targetId,
              targetType: widget.targetType,
              rating: _rating,
              comment: _commentController.text.trim(),
            ),
          );
    }
  }

  void _deleteReview() {
    if (widget.reviewId == null) return;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'حذف التقييم',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'هل أنت متأكد من حذف هذا التقييم؟\nلا يمكن التراجع عن هذا الإجراء.',
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              'إلغاء',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<ReviewBloc>().add(ReviewDeleted(widget.reviewId!));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  void _showDuplicateReviewDialog(BuildContext context, ReviewDuplicateDetected state) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated icon container
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.star_rounded,
                      color: AppColors.gold,
                      size: 36,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Title
              const Text(
                'لديك تقييم بالفعل!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Message
              Text(
                'لقد قمت بتقييم هذه الخدمة من قبل.\nيمكنك تعديل تقييمك أو حذفه من قسم التقييمات أدناه.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Primary button - View reviews
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    Navigator.of(context).pop(false);
                    // Trigger a refresh of reviews
                    if (state.targetType == 'venue') {
                      context.read<ReviewBloc>().add(VenueReviewsRequested(state.targetId));
                    } else {
                      context.read<ReviewBloc>().add(ServiceReviewsRequested(state.targetId));
                    }
                    // Show guidance snackbar
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Row(
                          children: [
                            Icon(Icons.arrow_downward, color: Colors.white, size: 20),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'مرر لأسفل للوصول إلى تقييمك واضغط عليه للتعديل',
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                        backgroundColor: AppColors.gold,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        duration: const Duration(seconds: 4),
                      ),
                    );
                  },
                  icon: const Icon(Icons.rate_review_outlined, size: 20),
                  label: const Text(
                    'عرض تقييمي',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Secondary button - Close
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    Navigator.of(context).pop(false);
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    'إغلاق',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ReviewBloc, ReviewState>(
      listener: (context, state) {
        if (state is ReviewSubmitSuccess) {
          Navigator.of(context).pop(true);
          widget.onReviewSubmitted?.call();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is ReviewUpdateSuccess) {
          Navigator.of(context).pop(true);
          widget.onReviewSubmitted?.call();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is ReviewDeleteSuccess) {
          Navigator.of(context).pop(true);
          widget.onReviewSubmitted?.call();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is ReviewDuplicateDetected) {
          _showDuplicateReviewDialog(context, state);
        } else if (state is ReviewError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Title
                  Text(
                    widget.isEditMode
                        ? 'تعديل تقييم ${widget.serviceName}'
                        : 'قيّم ${widget.serviceName}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),

                  // Subtitle
                  Text(
                    widget.isEditMode
                        ? 'يمكنك تعديل تقييمك أو حذفه'
                        : 'شاركنا تجربتك لمساعدة الآخرين',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // Star Rating
                  _buildStarRating(),
                  const SizedBox(height: 8),

                  // Rating text
                  Text(
                    _getRatingText(),
                    style: TextStyle(
                      fontSize: 14,
                      color: _rating > 0 ? AppColors.gold : Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // Comment field (optional)
                  TextFormField(
                    controller: _commentController,
                    maxLines: 4,
                    maxLength: 500,
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                    decoration: InputDecoration(
                      hintText: 'اكتب تعليقك هنا (اختياري)...',
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.gold, width: 2),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.red),
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                    // Comment is now optional - no validator needed
                  ),
                  const SizedBox(height: 24),

                  // Submit/Update button
                  BlocBuilder<ReviewBloc, ReviewState>(
                    builder: (context, state) {
                      final isLoading = state is ReviewSubmitting ||
                                        state is ReviewUpdating ||
                                        state is ReviewDeleting;

                      return ElevatedButton(
                        onPressed: isLoading ? null : _submitReview,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.gold,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                          disabledBackgroundColor: AppColors.gold.withValues(alpha: 0.5),
                        ),
                        child: isLoading && state is! ReviewDeleting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text(
                                widget.isEditMode ? 'تحديث التقييم' : 'إرسال التقييم',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      );
                    },
                  ),

                  // Delete button (only in edit mode)
                  if (widget.isEditMode && widget.reviewId != null) ...[
                    const SizedBox(height: 12),
                    BlocBuilder<ReviewBloc, ReviewState>(
                      builder: (context, state) {
                        final isDeleting = state is ReviewDeleting;

                        return OutlinedButton.icon(
                          onPressed: isDeleting ? null : _deleteReview,
                          icon: isDeleting
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                                  ),
                                )
                              : const Icon(Icons.delete_outline, size: 20),
                          label: Text(isDeleting ? 'جاري الحذف...' : 'حذف التقييم'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      },
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Cancel button
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(
                      'إلغاء',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStarRating() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final starIndex = 5 - index; // Reverse for RTL
        return GestureDetector(
          onTap: () {
            setState(() {
              _rating = starIndex.toDouble();
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Icon(
              starIndex <= _rating ? Icons.star_rounded : Icons.star_outline_rounded,
              size: 44,
              color: starIndex <= _rating ? AppColors.gold : Colors.grey.shade300,
            ),
          ),
        );
      }),
    );
  }

  String _getRatingText() {
    switch (_rating.toInt()) {
      case 1:
        return 'سيء';
      case 2:
        return 'مقبول';
      case 3:
        return 'جيد';
      case 4:
        return 'جيد جداً';
      case 5:
        return 'ممتاز';
      default:
        return 'اضغط على النجوم للتقييم';
    }
  }
}
