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
  // PREMIUM ACCESS (subscription OR trial)
  // ---------------------------------------------------------
  Future<bool> _hasPremiumAccess() async {
    final bool subscribed =
    await SubscriptionPaymentService.hasActiveSubscription();
    final bool isTrial = SharedPref.getBool('isTrial') ?? false;
    return subscribed || isTrial;
  }

  // ---------------------------------------------------------
  // ADS DECISION
  // ---------------------------------------------------------
  Future<bool> _shouldShowAds() async {
    final bool hasAccess = await _hasPremiumAccess();
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
    final Widget card = GestureDetector(
      onTap: () => _onTap(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildThumbnail(context),
          const SizedBox(height: 5),
          SizedBox(
            width: 260,
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
    if (video.priceType != 'free') return card;

    return FutureBuilder<bool>(
      future: _shouldShowAds(),
      builder: (context, snapshot) {
        final bool showAds = snapshot.data ?? false;

        if (!showAds) return card;

        return InterstitialAdWidget(
          onAdClosed: () => _onTap(context),
          child: card,
        );
      },
    );
  }

  // ---------------------------------------------------------
  // THUMBNAIL + OVERLAYS (UI UNCHANGED)
  // ---------------------------------------------------------
  Widget _buildThumbnail(BuildContext context) {
    return FutureBuilder<bool>(
      future: _hasPremiumAccess(),
      builder: (context, snapshot) {
        final bool hasAccess = snapshot.data ?? false;

        return Stack(
          children: [
            // image
            Container(
              height: 140,
              width: 260,
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
              width: 260,
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
            if (video.priceType != 'free' && !hasAccess)
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
      },
    );
  }

  // ---------------------------------------------------------
  // NAVIGATION (SUBSCRIPTION-BASED)
  // ---------------------------------------------------------
  Future<void> _onTap(BuildContext context) async {
    final bool hasAccess = await _hasPremiumAccess();
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
