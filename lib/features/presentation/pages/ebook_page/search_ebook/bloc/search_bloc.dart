// search_ebook_event.dart
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/network/api_controller.dart';
import '../../../../../../core/network/api_endpoints.dart';
import '../../../../../../core/services/payment_service.dart';
// video_model.dart

class Category {
  final dynamic id;
  final String name;

  Category({
    required this.id,
    required this.name,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? json['category_id'],
      name: json['name'] ?? json['category_name'] ?? '',
    );
  }
}


abstract class SearchEbookEvent {}

class SearchEbookQueryChanged extends SearchEbookEvent {
  final String query;
  final dynamic categoryId;

  SearchEbookQueryChanged({
    required this.query,
    this.categoryId,
  });
}

class LoadCategories extends SearchEbookEvent {}

class SelectCategory extends SearchEbookEvent {
  final dynamic categoryId;
  SelectCategory(this.categoryId);
}

class ClearSearchEbook extends SearchEbookEvent {}

// search_ebook_state.dart
abstract class SearchEbookState {
  const SearchEbookState();
}

class SearchEbookInitial extends SearchEbookState {
  const SearchEbookInitial();
}

class SearchEbookLoading extends SearchEbookState {
  const SearchEbookLoading();
}

class SearchEbookLoaded extends SearchEbookState {
  final List<dynamic> results;
  final List<Category> categories;
  final dynamic selectedCategoryId;

  const SearchEbookLoaded({
    required this.results,
    required this.categories,
    this.selectedCategoryId,
  });

  SearchEbookLoaded copyWith({
    List<dynamic>? results,
    List<Category>? categories,
    dynamic selectedCategoryId,
  }) {
    return SearchEbookLoaded(
      results: results ?? this.results,
      categories: categories ?? this.categories,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
    );
  }
}

class SearchEbookError extends SearchEbookState {
  final String message;
  const SearchEbookError(this.message);
}


class SearchEbookBloc extends Bloc<SearchEbookEvent, SearchEbookState> {
  String _currentQuery = '';
  dynamic _selectedCategoryId;
  List<Category> _categories = [];

  SearchEbookBloc() : super(const SearchEbookInitial()) {
    on<SearchEbookQueryChanged>(_onQueryChanged);
    on<LoadCategories>(_onLoadCategories);
    on<SelectCategory>(_onSelectCategory);
    on<ClearSearchEbook>(_onClearSearch);
  }

  Future<void> _onLoadCategories(
      LoadCategories event,
      Emitter<SearchEbookState> emit,
      ) async {
    try {
      final response = await dioClient.sendGetRequest(ApiEndpoints.ebookCategory);

      print('Category Response: ${response.data}');

      if (response.data != null) {
        var categoriesData = response.data['categories'] ?? response.data['data'] ?? [];

        if (categoriesData is! List) {
          categoriesData = [categoriesData];
        }

        _categories = categoriesData.map<Category>((category) {
          if (category is! Map<String, dynamic>) {
            return Category(
              id: category,
              name: category.toString(),
            );
          }
          return Category.fromJson(category);
        }).toList();

        emit(SearchEbookLoaded(
          results: [],
          categories: _categories,
          selectedCategoryId: _selectedCategoryId,
        ));
      } else {
        emit(const SearchEbookError('Failed to load categories'));
      }
    } catch (e, stackTrace) {
      print('Error loading categories: $e');
      print('Stack trace: $stackTrace');
      emit(SearchEbookError(e.toString()));
    }
  }

  Future<void> _onSelectCategory(
      SelectCategory event,
      Emitter<SearchEbookState> emit,
      ) async {
    _selectedCategoryId = event.categoryId;

    if (_currentQuery.isNotEmpty || _selectedCategoryId != null) {
      add(SearchEbookQueryChanged(
        query: _currentQuery,
        categoryId: _selectedCategoryId,
      ));
    } else {
      if (state is SearchEbookLoaded) {
        final currentState = state as SearchEbookLoaded;
        emit(currentState.copyWith(
          selectedCategoryId: _selectedCategoryId,
          results: [],
        ));
      }
    }
  }

  Future<void> _onQueryChanged(
      SearchEbookQueryChanged event,
      Emitter<SearchEbookState> emit,
      ) async {
    _currentQuery = event.query;

    if (_currentQuery.isEmpty && _selectedCategoryId == null) {
      if (state is SearchEbookLoaded) {
        final currentState = state as SearchEbookLoaded;
        emit(currentState.copyWith(results: []));
      } else {
        emit(SearchEbookLoaded(
          results: [],
          categories: _categories,
          selectedCategoryId: null,
        ));
      }
      return;
    }

    emit(const SearchEbookLoading());

    try {
      final response = await dioClient.sendPostRequest(
        ApiEndpoints.searchEbook,
        {
          'search': _currentQuery,
          'category': _selectedCategoryId,
        },
      );

      print('Search Response: ${response.data}');

      if (response.data != null && response.data['status'] == 1) {
        var searchResults = response.data['data'] ?? [];

        if (searchResults is! List) {
          searchResults = [searchResults];
        }

        emit(SearchEbookLoaded(
          results: searchResults,
          categories: _categories,
          selectedCategoryId: _selectedCategoryId,
        ));
      } else {
        emit(SearchEbookLoaded(
          results: [],
          categories: _categories,
          selectedCategoryId: _selectedCategoryId,
        ));
      }
    } catch (e, stackTrace) {
      print('Error in search: $e');
      print('Stack trace: $stackTrace');
      emit(SearchEbookError(e.toString()));
    }
  }

  Future<void> _onClearSearch(
      ClearSearchEbook event,
      Emitter<SearchEbookState> emit,
      ) async {
    _currentQuery = '';
    _selectedCategoryId = null;

    if (state is SearchEbookLoaded) {
      final currentState = state as SearchEbookLoaded;
      emit(currentState.copyWith(
        results: [],
        selectedCategoryId: null,
      ));
    } else {
      emit(SearchEbookLoaded(
        results: [],
        categories: _categories,
        selectedCategoryId: null,
      ));
    }
  }
}