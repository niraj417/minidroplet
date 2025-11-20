import 'dart:math';

import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:tinydroplets/features/presentation/pages/video_page/recipe_detail_page.dart';

import '../../../../core/constant/app_export.dart';

class AllRecipePage extends StatelessWidget {
  final Random _random = Random();

  AllRecipePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'All Recipes',
          style: TextStyle(fontSize: 20),
        ),
      ),
      body: _customGrid(_random),
    );
  }
}

Widget _customGrid(Random random) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 10.0),
    child: GridView.custom(
      gridDelegate: SliverQuiltedGridDelegate(
        crossAxisCount: 4,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        repeatPattern: QuiltedGridRepeatPattern.inverted,
        pattern: [
          const QuiltedGridTile(2, 2),
          const QuiltedGridTile(1, 1),
          const QuiltedGridTile(1, 1),
          const QuiltedGridTile(1, 2),
        ],
      ),
      childrenDelegate: SliverChildBuilderDelegate(
        childCount: 20,
        (context, index) {
          final int imageId = random.nextInt(1000);
          final String imageUrl = 'https://picsum.photos/$imageId';

          return GestureDetector(
            onTap: () => goto(
                context,
                RecipeDetailScreen(
                  videoId: '',
                )),
            child: Container(
              clipBehavior: Clip.hardEdge,
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(12)),
              child: CustomImage(
                imageUrl: imageUrl,
              ),
            ),
          );
        },
      ),
    ),
  );
}
