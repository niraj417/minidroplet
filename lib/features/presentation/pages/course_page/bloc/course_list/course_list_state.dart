

import '../../model/course_list_model.dart';

abstract class CourseState {
  final List<CourseModel>? courses;
  final bool isLoading;
  final String? error;

  const CourseState({
    this.courses,
    this.isLoading = false,
    this.error,
  });
}

class CourseInitial extends CourseState {}

class CourseLoaded extends CourseState {
  const CourseLoaded({
    required List<CourseModel> courses,
  }) : super(courses: courses, isLoading: false);
}

class CourseLoading extends CourseState {
  const CourseLoading({
    List<CourseModel>? courses,
  }) : super(courses: courses, isLoading: true);
}

class CourseError extends CourseState {
  const CourseError(String error)
      : super(error: error, isLoading: false);
}