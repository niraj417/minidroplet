import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tinydroplets/features/presentation/pages/course_page/video_lesson_page.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/services/payment_service.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../core/utils/shared_pref.dart';
import '../../../../core/utils/shared_pref_key.dart';
import '../subscription/subscription_screen.dart';
import 'bloc/course_detials/course_details_bloc.dart';
import 'bloc/course_detials/course_detials_event.dart';
import 'bloc/course_detials/course_detials_state.dart';
import 'model/course_detial_model.dart';

class CourseDetailPage extends StatefulWidget {
  final int userId;
  final int courseId;

  const CourseDetailPage({
    super.key,
    required this.userId,
    required this.courseId,
  });

  @override
  State<CourseDetailPage> createState() =>
      _CourseDetailPageState();
}

class _CourseDetailPageState extends State<CourseDetailPage> {

  bool isSubscribed = false;

  @override
  void initState() {
    super.initState();

    isSubscribed = SharedPref.getBool(SharedPrefKeys.hasPremiumAccess) ?? false;

    context.read<CourseDetailBloc>().add(
      FetchCourseDetail(
        userId: widget.userId,
        courseId: widget.courseId,
      ),
    );
  }

  // In CourseDetailPage
  void _openLesson(List<LessonModel> lessons, int currentIndex) async {
    final shouldRefresh = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CourseVideoLessonPage(
          lessons: lessons,
          currentIndex: currentIndex,
          courseId: widget.courseId.toString(),
          userId: widget.userId.toString(),
        ),
      ),
    );

    print("Should Refresh : ${shouldRefresh}");
    try{
      // If shouldRefresh is true, refresh the course details
      if (shouldRefresh == true) {
        if (context.mounted) {
          context.read<CourseDetailBloc>().add(
            FetchCourseDetail(
              userId: widget.userId,
              courseId: widget.courseId,
            ),
          );
        }
      }
    }catch(Exception){
      print("Error Recalling return COurse detials bloc");
    }

  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CourseDetailBloc, CourseDetailState>(
        builder: (context, state) {
          // 1️⃣ Loading
          if (state.isLoading) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          // 2️⃣ Error
          if (state.error != null) {
            return Scaffold(
              body: Center(
                child: Text(state.error!),
              ),
            );
          }

          // 3️⃣ No Data Yet (initial state)
          if (state.data == null) {
            return const Scaffold(
              body: SizedBox(),
            );
          }

          // 4️⃣ Safe Loaded State
          final data = state.data!;
          final bool isEnrolled = data.isEnrolled;
        return RefreshIndicator(
          backgroundColor: Color(AppColor.primaryColor),
          color: Colors.white,
          onRefresh: () async {
            context.read<CourseDetailBloc>().add(
              FetchCourseDetail(
                userId: widget.userId,
                courseId: widget.courseId,
              ),
            );
          },
          child: SafeArea(
            child: Scaffold(
              backgroundColor: const Color(0xFFF6F7FB),
              body: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBanner(data.thumbnail),
                    _buildHeaderSection(data, isEnrolled),
                    const SizedBox(height: 20),
                    _buildSectionHeader(),
                    const SizedBox(height: 10),
                    _buildLessonList(data.lessons),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        );
      }
    );
  }

  // --------------------------------------------------
  Widget _buildBanner(String thumbnail) {
    return Stack(
      children: [
        Image.network(
          thumbnail,
          //"https://t3.ftcdn.net/jpg/09/73/18/30/360_F_973183014_a4cDr6BWLx1ZdXuzvabLQuVLa5zcMZ4B.jpg",
          height: 220,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
        Positioned(
          top: 40,
          left: 16,
          child: CircleAvatar(
            backgroundColor: Colors.black.withOpacity(0.5),
            child: const BackButton(color: Colors.white),
          ),
        )
      ],
    );
  }

  // --------------------------------------------------
  Widget _buildHeaderSection(CourseDetailModel data, bool isEnrolled) {

    String buttonText;

    if (!isSubscribed) {
      buttonText = "Subscribe";
    } else if (!isEnrolled) {
      buttonText = "Enroll";
    } else {
      buttonText = "Continue";
    }

    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data.title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Overall progress ${data.completionPercentage}%",
                      style: const TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    LinearProgressIndicator(
                      value:
                      data.completionPercentage / 100,
                      minHeight: 6,
                      backgroundColor:
                      Colors.grey.shade300,
                      color: Colors.orange,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),

              GestureDetector(
                onTap: () async {
                  if (!isSubscribed) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SubscriptionPage(),
                      ),
                    );
                    return;
                  }

                  if (!isEnrolled) {
                    await dioClient.sendPostRequest(
                      ApiEndpoints.enrollCourse,
                      {
                        "user_id": widget.userId,
                        "course_id": widget.courseId,
                      },
                    );

                    // 🔥 Refetch course details after enrolling
                    context.read<CourseDetailBloc>().add(
                      FetchCourseDetail(
                        userId: widget.userId,
                        courseId: widget.courseId,
                      ),
                    );

                    return;
                  }

                  final lessons = data.lessons;

                  /// 1️⃣ Find lesson that is partially watched (resume case)
                  int resumeIndex = lessons.indexWhere(
                        (e) => !e.isCompleted && e.watchedDuration > 0,
                  );

                  /// 2️⃣ If found → resume it
                  if (resumeIndex != -1) {
                    _openLesson(lessons, resumeIndex);
                    return;
                  }

                  /// 3️⃣ Otherwise find first incomplete lesson
                  int firstIncompleteIndex = lessons.indexWhere(
                        (e) => !e.isCompleted,
                  );

                  if (firstIncompleteIndex != -1) {
                    _openLesson(lessons, firstIncompleteIndex);
                    return;
                  }

                  /// 4️⃣ If all completed → start from first lesson
                  _openLesson(lessons, 0);
                },
                child: Container(
                  height: 45,
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFFFB703),
                        Color(0xFFFB8500),
                      ],
                    ),
                  ),
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: Duration(milliseconds: 300),
                      child: Text(
                        buttonText,
                        key: ValueKey(buttonText),
                      ),
                    )
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  // --------------------------------------------------
  Widget _buildSectionHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          const Text(
            "Chapters",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          )
        ],
      ),
    );
  }

  // --------------------------------------------------
  Widget _buildLessonList(List<LessonModel> lessons) {
    return Padding(
      padding:
      const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: lessons.map((lesson) {
          final progressValue = lesson.totalDuration > 0
              ? lesson.watchedDuration / lesson.totalDuration
              : 0.0;
          return Padding(
            padding:
            const EdgeInsets.only(bottom: 12),
            child: LessonTile(
              number: lesson.number,
              title: lesson.title,
              subtitle:
              "Video • ${lesson.duration} mins",
              isCompleted: lesson.isCompleted,
              showProgressCircle:
              !lesson.isCompleted &&
                  !lesson.isLocked,
              isLocked: lesson.isLocked,
              progressValue: progressValue,
              onTap: () {
                if (!lesson.isLocked) {
                  _openLesson(lessons, (int.parse(lesson.number) - 1));
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }

}

//////////////////////////////////////////////////////////////////
/// Lesson Tile Widget
//////////////////////////////////////////////////////////////////

class LessonTile extends StatelessWidget {
  final String number;
  final String title;
  final String subtitle;
  final bool isCompleted;
  final bool showProgressCircle;
  final bool isLocked;
  final VoidCallback onTap;
  final double progressValue;

  const LessonTile({
    super.key,
    required this.number,
    required this.title,
    required this.subtitle,
    required this.isCompleted,
    this.showProgressCircle = false,
    required this.isLocked,
    required this.onTap,
    required this.progressValue,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isLocked ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
            )
          ],
        ),
        child: Row(
          children: [
            Text(
              number,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            /// Right Icon
            if (isCompleted)
              const CircleAvatar(
                radius: 18,
                backgroundColor: Colors.green,
                child: Icon(Icons.check, color: Colors.white),
              )
            else if (isLocked)
              const Icon(Icons.lock_outline)
            else if (showProgressCircle)
              SizedBox(
                height: 36,
                width: 36,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: progressValue.clamp(0.0, 1.0),
                      strokeWidth: 3,
                      color: Colors.green,
                    ),
                    Icon(Icons.play_arrow, size: 18),
                  ],
                ),
              )
            else
              const Icon(Icons.play_circle_outline),
          ],
        ),
      ),
    );
  }
}