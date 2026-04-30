import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:tinydroplets/features/presentation/pages/feed_page/model/feed_activity_model.dart';

import '../../../../../../core/network/api_controller.dart';
import '../../../../../../core/network/api_endpoints.dart';
import 'feed_activity_state.dart';


class FeedActivityCubit extends Cubit<FeedActivityState> {
  final DioClient dioClient;

  FeedActivityCubit(this.dioClient) : super(FeedActivityInitial());

  Future<void> fetchFeedActivityData() async {
    emit(FeedActivityLoading());
    try {
      final response = await dioClient.sendGetRequest(ApiEndpoints.feedActivity);
      debugPrint("Activity data: ---------> ${response.data}");

      if (response.data['status'] == 1 && response.data != null) {
        final data = FeedActivityModel.fromJson(response.data).data;
        emit(FeedActivityLoaded(data));
      } else {
        emit(const FeedActivityError('Failed to fetch data'));
      }
    } catch (e) {
      debugPrint("Error: ---------> ${e.toString()}");
      emit(FeedActivityError(e.toString()));
    }
  }
}
