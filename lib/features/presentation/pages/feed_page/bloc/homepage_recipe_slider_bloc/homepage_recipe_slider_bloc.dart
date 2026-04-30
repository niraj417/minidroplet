import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

import '../../../../../../core/network/api_controller.dart';
import '../../../../../../core/network/api_endpoints.dart';

/// ================= STATES =================
abstract class HomepageRecipeSliderState {}

class HomepageRecipeSliderInitial extends HomepageRecipeSliderState {}

class HomepageRecipeSliderLoading extends HomepageRecipeSliderState {}

class HomepageRecipeSliderLoaded extends HomepageRecipeSliderState {
  final List<Map<String, dynamic>> categories;

  HomepageRecipeSliderLoaded(this.categories);
}

class HomepageRecipeSliderError extends HomepageRecipeSliderState {
  final String message;

  HomepageRecipeSliderError(this.message);
}

/// ================= CUBIT =================
class HomepageRecipeSliderCubit
    extends Cubit<HomepageRecipeSliderState> {
  final DioClient dioClient;

  HomepageRecipeSliderCubit(this.dioClient)
      : super(HomepageRecipeSliderInitial());

  Future<void> fetchHomepageRecipeCategories() async {
    emit(HomepageRecipeSliderLoading());

    try {
      final response =
      await dioClient.sendGetRequest(ApiEndpoints.homepageRecipeSlider);

      debugPrint(
        'Homepage Recipe Slider API: ${response.data}',
      );

      if (response.data != null && response.data['status'] == 1) {
        final List raw = response.data['data'];

        final categories = raw
            .map<Map<String, dynamic>>(
              (item) => {
            'id': item['id'],
            'name': item['name'],
            'video_cat_id': item['video_cat_id'],
            'imageUrl': item['image'],
          },
        )
            .toList();

        emit(HomepageRecipeSliderLoaded(categories));
      } else {
        emit(
          HomepageRecipeSliderError(
            response.data['message'] ?? 'Failed to load categories',
          ),
        );
      }
    } catch (e) {
      debugPrint('HomepageRecipeSlider error: $e');
      emit(HomepageRecipeSliderError(e.toString()));
    }
  }
}
