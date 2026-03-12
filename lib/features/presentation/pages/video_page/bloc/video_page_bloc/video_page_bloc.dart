import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tinydroplets/features/presentation/pages/video_page/model/recipe_all_playlist_model.dart';

import '../../../../../../core/network/api_controller.dart';
import '../../../../../../core/network/api_endpoints.dart';
import '../../../../../../core/services/subscription_service.dart';
import '../../../feed_page/model/feed_slider_model.dart';
import '../../model/all_recipe_video_model.dart';
import '../../model/recipe_category_model.dart';
import '../../model/recipe_recommendation_model.dart';
// Add other necessary imports

class VideoPageCubit extends Cubit<VideoPageState> {
  final DioClient _dioClient = DioClient();

  VideoPageCubit() : super(VideoPageState.initial()) {
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    await refreshData();
  }


  Future<void> refreshData() async {

    emit(state.copyWith(isLoading: true));

    try {

      final results = await Future.wait([
        _dioClient.sendGetRequest(ApiEndpoints.recipeSlider),
        _dioClient.sendGetRequest(ApiEndpoints.recipeCategory),
        _dioClient.sendGetRequest(ApiEndpoints.recommendationRecipe),
        _dioClient.sendGetRequest(ApiEndpoints.allRecipeVideos),
        _dioClient.sendGetRequest(ApiEndpoints.recipeAllPlaylist),
        SubscriptionPaymentService.hasActiveSubscription(),
      ]);

      final sliderResponse = results[0] as Response;
      final categoryResponse = results[1] as Response;
      final recommendationResponse = results[2] as Response;
      final videoResponse = results[3] as Response;
      final playlistResponse = results[4] as Response;
      final subscription = results[5] as bool;

      emit(
        state.copyWith(
          recipeCarouselList:
          FeedSliderModel.fromJson(sliderResponse.data).data,

          allRecipeCategoryList:
          RecipeCategoryModel.fromJson(categoryResponse.data).data,

          recommendationRecipeList:
          RecipeRecommendationModel.fromJson(recommendationResponse.data).data ?? [],

          allRecipeVideoList:
          AllRecipeVideoModel.fromJson(videoResponse.data).data,

          recipeAllPlaylistList:
          RecipeAllPlaylistModel.fromJson(playlistResponse.data).data,

          subscribed: subscription,
          isLoading: false,
        ),
      );

    } catch (e) {

      debugPrint("Refresh error: $e");

      emit(state.copyWith(isLoading: false));
    }
  }





  Future<void> _loadSubscriptionStatus() async {
    try{
      final data = await SubscriptionPaymentService.hasActiveSubscription();
      emit(state.copyWith(subscribed: data));
    }catch(e){
      debugPrint('Error fetching video subscription status: $e');
    }
  }

  Future<void> fetchRecipeCarousel() async {
    try {
      final response =
          await _dioClient.sendGetRequest(ApiEndpoints.recipeSlider);
      if (response.data['status'] == 1) {
        final data = FeedSliderModel.fromJson(response.data);
        emit(state.copyWith(recipeCarouselList: data.data));
      }
    } catch (e) {
      debugPrint('Error fetching recipe carousel: $e');
    }
  }

  Future<void> fetchRecipeCategory() async {
    try {
      final response =
          await _dioClient.sendGetRequest(ApiEndpoints.recipeCategory);
      if (response.data['status'] == 1) {
        final data = RecipeCategoryModel.fromJson(response.data);
        emit(state.copyWith(allRecipeCategoryList: data.data));
      }
    } catch (e) {
      debugPrint('Error fetching categories: $e');
    }
  }

  Future<void> fetchRecommendationRecipe() async {
    try {
      final response =
          await _dioClient.sendGetRequest(ApiEndpoints.recommendationRecipe);
      if (response.data['status'] == 1) {
        final data = RecipeRecommendationModel.fromJson(response.data);
        emit(state.copyWith(recommendationRecipeList: data.data ?? []));
      }
    } catch (e) {
      debugPrint('Error fetching recommendations: $e');
    }
  }

  Future<void> fetchAllRecipeVideo() async {
    try {
      final response =
          await _dioClient.sendGetRequest(ApiEndpoints.allRecipeVideos);
      if (response.data['status'] == 1) {
        final data = AllRecipeVideoModel.fromJson(response.data);
        emit(state.copyWith(allRecipeVideoList: data.data));
      }
    } catch (e) {
      debugPrint('Error fetching weekly recipes: $e');
    }
  }

  Future<void> fetchRecipeAllPlaylist() async {
    try {
      final response =
          await _dioClient.sendGetRequest(ApiEndpoints.recipeAllPlaylist);
      if (response.data['status'] == 1) {
        final data = RecipeAllPlaylistModel.fromJson(response.data);
        emit(state.copyWith(recipeAllPlaylistList: data.data));
      }
    } catch (e) {
      debugPrint('Error fetching weekly recipes: $e');
    }
  }
}

class VideoPageState {
  final List<FeedSliderDataModel> recipeCarouselList;
  final List<RecipeCategoryDataModel> allRecipeCategoryList;
  final List<RecipeRecommendationDataModel> recommendationRecipeList;
  final List<AllRecipeVideoDataModel> allRecipeVideoList;
  final List<RecipeAllPlaylistDataModel> recipeAllPlaylistList;
  final bool subscribed;
  final bool isLoading;

  VideoPageState({
    required this.recipeCarouselList,
    required this.allRecipeCategoryList,
    required this.recommendationRecipeList,
    required this.allRecipeVideoList,
    required this.recipeAllPlaylistList,
    required this.subscribed,
    required this.isLoading,
  });

  VideoPageState.initial()
      : recipeCarouselList = [],
        allRecipeCategoryList = [],
        recommendationRecipeList = [],
        allRecipeVideoList = [],
        recipeAllPlaylistList = [],
        subscribed = false,
        isLoading = true;

  VideoPageState copyWith({
    List<FeedSliderDataModel>? recipeCarouselList,
    List<RecipeCategoryDataModel>? allRecipeCategoryList,
    List<RecipeRecommendationDataModel>? recommendationRecipeList,
    List<AllRecipeVideoDataModel>? allRecipeVideoList,
    List<RecipeAllPlaylistDataModel>? recipeAllPlaylistList,
    bool? subscribed,
    bool? isLoading,
  }) {
    return VideoPageState(
      recipeCarouselList: recipeCarouselList ?? this.recipeCarouselList,
      allRecipeCategoryList: allRecipeCategoryList ?? this.allRecipeCategoryList,
      recommendationRecipeList:
      recommendationRecipeList ?? this.recommendationRecipeList,
      allRecipeVideoList: allRecipeVideoList ?? this.allRecipeVideoList,
      recipeAllPlaylistList:
      recipeAllPlaylistList ?? this.recipeAllPlaylistList,
      subscribed: subscribed ?? this.subscribed,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
