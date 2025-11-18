import 'package:equatable/equatable.dart';
import 'package:wedly/data/models/service_model.dart';

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
  final List<String> availableCategories;
  final List<String> suggestions; // Auto-complete suggestions
  final List<String> recentSearches; // Recent search history
  final List<String> popularSearches; // Popular/trending searches

  const SearchLoaded({
    required this.services,
    this.query = '',
    this.selectedCategory,
    this.availableCategories = const [],
    this.suggestions = const [],
    this.recentSearches = const [],
    this.popularSearches = const [],
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
      ];

  SearchLoaded copyWith({
    List<ServiceModel>? services,
    String? query,
    String? selectedCategory,
    List<String>? availableCategories,
    List<String>? suggestions,
    List<String>? recentSearches,
    List<String>? popularSearches,
  }) {
    return SearchLoaded(
      services: services ?? this.services,
      query: query ?? this.query,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      availableCategories: availableCategories ?? this.availableCategories,
      suggestions: suggestions ?? this.suggestions,
      recentSearches: recentSearches ?? this.recentSearches,
      popularSearches: popularSearches ?? this.popularSearches,
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
