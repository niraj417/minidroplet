import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/network/api_controller.dart';
import '../../../../../../core/network/api_endpoints.dart';

import '../../model/all_recipe_video_model.dart';
import '../../model/ingredient_detail_model.dart';

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

class IngredientDetailCubit extends Cubit<IngredientDetailState> {
  IngredientDetailCubit(this.dioClient) : super(IngredientDetailInitial());

  final DioClient dioClient;
  int _requestToken = 0;

  Future<void> fetchAll(int ingredientId) async {
    if (ingredientId <= 0) {
      emit(IngredientDetailError('Invalid ingredient selected.'));
      return;
    }

    final requestToken = ++_requestToken;
    emit(IngredientDetailLoading());

    try {
      final results = await Future.wait<dynamic>([
        _fetchIngredientDetailsInternal(ingredientId),
        _fetchRelatedRecipesInternal(ingredientId),
      ]);

      if (isClosed || requestToken != _requestToken) {
        debugPrint(
          'Skipping stale ingredient detail response for ingredientId=$ingredientId',
        );
        return;
      }

      final ingredientData = results[0] as IngredientDetailDataModel?;
      final relatedVideos =
          (results[1] as List<AllRecipeVideoDataModel>?) ?? const [];

      if (ingredientData == null) {
        emit(IngredientDetailError('Failed to fetch ingredient details.'));
        return;
      }

      debugPrint(
        'Loaded ingredientId=$ingredientId with ${relatedVideos.length} related recipes',
      );
      emit(
        IngredientDetailLoadedWithVideos(
          ingredientData: ingredientData,
          allRecipeVideoList: relatedVideos,
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('fetchAll failed for ingredientId=$ingredientId: $e');
      debugPrint('$stackTrace');
      if (isClosed || requestToken != _requestToken) {
        return;
      }
      emit(IngredientDetailError('Something went wrong while loading data.'));
    }
  }

  Future<IngredientDetailDataModel?> _fetchIngredientDetailsInternal(
    int ingredientId,
  ) async {
    try {
      final response = await dioClient.sendPostRequest(
        ApiEndpoints.ingredientDetail,
        {'ingrediant_id': ingredientId.toString()},
      );

      debugPrint('Ingredient detail response for $ingredientId: ${response.data}');

      if (response.data is! Map<String, dynamic>) {
        debugPrint('Ingredient detail response was not a JSON object');
        return null;
      }

      final model = IngredientDetailModel.fromJson(response.data);
      if (model.status == 1 && model.data != null) {
        return model.data;
      }

      debugPrint(
        'Ingredient detail API returned status=${model.status}, message=${model.message}',
      );
      return null;
    } catch (e, stackTrace) {
      debugPrint('Error fetching ingredient details: $e');
      debugPrint('$stackTrace');
      return null;
    }
  }

  Future<List<AllRecipeVideoDataModel>> _fetchRelatedRecipesInternal(
    int ingredientId,
  ) async {
    try {
      debugPrint('Fetching related recipes for ingredientId=$ingredientId');

      final response = await dioClient.sendPostRequest(
        ApiEndpoints.relatedRecipe,
        {'ingrediant_id': ingredientId.toString()},
      );

      debugPrint('Related recipes response for $ingredientId: ${response.data}');
      debugPrint('Related recipes status code: ${response.statusCode}');

      if (response.data is! Map<String, dynamic>) {
        debugPrint('Related recipes response was not a JSON object');
        return const [];
      }

      final model = AllRecipeVideoModel.fromJson(response.data);
      debugPrint(
        'Related recipes parsed with status=${model.status}, count=${model.data.length}',
      );

      if (model.status == 1) {
        return model.data;
      }

      debugPrint(
        'Related recipes API returned status=${model.status}, message=${model.message}',
      );
      return const [];
    } catch (e, stackTrace) {
      debugPrint('Error fetching related recipes: $e');
      debugPrint('$stackTrace');
      return const [];
    }
  }

  Future<void> fetchIngredientDetails(int ingredientId) async {
    if (ingredientId <= 0) {
      emit(IngredientDetailError('Invalid ingredient selected.'));
      return;
    }

    emit(IngredientDetailLoading());

    final data = await _fetchIngredientDetailsInternal(ingredientId);
    if (data != null) {
      emit(IngredientDetailLoaded(data));
      return;
    }

    emit(IngredientDetailError('Failed to fetch ingredient details.'));
  }

  Future<void> fetchRelatedRecipes(int ingredientId) async {
    if (ingredientId <= 0) {
      emit(IngredientDetailError('Invalid ingredient selected.'));
      return;
    }

    final videos = await _fetchRelatedRecipesInternal(ingredientId);
    if (isClosed) {
      return;
    }
    emit(IngredientRelatedRecipesLoaded(videos));
  }
}
