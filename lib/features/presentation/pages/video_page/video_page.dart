import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tinydroplets/common/widgets/no_data_widget.dart';
import 'package:tinydroplets/common/widgets/search_text_card.dart';
import 'package:tinydroplets/core/utils/shared_pref_key.dart';
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
import '../../../../core/services/payment_service.dart';
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

  @override
  void initState() {
    super.initState();
    context.read<AgeGroupCubit>().fetchAgeGroup();
    isSubscribed =
        SharedPref.getBool(SharedPrefKeys.hasPremiumAccess) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => VideoPageCubit()),
        BlocProvider(create: (_) => IngredientCategoryCubit(dioClient)),
      ],
      child: _VideoPageContent(isSubscribed),
    );
  }
}

class _VideoPageContent extends StatelessWidget {
  final bool isSubscribed;
  const _VideoPageContent(this.isSubscribed);

  bool _shouldShowAd(String priceType) {
    return priceType == 'free' && !isSubscribed;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Recipe'),
      body: BlocBuilder<VideoPageCubit, VideoPageState>(
        builder: (context, state) {
          final hasPremium = isSubscribed || state.subscribed;

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
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: SearchTextCard(
                      text: 'Search, Favorite Recipe',
                      onTap: () =>
                          goto(context, const RecipeSearchFilterScreen()),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildCarousel(state, context, hasPremium),
                  const SizedBox(height: 10),
                  _buildVideoCategory(state, context),
                  const SizedBox(height: 10),
                  _ageGroup(context),
                  _ingredientCategory(context),
                  const SizedBox(height: 10),
                  _buildRecommendation(state, context, hasPremium),
                  const SizedBox(height: 10),
                  _buildRecipeOfTheWeek(state, context, hasPremium),
                  const SizedBox(height: 10),
                  _buildRecipePlaylist(state, context, hasPremium),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ================= INGREDIENT CATEGORY (FIXED) =================
  Widget _ingredientCategory(BuildContext context) {
    return IngredientCategory.horizontalList(
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
    );
  }

  // ================= AGE GROUP =================
  Widget _ageGroup(BuildContext context) {
    return BlocBuilder<AgeGroupCubit, AgeGroupState>(
      builder: (context, state) {
        if (state is AgeGroupLoading) {
          return Loader();
        }

        if (state is AgeGroupLoaded && state.ageGroupList.isNotEmpty) {
          return IngredientCategory.horizontalList(
            title: 'Age Group',
            onCategoryTap: (category) {
              final id = category['id']?.toString();
              final name = category['age_group']?.toString()
                  ?? category['name']?.toString();

              if (id == null || name == null || id.isEmpty) {
                debugPrint('⚠️ Invalid age group data: $category');
                return;
              }

              goto(
                context,
                RecipeCategoryVideoPage(
                  id: id,
                  categoryName: name,
                  ageGroup: id,
                ),
              );
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  // ================= VIDEO CATEGORY =================
  Widget _buildVideoCategory(VideoPageState state, BuildContext context) {
    if (state.allRecipeCategoryList.isEmpty) {
      return NoDataWidget(
        onPressed: () =>
            context.read<VideoPageCubit>().fetchRecipeCategory(),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            'Categories',
                () => goto(
              context,
              AllRecipeCategoryPage(
                allRecipeCategoryList: state.allRecipeCategoryList,
              ),
            ),
          ),
          SizedBox(
            height: 70,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: state.allRecipeCategoryList.length.clamp(0, 5),
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.only(right: 16),
                child: SizedBox(
                  width: 150,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => goto(
                      context,
                      RecipeCategoryVideoPage(
                        id: state.allRecipeCategoryList[index].id.toString(),
                        categoryName:
                        state.allRecipeCategoryList[index].name,
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
    );
  }

  // ================= SECTION HEADER =================
  Widget _sectionHeader(String title, VoidCallback onViewAll) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style:
            const TextStyle(fontWeight: FontWeight.w500, fontSize: 19)),
        TextButton(
          onPressed: onViewAll,
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
    );
  }
  // =============================================================
  Widget _buildCarousel(
      VideoPageState state, BuildContext context, bool hasPremium) {
    if (state.recipeCarouselList.isEmpty) {
      return const SizedBox.shrink();
    }

    return CustomCarousel(
      items: state.recipeCarouselList,
      itemBuilder: (context, item, _) => GestureDetector(
        onTap: () {
          if (hasPremium) {
            goto(context,
                RecipeDetailScreen(videoId: item.id.toString()));
          } else {
            goto(
              context,
              VideoCheckoutPage(
                id: item.id,
                title: item.title ?? '',
                thumbnail: item.thumbnail ?? '',
                amount: item.price ?? '',
                mainPrice: item.mainPrice ?? '',
              ),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CustomImage(
              imageUrl: item.image,
              fit: BoxFit.contain,
              width: 300,
              height: 200,
            ),
          ),
        ),
      ),
    );
  }

  // =============================================================
  Widget _buildRecommendation(
      VideoPageState state, BuildContext context, bool hasPremium) {
    if (state.recommendationRecipeList.isEmpty) {
      return NoDataWidget(
        onPressed: () =>
            context.read<VideoPageCubit>().fetchRecommendationRecipe(),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            'Recommendation',
                () => goto(
              context,
              AllRecommendationRecipePage(
                recommendationRecipeList:
                state.recommendationRecipeList,
              ),
            ),
          ),
          SizedBox(
            height: 255,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount:
              state.recommendationRecipeList.length.clamp(0, 5),
              itemBuilder: (context, index) {
                final item =
                state.recommendationRecipeList[index];
                final card = Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: RecipeCard(recipe: item),
                );

                if (_shouldShowAd(item.priceType)) {
                  return InterstitialAdWidget(
                    onAdClosed: () =>
                        _openRecommendation(context, item, hasPremium),
                    child: card,
                  );
                }

                return GestureDetector(
                  onTap: () =>
                      _openRecommendation(context, item, hasPremium),
                  child: card,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _openRecommendation(
      BuildContext context, dynamic item, bool hasPremium) {
    if (item.type == 'playlist') {
      hasPremium
          ? goto(context,
          RecipePlaylistScreen(playlistId: item.id.toString()))
          : goto(
        context,
        PlaylistCheckoutPage(
          id: int.parse(item.id),
          title: item.name ?? '',
          thumbnail: item.videoThumbnail ?? '',
          amount: item.price ?? '',
          mainPrice: item.mainPrice ?? '',
          totalVideo: item.totalVideos ?? '',
          description: item.description ?? '',
        ),
      );
    } else {
      hasPremium
          ? goto(context,
          RecipeDetailScreen(videoId: item.id.toString()))
          : goto(
        context,
        VideoCheckoutPage(
          id: int.parse(item.id),
          title: item.videoTitle ?? '',
          thumbnail: item.videoThumbnail ?? '',
          amount: item.price ?? '',
          mainPrice: item.mainPrice ?? '',
        ),
      );
    }
  }

  // =============================================================
  Widget _buildRecipePlaylist(
      VideoPageState state, BuildContext context, bool hasPremium) {
    if (state.recipeAllPlaylistList.isEmpty) {
      return NoDataWidget(
        onPressed: () =>
            context.read<VideoPageCubit>().fetchRecipeAllPlaylist(),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            'Playlist',
                () => goto(
              context,
              RecipeAllPlaylistPage(
                recipeAllPlaylistList:
                state.recipeAllPlaylistList,
              ),
            ),
          ),
          SizedBox(
            height: 255,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount:
              state.recipeAllPlaylistList.length.clamp(0, 5),
              itemBuilder: (context, index) {
                final item = state.recipeAllPlaylistList[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: GestureDetector(
                    onTap: () => hasPremium
                        ? goto(
                      context,
                      RecipePlaylistScreen(
                          playlistId: item.id.toString()),
                    )
                        : goto(
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
                    ),
                    child: AllPlaylistCard(recipe: item),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // =============================================================
  Widget _buildRecipeOfTheWeek(
      VideoPageState state, BuildContext context, bool hasPremium) {
    if (state.allRecipeVideoList.isEmpty) {
      return NoDataWidget(
        onPressed: () =>
            context.read<VideoPageCubit>().fetchAllRecipeVideo(),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            'Recipe Of The Week',
                () => goto(
              context,
              AllWeekRecipePage(
                allRecipeVideoList: state.allRecipeVideoList,
              ),
            ),
          ),
          SizedBox(
            height: 170,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: state.allRecipeVideoList.length,
              itemBuilder: (context, index) {
                final item = state.allRecipeVideoList[index];
                final card = Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: WeekRecipeCard(recipe: item),
                );

                if (_shouldShowAd(item.priceType)) {
                  return InterstitialAdWidget(
                    onAdClosed: () => hasPremium
                        ? goto(
                      context,
                      RecipeDetailScreen(
                          videoId: item.id.toString()),
                    )
                        : goto(
                      context,
                      VideoCheckoutPage(
                        id: item.id,
                        title: item.title,
                        thumbnail: item.thumbnail,
                        amount: item.price,
                        mainPrice: item.mainPrice,
                      ),
                    ),
                    child: card,
                  );
                }

                return GestureDetector(
                  onTap: () => hasPremium
                      ? goto(
                    context,
                    RecipeDetailScreen(
                        videoId: item.id.toString()),
                  )
                      : goto(
                    context,
                    VideoCheckoutPage(
                      id: item.id,
                      title: item.title,
                      thumbnail: item.thumbnail,
                      amount: item.price,
                      mainPrice: item.mainPrice,
                    ),
                  ),
                  child: card,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}