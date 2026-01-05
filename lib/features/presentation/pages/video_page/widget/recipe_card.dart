import 'package:flutter/material.dart';
import 'package:tinydroplets/core/utils/shared_pref_key.dart';
import 'package:tinydroplets/features/presentation/pages/video_page/model/recipe_recommendation_model.dart';

import '../../../../../core/constant/app_export.dart';

class RecipeCard extends StatelessWidget {
  final RecipeRecommendationDataModel recipe;

  const RecipeCard({
    super.key,
    required this.recipe,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasSubscription =
        SharedPref.getBool(SharedPrefKeys.hasPremiumAccess) ?? false;

    /// 🔐 Locked only if:
    /// - content is paid
    /// - user has NO subscription
    final bool showLocked =
        recipe.priceType == 'paid' && !hasSubscription;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            Container(
              height: 210,
              width: 155,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Theme.of(context).cardColor,
              ),
              clipBehavior: Clip.hardEdge,
              child: CustomImage(
                imageUrl: recipe.videoThumbnail,
              ),
            ),

            Container(
              height: 210,
              width: 155,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.black.withValues(alpha: 0.3),
              ),
              clipBehavior: Clip.hardEdge,
            ),

            /// 🔒 LOCKED BADGE (subscription-based)
            if (showLocked)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                  ),
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

            /// Playlist badge (unchanged)
            if (recipe.type == 'playlist')
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
            recipe.videoTitle,
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
  }
}
