import 'package:equatable/equatable.dart';
import 'package:wedly/data/models/service_model.dart';
import 'package:wedly/data/models/category_model.dart';

abstract class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class SearchInitial extends SearchState {
  const SearchInitial();
}

/// Loading state while searching
class SearchLoading extends SearchState {
  const SearchLoading();
}

/// Successfully loaded search results
class SearchLoaded extends SearchState {
  final List<ServiceModel> services;
  final String query;
  final String? selectedCategory;
  final List<CategoryModel> availableCategories;
  final List<String> suggestions; // Auto-complete suggestions
  final List<String> recentSearches; // Recent search history
  final List<String> popularSearches; // Popular/trending searches
  final bool isRefreshing; // Loading new data but keeping UI visible

  const SearchLoaded({
    required this.services,
    this.query = '',
    this.selectedCategory,
    this.availableCategories = const [],
    this.suggestions = const [],
    this.recentSearches = const [],
    this.popularSearches = const [],
    this.isRefreshing = false,
  });

  @override
  List<Object?> get props => [
        services,
        query,
        selectedCategory,
        availableCategories,
        suggestions,
        recentSearches,
        popularSearches,
        isRefreshing,
      ];

  SearchLoaded copyWith({
    List<ServiceModel>? services,
    String? query,
    String? selectedCategory,
    List<CategoryModel>? availableCategories,
    List<String>? suggestions,
    List<String>? recentSearches,
    List<String>? popularSearches,
    bool? isRefreshing,
  }) {
    return SearchLoaded(
      services: services ?? this.services,
      query: query ?? this.query,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      availableCategories: availableCategories ?? this.availableCategories,
      suggestions: suggestions ?? this.suggestions,
      recentSearches: recentSearches ?? this.recentSearches,
      popularSearches: popularSearches ?? this.popularSearches,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }
}

/// Error state
class SearchError extends SearchState {
  final String message;

  const SearchError(this.message);

  @override
  List<Object?> get props => [message];
}
