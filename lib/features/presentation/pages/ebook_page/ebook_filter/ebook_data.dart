import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// lib/models/ebook_filter_params.dart


class EbookFilterParams {
  final List<String>? categories;
  final String? ageGroup;
  final double? minPrice;
  final double? maxPrice;
  final String? searchQuery;

  EbookFilterParams({
    this.categories,
    this.ageGroup,
    this.minPrice,
    this.maxPrice,
    this.searchQuery,
  });

  Map<String, dynamic> toJson() {
    return {
      if (categories != null && categories!.isNotEmpty)
        'category': categories!.join(','),
      if (ageGroup != null) 'age_group': ageGroup,
      if (minPrice != null) 'min_price': minPrice.toString(),
      if (maxPrice != null) 'max_price': maxPrice.toString(),
      if (searchQuery != null && searchQuery!.isNotEmpty) 'search': searchQuery,
    };
  }
}

// lib/models/ebook.dart
class Ebook {
  final String id;
  final String title;
  final String description;
  final double price;
  final String category;
  final String ageGroup;

  Ebook({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.category,
    required this.ageGroup,
  });

  factory Ebook.fromJson(Map<String, dynamic> json) {
    return Ebook(
      id: json['id'].toString(),
      title: json['title'],
      description: json['description'],
      price: double.parse(json['price'].toString()),
      category: json['category'],
      ageGroup: json['age_group'],
    );
  }
}



/// Ebook service

// lib/services/ebook_service.dart


class EbookService {
  final DioClient _dioClient;

  EbookService({DioClient? dioClient}) : _dioClient = dioClient ?? DioClient();

  Future<List<Ebook>> searchEbooks(EbookFilterParams params) async {
    try {
      final formData = FormData.fromMap(params.toJson());
      final response = await _dioClient.dio.post('/search_ebooks', data: formData);

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => Ebook.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch ebooks');
      }
    } catch (e) {
      throw Exception('Error searching ebooks: $e');
    }
  }
}


// lib/bloc/ebook_search_event.dart
abstract class EbookSearchEvent {}

class SearchEbooks extends EbookSearchEvent {
  final EbookFilterParams params;
  SearchEbooks(this.params);
}

// lib/bloc/ebook_search_state.dart
abstract class EbookSearchState {}

class EbookSearchInitial extends EbookSearchState {}

class EbookSearchLoading extends EbookSearchState {}

class EbookSearchSuccess extends EbookSearchState {
  final List<Ebook> ebooks;
  EbookSearchSuccess(this.ebooks);
}

class EbookSearchError extends EbookSearchState {
  final String message;
  EbookSearchError(this.message);
}

// lib/bloc/ebook_search_bloc.dart

class EbookSearchBloc extends Bloc<EbookSearchEvent, EbookSearchState> {
  final EbookService _ebookService;

  EbookSearchBloc(this._ebookService) : super(EbookSearchInitial()) {
    on<SearchEbooks>(_onSearchEbooks);
  }

  Future<void> _onSearchEbooks(
      SearchEbooks event,
      Emitter<EbookSearchState> emit,
      ) async {
    emit(EbookSearchLoading());

    try {
      final ebooks = await _ebookService.searchEbooks(event.params);
      emit(EbookSearchSuccess(ebooks));
    } catch (e) {
      emit(EbookSearchError(e.toString()));
    }
  }
}