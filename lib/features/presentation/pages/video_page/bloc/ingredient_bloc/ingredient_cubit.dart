import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/network/api_controller.dart';
import '../../../../../../core/network/api_endpoints.dart';

// States
abstract class IngredientCategoryState {}

class IngredientCategoryInitial extends IngredientCategoryState {}

class IngredientCategoryLoading extends IngredientCategoryState {}

class IngredientCategoryLoaded extends IngredientCategoryState {
  final List<Map<String, dynamic>> categories;

  IngredientCategoryLoaded(this.categories);
}

class IngredientCategoryError extends IngredientCategoryState {
  final String message;

  IngredientCategoryError(this.message);
}

// Cubit
class IngredientCategoryCubit extends Cubit<IngredientCategoryState> {
  final DioClient dioClient;

  IngredientCategoryCubit(this.dioClient) : super(IngredientCategoryInitial());

  Future<void> fetchIngredientCategories() async {
    emit(IngredientCategoryLoading());

    try {
      final response = await dioClient.sendGetRequest(ApiEndpoints.ingredientCategory);
      debugPrint("Ingredient categories: ---------> ${response.data}");

      if (response.data['status'] == 1 && response.data != null) {
        final List<dynamic> rawData = response.data['data'];
        final List<Map<String, dynamic>> categories = rawData
            .map((item) => {
          'id': item['id'],
          'name': item['name'],
          'imageUrl': item['image'],
          'status': item['status'],
          'createdAt': item['created_at'],
        })
            .toList();

        emit(IngredientCategoryLoaded(categories));
      } else {
        emit(IngredientCategoryError('Failed to fetch data'));
      }
    } catch (e) {
      debugPrint("Error: ---------> ${e.toString()}");
      emit(IngredientCategoryError(e.toString()));
    }
  }

}