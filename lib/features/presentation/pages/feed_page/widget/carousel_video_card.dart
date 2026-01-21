import 'package:flutter/material.dart';
import 'package:tinydroplets/core/constant/app_export.dart';
import 'package:tinydroplets/core/services/subscription_service.dart';
import 'package:tinydroplets/core/services/ad_service/interstitial_ad/interstitial_ad_widget.dart';
import 'package:tinydroplets/core/utils/shared_pref.dart';

import '../../video_page/model/all_recipe_video_model.dart';
import '../../video_page/recipe_detail_page.dart';
import '../../video_page/video_checkout_page.dart';

class CarouselVideoCard extends StatelessWidget {
  final AllRecipeVideoDataModel video;

  const CarouselVideoCard({
    super.key,
    required this.video,
  });

  // ---------------------------------------------------------
  // PREMIUM ACCESS (subscription OR trial) – SINGLE SOURCE
  // ---------------------------------------------------------
  Future<bool> _hasPremiumAccess() async {
    final loginData = SharedPref.getLoginData();

    if (loginData == null || loginData.data == null) return false;

    final subscription = loginData.data!.subscription;

    if (subscription == null) return false;

    return subscription.isActive == 1 || subscription.isTrial == 1;
  }

  // ---------------------------------------------------------
  // ADS DECISION
  // ---------------------------------------------------------
  bool _shouldShowAds({
    required bool hasAccess,
  }) {
    return video.priceType == 'free' && !hasAccess;
  }

  // ---------------------------------------------------------
  // Build full thumbnail URL
  // ---------------------------------------------------------
  String fullThumbnail(String thumb) {
    if (thumb.startsWith('http')) return thumb;
    return 'https://api.tinydroplets.com/$thumb';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _hasPremiumAccess(),
      builder: (context, snapshot) {
        final bool hasAccess = snapshot.data ?? false;

        final Widget card = GestureDetector(
          onTap: () => _onTap(context, hasAccess),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildThumbnail(context, hasAccess),
              const SizedBox(height: 5),
              SizedBox(
                width: 180,
                child: Text(
                  video.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );

        /// 🔕 Ads ONLY for:
        /// - free videos
        /// - user has NO subscription
        /// - user is NOT on trial
        if (!_shouldShowAds(hasAccess: hasAccess)) {
          return card;
        }

        return InterstitialAdWidget(
          onAdClosed: () => _onTap(context, hasAccess),
          child: card,
        );
      },
    );
  }

  // ---------------------------------------------------------
  // THUMBNAIL + OVERLAYS (UI UNCHANGED)
  // ---------------------------------------------------------
  Widget _buildThumbnail(BuildContext context, bool hasAccess) {
    return Stack(
      children: [
        // image
        Container(
          height: 140,
          width: 180,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: Theme.of(context).cardColor,
          ),
          clipBehavior: Clip.hardEdge,
          child: CustomImage(
            imageUrl: fullThumbnail(video.thumbnail),
            fit: BoxFit.cover,
          ),
        ),

        // dark overlay
        Container(
          height: 140,
          width: 180,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: Colors.black.withOpacity(0.25),
          ),
        ),

        // play icon centered
        const Positioned.fill(
          child: Center(
            child: Icon(
              Icons.play_circle_fill_outlined,
              size: 42,
              color: Colors.white,
            ),
          ),
        ),

        /// 🔒 LOCKED tag (paid + no access)
        if (hasAccess)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'Locked',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ---------------------------------------------------------
  // NAVIGATION (SUBSCRIPTION-BASED)
  // ---------------------------------------------------------
  Future<void> _onTap(BuildContext context, bool hasAccess) async {
    final bool isPaid = video.priceType != 'free';

    /// ❌ Paid video + no access → checkout ONLY
    if (isPaid && !hasAccess) {
      goto(
        context,
        VideoCheckoutPage(
          id: video.id,
          title: video.title,
          thumbnail: video.thumbnail,
          amount: video.price,
          mainPrice: video.mainPrice,
        ),
      );
      return;
    }

    /// ✅ Free OR premium
    goto(
      context,
      RecipeDetailScreen(videoId: video.id.toString()),
    );
  }
}
