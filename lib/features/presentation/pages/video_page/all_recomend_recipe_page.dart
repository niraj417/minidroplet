import 'package:flutter/material.dart';
import 'package:tinydroplets/core/constant/app_export.dart';
import 'package:tinydroplets/core/utils/shared_pref_key.dart';
import 'package:tinydroplets/core/services/ad_service/interstitial_ad/interstitial_ad_widget.dart';
import 'package:tinydroplets/features/presentation/pages/video_page/playlist_checkout_page.dart';
import 'package:tinydroplets/features/presentation/pages/video_page/recipe_detail_page.dart';
import 'package:tinydroplets/features/presentation/pages/video_page/recipe_playlist_screen.dart';
import 'package:tinydroplets/features/presentation/pages/video_page/video_checkout_page.dart';
import 'model/recipe_recommendation_model.dart';

class AllRecommendationRecipePage extends StatelessWidget {
  final List<RecipeRecommendationDataModel> recommendationRecipeList;

  const AllRecommendationRecipePage({
    super.key,
    required this.recommendationRecipeList,
  });

  bool _hasPremium() {
    return SharedPref.getBool(SharedPrefKeys.hasPremiumAccess) ?? false;
  }

  bool _shouldShowAd(String priceType) {
    return priceType == 'free' && !_hasPremium();
  }

  bool _isLocked(String priceType) {
    return priceType != 'free' && !_hasPremium();
  }

  void _navigate(BuildContext context, RecipeRecommendationDataModel item) {
    final bool hasPremium = _hasPremium();
    final bool isPaid = item.priceType != 'free';

    if (item.type == 'playlist') {
      if (isPaid && !hasPremium) {
        goto(
          context,
          PlaylistCheckoutPage(
            id: int.tryParse(item.id) ?? 0,
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
      if (isPaid && !hasPremium) {
        goto(
          context,
          VideoCheckoutPage(
            id: int.tryParse(item.id) ?? 0,
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
  }

  @override
  Widget build(BuildContext context) {
    final bool hasPremium = _hasPremium();

    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: recommendationRecipeList.isEmpty
            ? const Center(child: Text('No data available'))
            : GridView.builder(
          padding: const EdgeInsets.all(8),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount:
            (MediaQuery.of(context).size.width ~/ 180)
                .clamp(1, 4),
            crossAxisSpacing: 20,
            mainAxisSpacing: 2,
            childAspectRatio: 3 / 4,
          ),
          itemCount: recommendationRecipeList.length,
          itemBuilder: (context, index) {
            final item = recommendationRecipeList[index];

            final Widget card = LayoutBuilder(
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
                        ),

                        /// 🔒 LOCKED TAG (replaces Paid)
                        if (_isLocked(item.priceType))
                          Positioned(
                            top: 5,
                            right: 5,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(Icons.lock, color: Colors.black87,size: 20,),
                            ),
                          ),

                        /// Playlist tag
                        if (item.type == 'playlist')
                          Positioned(
                            bottom: 20,
                            right: 0,
                            child: Container(
                              padding:
                              const EdgeInsets.only(left: 6.0),
                              decoration: BoxDecoration(
                                borderRadius:
                                const BorderRadius.only(
                                  topLeft: Radius.circular(4.0),
                                  bottomLeft: Radius.circular(4.0),
                                ),
                                color: Theme.of(context).cardColor,
                              ),
                              child: const Text(
                                'Playlist',
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                          ),

                        const Positioned.fill(
                          child: Center(
                            child: Icon(
                              Icons.play_circle_fill_outlined,
                              size: 40,
                              color: Colors.white,
                            ),
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
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                );
              },
            );

            if (_shouldShowAd(item.priceType)) {
              return InterstitialAdWidget(
                onAdClosed: () => _navigate(context, item),
                child: card,
              );
            }

            return GestureDetector(
              onTap: () => _navigate(context, item),
              child: card,
            );
          },
        ),
      ),
    );
  }
}