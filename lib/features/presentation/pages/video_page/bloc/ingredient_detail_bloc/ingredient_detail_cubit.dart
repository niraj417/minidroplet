import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/network/api_controller.dart';
import '../../../../../../core/network/api_endpoints.dart';

import '../../model/all_recipe_video_model.dart';
import '../../model/ingredient_detail_model.dart';

/// ---------- STATES ----------
abstract class IngredientDetailState {}

class IngredientDetailInitial extends IngredientDetailState {}

class IngredientDetailLoading extends IngredientDetailState {}

class IngredientDetailError extends IngredientDetailState {
  final String message;
  IngredientDetailError(this.message);
}

class IngredientDetailLoaded extends IngredientDetailState {
  final IngredientDetailDataModel ingredientData;
  IngredientDetailLoaded(this.ingredientData);
}

class IngredientRelatedRecipesLoaded extends IngredientDetailState {
  final List<AllRecipeVideoDataModel> relatedVideos;
  IngredientRelatedRecipesLoaded(this.relatedVideos);
}

class IngredientDetailLoadedWithVideos extends IngredientDetailState {
  final IngredientDetailDataModel ingredientData;
  final List<AllRecipeVideoDataModel> allRecipeVideoList;

  IngredientDetailLoadedWithVideos({
    required this.ingredientData,
    required this.allRecipeVideoList,
  });
}

/// ---------- CUBIT ----------
class IngredientDetailCubit extends Cubit<IngredientDetailState> {
  final DioClient dioClient;

  IngredientDetailCubit(this.dioClient) : super(IngredientDetailInitial());

  // Fixed fetchAll method
  Future<void> fetchAll(int ingredientId) async {
    emit(IngredientDetailLoading());

    try {
      // Execute both APIs concurrently
      final results = await Future.wait([
        _fetchIngredientDetailsInternal(ingredientId),
        _fetchRelatedRecipesInternal(ingredientId),
      ]);

      final ingredientData = results[0] as IngredientDetailDataModel?;
      final relatedVideos = results[1] as List<AllRecipeVideoDataModel>?;

      if (ingredientData != null) {
        emit(IngredientDetailLoadedWithVideos(
          ingredientData: ingredientData,
          allRecipeVideoList: relatedVideos ?? [],
        ));
      } else {
        emit(IngredientDetailError('Failed to fetch ingredient details'));
      }
    } catch (e) {
      emit(IngredientDetailError(e.toString()));
    }
  }

  // Internal method - doesn't emit states directly
  Future<IngredientDetailDataModel?> _fetchIngredientDetailsInternal(int ingredientId) async {
    try {
      final response = await dioClient.sendPostRequest(
        ApiEndpoints.ingredientDetail,
        {'ingrediant_id': ingredientId.toString()},
      );

      debugPrint("Ingredient details response: ---------> ${response.data}");

      if (response.data != null) {
        final model = IngredientDetailModel.fromJson(response.data);
        if (model.status == 1 && model.data != null) {
          return model.data!;
        }
      }
      return null;
    } catch (e) {
      debugPrint("Error fetching ingredient details: $e");
      return null;
    }
  }

  // Internal method - doesn't emit states directly
  Future<List<AllRecipeVideoDataModel>?> _fetchRelatedRecipesInternal(int ingredientId) async {
    try {
      debugPrint("🔍 Fetching related recipes for ingredient: $ingredientId");

      final response = await dioClient.sendPostRequest(
        ApiEndpoints.relatedRecipe,
        {'ingrediant_id': ingredientId.toString()},
      );

      debugPrint("📡 Related recipes RAW response: ${response.data}");
      debugPrint("📡 Response status code: ${response.statusCode}");

      if (response.data != null) {
        final model = AllRecipeVideoModel.fromJson(response.data);

        debugPrint("📊 Model status: ${model.status}");
        debugPrint("📊 Model message: ${model.message}");
        debugPrint("📊 Model data length: ${model.data?.length ?? 0}");

        if (model.status == 1 && model.data != null) {
          debugPrint("✅ Successfully parsed ${model.data!.length} related recipes");
          return model.data!;
        } else {
          debugPrint("❌ API returned status: ${model.status}, message: ${model.message}");
        }
      } else {
        debugPrint("❌ Response data is null");
      }
      return [];
    } catch (e) {
      debugPrint("💥 Error fetching related recipes: $e");
      debugPrint("💥 Stack trace: ${StackTrace.current}");
      return [];
    }
  }

  // Keep these for individual calls if needed
  Future<void> fetchIngredientDetails(int ingredientId) async {
    emit(IngredientDetailLoading());

    final data = await _fetchIngredientDetailsInternal(ingredientId);
    if (data != null) {
      emit(IngredientDetailLoaded(data));
    } else {
      emit(IngredientDetailError('Failed to fetch ingredient details'));
    }
  }

  Future<void> fetchRelatedRecipes(int ingredientId) async {
    final videos = await _fetchRelatedRecipesInternal(ingredientId);
    if (videos != null) {
      emit(IngredientRelatedRecipesLoaded(videos));
    } else {
      emit(IngredientDetailError('Failed to fetch related recipes'));
    }
  }
}
