import 'package:flutter/material.dart';
import 'package:tinydroplets/features/presentation/pages/video_page/model/all_recipe_video_model.dart';

import '../../../../../core/constant/app_export.dart';

class WeekRecipeCard extends StatelessWidget {
  final AllRecipeVideoDataModel recipe;
  final bool hasPremiumAccess;

  const WeekRecipeCard({
    super.key,
    required this.recipe,
    required this.hasPremiumAccess,
  });

  @override
  Widget build(BuildContext context) {
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
  }
}
