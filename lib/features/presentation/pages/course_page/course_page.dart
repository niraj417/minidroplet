import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:tinydroplets/features/presentation/pages/course_page/course_overview_page.dart';

import '../../../../common/widgets/app_bar/custom_app_bar.dart';
import '../../../../core/constant/app_vector.dart';
import '../../../../core/utils/shared_pref.dart';
import 'bloc/course_detials/course_details_bloc.dart';
import 'bloc/course_list/course_list_bloc.dart';
import 'bloc/course_list/course_list_event.dart';
import 'bloc/course_list/course_list_state.dart';

class CourseListPage extends StatefulWidget {
  const CourseListPage({super.key});

  @override
  State<CourseListPage> createState() => _CourseListPageState();
}

class _CourseListPageState extends State<CourseListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    context.read<CourseBloc>().add(
      FetchCourseList(SharedPref.getLoginData()!.data!.id ?? 0),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: CustomAppBar(title: 'Courses'),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<CourseBloc>().add(
            FetchCourseList(SharedPref.getLoginData()!.data!.id ?? 0),
          );
        },
        child: Column(
          children: [
            _buildTabs(),
            const SizedBox(height: 10),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  CourseListView(tabIndex: 0),
                  CourseListView(tabIndex: 1),
                  CourseListView(tabIndex: 2),
                ],
              ),
            ),
            SizedBox(height: 120,),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: false,
        indicator: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFFFFB703),
              Color(0xFFFB8500),
            ],
          ),
          borderRadius: BorderRadius.circular(25),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey.shade600,
        dividerColor: Colors.transparent, // 🔥 removes bottom divider
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        tabs: const [
          Tab(text: "All"),
          Tab(text: "In Progress"),
          Tab(text: "Completed"),
        ],
      ),
    );
  }
}

class CourseListView extends StatelessWidget {
  final int tabIndex;

  const CourseListView({super.key, required this.tabIndex});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CourseBloc, CourseState>(
      builder: (context, state) {
        if (state.isLoading) {
          return Stack(
            children: [

              /// ============================
              /// SHIMMER LIST
              /// ============================
              ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: 5,
                itemBuilder: (_, __) => const Padding(
                  padding: EdgeInsets.only(bottom: 20),
                  child: CourseCardShimmer(),
                ),
              ),

              /// ============================
              /// LOTTIE ANIMATION OVERLAY
              /// ============================
              Positioned.fill(
                child: Container(
                  color: Colors.white.withOpacity(0.6),
                  child: Center(
                    child: Lottie.asset(
                      AppVector.waterDropLoading,
                      width: 120,
                      height: 120,
                      repeat: true,
                    ),
                  ),
                ),
              ),
            ],
          );
        }

        if (state.error != null) {
          return Center(child: Text(state.error!));
        }

        final courses = state.courses ?? [];

        // TAB FILTERING
        final filteredCourses = courses.where((course) {
          switch (tabIndex) {

            case 1: // In Progress
              return course.isEnrolled &&
                  course.completionPercentage < 100;

            case 2: // Completed
              return course.isEnrolled &&
                  course.completionPercentage == 100;

            default: // All
              return true;
          }
        }).toList();

        return RefreshIndicator(
            onRefresh: () async {
              context.read<CourseBloc>().add(
                FetchCourseList(
                  SharedPref.getLoginData()!.data!.id ?? 0,
                ),
              );
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredCourses.length,
              itemBuilder: (context, index) {
              final course = filteredCourses[index];

              if (filteredCourses.isEmpty) {
                return const Center(
                  child: Text(
                    "No courses available",
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: CourseCard(
                  course_id: course.id,
                  title: course.title,
                  thumbnail: course.thumbnail,
                  progress: course.completionPercentage / 100,
                  shortDescription: course.shortDescription,
                  chapters: course.totalLessons,
                  isLocked: course.isLocked,
                ),
              );
            },
          )
        );
      },
    );
  }
}

class CourseCard extends StatelessWidget {
  final int course_id;
  final String title;
  final String thumbnail;
  final String shortDescription;
  final double progress;// 0.0 - 1.0
  final int chapters;
  final bool isLocked;

  const CourseCard({
    super.key,
    required this.course_id,
    required this.title,
    required this.thumbnail,
    required this.progress,
    required this.chapters,
    required this.isLocked,
    required this.shortDescription,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final shouldRefresh = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider(
              create: (_) => CourseDetailBloc(),
              child: CourseDetailPage(
                userId: SharedPref.getLoginData()!.data!.id ?? 0,
                courseId: course_id,
              ),
            ),
          ),
        );

        if (shouldRefresh == true && context.mounted) {
          context.read<CourseBloc>().add(
            FetchCourseList(
              SharedPref.getLoginData()!.data!.id ?? 0,
            ),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildThumbnail(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    shortDescription,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (!isLocked) _buildProgressSection(),
                  //if (isLocked) _buildFreePreview(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnail() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),
          child: Image.network(
            thumbnail,
            height: 180,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        if (isLocked)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: const Center(
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.orange,
                  child: Icon(
                    Icons.lock,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProgressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "${(progress * 100).toInt()}% completed",
          style: const TextStyle(
            color: Colors.orange,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: Colors.grey.shade300,
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              "$chapters Chapters",
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFreePreview() {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          "FREE PREVIEW",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class CourseCardShimmer extends StatelessWidget {
  const CourseCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Thumbnail shimmer
          Container(
            height: 180,
            decoration: const BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _shimmerBox(height: 20, width: 150),
                const SizedBox(height: 10),
                _shimmerBox(height: 14, width: double.infinity),
                const SizedBox(height: 6),
                _shimmerBox(height: 14, width: 200),
                const SizedBox(height: 10),
                _shimmerBox(height: 8, width: double.infinity),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _shimmerBox({required double height, required double width}) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}