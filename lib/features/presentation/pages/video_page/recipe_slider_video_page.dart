import 'package:flutter/material.dart';
import 'package:tinydroplets/features/presentation/pages/video_page/recipe_detail_page.dart';
import 'package:tinydroplets/features/presentation/pages/video_page/video_checkout_page.dart';

import '../../../../common/navigation/navigation_service.dart';
import '../../../../common/widgets/custom_image.dart';
import '../../../../common/widgets/loader.dart';
import '../../../../common/widgets/no_data_widget.dart';
import '../../../../core/network/api_controller.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/services/ad_service/interstitial_ad/interstitial_ad_widget.dart';
import '../../../../core/utils/shared_pref.dart';
import '../../../../core/utils/shared_pref_key.dart';
import 'model/all_recipe_video_model.dart';

class RecipeSubcategoryVideoPage extends StatefulWidget {
  final String subCategoryId;
  final String title;

  const RecipeSubcategoryVideoPage({
    super.key,
    required this.subCategoryId,
    required this.title,
  });

  @override
  State<RecipeSubcategoryVideoPage> createState() =>
      _RecipeSubcategoryVideoPageState();
}

class _RecipeSubcategoryVideoPageState
    extends State<RecipeSubcategoryVideoPage> {
  final DioClient _dioClient = DioClient();

  List<AllRecipeVideoDataModel> _videos = [];
  bool _isLoading = true;

  late final bool _hasPremium;

  @override
  void initState() {
    super.initState();

    _hasPremium =
        SharedPref.getBool(SharedPrefKeys.hasPremiumAccess) ?? false;

    _loadVideos();
  }

  Future<void> _loadVideos() async {
    try {
      final response = await _dioClient.sendGetRequest(
        '${ApiEndpoints.allRecipeVideosByMultipleSubcategories}?subcat_ids=${widget.subCategoryId}',
      );

      final model = AllRecipeVideoModel.fromJson(response.data);

      setState(() {
        _videos = model.data ?? [];
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: _isLoading
          ? const Center(child: Loader())
          : _videos.isEmpty
          ? NoDataWidget(onPressed: _loadVideos)
          : GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate:
        const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
          childAspectRatio: 0.9,
        ),
        itemCount: _videos.length,
        itemBuilder: (_, index) {
          final video = _videos[index];
          final isFree = video.priceType == 'free';

          final card = _buildVideoCard(video);

          if (isFree && !_hasPremium) {
            return InterstitialAdWidget(
              onAdClosed: () => _openVideo(video),
              child: card,
            );
          }

          return GestureDetector(
            onTap: () => _openVideo(video),
            child: card,
          );
        },
      ),
    );
  }

  Widget _buildVideoCard(AllRecipeVideoDataModel video) {
    final showLocked =
        !_hasPremium && video.priceType != 'free';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 110,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Theme.of(context).cardColor,
                ),
                clipBehavior: Clip.hardEdge,
                child: CustomImage(imageUrl: video.thumbnail),
              ),
              Container(
                height: 110,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.black.withOpacity(0.2),
                ),
              ),
              if (showLocked)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.lock,
                      color: Colors.black87,
                      size: 20,
                    ),
                  ),
                ),
              const Positioned.fill(
                child: Icon(
                  Icons.play_circle_fill_outlined,
                  size: 40,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            video.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            video.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13),
          ),
        ],
      ),
    );
  }

  void _openVideo(AllRecipeVideoDataModel video) {
    if (video.priceType == 'free' || _hasPremium) {
      goto(
        context,
        RecipeDetailScreen(videoId: video.id.toString()),
      );
    } else {
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
    }
  }

}