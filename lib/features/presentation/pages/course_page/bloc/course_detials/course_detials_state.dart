import '../../model/course_detial_model.dart';

class CourseDetailState {
  final CourseDetailModel? data;
  final bool isLoading;
  final String? error;

  CourseDetailState({
    this.data,
    this.isLoading = false,
    this.error,
  });

  CourseDetailState copyWith({
    CourseDetailModel? data,
    bool? isLoading,
    String? error,
  }) {
    return CourseDetailState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}