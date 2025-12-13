import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tinydroplets/common/widgets/no_data_widget.dart';
import 'package:tinydroplets/common/widgets/search_text_card.dart';
import 'package:tinydroplets/core/utils/shared_pref_key.dart';
import 'package:tinydroplets/features/presentation/pages/feed_page/bloc/feed_bloc.dart';
import 'package:tinydroplets/features/presentation/pages/video_page/all_recipe_category_page.dart';
import 'package:tinydroplets/features/presentation/pages/video_page/all_recomend_recipe_page.dart';
import 'package:tinydroplets/features/presentation/pages/video_page/all_week_recipe_page.dart';
import 'package:tinydroplets/features/presentation/pages/video_page/ingredient_page.dart';
import 'package:tinydroplets/features/presentation/pages/video_page/playlist_checkout_page.dart';
import 'package:tinydroplets/features/presentation/pages/video_page/recipe_all_playlist_page.dart';
import 'package:tinydroplets/features/presentation/pages/video_page/recipe_category_videos_page.dart';
import 'package:tinydroplets/features/presentation/pages/video_page/recipe_detail_page.dart';
import 'package:tinydroplets/features/presentation/pages/video_page/recipe_playlist_screen.dart';
import 'package:tinydroplets/features/presentation/pages/video_page/search_recipe_page.dart';
import 'package:tinydroplets/features/presentation/pages/video_page/video_checkout_page.dart';
import 'package:tinydroplets/features/presentation/pages/video_page/widget/all_playlist_card.dart';
import 'package:tinydroplets/features/presentation/pages/video_page/widget/ingredient_category.dart';
import 'package:tinydroplets/features/presentation/pages/video_page/widget/recipe_card.dart';
import 'package:tinydroplets/features/presentation/pages/video_page/widget/video_category_card.dart';
import 'package:tinydroplets/features/presentation/pages/video_page/widget/week_recipe_card.dart';

import '../../../../common/widgets/custom_caraousel.dart';
import '../../../../common/widgets/guest_user_restriction.dart';
import '../../../../common/widgets/loader.dart';
import '../../../../core/constant/app_export.dart';
import '../../../../core/services/ad_service/interstitial_ad/interstitial_ad_widget.dart';
import '../../../../core/services/subscription_service.dart';
import '../feed_page/bloc/age_group_bloc/age_group_cubit.dart';
import 'bloc/ingredient_bloc/ingredient_cubit.dart';
import 'bloc/video_page_bloc/video_page_bloc.dart';

class VideoPage extends StatefulWidget {
  const VideoPage({super.key});

  @override
  State<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {

  bool isSubscribed = false;
  bool paidAvailable = false;

  @override
  void initState() {
    super.initState();
    context.read<AgeGroupCubit>().fetchAgeGroup();
    isSubscribed = SharedPref.getBool("isSubscribed") ?? false;
    paidAvailable = SharedPref.getBool(SharedPrefKeys.hasPremiumAccess) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => VideoPageCubit(),
      child: _VideoPageContent(paidAvailable),
    );
  }
}

class _VideoPageContent extends StatelessWidget {

  final bool isSubscribed;

  _VideoPageContent(this.isSubscribed);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Recipe'),
      body: BlocBuilder<VideoPageCubit, VideoPageState>(
        builder: (context, state) {
          return RefreshIndicator(
            backgroundColor: Color(AppColor.primaryColor),
            color: Colors.white,

            onRefresh: () async {
              await context.read<AgeGroupCubit>().fetchAgeGroup();
              await context.read<VideoPageCubit>().refreshData();
            },
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: SearchTextCard(
                      text: 'Search, Favorite Recipe',
                      onTap:
                          () => goto(context, const RecipeSearchFilterScreen()),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildCarousel(state, context),
                  const SizedBox(height: 10),

                  _buildVideoCategory(state, context),

                  const SizedBox(height: 10),
                  _ageGroup(context),
                  _ingredientCategory(context),
                  const SizedBox(height: 10),
                  _buildRecommendation(state, context),
                  const SizedBox(height: 10),

                  _buildRecipeOfTheWeek(state, context),
                  const SizedBox(height: 10),
                  _buildRecipePlaylist(state, context),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCarousel(VideoPageState state, BuildContext context) {
    return state.recipeCarouselList.isEmpty
        ? SizedBox.shrink()
        // NoDataWidget(onPressed: () => context.read<VideoPageCubit>().fetchRecipeCarousel())
        : CustomCarousel(
          items: state.recipeCarouselList,
          itemBuilder:
              (context, feedSliderItem, index) => GestureDetector(
                onTap: () {
                  if (feedSliderItem.isBuy == '0' || isSubscribed) {
                    if(state.subscribed || isSubscribed){
                      goto(context, RecipeDetailScreen(videoId: feedSliderItem.id.toString()));
                    } else {
                      goto(
                        context,
                        VideoCheckoutPage(
                          id: feedSliderItem.id,
                          title: feedSliderItem.title ?? '',
                          thumbnail: feedSliderItem.thumbnail ?? '',
                          amount: feedSliderItem.price ?? '',
                          mainPrice: feedSliderItem.mainPrice ?? '',
                        ),
                      );
                    }
                  } else {
                    goto(
                      context,
                      RecipeDetailScreen(videoId: feedSliderItem.id.toString()),
                    );
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CustomImage(
                      imageUrl: feedSliderItem.image,
                      fit: BoxFit.contain,
                      width: 300,
                      height: 200,
                    ),
                  ),
                ),
              ),
        );
  }

  Widget _buildVideoCategory(VideoPageState state, BuildContext context) {
    return state.allRecipeCategoryList.isNotEmpty
        ? Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Categories',
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 19),
                  ),
                  TextButton(
                    onPressed:
                        () => goto(
                          context,
                          AllRecipeCategoryPage(
                            allRecipeCategoryList: state.allRecipeCategoryList,
                          ),
                        ),
                    child: Text(
                      'View all',
                      style: TextStyle(
                        color: Color(AppColor.primaryColor),
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 70,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: state.allRecipeCategoryList.length.clamp(0, 5),
                  itemBuilder:
                      (context, index) => Padding(
                        padding: const EdgeInsets.only(right: 16.0),
                        child: SizedBox(
                          width: 150,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap:
                                () => goto(
                                  context,
                                  RecipeCategoryVideoPage(
                                    id:
                                        state.allRecipeCategoryList[index].id
                                            .toString(),
                                    categoryName:
                                        state.allRecipeCategoryList[index].name
                                            .toString(),
                                  ),
                                ),
                            child: VideoCategoryCard(
                              category: state.allRecipeCategoryList[index],
                            ),
                          ),
                        ),
                      ),
                ),
              ),
            ],
          ),
        )
        : NoDataWidget(
          onPressed: () => context.read<VideoPageCubit>().fetchRecipeCategory(),
        );
  }

  Widget _buildRecommendation(VideoPageState state, BuildContext context) {
    return state.recommendationRecipeList.isEmpty
        ? _buildEmptyRecommendation(context)
        : Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recommendation',
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 19),
                  ),
                  TextButton(
                    onPressed:
                        () => goto(
                          context,
                          AllRecommendationRecipePage(
                            recommendationRecipeList:
                                state.recommendationRecipeList,
                          ),
                        ),
                    child: Text(
                      'View all',
                      style: TextStyle(
                        color: Color(AppColor.primaryColor),
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 255,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: state.recommendationRecipeList.length.clamp(0, 5),
                  itemBuilder: (context, index) {
                    final item = state.recommendationRecipeList[index];
                    final isFree = item.isBuy.trim() == '0';

                    return isFree
                        ? InterstitialAdWidget(
                          onAdClosed: () {
                            _handleRecommendationTap(context, state, index);
                          },
                          child: _buildRecommendationCard(
                            context,
                            state,
                            index,
                          ),
                        )
                        : _buildRecommendationCard(context, state, index);
                  },
                ),
              ),
            ],
          ),
        );
  }

  Widget _buildEmptyRecommendation(BuildContext context) {
    return NoDataWidget(
      onPressed:
          () => context.read<VideoPageCubit>().fetchRecommendationRecipe(),
    );
  }

  Widget _buildRecommendationCard(
    BuildContext context,
    VideoPageState state,
    int index,
  ) {
    final item = state.recommendationRecipeList[index];
    final isFree = item.priceType == 'free';

    // Debug logging
    print(
      'Video Item ${item.id}: priceType=${item.priceType}, isBuy=${item.isBuy}, isFree=$isFree',
    );

    final childCard = Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: RecipeCard(recipe: state.recommendationRecipeList[index]),
    );

    return isFree
        ? InterstitialAdWidget(
          onAdClosed: () {
            print('Ad closed for recommendation item ${item.id}');
            _navigateToDestination(context, state, index);
          },
          child: childCard,
        )
        : GestureDetector(
          onTap: () {
            print('GestureDetector tapped for recommendation item ${item.id}');
            _navigateToDestination(context, state, index);
          },
          child: childCard,
        );
  }

  void _navigateToDestination(
    BuildContext context,
    VideoPageState state,
    int index,
  ) {
    final item = state.recommendationRecipeList[index];

    debugPrint('Navigating for item: ${item.toJson()}');

    if (item.type == 'playlist') {
      debugPrint('Playlist detected');
      debugPrint('isBuy value: ${item.isBuy}');

      if (item.isBuy.trim() == '0' || isSubscribed) {
        if(state.subscribed || isSubscribed) {
          debugPrint('Navigating to RecipePlaylistScreen');
          goto(context, RecipePlaylistScreen(playlistId: item.id.toString()));
        } else {
          debugPrint('Navigating to PlaylistCheckoutPage');
          goto(
            context,
            PlaylistCheckoutPage(
              id: int.parse(item.id) ?? 0,
              title: item.name ?? '',
              thumbnail: item.videoThumbnail ?? '',
              amount: item.price ?? '',
              mainPrice: item.mainPrice ?? '',
              totalVideo: item.totalVideos ?? '',
              description: item.description ?? '',
            ),
          );
        }
      } else {
        debugPrint('Navigating to RecipePlaylistScreen');
        goto(context, RecipePlaylistScreen(playlistId: item.id.toString()));
      }
    } else {
      debugPrint('Video detected');
      debugPrint('isBuy value: ${item.isBuy}');

      if (item.isBuy.trim() == '0' || isSubscribed) {
        if(state.subscribed || isSubscribed){
          debugPrint('Navigating to RecipeDetailScreen');
          goto(context, RecipeDetailScreen(videoId: item.id.toString()));
        } else {
          debugPrint('Navigating to VideoCheckoutPage');
          goto(
            context,
            VideoCheckoutPage(
              id: int.parse(item.id) ?? 0,
              title: item.videoTitle ?? '',
              thumbnail: item.videoThumbnail ?? '',
              amount: item.price ?? '',
              mainPrice: item.mainPrice ?? '',
            ),
          );
        }
      } else {
        debugPrint('Navigating to RecipeDetailScreen');
        goto(context, RecipeDetailScreen(videoId: item.id.toString()));
      }
    }
  }

  void _handleRecommendationTap(
    BuildContext context,
    VideoPageState state,
    int index,
  ) {
    final item = state.recommendationRecipeList[index];

    debugPrint('Tapped item: ${item.toJson()}');

    if (item.type == 'playlist') {
      debugPrint('Playlist detected');
      debugPrint('isBuy value: ${item.isBuy}');

      if (item.isBuy.trim() == '0' || isSubscribed) {
        if(state.subscribed || isSubscribed){
          debugPrint('Navigating to RecipePlaylistScreen');
          goto(context, RecipePlaylistScreen(playlistId: item.id.toString()));
        } else {
          debugPrint('Navigating to PlaylistCheckoutPage');
          goto(
            context,
            PlaylistCheckoutPage(
              id: int.parse(item.id) ?? 0,
              title: item.name ?? '',
              thumbnail: item.videoThumbnail ?? '',
              amount: item.price ?? '',
              mainPrice: item.mainPrice ?? '',
              totalVideo: item.totalVideos ?? '',
              description: item.description ?? '',
            ),
          );
        }
      } else {
        debugPrint('Navigating to RecipePlaylistScreen');
        goto(context, RecipePlaylistScreen(playlistId: item.id.toString()));
      }
    } else {
      debugPrint('Video detected');
      debugPrint('isBuy value: ${item.isBuy}');

      if (item.isBuy.trim() == '0' || isSubscribed) {
        if(state.subscribed || isSubscribed){
          debugPrint('Navigating to RecipeDetailScreen');
          goto(context, RecipeDetailScreen(videoId: item.id.toString()));
        } else {
          debugPrint('Navigating to VideoCheckoutPage');
          goto(
            context,
            VideoCheckoutPage(
              id: int.parse(item.id) ?? 0,
              title: item.videoTitle ?? '',
              thumbnail: item.videoThumbnail ?? '',
              amount: item.price ?? '',
              mainPrice: item.mainPrice ?? '',
            ),
          );
        }
      } else {
        debugPrint('Navigating to RecipeDetailScreen');
        goto(context, RecipeDetailScreen(videoId: item.id.toString()));
      }
    }
  }

  Widget _buildRecipePlaylist(VideoPageState state, BuildContext context) {
    return state.recipeAllPlaylistList.isEmpty
        ? _buildEmptyRecipePlaylist(context)
        : Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Playlist',
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 19),
                  ),
                  TextButton(
                    onPressed:
                        () => goto(
                          context,
                          RecipeAllPlaylistPage(
                            recipeAllPlaylistList: state.recipeAllPlaylistList,
                          ),
                        ),
                    child: Text(
                      'View all',
                      style: TextStyle(
                        color: Color(AppColor.primaryColor),
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 255,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: state.recipeAllPlaylistList.length.clamp(0, 5),
                  itemBuilder:
                      (context, index) =>
                          _buildRecipePlaylistCard(context, state, index),
                ),
              ),
            ],
          ),
        );
  }

  Widget _buildEmptyRecipePlaylist(BuildContext context) {
    return NoDataWidget(
      onPressed: () => context.read<VideoPageCubit>().fetchRecipeAllPlaylist(),
    );
  }

  Widget _buildRecipePlaylistCard(
    BuildContext context,
    VideoPageState state,
    int index,
  ) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: GestureDetector(
        onTap: () => _handleRecipePlaylistTap(context, state, index),
        child: AllPlaylistCard(recipe: state.recipeAllPlaylistList[index]),
      ),
    );
  }

  void _handleRecipePlaylistTap(
    BuildContext context,
    VideoPageState state,
    int index,
  ) {
    final item = state.recipeAllPlaylistList[index];
    if(SharedPref.isGuestUser()){
      GuestRestrictionDialog.show(context);
      return;
    }
    if (item.isBuy == '0' || isSubscribed) {
      if(state.subscribed || isSubscribed){
        goto(context, RecipePlaylistScreen(playlistId: item.id.toString()));
      } else {
        goto(
          context,
          PlaylistCheckoutPage(
            id: item.id,
            title: item.name,
            thumbnail: item.thumbnail,
            amount: item.price,
            mainPrice: item.mainPrice,
            totalVideo: item.totalVideos,
            description: item.description,
          ),
        );
      }
    } else {
      goto(context, RecipePlaylistScreen(playlistId: item.id.toString()));
    }
  }

  Widget _buildRecipeOfTheWeek(VideoPageState state, BuildContext context) {
    return state.allRecipeVideoList.isEmpty
        ? NoDataWidget(
          onPressed: () => context.read<VideoPageCubit>().fetchAllRecipeVideo(),
        )
        : Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recipe Of The Week',
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 19),
                  ),
                  TextButton(
                    onPressed:
                        () => goto(
                          context,
                          AllWeekRecipePage(
                            allRecipeVideoList: state.allRecipeVideoList,
                          ),
                        ),
                    child: Text(
                      'View all',
                      style: TextStyle(
                        color: Color(AppColor.primaryColor),
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 170,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: state.allRecipeVideoList.length,
                  itemBuilder:
                      (context, index) =>
                          _buildWeekRecipeCard(context, state, index),
                ),
              ),
            ],
          ),
        );
  }

  Widget _buildWeekRecipeCard(
    BuildContext context,
    VideoPageState state,
    int index,
  ) {
    final item = state.allRecipeVideoList[index];
    final isFree = item.priceType == 'free';


    final childCard = Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: WeekRecipeCard(recipe: state.allRecipeVideoList[index]),
    );

    return isFree
        ? InterstitialAdWidget(
          onAdClosed: () {
            print('Ad closed for week recipe item ${item.id}');
            _navigateToWeekRecipeDestination(context, state, index);
          },
          child: childCard,
        )
        : GestureDetector(
          onTap: () {
            print('GestureDetector tapped for week recipe item ${item.id}');
            _navigateToWeekRecipeDestination(context, state, index);
          },
          child: childCard,
        );
  }

  void _navigateToWeekRecipeDestination(
    BuildContext context,
    VideoPageState state,
    int index,
  ) {
    final item = state.allRecipeVideoList[index];

    debugPrint('Navigating for week recipe item: ${item.toString()}');
    debugPrint('isBuy value: ${item.isBuy}');

    if (item.isBuy == '0' || isSubscribed) {
      if(state.subscribed || isSubscribed) {
        debugPrint('Navigating to RecipeDetailScreen');
        goto(context, RecipeDetailScreen(videoId: item.id.toString()));
      } else {
        debugPrint('Navigating to VideoCheckoutPage');
        goto(
          context,
          VideoCheckoutPage(
            id: item.id,
            title: item.title,
            thumbnail: item.thumbnail,
            amount: item.price,
            mainPrice: item.mainPrice,
          ),
        );
      }
    } else {
      debugPrint('Navigating to RecipeDetailScreen');
      goto(context, RecipeDetailScreen(videoId: item.id.toString()));
    }
  }

  Widget _ageGroup(BuildContext context) {
    return BlocBuilder<AgeGroupCubit, AgeGroupState>(
      builder: (context, state) {
        if (state is AgeGroupLoading) {
          return Loader();
        } else if (state is AgeGroupLoaded) {
          return state.ageGroupList.isEmpty
              ? const SizedBox.shrink()
              : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: const Text(
                      'Age Group',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                      ),
                    ),
                  ),

                  SizedBox(
                    height: 60,
                    width: MediaQuery.of(context).size.width,
                    child: ListView.builder(
                      itemCount: state.ageGroupList.length,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        CommonMethods.devLog(
                          logName: 'All age id',
                          message: state.ageGroupList[index],
                        );
                        return Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: GestureDetector(
                            onTap:
                                () => goto(
                                  context,
                                  RecipeCategoryVideoPage(
                                    id:
                                        state.ageGroupList[index]['id']
                                            .toString(),
                                    categoryName:
                                        state.ageGroupList[index]['age_group']
                                            .toString(),
                                    ageGroup:
                                        state.ageGroupList[index]['id']
                                            .toString(),
                                  ),
                                ),
                            child: Builder(
                              builder: (context) {
                                return Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color:
                                        Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.grey[900]
                                            : Colors.grey[200],
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    vertical: 5,
                                    horizontal: 10,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    state.ageGroupList[index]['age_group']
                                        .toString(),
                                    style: TextStyle(
                                      fontSize: 16,
                                      //color: Color(AppColor.primaryColor),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
        } else if (state is AgeGroupError) {
          return Center(child: Text('Error: ${state.message}'));
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  Widget _ingredientCategory(BuildContext context) {
    return BlocProvider<IngredientCategoryCubit>(
      create: (context) => IngredientCategoryCubit(dioClient),
      child: IngredientCategory.horizontalList(
        title: 'Ingredient Categories',
        onCategoryTap: (category) {
          goto(
            context,
            IngredientPage(
              categoryId: category['id'],
              categoryName: category['name'],
            ),
          );
        },
      ),
    );
  }
}
