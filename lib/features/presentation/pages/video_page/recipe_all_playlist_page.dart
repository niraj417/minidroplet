import 'package:tinydroplets/features/presentation/pages/video_page/playlist_checkout_page.dart';
import 'package:tinydroplets/features/presentation/pages/video_page/recipe_detail_page.dart';
import 'package:tinydroplets/features/presentation/pages/video_page/recipe_playlist_screen.dart';
import 'package:tinydroplets/features/presentation/pages/video_page/widget/recipe_card.dart';

import '../../../../common/widgets/guest_user_restriction.dart';
import '../../../../core/constant/app_export.dart';
import 'model/recipe_all_playlist_model.dart';
import 'model/recipe_recommendation_model.dart';

class RecipeAllPlaylistPage extends StatelessWidget {
  final List<RecipeAllPlaylistDataModel> recipeAllPlaylistList;
  const RecipeAllPlaylistPage({super.key, required this.recipeAllPlaylistList});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child:
            recipeAllPlaylistList.isEmpty
                ? Center(child: Text('No data available'))
                : GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: (MediaQuery.of(context).size.width ~/ 180)
                        .clamp(1, 4),
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 2,
                    childAspectRatio: 2.1 / 4,
                  ),
                  itemCount: recipeAllPlaylistList.length,
                  itemBuilder: (context, index) {
                    return Center(
                      child: GestureDetector(
                        onTap: () {
                          if(SharedPref.isGuestUser()){
                            GuestRestrictionDialog.show(context);
                            return;
                          }

                          final item = recipeAllPlaylistList[index];
                          if (item.isBuy == '0') {
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
                        },
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
                                    imageUrl:
                                        recipeAllPlaylistList[index].thumbnail,
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
                                // if (recipeAllPlaylistList[index].isBuy == '1')
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                    ),
                                    child: Center(
                                      child: Text(
                                        recipeAllPlaylistList[index]
                                                    .priceType ==
                                                'paid'
                                            ? 'Paid'
                                            : 'Free',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
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
                                recipeAllPlaylistList[index].name,
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
