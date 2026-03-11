import 'package:tinydroplets/features/presentation/pages/video_page/recipe_category_videos_page.dart';
import 'package:tinydroplets/features/presentation/pages/video_page/widget/video_category_card.dart';
import '../../../../core/constant/app_export.dart';
import 'model/recipe_category_model.dart';

class AllRecipeCategoryPage extends StatelessWidget {
  final List<RecipeCategoryDataModel> allRecipeCategoryList;

  const AllRecipeCategoryPage({super.key, required this.allRecipeCategoryList});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          padding: const EdgeInsets.all(8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 250 / 120,
          ),
          itemCount: allRecipeCategoryList.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () => goto(
                  context,
                  RecipeCategoryVideoPage(
                    id: allRecipeCategoryList[index].id.toString(),
                    categoryName: allRecipeCategoryList[index].name.toString(),

                  )),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: CustomImage(
                        imageUrl: allRecipeCategoryList[index].image,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    Center(
                      child: Text(
                        allRecipeCategoryList[index].name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
