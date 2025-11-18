import 'package:equatable/equatable.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

/// Event to search services with query and optional category filter
class SearchServices extends SearchEvent {
  final String query;
  final String? category;

  const SearchServices({
    required this.query,
    this.category,
  });

  @override
  List<Object?> get props => [query, category];
}

/// Event to filter by category only
class FilterByCategory extends SearchEvent {
  final String? category; // null means show all

  const FilterByCategory(this.category);

  @override
  List<Object?> get props => [category];
}

/// Event to clear search and show all services
class ClearSearch extends SearchEvent {
  const ClearSearch();
}

/// Event to load all categories for filter chips
class LoadCategories extends SearchEvent {
  const LoadCategories();
}

/// Event to load search suggestions based on query
class LoadSuggestions extends SearchEvent {
  final String query;

  const LoadSuggestions(this.query);

  @override
  List<Object?> get props => [query];
}

/// Event to save a search query to recent searches
class SaveRecentSearch extends SearchEvent {
  final String query;

  const SaveRecentSearch(this.query);

  @override
  List<Object?> get props => [query];
}

/// Event to remove a specific recent search
class RemoveRecentSearch extends SearchEvent {
  final String query;

  const RemoveRecentSearch(this.query);

  @override
  List<Object?> get props => [query];
}

/// Event to clear all recent searches
class ClearRecentSearches extends SearchEvent {
  const ClearRecentSearches();
}
