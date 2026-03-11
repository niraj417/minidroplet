import 'package:tinydroplets/features/presentation/pages/video_page/model/recipe_category_model.dart';

import '../../../../../core/constant/app_export.dart';

class VideoCategoryCard extends StatelessWidget {
  final RecipeCategoryDataModel category;

  const VideoCategoryCard({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomImage(
              imageUrl: category.image,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          Center(
            child: Text(
              category.name,
              style: const TextStyle(
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );

    /*return Container(
      margin: const EdgeInsets.only(right: 2),
      child: Column(
        children: [
          Container(
            width: 140,
            decoration: BoxDecoration(
              color: Colors.red,
              //  color: category.color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            alignment: Alignment.center,
            child: Column(
              children: [
                // Icon(
                //   category.icon,
                //   color: category.color,
                //   size: 40,
                // ),
                // CustomImage(
                //   imageUrl: category.image,
                //   height: 40,
                //   width: 40,
                // ),
                const SizedBox(height: 8),
                Text(
                  category.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );*/
  }
}
