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

  void _fetchInitialData() {
    fetchRecipeCarousel();
    fetchRecipeCategory();
    fetchRecommendationRecipe();
    fetchAllRecipeVideo();
    fetchRecipeAllPlaylist();
    _loadSubscriptionStatus();
  }

  Future<void> refreshData() async {
    await Future.wait([
      fetchRecipeCarousel(),
      fetchRecipeCategory(),
      fetchRecommendationRecipe(),
      fetchAllRecipeVideo(),
      fetchRecipeAllPlaylist(),
      _loadSubscriptionStatus(),
    ]);
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

  VideoPageState({
    required this.recipeCarouselList,
    required this.allRecipeCategoryList,
    required this.recommendationRecipeList,
    required this.allRecipeVideoList,
    required this.recipeAllPlaylistList,
    required this.subscribed
  });

  VideoPageState.initial()
      : recipeCarouselList = [],
        allRecipeCategoryList = [],
        recommendationRecipeList = [],
        allRecipeVideoList = [],
        recipeAllPlaylistList = [],
        subscribed = false;

  VideoPageState copyWith({
    List<FeedSliderDataModel>? recipeCarouselList,
    List<RecipeCategoryDataModel>? allRecipeCategoryList,
    List<RecipeRecommendationDataModel>? recommendationRecipeList,
    List<AllRecipeVideoDataModel>? allRecipeVideoList,
    List<RecipeAllPlaylistDataModel>? recipeAllPlaylistList,
    bool? subscribed,
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
    );
  }
}
