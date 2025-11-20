import 'package:tinydroplets/features/presentation/pages/video_page/playlist_checkout_page.dart';
import 'package:tinydroplets/features/presentation/pages/video_page/recipe_detail_page.dart';
import 'package:tinydroplets/features/presentation/pages/video_page/recipe_playlist_screen.dart';
import 'package:tinydroplets/features/presentation/pages/video_page/video_checkout_page.dart';

import '../../../../core/constant/app_export.dart';
import '../../../../core/services/ad_service/interstitial_ad/interstitial_ad_widget.dart';
import 'model/recipe_recommendation_model.dart';

class AllRecommendationRecipePage extends StatelessWidget {
  final List<RecipeRecommendationDataModel> recommendationRecipeList;
  const AllRecommendationRecipePage({
    super.key,
    required this.recommendationRecipeList,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child:
            recommendationRecipeList.isEmpty
                ? Center(child: Text('No data available'))
                : GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: (MediaQuery.of(context).size.width ~/ 180)
                        .clamp(1, 4),
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 2,
                    childAspectRatio: 3 / 4,
                  ),
                  itemCount: recommendationRecipeList.length,
                  itemBuilder: (context, index) {
                    final item = recommendationRecipeList[index];
                    final isFree = item.priceType == 'free';

                    // Debug logging
                    print(
                      'Video Item ${item.id}: priceType=${item.priceType}, isBuy=${item.isBuy}, isFree=$isFree',
                    );

                    final childCard = LayoutBuilder(
                      builder: (context, constraints) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Stack(
                              children: [
                                Container(
                                  height: constraints.maxHeight * 0.75,
                                  width: constraints.maxWidth,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: Theme.of(context).cardColor,
                                  ),
                                  clipBehavior: Clip.hardEdge,
                                  child: CustomImage(
                                    imageUrl: item.videoThumbnail,
                                  ),
                                ),
                                Container(
                                  height: constraints.maxHeight * 0.75,
                                  width: constraints.maxWidth,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: Colors.black.withOpacity(0.3),
                                  ),
                                  clipBehavior: Clip.hardEdge,
                                ),
                                if (item.isBuy == '0')
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 2,
                                      ),
                                      color: Colors.white,
                                      child: Text(
                                        item.priceType == 'paid' ? 'Paid' : '',
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                if (item.type == 'playlist')
                                  Positioned(
                                    bottom: 20,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.only(left: 6.0),
                                      decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(4.0),
                                          bottomLeft: Radius.circular(4.0),
                                        ),
                                        color: Theme.of(context).cardColor,
                                      ),
                                      clipBehavior: Clip.hardEdge,
                                      child: const Text(
                                        'Playlist',
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ),
                                  ),
                                const Positioned(
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
                              ],
                            ),
                            const SizedBox(height: 5),
                            Expanded(
                              child: Text(
                                item.videoTitle,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                                softWrap: true,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        );
                      },
                    );

                    return isFree
                        ? InterstitialAdWidget(
                          onAdClosed: () {
                            print('Ad closed for video item ${item.id}');
                            if (item.type == 'playlist') {
                              if (item.isBuy.trim() == '0') {
                                goto(
                                  context,
                                  PlaylistCheckoutPage(
                                    id: int.parse(item.id) ?? 0,
                                    title: item.name ?? '',
                                    thumbnail: item.videoThumbnail ?? '',
                                    amount: item.price ?? '',
                                    mainPrice: item.mainPrice ?? '',
                                    totalVideo: item.totalVideos ?? '',
                                    description: item.description ?? '',
                                  ),
                                );
                              } else {
                                goto(
                                  context,
                                  RecipePlaylistScreen(
                                    playlistId: item.id.toString(),
                                  ),
                                );
                              }
                            } else {
                              if (item.isBuy.trim() == '0') {
                                goto(
                                  context,
                                  VideoCheckoutPage(
                                    id: int.parse(item.id) ?? 0,
                                    title: item.videoTitle ?? '',
                                    thumbnail: item.videoThumbnail ?? '',
                                    amount: item.price ?? '',
                                    mainPrice: item.mainPrice ?? '',
                                  ),
                                );
                              } else {
                                goto(
                                  context,
                                  RecipeDetailScreen(
                                    videoId: item.id.toString(),
                                  ),
                                );
                              }
                            }
                          },
                          child: childCard,
                        )
                        : GestureDetector(
                          onTap: () {
                            print(
                              'GestureDetector tapped for video item ${item.id}',
                            );
                            if (item.type == 'playlist') {
                              if (item.isBuy.trim() == '0') {
                                goto(
                                  context,
                                  PlaylistCheckoutPage(
                                    id: int.parse(item.id) ?? 0,
                                    title: item.name ?? '',
                                    thumbnail: item.videoThumbnail ?? '',
                                    amount: item.price ?? '',
                                    mainPrice: item.mainPrice ?? '',
                                    totalVideo: item.totalVideos ?? '',
                                    description: item.description ?? '',
                                  ),
                                );
                              } else {
                                goto(
                                  context,
                                  RecipePlaylistScreen(
                                    playlistId: item.id.toString(),
                                  ),
                                );
                              }
                            } else {
                              if (item.isBuy.trim() == '0') {
                                goto(
                                  context,
                                  VideoCheckoutPage(
                                    id: int.parse(item.id) ?? 0,
                                    title: item.videoTitle ?? '',
                                    thumbnail: item.videoThumbnail ?? '',
                                    amount: item.price ?? '',
                                    mainPrice: item.mainPrice ?? '',
                                  ),
                                );
                              } else {
                                goto(
                                  context,
                                  RecipeDetailScreen(
                                    videoId: item.id.toString(),
                                  ),
                                );
                              }
                            }
                          },
                          child: childCard,
                        );
                  },
                ),
      ),
    );
  }
}
