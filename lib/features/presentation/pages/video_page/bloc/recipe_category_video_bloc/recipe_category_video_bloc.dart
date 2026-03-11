import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../core/constant/app_export.dart';
import '../../../../../../core/network/api_endpoints.dart';
import '../../../../../../core/services/payment_service.dart';
import '../../model/all_recipe_video_model.dart';
import '../../model/recipe_subcategory_model.dart';

abstract class RecipeCategoryState {
  const RecipeCategoryState();
}

class RecipeCategoryInitial extends RecipeCategoryState {}

class RecipeCategoryLoading extends RecipeCategoryState {}

class RecipeCategoryError extends RecipeCategoryState {
  final String message;
  RecipeCategoryError(this.message);
}

class RecipeCategoryLoaded extends RecipeCategoryState {
  final List<AllRecipeVideoDataModel> videos;
  final List<RecipeSubcategoryDataModel> subcategories;
  final String currentCategoryId;

  RecipeCategoryLoaded({
    required this.videos,
    required this.subcategories,
    required this.currentCategoryId,
  });
}

// recipe_category_cubit.dart
class RecipeCategoryCubit extends Cubit<RecipeCategoryState> {
  final String initialCategoryId;
  final String categoryName;

  RecipeCategoryCubit({
    required this.initialCategoryId,
    required this.categoryName,
  }) : super(RecipeCategoryInitial()) {
    loadInitialData();
  }

  void loadInitialData() async {
    emit(RecipeCategoryLoading());
    try {
      final videos = await _fetchRecipeVideos(initialCategoryId);
      final subcategories = await _fetchSubcategories();
      emit(RecipeCategoryLoaded(
        videos: videos,
        subcategories: subcategories,
        currentCategoryId: initialCategoryId,
      ));
    } catch (e) {
      emit(RecipeCategoryError(e.toString()));
    }
  }

  void changeCategory(String newCategoryId) async {
    emit(RecipeCategoryLoading());
    try {
      // Always fetch videos using the new category ID
      final videos = await _fetchRecipeVideos(newCategoryId);

      if (state is RecipeCategoryLoaded) {
        final currentState = state as RecipeCategoryLoaded;
        emit(RecipeCategoryLoaded(
          videos: videos,
          subcategories: currentState.subcategories,
          currentCategoryId: newCategoryId,
        ));
      }
    } catch (e) {
      debugPrint('Error changing category: $e');
      emit(RecipeCategoryError(e.toString()));
    }
  }

  Future<List<AllRecipeVideoDataModel>> _fetchRecipeVideos(String categoryId) async {
    try {
      final response = await dioClient.sendGetRequest(
        ApiEndpoints.recipeCategoryVideo(categoryId),
      );

      if (response.data['status'] == 1) {
        final data = AllRecipeVideoModel.fromJson(response.data);
        return data.data ?? [];
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load data');
      }
    } catch (e) {
      debugPrint('Error fetching videos: $e');
      throw Exception('Failed to load recipe videos');
    }
  }

  Future<List<RecipeSubcategoryDataModel>> _fetchSubcategories() async {
    try {
      final response = await dioClient.sendPostRequest(
        ApiEndpoints.subcategoryList,
        {"category_id": initialCategoryId},
      );

      final model = RecipeSubcategoryModel.fromJson(response.data);
      if (model.status == 1) {
        // Add "All" category at the beginning of the list
        final allCategories = [
          RecipeSubcategoryDataModel(
            id: int.parse(initialCategoryId),
            name: 'All',
          ),
          ...model.data
        ];
        return allCategories;
      }
      throw Exception(model.message);
    } catch (e) {
      debugPrint('Error fetching subcategories: $e');
      throw Exception('Failed to load subcategories');
    }
  }
}

