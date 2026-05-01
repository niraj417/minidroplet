import 'package:flutter/material.dart';
import 'package:tinydroplets/core/utils/shared_pref_key.dart';
import 'package:tinydroplets/features/presentation/pages/video_page/model/recipe_all_playlist_model.dart';

import '../../../../../core/constant/app_export.dart';

class AllPlaylistCard extends StatelessWidget {
  final RecipeAllPlaylistDataModel recipe;

  const AllPlaylistCard({
    super.key,
    required this.recipe,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasSubscription =
        SharedPref.getBool(SharedPrefKeys.hasPremiumAccess) ?? false;

    /// 🔐 Show LOCKED only if:
    /// - playlist is paid
    /// - user does NOT have subscription
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
                imageUrl: recipe.thumbnail,
                width: 155,
                height: 210,
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
                top: 8,
                right: 8,
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.lock, color: Colors.black87,size: 20,),
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
            recipe.name,
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
