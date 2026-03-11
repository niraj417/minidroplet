import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/constant/app_export.dart';
import '../../../video_page/model/all_recipe_video_model.dart';

class HomepageCarouselCubit extends Cubit<HomepageCarouselState> {
  final DioClient _dioClient = DioClient();

  HomepageCarouselCubit() : super(HomepageCarouselLoading());

  Future<void> fetchHomepageCarousels() async {
    emit(HomepageCarouselLoading());

    try {
      final response =
      await _dioClient.sendGetRequest(ApiEndpoints.homepageCarousels);

      print("🔥 API CALLED at ${DateTime.now()}");

      if (response.data['status'] == 1) {
        final model = HomepageCarouselModel.fromJson(response.data);
        emit(HomepageCarouselLoaded(carousels: model.data));
      } else {
        emit(HomepageCarouselError("Invalid response status"));
      }
    } catch (e) {
      emit(HomepageCarouselError(e.toString()));
    }
  }
}

// --------------------- STATES ---------------------

abstract class HomepageCarouselState {}

class HomepageCarouselLoading extends HomepageCarouselState {}

class HomepageCarouselLoaded extends HomepageCarouselState {
  final List<HomepageCarouselDataModel> carousels;
  HomepageCarouselLoaded({required this.carousels});
}

class HomepageCarouselError extends HomepageCarouselState {
  final String message;
  HomepageCarouselError(this.message);
}

class HomepageCarouselModel {
  final int status;
  final String message;
  final List<HomepageCarouselDataModel> data;

  HomepageCarouselModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory HomepageCarouselModel.fromJson(Map<String, dynamic> json) {
    return HomepageCarouselModel(
      status: json["status"],
      message: json["message"],
      data: (json["data"] as List)
          .map((e) => HomepageCarouselDataModel.fromJson(e))
          .toList(),
    );
  }
}

class HomepageCarouselDataModel {
  final int carouselId;
  final String carouselTitle;
  final int videoCatId;
  final List<AllRecipeVideoDataModel> videos;

  HomepageCarouselDataModel({
    required this.carouselId,
    required this.carouselTitle,
    required this.videoCatId,
    required this.videos,
  });

  factory HomepageCarouselDataModel.fromJson(Map<String, dynamic> json) {
    return HomepageCarouselDataModel(
      carouselId: json["carousel_id"],
      carouselTitle: json["carousel_title"],
      videoCatId: json["video_cat_id"],
      videos: (json["videos"] as List)
          .map((v) => AllRecipeVideoDataModel.fromJson(v))
          .toList(),
    );
  }
}


