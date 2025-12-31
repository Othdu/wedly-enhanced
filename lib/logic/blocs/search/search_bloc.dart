import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wedly/data/models/service_model.dart';
import 'package:wedly/data/repositories/service_repository.dart';
import 'package:wedly/logic/blocs/search/search_event.dart';
import 'package:wedly/logic/blocs/search/search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final ServiceRepository serviceRepository;
  static const String _recentSearchesKey = 'recent_searches';
  static const int _maxRecentSearches = 10;

  // Mock popular searches (will be replaced with API data)
  static const List<String> _mockPopularSearches = [
    'قاعات أفراح',
    'مصور أفراح',
    'كوافير',
    'تصوير فيديو',
    'زهور وتنسيق',
    'دي جي',
  ];

  SearchBloc({required this.serviceRepository}) : super(const SearchInitial()) {
    on<LoadCategories>(_onLoadCategories);
    on<SearchServices>(_onSearchServices);
    on<FilterByCategory>(_onFilterByCategory);
    on<ClearSearch>(_onClearSearch);
    on<LoadSuggestions>(_onLoadSuggestions);
    on<SaveRecentSearch>(_onSaveRecentSearch);
    on<RemoveRecentSearch>(_onRemoveRecentSearch);
    on<ClearRecentSearches>(_onClearRecentSearches);
  }

  /// تحميل جميع الفئات المتاحة
  Future<void> _onLoadCategories(
    LoadCategories event,
    Emitter<SearchState> emit,
  ) async {
    try {
      emit(const SearchLoading());

      // الحصول على جميع الخدمات والفئات
      final services = await serviceRepository.getServices();
      final categories = await serviceRepository.getCategoriesWithDetails();
      final recentSearches = await _getRecentSearches();

      emit(SearchLoaded(
        services: services,
        availableCategories: categories,
        recentSearches: recentSearches,
        popularSearches: _mockPopularSearches,
      ));
    } catch (e) {
      emit(const SearchError('حدث خطأ في تحميل البيانات'));
    }
  }

  /// البحث في الخدمات حسب الكلمة المفتاحية والفئة
  Future<void> _onSearchServices(
    SearchServices event,
    Emitter<SearchState> emit,
  ) async {
    try {
      // If already loaded, show refreshing state instead of full loading
      if (state is SearchLoaded) {
        emit((state as SearchLoaded).copyWith(isRefreshing: true));
      } else {
        emit(const SearchLoading());
      }

      // الحصول على جميع الخدمات
      final allServices = await serviceRepository.getServices();
      final categories = await serviceRepository.getCategoriesWithDetails();

      // Create a map for category ID to Arabic name lookup
      final categoryIdToNameMap = Map.fromEntries(
        categories.map((cat) => MapEntry(cat.id, cat.nameAr)),
      );

      // الفلترة حسب الفئة إذا تم تحديدها
      List<ServiceModel> filteredServices = allServices;
      if (event.category != null && event.category!.isNotEmpty) {
        filteredServices = allServices
            .where((service) => service.category == event.category)
            .toList();
      }

      // الفلترة حسب كلمة البحث
      if (event.query.isNotEmpty) {
        final query = event.query.toLowerCase().trim();
        filteredServices = filteredServices.where((service) {
          final serviceName = service.name.toLowerCase();
          final serviceDescription = service.description.toLowerCase();
          final categoryArabicName = categoryIdToNameMap[service.category]?.toLowerCase() ?? '';

          // Direct match in name, description, or category
          if (serviceName.contains(query) ||
              serviceDescription.contains(query) ||
              categoryArabicName.contains(query)) {
            return true;
          }

          // Smart keyword matching for Arabic search terms
          // Extract keywords from search query
          final searchKeywords = _extractArabicKeywords(query);

          // Check if service name or description contains any of the keywords
          for (final keyword in searchKeywords) {
            if (serviceName.contains(keyword) || serviceDescription.contains(keyword)) {
              return true;
            }
          }

          return false;
        }).toList();
      }

      emit(SearchLoaded(
        services: filteredServices,
        query: event.query,
        selectedCategory: event.category,
        availableCategories: categories,
      ));
    } catch (e) {
      emit(const SearchError('حدث خطأ في البحث'));
    }
  }

  /// Extract keywords from Arabic search terms for smart matching
  /// For example: "قاعات أفراح" -> ["قاعة", "قاعات", "قاعه", "أفراح", "فرح"]
  List<String> _extractArabicKeywords(String query) {
    final keywords = <String>[];
    final words = query.split(' ');

    for (final word in words) {
      if (word.isEmpty) continue;

      // Add the original word
      keywords.add(word);

      // Smart variations for common Arabic words
      if (word.contains('قاعات')) {
        keywords.addAll(['قاعة', 'قاعه', 'قاعات']);
      } else if (word.contains('قاعة')) {
        keywords.addAll(['قاعة', 'قاعه', 'قاعات']);
      } else if (word.contains('قاعه')) {
        keywords.addAll(['قاعة', 'قاعه', 'قاعات']);
      }

      if (word.contains('أفراح')) {
        keywords.addAll(['فرح', 'أفراح', 'افراح']);
      } else if (word.contains('فرح')) {
        keywords.addAll(['فرح', 'أفراح', 'افراح']);
      }

      if (word.contains('تصوير')) {
        keywords.addAll(['تصوير', 'مصور', 'مصورين', 'صور']);
      } else if (word.contains('مصور')) {
        keywords.addAll(['تصوير', 'مصور', 'مصورين', 'صور']);
      }

      if (word.contains('فوتوغراف')) {
        keywords.addAll(['فوتوغراف', 'فوتوغرافي', 'فوتوغرافيا']);
      }

      if (word.contains('كوافير')) {
        keywords.addAll(['كوافير', 'كوافيرة', 'تجميل', 'ميك', 'ميكب']);
      } else if (word.contains('تجميل')) {
        keywords.addAll(['كوافير', 'تجميل', 'ميك', 'ميكب']);
      }

      if (word.contains('ديكور')) {
        keywords.addAll(['ديكور', 'كوش', 'زينة', 'تزيين']);
      } else if (word.contains('كوش')) {
        keywords.addAll(['ديكور', 'كوش', 'زينة', 'تزيين']);
      }

      if (word.contains('موسيق')) {
        keywords.addAll(['موسيقى', 'موسيقي', 'فرقة', 'فرق']);
      } else if (word.contains('فرق')) {
        keywords.addAll(['موسيقى', 'فرقة', 'فرق']);
      }

      if (word.contains('حلويات')) {
        keywords.addAll(['حلويات', 'كيك', 'حلوى']);
      } else if (word.contains('كيك')) {
        keywords.addAll(['حلويات', 'كيك', 'حلوى']);
      }
    }

    return keywords.toSet().toList(); // Remove duplicates
  }

  /// الفلترة حسب الفئة فقط
  Future<void> _onFilterByCategory(
    FilterByCategory event,
    Emitter<SearchState> emit,
  ) async {
    try {
      // If already loaded, show refreshing state instead of full loading
      if (state is SearchLoaded) {
        emit((state as SearchLoaded).copyWith(isRefreshing: true));
      } else {
        emit(const SearchLoading());
      }

      final allServices = await serviceRepository.getServices();
      final categories = await serviceRepository.getCategoriesWithDetails();

      // الفلترة حسب الفئة إذا تم تحديدها، وإلا عرض الكل
      final filteredServices = event.category != null && event.category!.isNotEmpty
          ? allServices
              .where((service) => service.category == event.category)
              .toList()
          : allServices;

      // الحفاظ على كلمة البحث الحالية إذا كانت موجودة
      String currentQuery = '';
      if (state is SearchLoaded) {
        currentQuery = (state as SearchLoaded).query;
      }

      emit(SearchLoaded(
        services: filteredServices,
        query: currentQuery,
        selectedCategory: event.category,
        availableCategories: categories,
      ));
    } catch (e) {
      emit(const SearchError('حدث خطأ في الفلترة'));
    }
  }

  /// مسح البحث وعرض جميع الخدمات
  Future<void> _onClearSearch(
    ClearSearch event,
    Emitter<SearchState> emit,
  ) async {
    try {
      emit(const SearchLoading());

      final services = await serviceRepository.getServices();
      final categories = await serviceRepository.getCategoriesWithDetails();
      final recentSearches = await _getRecentSearches();

      emit(SearchLoaded(
        services: services,
        availableCategories: categories,
        recentSearches: recentSearches,
        popularSearches: _mockPopularSearches,
      ));
    } catch (e) {
      emit(const SearchError('حدث خطأ في تحميل البيانات'));
    }
  }

  /// تحميل الاقتراحات بناءً على كلمة البحث
  Future<void> _onLoadSuggestions(
    LoadSuggestions event,
    Emitter<SearchState> emit,
  ) async {
    try {
      // الحصول على الحالة الحالية
      if (state is! SearchLoaded) return;
      final currentState = state as SearchLoaded;

      // إذا كانت كلمة البحث فارغة، إظهار الاقتراحات الشائعة والأخيرة
      if (event.query.isEmpty) {
        final recentSearches = await _getRecentSearches();
        emit(currentState.copyWith(
          suggestions: [],
          recentSearches: recentSearches,
          popularSearches: _mockPopularSearches,
          isRefreshing: false,
        ));
        return;
      }

      // توليد اقتراحات بناءً على أسماء الخدمات والفئات
      final allServices = await serviceRepository.getServices();
      final categories = await serviceRepository.getCategoriesWithDetails();
      final query = event.query.toLowerCase();

      // جمع الاقتراحات من أسماء الخدمات
      final serviceSuggestions = allServices
          .where((service) => service.name.toLowerCase().contains(query))
          .map((service) => service.name)
          .toSet() // إزالة المكررات
          .take(5)
          .toList();

      // جمع الاقتراحات من الفئات (use Arabic names)
      final categorySuggestions = categories
          .where((category) => category.nameAr.toLowerCase().contains(query))
          .map((category) => category.nameAr)
          .take(3)
          .toList();

      // دمج الاقتراحات
      final suggestions = [
        ...serviceSuggestions,
        ...categorySuggestions,
      ].take(8).toList();

      emit(currentState.copyWith(
        suggestions: suggestions,
        isRefreshing: false,
      ));
    } catch (e) {
      // في حالة الخطأ، لا نغير الحالة
    }
  }

  /// حفظ كلمة بحث في السجل
  Future<void> _onSaveRecentSearch(
    SaveRecentSearch event,
    Emitter<SearchState> emit,
  ) async {
    try {
      if (event.query.trim().isEmpty) return;

      final prefs = await SharedPreferences.getInstance();
      final recentSearches = prefs.getStringList(_recentSearchesKey) ?? [];

      // إزالة الكلمة إذا كانت موجودة مسبقاً
      recentSearches.remove(event.query);

      // إضافة الكلمة في البداية
      recentSearches.insert(0, event.query);

      // الاحتفاظ بآخر 10 عمليات بحث فقط
      if (recentSearches.length > _maxRecentSearches) {
        recentSearches.removeRange(_maxRecentSearches, recentSearches.length);
      }

      // حفظ القائمة
      await prefs.setStringList(_recentSearchesKey, recentSearches);

      // تحديث الحالة إذا كانت SearchLoaded
      if (state is SearchLoaded) {
        final currentState = state as SearchLoaded;
        emit(currentState.copyWith(
          recentSearches: recentSearches,
          isRefreshing: false,
        ));
      }
    } catch (e) {
      // في حالة الخطأ، لا نغير الحالة
    }
  }

  /// الحصول على عمليات البحث الأخيرة
  Future<List<String>> _getRecentSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList(_recentSearchesKey) ?? [];
    } catch (e) {
      return [];
    }
  }

  /// حذف عملية بحث معينة من السجل
  Future<void> _onRemoveRecentSearch(
    RemoveRecentSearch event,
    Emitter<SearchState> emit,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recentSearches = prefs.getStringList(_recentSearchesKey) ?? [];

      // إزالة الكلمة المحددة
      recentSearches.remove(event.query);

      // حفظ القائمة المحدثة
      await prefs.setStringList(_recentSearchesKey, recentSearches);

      // تحديث الحالة إذا كانت SearchLoaded
      if (state is SearchLoaded) {
        final currentState = state as SearchLoaded;
        emit(currentState.copyWith(
          recentSearches: recentSearches,
          isRefreshing: false,
        ));
      }
    } catch (e) {
      // في حالة الخطأ، لا نغير الحالة
    }
  }

  /// مسح جميع عمليات البحث الأخيرة
  Future<void> _onClearRecentSearches(
    ClearRecentSearches event,
    Emitter<SearchState> emit,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // مسح القائمة
      await prefs.remove(_recentSearchesKey);

      // تحديث الحالة إذا كانت SearchLoaded
      if (state is SearchLoaded) {
        final currentState = state as SearchLoaded;
        emit(currentState.copyWith(
          recentSearches: [],
          isRefreshing: false,
        ));
      }
    } catch (e) {
      // في حالة الخطأ، لا نغير الحالة
    }
  }
}
