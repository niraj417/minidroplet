import 'package:tinydroplets/features/presentation/pages/video_page/model/all_recipe_video_model.dart';

import '../../../../../core/constant/app_export.dart';

class WeekRecipeCard extends StatelessWidget {
  final AllRecipeVideoDataModel recipe;

  const WeekRecipeCard({
    super.key,
    required this.recipe,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 140,
                width: 260,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Theme.of(context).cardColor,
                ),
                clipBehavior: Clip.hardEdge,
                child: CustomImage(
                  imageUrl: recipe.thumbnail,
                ),
              ),
              Container(
                height: 140,
                width: 260,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.black.withValues(alpha: 0.3),
                ),
                clipBehavior: Clip.hardEdge,
              ),
              Positioned(
                top: 0,
                bottom: 0,
                left: 0,
                right: 0,
                child: Icon(
                  Icons.play_circle_fill_outlined,
                  size: 40,
                  color: Colors.white,
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  // padding: EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                  ),
                  child: Center(
                    child: Text(
                      recipe.isBuy ==
                          '0'
                          ? 'Paid'
                          : '',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Expanded(
            child: Text(
              recipe.title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
              softWrap: true,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
