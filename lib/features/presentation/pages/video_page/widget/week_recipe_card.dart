import 'package:flutter/material.dart';
import 'package:tinydroplets/features/presentation/pages/video_page/model/all_recipe_video_model.dart';

import '../../../../../core/constant/app_export.dart';

class WeekRecipeCard extends StatelessWidget {
  static const double _cardWidth = 150;
  static const double _imageHeight = 140;

  final AllRecipeVideoDataModel recipe;
  final bool hasPremiumAccess;

  const WeekRecipeCard({
    super.key,
    required this.recipe,
    required this.hasPremiumAccess,
  });

  @override
  Widget build(BuildContext context) {
    final bool showLocked = recipe.priceType == 'paid' && !hasPremiumAccess;
    final title = recipe.title.trim().isEmpty ? 'Untitled recipe' : recipe.title;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            Container(
              height: _imageHeight,
              width: _cardWidth,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Theme.of(context).cardColor,
              ),
              clipBehavior: Clip.hardEdge,
              child: const RepaintBoundary(
                child: SizedBox.expand(),
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: CustomImage(
                imageUrl: recipe.thumbnail,
                width: _cardWidth,
                height: _imageHeight,
                memCacheWidth: 420,
                memCacheHeight: 420,
              ),
            ),
            Container(
              height: _imageHeight,
              width: _cardWidth,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.black.withOpacity(0.3),
              ),
            ),
            const Positioned.fill(
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
        const SizedBox(height: 8),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            softWrap: true,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
