import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/network/api_endpoints.dart';
import '../../../../../../core/services/payment_service.dart';
import '../../model/course_list_model.dart';
import 'course_list_event.dart';
import 'course_list_state.dart';


class CourseBloc extends Bloc<CourseEvent, CourseState> {
  CourseBloc() : super(CourseInitial()) {
    on<FetchCourseList>(_onFetchCourseList);
  }

  Future<void> _onFetchCourseList(
      FetchCourseList event,
      Emitter<CourseState> emit,
      ) async {
    emit(CourseLoading(courses: state.courses));

    try {
      final response = await dioClient.sendPostRequest(
        ApiEndpoints.courseList,
        {
          "user_id": event.userId,
        },
      );

      if (response.data['status'] == 1 || response.data['status'] == 0) {
        final List data = response.data['data'] ?? [];

        final courses =
        data.map((e) => CourseModel.fromJson(e)).toList();

        emit(CourseLoaded(courses: courses));
      } else {
        emit(CourseError(response.data['msg'] ?? "Something went wrong"));
      }
    } catch (e) {
      emit(CourseError(e.toString()));
    }
  }
}