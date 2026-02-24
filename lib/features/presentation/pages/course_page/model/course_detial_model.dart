
class CourseDetailModel {
  final int courseId;
  final String title;
  final String thumbnail;
  final int completionPercentage;
  final bool isEnrolled;
  final List<LessonModel> lessons;

  CourseDetailModel({
    required this.courseId,
    required this.title,
    required this.thumbnail,
    required this.completionPercentage,
    required this.isEnrolled,
    required this.lessons,
  });

  factory CourseDetailModel.fromJson(Map<String, dynamic> json) {
    return CourseDetailModel(
      courseId: json['course_id'],
      title: json['title'],
      thumbnail: json['thumbnail'] ?? "",
      completionPercentage: json['completion_percentage'] ?? 0,
      isEnrolled: json['is_enrolled'],
      lessons: (json['lessons'] as List)
          .map((e) => LessonModel.fromJson(e))
          .toList(),
    );
  }
}

class LessonModel {
  final int lessonId;
  final int videoId;
  final String number;
  final String title;
  final String description;
  final String videoUrl;
  final String thumbnail;
  final String duration;
  final bool isCompleted;
  final int watchedDuration;
  final int totalDuration;
  final bool isLocked;

  LessonModel({
    required this.lessonId,
    required this.videoId,
    required this.number,
    required this.title,
    required this.description,
    required this.videoUrl,
    required this.thumbnail,
    required this.duration,
    required this.isCompleted,
    required this.watchedDuration,
    required this.totalDuration,
    required this.isLocked,
  });

  factory LessonModel.fromJson(Map<String, dynamic> json) {
    return LessonModel(
      lessonId: json['lesson_id'],
      videoId: json['video_id'],
      number: json['number'],
      title: json['title'],
      description: json['description'] ?? "",
      videoUrl: json['video_url'] ?? "",
      thumbnail: json['thumbnail'] ?? "",
      duration: json['duration'] ?? "",
      isCompleted: json['is_completed'],
      isLocked: json['is_locked'],
      watchedDuration:
      int.tryParse(json['watched_duration'].toString()) ?? 0,
      totalDuration:
      int.tryParse(json['total_duration'].toString()) ?? 0,
    );
  }
}