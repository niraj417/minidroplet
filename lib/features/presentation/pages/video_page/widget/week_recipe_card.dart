import 'package:flutter/material.dart';
import 'package:tinydroplets/features/presentation/pages/video_page/model/all_recipe_video_model.dart';

import '../../../../../core/constant/app_export.dart';
import '../../../../../core/services/subscription_state_manager.dart';

class WeekRecipeCard extends StatelessWidget {
  final AllRecipeVideoDataModel recipe;

  const WeekRecipeCard({
    super.key,
    required this.recipe,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SubscriptionStatus>(
      future: SubscriptionStateManager.resolve(),
      builder: (context, snapshot) {
        final SubscriptionStatus status =
            snapshot.data ?? SubscriptionStatus.free;

        /// 🔐 Premium access (trial OR subscribed)
        final bool hasPremiumAccess =
        SubscriptionStateManager.hasPremiumAccess(status);

        /// 🔒 Show lock ONLY when:
        /// - content is paid
        /// - user does NOT have premium access
        final bool showLocked =
            recipe.priceType == 'paid' && !hasPremiumAccess;

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
                      width: 260,
                      height: 140,
                    ),
                  ),

                  Container(
                    height: 140,
                    width: 260,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.black.withOpacity(0.3),
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

                  /// 🔒 LOCK BADGE (subscription-aware)
                  if (showLocked)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.75),
                          borderRadius: BorderRadius.circular(6),
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

              const SizedBox(height: 5),

              Expanded(
                child: Text(
                  recipe.title,
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
          ),
        );
      },
    );
  }
}
