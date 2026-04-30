

import '../../model/course_list_model.dart';

abstract class CourseState {
  final List<CourseModel>? courses;
  final bool isLoading;
  final String? error;

  final bool isComingSoon;

  const CourseState({
    this.courses,
    this.isLoading = false,
    this.error,
    this.isComingSoon = false,
  });
}

class CourseInitial extends CourseState {}

class CourseLoading extends CourseState {
  const CourseLoading({List<CourseModel>? courses})
      : super(isLoading: true, courses: courses);
}

class CourseLoaded extends CourseState {
  const CourseLoaded({required List<CourseModel> courses})
      : super(courses: courses);
}

class CourseComingSoon extends CourseState {
  const CourseComingSoon()
      : super(isComingSoon: true, courses: const []);
}

class CourseError extends CourseState {
  const CourseError(String message)
      : super(error: message);
}