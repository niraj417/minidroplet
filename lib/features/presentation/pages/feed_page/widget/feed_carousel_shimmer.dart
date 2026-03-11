import 'package:shimmer/shimmer.dart';
import '../../../../../common/widgets/custom_caraousel.dart';
import '../../../../../core/constant/app_export.dart';

class FeedCarouselShimmer extends StatelessWidget {
  const FeedCarouselShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade400,
      highlightColor: Colors.white,
      child: CustomCarousel(
        items: List.generate(3, (index) => index),
        itemBuilder: (context, feedSliderItem, index) => Padding(
          padding: const EdgeInsets.all(8.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 300,
              height: 200,
              decoration: BoxDecoration(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
