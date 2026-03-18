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

      final data = response.data;

      if (data['status'] == 0 &&
          data['message'] == "Coming Soon") {
        emit(const CourseComingSoon());
        return;
      }

      if (data['status'] == 1) {
        final courses = (data['data'] as List)
            .map((e) => CourseModel.fromJson(e))
            .toList();

        emit(CourseLoaded(courses: courses));
        return;
      }

      emit(CourseError(data['message']));
    } catch (e) {

      /// 🔥 HANDLE EXCEPTION COMING SOON
      if (e.toString().toLowerCase().contains("coming soon")) {
        emit(const CourseComingSoon());
        return;
      }

      emit(CourseError(e.toString()));
    }
  }
}