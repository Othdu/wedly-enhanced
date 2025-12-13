import 'package:wedly/data/models/category_model.dart';
import 'package:wedly/data/services/api_client.dart';
import 'package:wedly/data/services/api_constants.dart';

/// Repository for category-related operations
class CategoryRepository {
  final ApiClient? apiClient;
  final bool useMockData;

  CategoryRepository({
    this.apiClient,
    this.useMockData = false,
  });

  /// Fetch all categories from the API
  ///
  /// Returns a list of [CategoryModel] objects
  /// Throws [ApiException] on network or server errors
  Future<List<CategoryModel>> getCategories() async {
    if (useMockData) {
      // Mock implementation if needed
      await Future.delayed(const Duration(milliseconds: 500));
      return _getMockCategories();
    }

    final response = await apiClient!.get(ApiConstants.categories);

    // Handle API response structure
    final data = response.data;

    // Extract categories from nested structure: data.categories
    dynamic categoriesJson;

    if (data is Map) {
      if (data.containsKey('data') && data['data'] is Map) {
        // Response has nested structure: { data: { categories: [...] } }
        categoriesJson = data['data']['categories'];
      } else if (data.containsKey('data') && data['data'] is List) {
        // Response has structure: { data: [...] }
        categoriesJson = data['data'];
      } else if (data.containsKey('categories')) {
        // Response has structure: { categories: [...] }
        categoriesJson = data['categories'];
      } else {
        categoriesJson = data;
      }
    } else {
      categoriesJson = data;
    }

    if (categoriesJson is! List) {
      throw Exception('Invalid response format: expected a list of categories');
    }

    return categoriesJson
        .map((json) => CategoryModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Mock categories for testing (fallback)
  List<CategoryModel> _getMockCategories() {
    return [
      const CategoryModel(
        id: '1',
        name: 'Photography',
        nameAr: 'تصوير فوتوغرافي',
        imageUrl: '',
      ),
      const CategoryModel(
        id: '2',
        name: 'Decoration',
        nameAr: 'كوش وديكور',
        imageUrl: '',
      ),
      const CategoryModel(
        id: '3',
        name: 'Music',
        nameAr: 'فرق موسيقية',
        imageUrl: '',
      ),
      const CategoryModel(
        id: '4',
        name: 'Venue',
        nameAr: 'قاعات أفراح',
        imageUrl: '',
      ),
      const CategoryModel(
        id: '5',
        name: 'Beauty',
        nameAr: 'تجميل وميك أب',
        imageUrl: '',
      ),
      const CategoryModel(
        id: '6',
        name: 'Event Planning',
        nameAr: 'تنظيم حفلات',
        imageUrl: '',
      ),
      const CategoryModel(
        id: '7',
        name: 'Cake',
        nameAr: 'كيك وحلويات',
        imageUrl: '',
      ),
      const CategoryModel(
        id: '8',
        name: 'DJ',
        nameAr: 'دي جي',
        imageUrl: '',
      ),
    ];
  }
}
