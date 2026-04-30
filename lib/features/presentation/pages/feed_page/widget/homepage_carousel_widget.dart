import 'package:flutter/material.dart';
import '../../../../../core/theme/app_color.dart';
import '../bloc/homepage_carousel_bloc/homepage_carousel_bloc.dart';
import 'carousel_video_card.dart';

class HomepageCarouselWidget extends StatelessWidget {
  final List<HomepageCarouselDataModel> carousels;
  final bool isLoading;
  final String? error;

  const HomepageCarouselWidget({
    super.key,
    required this.carousels,
    this.isLoading = false,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    // --------------------
    // LOADING STATE
    // --------------------
    if (isLoading) {
      return _buildLoadingShimmer();
    }

    // --------------------
    // ERROR STATE
    // --------------------
    if (error != null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text(
            "Failed to load carousels",
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ),
      );
    }

    // 🔍 DEBUG: Log the carousels data
    print('📊 HomepageCarouselWidget - Total carousels: ${carousels.length}');
    for (var carousel in carousels) {
      print('   Carousel: ${carousel.carouselTitle}');
      print('   Videos count: ${carousel.videos?.length ?? 0}');
      if (carousel.videos != null && carousel.videos!.isNotEmpty) {
        print('   First video title: ${carousel.videos!.first.title}');
      }
    }

    // --------------------
    // FILTER EMPTY CAROUSELS
    // --------------------
    final visibleCarousels = carousels
        .where((carousel) => carousel.videos != null && carousel.videos!.isNotEmpty)
        .toList();

    print('📊 Visible carousels after filter: ${visibleCarousels.length}');

    // --------------------
    // EMPTY STATE
    // --------------------
    if (visibleCarousels.isEmpty) {
      print('⚠️ No visible carousels found');
      return const SizedBox.shrink();
    }

    // --------------------
    // SUCCESS STATE
    // --------------------
    return Column(
      children: List.generate(
        visibleCarousels.length,
            (index) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: _buildSingleCarousel(
            context,
            visibleCarousels[index],
          ),
        ),
      ),
    );
  }

  // --------------------------------------------------------
  // UI: Single carousel section (title + horizontal list)
  // --------------------------------------------------------
  Widget _buildSingleCarousel(
      BuildContext context,
      HomepageCarouselDataModel carousel,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // -----------------------------------
        // TITLE BAR
        // -----------------------------------
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                carousel.carouselTitle,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                " ",
                style: TextStyle(
                  color: Color(AppColor.primaryColor),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // -----------------------------------
        // VIDEO LIST
        // -----------------------------------
        SizedBox(
          height: 170,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            scrollDirection: Axis.horizontal,
            itemCount: carousel.videos.length,
            itemBuilder: (context, index) {
              final video = carousel.videos[index];

              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: CarouselVideoCard(video: video),
              );
            },
          ),
        ),
      ],
    );
  }

  // --------------------------------------------------------
  // LOADING SHIMMER
  // --------------------------------------------------------
  Widget _buildLoadingShimmer() {
    return Column(
      children: List.generate(2, (index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            children: [
              Container(
                height: 20,
                width: 150,
                margin: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),

              const SizedBox(height: 10),

              SizedBox(
                height: 170,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 3,
                  itemBuilder: (_, __) => Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Container(
                      height: 140,
                      width: 260,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
