import 'package:flutter/material.dart';
import 'package:tinydroplets/core/constant/app_export.dart';
import 'package:tinydroplets/core/services/ad_service/interstitial_ad/interstitial_ad_widget.dart';
import 'package:tinydroplets/features/presentation/pages/video_page/recipe_detail_page.dart';
import 'package:tinydroplets/features/presentation/pages/video_page/video_checkout_page.dart';
import '../../../../core/services/subscription_state_manager.dart';
import 'model/all_recipe_video_model.dart';

class AllWeekRecipePage extends StatelessWidget {
  const AllWeekRecipePage({
    super.key,
    required this.allRecipeVideoList,
  });

  final List<AllRecipeVideoDataModel> allRecipeVideoList;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SubscriptionStatus>(
      future: SubscriptionStateManager.resolve(),
      builder: (context, snapshot) {
        final SubscriptionStatus status =
            snapshot.data ?? SubscriptionStatus.free;

        final bool hasPremiumAccess =
        SubscriptionStateManager.hasPremiumAccess(status);

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

                final bool isPaid = item.priceType == 'paid';

                /// 🔒 Lock only if paid + no premium
                final bool isLocked = isPaid && !hasPremiumAccess;

                /// 📺 Show ad only if free + no premium
                final bool shouldShowAd =
                    !isPaid && !hasPremiumAccess;

                void navigate() {
                  if (isLocked) {
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
                      RecipeDetailScreen(
                        videoId: item.id.toString(),
                      ),
                    );
                  }
                }

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

                            /// 🔒 LOCK ICON (subscription based)
                            if (isLocked)
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.7),
                                    borderRadius:
                                    BorderRadius.circular(6),
                                  ),
                                  child: const Icon(
                                    Icons.lock,
                                    color: Colors.black87,
                                    size: 20,
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

                if (shouldShowAd) {
                  return InterstitialAdWidget(
                    onAdClosed: navigate,
                    child: childWidget,
                  );
                }

                return GestureDetector(
                  onTap: navigate,
                  child: childWidget,
                );
              },
            ),
          ),
        );
      },
    );
  }
}
