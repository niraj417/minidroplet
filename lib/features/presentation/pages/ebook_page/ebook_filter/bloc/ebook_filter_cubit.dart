// import 'package:equatable/equatable.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
//
// import '../../../../../../core/network/api_controller.dart';
// import '../../../../../../core/network/api_endpoints.dart';
//
// class EbookSearchState extends Equatable {
//   final List<Map<String, dynamic>> books;
//   final bool isLoading;
//   final Map<String, List<String>> selectedFilters;
//   final double minPrice;
//   final double maxPrice;
//   final String searchQuery;
//   final List<Map<String, dynamic>> categories;
//   final List<Map<String, dynamic>> ageGroups;
//   final bool isFilterLoading;
//
//   const EbookSearchState({
//     this.books = const [],
//     this.isLoading = false,
//     this.selectedFilters = const {
//       'category': [],
//       'age_group': [],
//     },
//     this.minPrice = 1,
//     this.maxPrice = 20000,
//     this.searchQuery = '',
//     this.categories = const [],
//     this.ageGroups = const [],
//     this.isFilterLoading = false,
//   });
//
//   EbookSearchState copyWith({
//     List<Map<String, dynamic>>? books,
//     bool? isLoading,
//     Map<String, List<String>>? selectedFilters,
//     double? minPrice,
//     double? maxPrice,
//     String? searchQuery,
//     List<Map<String, dynamic>>? categories,
//     List<Map<String, dynamic>>? ageGroups,
//     bool? isFilterLoading,
//   }) {
//     return EbookSearchState(
//       books: books ?? this.books,
//       isLoading: isLoading ?? this.isLoading,
//       selectedFilters: selectedFilters ?? this.selectedFilters,
//       minPrice: minPrice ?? this.minPrice,
//       maxPrice: maxPrice ?? this.maxPrice,
//       searchQuery: searchQuery ?? this.searchQuery,
//       categories: categories ?? this.categories,
//       ageGroups: ageGroups ?? this.ageGroups,
//       isFilterLoading: isFilterLoading ?? this.isFilterLoading,
//     );
//   }
//
//   @override
//   List<Object?> get props => [
//     books,
//     isLoading,
//     selectedFilters,
//     minPrice,
//     maxPrice,
//     searchQuery,
//     categories,
//     ageGroups,
//     isFilterLoading,
//   ];
// }
//
//
//
// class EbookSearchCubit extends Cubit<EbookSearchState> {
//   final DioClient dioClient;
//
//   EbookSearchCubit({required this.dioClient}) : super(const EbookSearchState()) {
//     fetchFilterData();
//     fetchBooks();
//   }
//
//   void updateSearchQuery(String query) {
//     emit(state.copyWith(searchQuery: query));
//     fetchBooks();
//   }
//
//   void updateFilters(Map<String, List<String>> filters, double minPrice, double maxPrice) {
//     emit(state.copyWith(
//       selectedFilters: filters,
//       minPrice: minPrice,
//       maxPrice: maxPrice,
//     ));
//     fetchBooks();
//   }
//
//   void clearFilters() {
//     emit(state.copyWith(
//       selectedFilters: {
//         'category': [],
//         'age_group': [],
//       },
//       minPrice: 1,
//       maxPrice: 20000,
//     ));
//     fetchBooks();
//   }
//
//   Future<void> fetchBooks() async {
//     emit(state.copyWith(isLoading: true));
//
//     try {
//       final queryParameters = {
//         if (state.searchQuery.isNotEmpty) 'search': state.searchQuery,
//         if (state.selectedFilters['category']!.isNotEmpty)
//           'category': state.selectedFilters['category']!.join(','),
//         if (state.selectedFilters['age_group']!.isNotEmpty)
//           'age_group': state.selectedFilters['age_group']!.join(','),
//         'min_price': state.minPrice.toString(),
//         'max_price': state.maxPrice.toString(),
//       };
//
//       final response = await dioClient.sendPostRequest(
//         ApiEndpoints.searchEbook,
//         queryParameters,
//       );
//
//       if (response.statusCode == 200 && response.data['status'] == 1) {
//         emit(state.copyWith(
//           books: List<Map<String, dynamic>>.from(response.data['data']),
//           isLoading: false,
//         ));
//       }
//     } catch (e) {
//       print('Error fetching books: $e');
//       emit(state.copyWith(isLoading: false));
//     }
//   }
//
//   Future<void> fetchFilterData() async {
//     emit(state.copyWith(isFilterLoading: true));
//
//     try {
//       final response = await dioClient.sendGetRequest(ApiEndpoints.ebookCategory);
//
//       if (response.statusCode == 200 && response.data['status'] == 1) {
//         emit(state.copyWith(
//           categories: List<Map<String, dynamic>>.from(response.data['data']['category']),
//           ageGroups: List<Map<String, dynamic>>.from(response.data['data']['age_group']),
//           isFilterLoading: false,
//         ));
//       }
//     } catch (e) {
//       print('Error fetching filter options: $e');
//       emit(state.copyWith(isFilterLoading: false));
//     }
//   }
// }