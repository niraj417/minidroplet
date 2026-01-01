import 'package:flutter/material.dart';
import 'package:tinydroplets/core/constant/app_export.dart';
import 'package:tinydroplets/core/utils/shared_pref_key.dart';
import 'package:tinydroplets/core/services/ad_service/interstitial_ad/interstitial_ad_widget.dart';
import 'package:tinydroplets/features/presentation/pages/video_page/recipe_detail_page.dart';
import 'package:tinydroplets/features/presentation/pages/video_page/video_checkout_page.dart';
import 'model/all_recipe_video_model.dart';

class AllWeekRecipePage extends StatelessWidget {
  const AllWeekRecipePage({
    super.key,
    required this.allRecipeVideoList,
  });

  final List<AllRecipeVideoDataModel> allRecipeVideoList;

  bool _hasPremium() {
    return SharedPref.getBool(SharedPrefKeys.hasPremiumAccess) ?? false;
  }

  bool _shouldShowAd(String priceType) {
    return priceType == 'free' && !_hasPremium();
  }

  bool _isLocked(String priceType) {
    return priceType != 'free' && !_hasPremium();
  }

  void _navigate(BuildContext context, AllRecipeVideoDataModel item) {
    final bool hasPremium = _hasPremium();
    final bool isPaid = item.priceType != 'free';

    if (isPaid && !hasPremium) {
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
      goto(
        context,
        RecipeDetailScreen(videoId: item.id.toString()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: allRecipeVideoList.isEmpty
            ? const Center(child: Text('No data available'))
            : ListView.builder(
          itemCount: allRecipeVideoList.length,
          physics: const AlwaysScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final item = allRecipeVideoList[index];

            final childWidget = Center(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 10,
                ),
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
                            imageUrl: item.thumbnail,
                          ),
                        ),
                        Container(
                          height: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.black.withOpacity(0.3),
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

                        /// 🔒 LOCKED TAG (replaces Paid)
                        if (_isLocked(item.priceType))
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              color: Colors.white,
                              child: const Text(
                                'Locked',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      item.description,
                      style: const TextStyle(fontSize: 15),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );

            if (_shouldShowAd(item.priceType)) {
              return InterstitialAdWidget(
                onAdClosed: () => _navigate(context, item),
                child: childWidget,
              );
            }

            return GestureDetector(
              onTap: () => _navigate(context, item),
              child: childWidget,
            );
          },
        ),
      ),
    );
  }
}
