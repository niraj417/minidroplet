import 'package:flutter/material.dart';
import 'package:tinydroplets/features/presentation/pages/video_page/playlist_checkout_page.dart';
import 'package:tinydroplets/features/presentation/pages/video_page/recipe_playlist_screen.dart';

import '../../../../common/widgets/guest_user_restriction.dart';
import '../../../../core/constant/app_export.dart';
import '../../../../core/utils/shared_pref_key.dart';
import 'model/recipe_all_playlist_model.dart';

class RecipeAllPlaylistPage extends StatelessWidget {
  final List<RecipeAllPlaylistDataModel> recipeAllPlaylistList;

  const RecipeAllPlaylistPage({
    super.key,
    required this.recipeAllPlaylistList,
  });

  bool _hasPremium() {
    return SharedPref.getBool(SharedPrefKeys.hasPremiumAccess) ?? false;
  }

  bool _isLocked(String priceType) {
    return priceType == 'paid' && !_hasPremium();
  }

  void _navigate(BuildContext context, RecipeAllPlaylistDataModel item) {
    if (SharedPref.isGuestUser()) {
      GuestRestrictionDialog.show(context);
      return;
    }

    final bool hasPremium = _hasPremium();
    final bool isPaid = item.priceType == 'paid';

    if (isPaid && !hasPremium) {
      goto(
        context,
        PlaylistCheckoutPage(
          id: item.id,
          title: item.name ?? '',
          thumbnail: item.thumbnail ?? '',
          amount: item.price ?? '',
          mainPrice: item.mainPrice ?? '',
          totalVideo: item.totalVideos,
          description: item.description,
        ),
      );
    } else {
      goto(
        context,
        RecipePlaylistScreen(
          playlistId: item.id.toString(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: recipeAllPlaylistList.isEmpty
            ? const Center(child: Text('No data available'))
            : GridView.builder(
          padding: const EdgeInsets.all(8),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount:
            (MediaQuery.of(context).size.width ~/ 180)
                .clamp(1, 4),
            crossAxisSpacing: 20,
            mainAxisSpacing: 2,
            childAspectRatio: 2.1 / 4,
          ),
          itemCount: recipeAllPlaylistList.length,
          itemBuilder: (context, index) {
            final item = recipeAllPlaylistList[index];

            return Center(
              child: GestureDetector(
                onTap: () => _navigate(context, item),
                child: Column(
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
                            imageUrl: item.thumbnail,
                          ),
                        ),
                        Container(
                          height: 210,
                          width: 155,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.black.withOpacity(0.3),
                          ),
                        ),

                        /// 🔒 LOCKED BADGE (replaces Paid/Free)
                        if (_isLocked(item.priceType))
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

                        const Positioned.fill(
                          child: Center(
                            child: Icon(
                              Icons.play_circle_fill_outlined,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Expanded(
                      child: Text(
                        item.name,
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
              ),
            );
          },
        ),
      ),
    );
  }
}
