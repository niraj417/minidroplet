import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tinydroplets/features/presentation/pages/course_page/model/course_detial_model.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/services/payment_service.dart';
import '../../../components/report_content/report_content.dart';
import '../video_player/flick_video_player/flick_custom_video_player.dart';
import 'bloc/course_detials/course_details_bloc.dart';
import 'bloc/course_detials/course_detials_event.dart';

class CourseVideoLessonPage extends StatefulWidget {
  final List<LessonModel> lessons;
  final int currentIndex;
  final String courseId;
  final String userId;

  const CourseVideoLessonPage({
    super.key,
    required this.lessons,
    required this.currentIndex,
    required this.courseId,
    required this.userId,
  });

  @override
  State<CourseVideoLessonPage> createState() => _CourseVideoLessonPageState();
}

class _CourseVideoLessonPageState extends State<CourseVideoLessonPage> {
  late int _currentIndex;
  late LessonModel _lesson;
  bool _isExpanded = false;

  int _lastSentSecond = 0;
  bool _completedSent = false;
  bool _isUpdating = false; // Add thi
  bool _progressUpdated = false;// s to prevent multiple simultaneous updates

  void _handleVideoProgress(
      Duration position,
      Duration totalDuration,
      ) async {
    final currentSecond = position.inSeconds;
    final totalSecond = totalDuration.inSeconds;

    if (totalSecond == 0) return;

    final percentage = currentSecond / totalSecond;

    /// 🔁 Send every 5 seconds
    if (!_completedSent &&
        currentSecond - _lastSentSecond >= 5) {
      _lastSentSecond = currentSecond;

      if (!_completedSent) {
        await _updateProgress(
          watchedDuration: currentSecond,
          isCompleted: false,
        );
      }
    }

    /// ✅ Mark complete at 90%
    if (percentage >= 0.9 && !_completedSent) {
      _completedSent = true;

      await _updateProgress(
        watchedDuration: currentSecond,
        isCompleted: true,
      );
    }
  }

  Future<void> _updateProgress({
    required int watchedDuration,
    required bool isCompleted,
  }) async {
    // Prevent multiple simultaneous updates
    if (_isUpdating) return;

    _isUpdating = true;

    try {
      debugPrint('📤 Updating progress: lesson ${_lesson.lessonId}, duration: $watchedDuration, completed: $isCompleted');

      final response = await dioClient.sendPostRequest(
        ApiEndpoints.updateCourseProgress,
        {
          "user_id": widget.userId,
          "lesson_id": _lesson.lessonId,
          "watched_duration": watchedDuration,
          "is_completed": isCompleted ? 1 : 0,
        },
      );

      debugPrint('✅ Progress update response: ${response.data}');

      _progressUpdated = true;

      // // Only try to refresh CourseDetailBloc if it exists in the widget tree
      // try {
      //   // Check if bloc exists before trying to access it
      //   if (context.mounted && context.read<CourseDetailBloc>() != null) {
      //     context.read<CourseDetailBloc>().add(
      //       FetchCourseDetail(
      //         userId: int.parse(widget.userId),
      //         courseId: int.parse(widget.courseId),
      //       ),
      //     );
      //   }
      // } catch (blocError) {
      //   // Bloc not found - but that's okay, API already succeeded
      //   debugPrint('⚠️ CourseDetailBloc not found, but API call succeeded');
      // }

    } catch (e) {
      debugPrint("❌ Progress update failed: $e");

      // Show error to user if needed
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update progress'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } finally {
      _isUpdating = false;
    }
  }

  void _goBack() {
    print("Go Back mehtod Invoked ");
    // Pass true back if progress was updated
    Navigator.pop(context, _progressUpdated);
  }

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.currentIndex;
    _lesson = widget.lessons[_currentIndex];
  }

  void _loadLesson(int index) {
    if (index < 0 || index >= widget.lessons.length) return;

    setState(() {
      _currentIndex = index;
      _lesson = widget.lessons[index];

      // Reset progress tracking for new lesson
      _lastSentSecond = 0;
      _completedSent = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final videoUrl = _lesson.videoUrl;

    return SafeArea(
      child: PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          if (!didPop) {
            _goBack(); // always send result back
          }
        },
        child: Scaffold(
          backgroundColor: const Color(0xFFF6F7FB),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: _goBack,
            ),
            actions: [
              ReportContentWidget(
                contentId: int.parse(_lesson.lessonId.toString()),
                contentType: 'e_video',
              ),
            ],
          ),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// ---------------- VIDEO PLAYER ----------------
                videoUrl.isNotEmpty
                    ? FlickCustomVideoPlayer(
                  videoUrl: videoUrl,
                  onProgress: _handleVideoProgress,
                )
                    : Container(
                  height: 220,
                  color: Colors.black,
                  child: const Center(
                    child: Text(
                      "Loading video...",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),

                /// ---------------- CONTENT AREA ----------------
                Container(
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      /// TITLE
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${_lesson.number}  ${_lesson.title}",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _lesson.duration,
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),

                      const Divider(height: 1),

                      /// DESCRIPTION
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: _buildExpandableDescription(_lesson.description),
                      ),

                      const SizedBox(height: 20),

                      /// PREVIOUS / NEXT
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 14),
                        decoration: const BoxDecoration(
                          border: Border(
                            top: BorderSide(color: Colors.grey),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [

                            GestureDetector(
                              onTap: _currentIndex > 0
                                  ? () => _loadLesson(_currentIndex - 1)
                                  : null,
                              child: Text(
                                "‹ Previous",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: _currentIndex > 0
                                      ? Colors.black
                                      : Colors.grey,
                                ),
                              ),
                            ),

                            GestureDetector(
                              onTap: _currentIndex <
                                  widget.lessons.length - 1
                                  ? () => _loadLesson(_currentIndex + 1)
                                  : null,
                              child: Text(
                                "Next ›",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: _currentIndex <
                                      widget.lessons.length - 1
                                      ? Colors.black
                                      : Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExpandableDescription(String description) {
    const int maxLength = 300;

    final bool isLong = description.length > maxLength;

    final String displayText = !_isExpanded && isLong
        ? description.substring(0, maxLength) + "..."
        : description;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Description",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: Text(
            description.isNotEmpty
                ? displayText
                : "No description available.",
            style: const TextStyle(height: 1.5),
          ),
        ),

        if (isLong)
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                _isExpanded ? "Read less" : "Read more",
                style: const TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }
}