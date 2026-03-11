class CourseModel {
  final int id;
  final String title;
  final String shortDescription;
  final String thumbnail;
  final int totalLessons;
  final bool isEnrolled;
  final int completionPercentage;
  final bool isLocked;

  CourseModel({
    required this.id,
    required this.title,
    required this.shortDescription,
    required this.thumbnail,
    required this.totalLessons,
    required this.isEnrolled,
    required this.completionPercentage,
    required this.isLocked,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id'],
      title: json['title'] ?? '',
      shortDescription: json['short_description'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      totalLessons: json['total_lessons'] ?? 0,
      isEnrolled: json['is_enrolled'] ?? false,
      completionPercentage: json['completion_percentage'] ?? 0,
      isLocked: json['is_locked'] ?? false,
    );
  }
}