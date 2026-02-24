import 'package:equatable/equatable.dart';

abstract class CourseEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchCourseList extends CourseEvent {
  final int userId;

  FetchCourseList(this.userId);

  @override
  List<Object?> get props => [userId];
}