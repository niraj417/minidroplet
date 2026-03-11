abstract class CourseDetailEvent {}

class FetchCourseDetail extends CourseDetailEvent {
  final int userId;
  final int courseId;

  FetchCourseDetail({
    required this.userId,
    required this.courseId,
  });
}