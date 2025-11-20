import 'package:tinydroplets/features/presentation/pages/video_page/recipe_detail_page.dart';
import 'package:tinydroplets/features/presentation/pages/video_page/video_checkout_page.dart';

import '../../../../core/constant/app_export.dart';
import '../../../../core/services/ad_service/interstitial_ad/interstitial_ad_widget.dart';
import 'model/all_recipe_video_model.dart';

class AllWeekRecipePage extends StatelessWidget {
  const AllWeekRecipePage({super.key, required this.allRecipeVideoList});

  final List<AllRecipeVideoDataModel> allRecipeVideoList;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: allRecipeVideoList.isEmpty
            ? Center(
                child: Text('No data available'),
              )
            :ListView.builder(
          itemCount: allRecipeVideoList.length,
          physics: const AlwaysScrollableScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (context, index) {
            final item = allRecipeVideoList[index];
            final isFree = item.priceType == 'free';

            // Debug logging
            print('ListView Recipe Item ${item.id}: priceType=${item.priceType}, isBuy=${item.isBuy}, isFree=$isFree');

            final childWidget = Center(
              child: Container(
                width: double.infinity, // Ensures full width
                padding: const EdgeInsets.symmetric(
                    vertical: 10, horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        Container(
                          height: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Theme.of(context).cardColor,
                          ),
                          clipBehavior: Clip.hardEdge,
                          child: CustomImage(
                            imageUrl: allRecipeVideoList[index].thumbnail,
                          ),
                        ),
                        Container(
                          height: 200,
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
                            padding: EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(
                              color: Colors.white,
                            ),
                            child: Center(
                              child: Text(
                                allRecipeVideoList[index].isBuy == '0'
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
                    Text(
                      allRecipeVideoList[index].title,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2, // Prevents overflow
                    ),
                    Text(
                      allRecipeVideoList[index].description,
                      style: const TextStyle(fontSize: 15),
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2, // Prevents overflow
                    ),
                  ],
                ),
              ),
            );

            return isFree
                ? InterstitialAdWidget(
              onAdClosed: () {
                print('Ad closed for ListView recipe item ${item.id}');
                _navigateToListViewRecipeDestination(context, index);
              },
              child: childWidget,
            )
                : GestureDetector(
              onTap: () {
                print('GestureDetector tapped for ListView recipe item ${item.id}');
                _navigateToListViewRecipeDestination(context, index);
              },
              child: childWidget,
            );
          },
        )
      ),
    );
  }
  void _navigateToListViewRecipeDestination(BuildContext context, int index) {
    final item = allRecipeVideoList[index];

    debugPrint('Navigating for ListView recipe item: ${item.toString()}');
    debugPrint('isBuy value: ${item.isBuy}');

    if (item.isBuy == '0') {
      debugPrint('Navigating to VideoCheckoutPage');
      goto(
        context,
        VideoCheckoutPage(
          id: item.id,
          title: item.title,
          thumbnail: item.thumbnail,
          amount: item.price,
          mainPrice: item.mainPrice,
        ),
      );
    } else {
      debugPrint('Navigating to RecipeDetailScreen');
      goto(
        context,
        RecipeDetailScreen(videoId: item.id.toString()),
      );
    }
  }
}
