import 'package:wedly/data/models/category_model.dart';
import 'package:wedly/data/services/api_client.dart';
import 'package:wedly/data/services/api_constants.dart';

/// Repository for category-related operations
class CategoryRepository {
  final ApiClient _apiClient;

  CategoryRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Fetch all categories from the API
  Future<List<CategoryModel>> getCategories() async {
    final response = await _apiClient.get(ApiConstants.categories);

    final data = response.data;

    dynamic categoriesJson;

    if (data is Map) {
      if (data.containsKey('data') && data['data'] is Map) {
        categoriesJson = data['data']['categories'];
      } else if (data.containsKey('data') && data['data'] is List) {
        categoriesJson = data['data'];
      } else if (data.containsKey('categories')) {
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
}
