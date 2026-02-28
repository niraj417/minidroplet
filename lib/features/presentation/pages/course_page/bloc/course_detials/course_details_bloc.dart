
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/constant/app_export.dart';
import '../../../../../../core/network/api_endpoints.dart';
import '../../../../../../core/services/payment_service.dart';
import '../../model/course_detial_model.dart';
import 'course_detials_event.dart';
import 'course_detials_state.dart';

class CourseDetailBloc
    extends Bloc<CourseDetailEvent, CourseDetailState> {

  CourseDetailBloc() : super(CourseDetailState()) {
    on<FetchCourseDetail>(_onFetch);
  }

  Future<void> _onFetch(
      FetchCourseDetail event,
      Emitter<CourseDetailState> emit,
      ) async {

    emit(state.copyWith(
      isLoading: true,
      error: null,
    ));

    try {
      final response = await dioClient.sendPostRequest(
        ApiEndpoints.courseDetials,
        {
          "user_id": event.userId,
          "course_id": event.courseId,
        },
      );

      if (response.data['status'] == 1) {
        final model =
        CourseDetailModel.fromJson(response.data['data']);

        debugPrint("API completion: ${response.data['data']['completion_percentage']}");

        emit(state.copyWith(
          isLoading: false,
          data: model,
          error: null,
        ));
      } else {
        emit(state.copyWith(
          isLoading: false,
          error: response.data['message'],
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }
}