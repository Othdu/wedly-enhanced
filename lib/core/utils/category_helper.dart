import '../../data/models/category_model.dart';
import '../../data/repositories/category_repository.dart';
import 'package:flutter/foundation.dart';

/// Helper class for category-related utilities
class CategoryHelper {
  /// Cached categories loaded from API
  static Map<String, CategoryModel>? _cachedCategories;

  /// Map of common category IDs/names to Arabic names
  /// This serves as a fallback when category data is not available
  static const Map<String, String> _categoryNameMap = {
    // English names
    'Photography': 'تصوير فوتوغرافي',
    'Videography': 'تصوير فيديو',
    'Decoration': 'كوش وديكور',
    'Music': 'فرق موسيقية',
    'Venue': 'قاعات أفراح',
    'Beauty': 'تجميل وميك أب',
    'Event Planning': 'تنظيم حفلات',
    'Cake': 'كيك وحلويات',
    'DJ': 'دي جي',
    'Makeup': 'ميك أب',
    'Wedding Dress': 'فستان زفاف',
    'Cars': 'سيارات',
    'Catering': 'تقديم طعام',
    'Wedding Planner': 'منظم حفلات زفاف',

    // Numeric IDs
    '1': 'تصوير فوتوغرافي',
    '2': 'كوش وديكور',
    '3': 'فرق موسيقية',
    '4': 'قاعات أفراح',
    '5': 'تجميل وميك أب',
    '6': 'تنظيم حفلات',
    '7': 'كيك وحلويات',
    '8': 'دي جي',
  };

  /// Load categories from repository and cache them
  static Future<void> loadCategories(CategoryRepository repository) async {
    try {
      final categories = await repository.getCategories();
      _cachedCategories = {
        for (var category in categories) category.id: category,
      };
    } catch (e) {
      // Keep existing cache or leave as null
      debugPrint('Failed to load categories: $e');
    }
  }

  /// Get the Arabic name for a category using cached data
  ///
  /// First checks the cache loaded from API, then falls back to static map
  static String getCategoryArabicName(String? category) {
    if (category == null || category.isEmpty) {
      return 'غير محدد';
    }

    // First check cached categories from API
    if (_cachedCategories != null && _cachedCategories!.containsKey(category)) {
      return _cachedCategories![category]!.nameAr;
    }

    // Check if it's in the static map (by ID or name)
    if (_categoryNameMap.containsKey(category)) {
      return _categoryNameMap[category]!;
    }

    // If it looks like a MongoDB ObjectId (24 hex characters), return unknown
    if (category.length == 24 && RegExp(r'^[0-9a-fA-F]+$').hasMatch(category)) {
      return 'غير محدد';
    }

    // Return the original string if not found
    return category;
  }

  /// Get category model from cache
  static CategoryModel? getCategoryById(String? categoryId) {
    if (categoryId == null || _cachedCategories == null) {
      return null;
    }
    return _cachedCategories![categoryId];
  }

  /// Check if a category string looks like an ID
  static bool isCategoryId(String category) {
    // MongoDB ObjectId is 24 hex characters
    return category.length == 24 &&
        RegExp(r'^[0-9a-fA-F]+$').hasMatch(category);
  }

  /// Clear cached categories (useful for testing or forcing refresh)
  static void clearCache() {
    _cachedCategories = null;
  }
}
