import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../core/network/api_controller.dart';
import '../../../../../../core/network/api_endpoints.dart';
// States
abstract class IngredientState {}

class IngredientInitial extends IngredientState {}

class IngredientLoading extends IngredientState {}

class IngredientLoaded extends IngredientState {
  final List<Map<String, dynamic>> ingredients;

  IngredientLoaded(this.ingredients);
}

class IngredientError extends IngredientState {
  final String message;

  IngredientError(this.message);
}

// Cubit
class IngredientCubit extends Cubit<IngredientState> {
  final DioClient dioClient;

  IngredientCubit(this.dioClient) : super(IngredientInitial());

  Future<void> fetchIngredients(int categoryId) async {
    emit(IngredientLoading());

    try {
      final response = await dioClient.sendGetRequest(
          '${ApiEndpoints.allIngredient}?category_id=$categoryId'
      );

      debugPrint("Ingredients data: ---------> ${response.data}");

      if (response.data['status'] == 1 && response.data != null) {
        // Map the response directly without creating a model
        final List<dynamic> rawData = response.data['data'];
        final List<Map<String, dynamic>> ingredients = rawData
            .map((item) => {
          'id': item['id'],
          'name': item['name'],
          'imageUrl': item['image'],
          'categoryId': item['category'],
          'description': item['description'],
          'status': item['status'],
          'createdAt': item['created_at'],
        })
            .toList();

        emit(IngredientLoaded(ingredients));
      } else {
        emit(IngredientError('Failed to fetch ingredients'));
      }
    } catch (e) {
      debugPrint("Error: ---------> ${e.toString()}");
      emit(IngredientError(e.toString()));
    }
  }
}