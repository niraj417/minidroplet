import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/app_color.dart';
import '../bloc/homepage_carousel_bloc/homepage_carousel_bloc.dart';
import 'carousel_video_card.dart';

class HomepageCarouselWidget extends StatelessWidget {
  const HomepageCarouselWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomepageCarouselCubit, HomepageCarouselState>(
      builder: (context, state) {
        // --------------------
        // LOADING STATE
        // --------------------
        if (state is HomepageCarouselLoading) {
          return _buildLoadingShimmer();
        }

        // --------------------
        // ERROR STATE
        // --------------------
        if (state is HomepageCarouselError) {
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

        // --------------------
        // SUCCESS STATE
        // --------------------
        if (state is HomepageCarouselLoaded) {
          if (state.carousels.isEmpty) {
            return const SizedBox.shrink();
          }

          return Column(
            children: List.generate(
              state.carousels.length,
                  (i) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: _buildSingleCarousel(context, state.carousels[i]),
              ),
            ),
          );
        }

        // Fallback UI
        return const SizedBox.shrink();
      },
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
                  fontSize: 23,
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
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
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
