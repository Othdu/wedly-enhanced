import 'dart:async'; // تمت الإضافة لدعم الـ Debounce
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wedly/core/di/injection_container.dart';
import 'package:wedly/logic/blocs/search/search_bloc.dart';
import 'package:wedly/logic/blocs/search/search_event.dart';
import 'package:wedly/logic/blocs/search/search_state.dart';
import 'package:wedly/data/models/service_model.dart';
import 'package:wedly/presentation/widgets/skeleton_loading.dart';
import 'package:wedly/presentation/widgets/category_service_card.dart';
import 'package:wedly/routes/app_router.dart';

class UserSearchScreen extends StatefulWidget {
  const UserSearchScreen({super.key});

  @override
  State<UserSearchScreen> createState() => _UserSearchScreenState();

  // Public static method to focus search field
  static void focusSearchField() {
    _UserSearchScreenState.focusSearch();
  }
}

class _UserSearchScreenState extends State<UserSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  Timer? _debounce;
  bool _showSuggestions = false;

  // Static reference to the current instance
  static _UserSearchScreenState? _currentInstance;

  @override
  void initState() {
    super.initState();
    // Store reference to this instance
    _currentInstance = this;

    // الاستماع لتغييرات التركيز
    _searchFocusNode.addListener(() {
      setState(() {
        _showSuggestions = _searchFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    // Clear reference when disposing
    if (_currentInstance == this) {
      _currentInstance = null;
    }
    _debounce?.cancel(); // إلغاء التايمر عند الخروج
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  // Method to focus the search field
  void focusSearchField() {
    _searchFocusNode.requestFocus();
  }

  // Static method to focus from outside
  static void focusSearch() {
    _currentInstance?.focusSearchField();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<SearchBloc>()..add(const LoadCategories()),
      // تمت إضافة Directionality لضمان دعم كامل للغة العربية (RTL)
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: const Color(0xFFF5F5F5),
          body: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            behavior: HitTestBehavior.opaque,
            child: SafeArea(
              child: Column(
              children: [
                // شريط البحث
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: BlocBuilder<SearchBloc, SearchState>(
                    builder: (context, state) {
                      return TextField(
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        textInputAction: TextInputAction.search,
                        onSubmitted: (_) => FocusScope.of(context).unfocus(),
                        // تمت إزالة textAlign: TextAlign.right لأن Directionality تتكفل بها
                        style: const TextStyle(fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'ابحث عن قاعة، مصور، أو خدمة لحفلتك...',
                          hintStyle: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                          // prefixIcon يظهر يميناً في RTL
                          prefixIcon: const Padding(
                            padding: EdgeInsets.all(12),
                            child: Icon(
                              Icons.search,
                              color: Color(0xFFD4AF37),
                              size: 24,
                            ),
                          ),
                          // suffixIcon يظهر يساراً في RTL
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: Icon(
                                    Icons.clear,
                                    color: Colors.grey[400],
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    // إلغاء أي بحث جاري
                                    if (_debounce?.isActive ?? false) {
                                      _debounce!.cancel();
                                    }
                                    _searchController.clear();
                                    context.read<SearchBloc>().add(
                                      const ClearSearch(),
                                    );
                                    setState(() {});
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: const Color(0xFFF5F5F5),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onChanged: (value) {
                          // تحديث واجهة المستخدم لإظهار/إخفاء زر المسح
                          setState(() {});

                          // تحميل الاقتراحات فوراً
                          context.read<SearchBloc>().add(
                            LoadSuggestions(value),
                          );

                          // [تحسين] - إضافة Debounce لتقليل الضغط على الـ API
                          if (_debounce?.isActive ?? false) _debounce!.cancel();
                          _debounce = Timer(
                            const Duration(milliseconds: 500),
                            () {
                              // الحصول على الفئة المحددة حالياً من الـ Bloc
                              String? selectedCategory;
                              // استخدام context.read للحصول على الحالة الحالية
                              final currentState = context
                                  .read<SearchBloc>()
                                  .state;
                              if (currentState is SearchLoaded) {
                                selectedCategory =
                                    currentState.selectedCategory;
                              }

                              // تفعيل البحث
                              context.read<SearchBloc>().add(
                                SearchServices(
                                  query: value,
                                  category: selectedCategory,
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),

                // فلاتر الفئات
                BlocBuilder<SearchBloc, SearchState>(
                  builder: (context, state) {
                    if (state is SearchLoaded &&
                        state.availableCategories.isNotEmpty) {
                      return Container(
                        color: Colors.white,
                        padding: const EdgeInsets.only(
                          right: 16,
                          left: 16,
                          bottom: 12,
                        ),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            // تمت إزالة reverse: true لأن Directionality تتكفل بها
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                              // رقاقة "الكل" - الأولى من اليمين
                              _buildCategoryChip(
                                context,
                                'الكل',
                                null,
                                state.selectedCategory == null,
                              ),
                              const SizedBox(width: 8),

                              // رقائق الفئات - مرتبة من اليمين لليسار
                              // تمت إزالة .reversed
                              ...state.availableCategories.map((category) {
                                final isSelected =
                                    state.selectedCategory == category.id;
                                // [تحسين] - إضافة Padding هنا لتنظيم المسافات
                                return Padding(
                                  // استخدام padding right لعمل مسافة قبل العنصر في RTL
                                  padding: const EdgeInsets.only(right: 8),
                                  child: _buildCategoryChip(
                                    context,
                                    category.nameAr, // Display Arabic name
                                    category.id, // Use ID as value
                                    isSelected,
                                  ),
                                );
                              }),
                            ],
                          ),
                            ),
                          ),
                        );
                      
                    }
                    return const SizedBox.shrink();
                  },
                ),

                // قسم الاقتراحات
                BlocBuilder<SearchBloc, SearchState>(
                  builder: (context, state) {
                    if (!_showSuggestions || state is! SearchLoaded) {
                      return const SizedBox.shrink();
                    }

                    // إظهار الاقتراحات عند الكتابة
                    if (_searchController.text.isNotEmpty &&
                        state.suggestions.isNotEmpty) {
                      return _buildSuggestionsPanel(
                        context,
                        state.suggestions,
                        'اقتراحات البحث',
                        Icons.search,
                      );
                    }

                    // إظهار عمليات البحث الأخيرة عندما يكون الحقل فارغاً
                    if (_searchController.text.isEmpty &&
                        state.recentSearches.isNotEmpty) {
                      return _buildRecentSearchesPanel(
                        context,
                        state.recentSearches,
                      );
                    }

                    // إظهار الاقتراحات الشائعة
                    if (_searchController.text.isEmpty &&
                        state.popularSearches.isNotEmpty) {
                      return _buildSuggestionsPanel(
                        context,
                        state.popularSearches,
                        'اقتراحات شائعة',
                        Icons.trending_up,
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),

                // قسم النتائج
                Expanded(
                  child: BlocBuilder<SearchBloc, SearchState>(
                    builder: (context, state) {
                      if (state is SearchLoading) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFFD4AF37),
                          ),
                        );
                      } else if (state is SearchError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                size: 64,
                                color: Colors.red,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                state.message,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.red,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      } else if (state is SearchLoaded) {
                        // Show skeleton while refreshing
                        if (state.isRefreshing) {
                          return _buildLoadingSkeleton();
                        }

                        if (state.services.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 80,
                                  color: Colors.grey[300],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'لا توجد نتائج',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'جرب البحث بكلمات مختلفة',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: state.services.length,
                          itemBuilder: (context, index) {
                            final service = state.services[index];
                            return CategoryServiceCard(
                              service: service,
                              onTap: () => _navigateToServiceDetails(context, service),
                            );
                          },
                        );
                      }

                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ],
            ),
          ), // SafeArea
        ), // GestureDetector
        ),
      ),
    );
  }

  Widget _buildCategoryChip(
    BuildContext context,
    String label,
    String? category,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: () {
        // [تحسين] - توحيد منطق البحث. إرسال نفس الحدث
        // من الفلاتر ومن شريط البحث
        final newCategory = isSelected ? null : category;
        final currentQuery = _searchController.text;

        context.read<SearchBloc>().add(
          SearchServices(query: currentQuery, category: newCategory),
        );
        // [تحسين] - إخفاء الكيبورد عند اختيار فئة
        _searchFocusNode.unfocus();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFD4AF37) : Colors.white,
          borderRadius: BorderRadius.circular(33),
          border: Border.all(
            color: isSelected ? const Color(0xFFD4AF37) : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
          textDirection: TextDirection.rtl,
        ),
      ),
    );
  }


  Widget _buildSuggestionsPanel(
    BuildContext context,
    List<String> suggestions,
    String title,
    IconData icon,
  ) {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // عنوان القسم
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Icon(icon, size: 18, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),

          // قائمة الاقتراحات
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: suggestions.length > 6 ? 6 : suggestions.length,
            itemBuilder: (context, index) {
              final suggestion = suggestions[index];
              return InkWell(
                onTap: () {
                  // ملء حقل البحث بالاقتراح
                  _searchController.text = suggestion;

                  // حفظ في عمليات البحث الأخيرة
                  context.read<SearchBloc>().add(SaveRecentSearch(suggestion));

                  // تنفيذ البحث
                  final currentState = context.read<SearchBloc>().state;
                  String? selectedCategory;
                  if (currentState is SearchLoaded) {
                    selectedCategory = currentState.selectedCategory;
                  }

                  context.read<SearchBloc>().add(
                    SearchServices(
                      query: suggestion,
                      category: selectedCategory,
                    ),
                  );

                  // إخفاء الكيبورد
                  _searchFocusNode.unfocus();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey[200]!, width: 1),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          suggestion,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Icon(Icons.north_west, size: 16, color: Colors.grey[400]),
                    ],
                  ),
                ),
              );
            },
          ),

          // خط فاصل
          Container(height: 1, color: Colors.grey[300]),
        ],
      ),
    );
  }

  Widget _buildRecentSearchesPanel(
    BuildContext context,
    List<String> recentSearches,
  ) {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // عنوان القسم مع زر مسح الكل
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                const Icon(Icons.history, size: 18, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  'عمليات البحث الأخيرة',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                const Spacer(),
                // زر مسح الكل
                TextButton(
                  onPressed: () {
                    // عرض تأكيد قبل المسح
                    showDialog(
                      context: context,
                      builder: (dialogContext) => AlertDialog(
                        title: const Text('مسح السجل'),
                        content: const Text(
                          'هل تريد مسح جميع عمليات البحث الأخيرة؟',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(dialogContext),
                            child: const Text('إلغاء'),
                          ),
                          TextButton(
                            onPressed: () {
                              context.read<SearchBloc>().add(
                                const ClearRecentSearches(),
                              );
                              Navigator.pop(dialogContext);
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                            child: const Text('مسح الكل'),
                          ),
                        ],
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: const Size(0, 32),
                  ),
                  child: const Text('مسح الكل', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),

          // قائمة عمليات البحث الأخيرة
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recentSearches.length > 6 ? 6 : recentSearches.length,
            itemBuilder: (context, index) {
              final search = recentSearches[index];
              return Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey[200]!, width: 1),
                  ),
                ),
                child: Row(
                  children: [
                    // الجزء القابل للنقر للبحث
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          // ملء حقل البحث
                          _searchController.text = search;

                          // تنفيذ البحث
                          final currentState = context.read<SearchBloc>().state;
                          String? selectedCategory;
                          if (currentState is SearchLoaded) {
                            selectedCategory = currentState.selectedCategory;
                          }

                          context.read<SearchBloc>().add(
                            SearchServices(
                              query: search,
                              category: selectedCategory,
                            ),
                          );

                          // إخفاء الكيبورد
                          _searchFocusNode.unfocus();
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  search,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.north_west,
                                size: 16,
                                color: Colors.grey[400],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // زر الحذف
                    IconButton(
                      icon: const Icon(Icons.close),
                      iconSize: 18,
                      color: Colors.grey[400],
                      padding: const EdgeInsets.all(12),
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        context.read<SearchBloc>().add(
                          RemoveRecentSearch(search),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              );
            },
          ),

          // خط فاصل
          Container(height: 1, color: Colors.grey[300]),
        ],
      ),
    );
  }

  // Navigation logic based on service category
  void _navigateToServiceDetails(BuildContext context, ServiceModel service) {
    // Check for venue first (venues have chair_count)
    if (service.chairCount != null && service.chairCount! > 0) {
      // This is a venue service - navigate to venue details
      Navigator.pushNamed(
        context,
        AppRouter.venueDetails,
        arguments: {'venue': service.toVenueModel()},
      );
    } else {
      // All other services use the dynamic booking screen
      Navigator.pushNamed(
        context,
        AppRouter.dynamicServiceBooking,
        arguments: {'service': service},
      );
    }
  }

  // OLD HELPER METHODS - No longer needed with dynamic booking screen
  // Kept as comments for reference
  /*
  // Helper methods to identify service types
  bool _isPhotographerService(ServiceModel service) {
    final serviceCategory = service.category.toLowerCase();
    final photographerCategories = [
      'photography',
      'مصورين',
      'تصوير فوتوغرافي',
      'مصور',
    ];
    return photographerCategories.any(
      (category) => serviceCategory.contains(category.toLowerCase()),
    );
  }

  bool _isVideographerService(ServiceModel service) {
    final serviceCategory = service.category.toLowerCase();
    final videographerCategories = [
      'videography',
      'فيديوغراف',
      'فيديو',
      'تصوير فيديو',
    ];
    return videographerCategories.any(
      (category) => serviceCategory.contains(category.toLowerCase()),
    );
  }

  bool _isMakeupArtistService(ServiceModel service) {
    final serviceCategory = service.category.toLowerCase().trim();
    if (serviceCategory == 'beauty') return true;

    final makeupArtistCategories = [
      'beauty',
      'كوافير وميكب',
      'تجميل وميك أب',
      'ميكب',
      'كوافير',
      'تجميل',
      'makeup',
      'hair',
    ];
    return makeupArtistCategories.any(
      (category) => serviceCategory.contains(category.toLowerCase()),
    );
  }

  bool _isCarService(ServiceModel service) {
    final serviceCategory = service.category.toLowerCase().trim();
    final carCategories = [
      'cars',
      'سيارات',
      'سيارات الزفاف',
      'سيارات زفاف',
      'نقل',
      'transportation',
      'wedding cars',
    ];
    return carCategories.any(
      (category) => serviceCategory.contains(category.toLowerCase()),
    );
  }

  bool _isWeddingDressService(ServiceModel service) {
    final serviceCategory = service.category.toLowerCase().trim();
    final weddingDressCategories = [
      'wedding dress',
      'فساتين',
      'فساتين الزفاف',
      'فساتين زفاف',
      'فستان',
      'dresses',
      'bridal',
      'عروس',
    ];
    return weddingDressCategories.any(
      (category) => serviceCategory.contains(category.toLowerCase()),
    );
  }

  bool _isDecorationService(ServiceModel service) {
    final serviceCategory = service.category.toLowerCase().trim();
    final decorationCategories = [
      'decoration',
      'ديكور',
      'الديكور',
      'الديكور والزينة',
      'ديكور والزينة',
      'زينة',
      'تزيين',
      'decor',
      'كوش',
    ];
    return decorationCategories.any(
      (category) => serviceCategory.contains(category.toLowerCase()),
    );
  }

  bool _isWeddingPlannerService(ServiceModel service) {
    final serviceCategory = service.category.toLowerCase().trim();
    final weddingPlannerCategories = [
      'wedding planner',
      'منظم حفلات',
      'منظم',
      'تنظيم حفلات',
      'planner',
      'event planner',
    ];
    return weddingPlannerCategories.any(
      (category) => serviceCategory.contains(category.toLowerCase()),
    );
  }
  */

  /// Build skeleton loading for services list
  Widget _buildLoadingSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          height: 380,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: SkeletonLoading.shimmer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Image skeleton
                Container(
                  height: 200,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                ),
                // Content skeleton
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 20,
                        width: double.infinity,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 12),
                      Container(
                        height: 16,
                        width: 150,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 16),
                      Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
