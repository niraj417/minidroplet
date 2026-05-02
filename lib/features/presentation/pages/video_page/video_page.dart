import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:tinydroplets/common/widgets/no_data_widget.dart';
import 'package:tinydroplets/common/widgets/search_text_card.dart';
import 'package:tinydroplets/core/utils/shared_pref_key.dart';
import 'package:tinydroplets/features/presentation/pages/video_page/all_recipe_category_page.dart' show AllRecipeCategoryPage;
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
import '../../../../core/constant/app_vector.dart';
import '../../../../core/services/ad_service/interstitial_ad/interstitial_ad_widget.dart';
import '../../../../core/services/internet_connectivity/internet_cubit.dart';
import '../../../../core/services/internet_connectivity/internet_state.dart';
import '../../../../core/services/internet_connectivity/widget/no_internet_dialog.dart';
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
  static const int _maxCarouselItems = 5;
  static const int _maxWeekRecipeItems = 8;
  static const int _homeSectionCount = 15;

  late final VideoPageCubit _videoPageCubit;
  late final IngredientCategoryCubit _ingredientCategoryCubit;
  late final AgeGroupCubit _recipeAgeGroupCubit;
  bool _isLowEndDevice = false;

  @override
  void initState() {
    super.initState();
    _videoPageCubit = VideoPageCubit();
    _ingredientCategoryCubit = IngredientCategoryCubit(dioClient);
    _recipeAgeGroupCubit = AgeGroupCubit()..fetchAgeGroup();
    _detectLowEndDevice();
  }

  @override
  void dispose() {
    _recipeAgeGroupCubit.close();
    _videoPageCubit.close();
    _ingredientCategoryCubit.close();
    super.dispose();
  }

  /// 🔐 SINGLE SOURCE OF TRUTH
  bool _hasPremiumAccess(VideoPageState state) {
    final loginData = SharedPref.getLoginData();
    final subscription = loginData?.data?.subscription;

    final bool isSubscribed =
        SharedPref.getBool(SharedPrefKeys.hasPremiumAccess) ?? false;

    final bool hasActiveSub = subscription?.isActive == 1;
    final bool hasTrial = subscription?.isTrial == 1;

    return isSubscribed || state.subscribed || hasActiveSub || hasTrial;
  }

  bool _shouldShowAd(String priceType, bool hasPremium) {
    return priceType == 'free' && !hasPremium;
  }

  bool _canOpenDirectly(String priceType, bool hasPremium) {
    return priceType == 'free' || hasPremium;
  }

  bool _isFreePrice(String? price) {
    final normalized = (price ?? '').trim();
    return normalized.isEmpty || normalized == '0' || normalized == '0.00';
  }

  int _asInt(dynamic value) {
    if (value is int) {
      return value;
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  Future<void> _detectLowEndDevice() async {
    try {
      bool isLowEnd = false;

      if (Platform.isAndroid) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        isLowEnd =
            androidInfo.isLowRamDevice || androidInfo.physicalRamSize <= 4096;
        debugPrint(
          'Recipe hub device profile: lowRam=${androidInfo.isLowRamDevice}, '
          'physicalRamMb=${androidInfo.physicalRamSize}, '
          'availableRamMb=${androidInfo.availableRamSize}',
        );
      } else if (Platform.isIOS) {
        final iosInfo = await DeviceInfoPlugin().iosInfo;
        isLowEnd = iosInfo.physicalRamSize <= 3072;
        debugPrint(
          'Recipe hub iOS device profile: physicalRamMb=${iosInfo.physicalRamSize}, '
          'availableRamMb=${iosInfo.availableRamSize}',
        );
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _isLowEndDevice = isLowEnd;
      });
    } catch (e, stackTrace) {
      debugPrint('Low-end device detection failed: $e');
      debugPrint('$stackTrace');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(
          value: _videoPageCubit,
        ),
        BlocProvider.value(
          value: _ingredientCategoryCubit,
        ),
        BlocProvider.value(
          value: _recipeAgeGroupCubit,
        ),
      ],
      child: BlocListener<InternetCubit, InternetState>(
        listener: (context, state) async {

          // Removed aggressive auto-refresh on InternetConnected to prevent duplicate API flooding
          // which caused OOM crashes on low-end devices.

          if (state is InternetDisconnected) {
            NoInternetDialog(
              onRetry: () async {
                await context.read<VideoPageCubit>().refreshData();
              },
            );
          }

        },
      child: Scaffold(
        appBar: CustomAppBar(
          title: 'Recipe Hub',
          subtitle: 'Age-appropriate, parent-approved recipes',
        ),
        body: BlocBuilder<VideoPageCubit, VideoPageState>(
          builder: (context, state) {
                final bool hasPremium = _hasPremiumAccess(state);
                final bool isLoading = state.isLoading;

            return Stack(
              children: [
                RefreshIndicator(
                  backgroundColor: Color(AppColor.primaryColor),
                  color: Colors.white,
                  onRefresh: () async {
                    await _recipeAgeGroupCubit.fetchAgeGroup();
                    await context.read<VideoPageCubit>().refreshData();
                  },
                  child: _buildHomeList(state, context, hasPremium),
                ),
                /// ==============================
                /// LOTTIE OVERLAY
                /// ==============================
                if (isLoading)
                  Positioned.fill(
                    child: Container(
                      color: Colors.white.withOpacity(0.6),
                      child: Center(
                        child: Lottie.asset(
                          AppVector.waterDropLoading,
                          width: 120,
                          height: 120,
                          repeat: true,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    ),
    );
  }

  Widget _buildHomeList(
    VideoPageState state,
    BuildContext context,
    bool hasPremium,
  ) {
    if (_isLowEndDevice) {
      return ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        cacheExtent: 280,
        itemCount: _homeSectionCount,
        itemBuilder: (context, index) =>
            _buildHomeSection(index, state, context, hasPremium),
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: List<Widget>.generate(
        _homeSectionCount,
        (index) => _buildHomeSection(index, state, context, hasPremium),
        growable: false,
      ),
    );
  }

  Widget _buildHomeSection(
    int index,
    VideoPageState state,
    BuildContext context,
    bool hasPremium,
  ) {
    switch (index) {
      case 0:
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: SearchTextCard(
            text: 'Search, Favorite Recipe',
            onTap: () => goto(context, const RecipeSearchFilterScreen()),
          ),
        );
      case 1:
        return const SizedBox(height: 20);
      case 2:
        return _buildCarousel(state, context, hasPremium);
      case 3:
        return _ageGroup(context);
      case 4:
        return _ingredientCategory(context);
      case 5:
        return const SizedBox(height: 10);
      case 6:
        return _buildRecipePlaylist(state, context, hasPremium);
      case 7:
        return const SizedBox(height: 10);
      case 8:
        return _buildVideoCategory(state, context);
      case 9:
        return const SizedBox(height: 10);
      case 10:
        return _buildRecommendation(state, context, hasPremium);
      case 11:
        return const SizedBox(height: 10);
      case 12:
        return _buildRecipeOfTheWeek(state, context, hasPremium);
      case 13:
        return const SizedBox(height: 120);
      case 14:
        return const SizedBox.shrink();
      default:
        return const SizedBox.shrink();
    }
  }

  // ================= INGREDIENT CATEGORY =================
  Widget _ingredientCategory(BuildContext context) {
    return IngredientCategory.horizontalList(
      title: 'Starting solid',
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<AgeGroupCubit, AgeGroupState>(
      builder: (context, state) {
        if (state is AgeGroupLoading) return Loader();
        if (state is! AgeGroupLoaded || state.ageGroupList.isEmpty) {
          return const SizedBox.shrink();
        }

        return SizedBox(
          height: 60,
          child: ListView.builder(
            cacheExtent: _isLowEndDevice ? 120 : null,
            addAutomaticKeepAlives: !_isLowEndDevice,
            scrollDirection: Axis.horizontal,
            itemCount: state.ageGroupList.length,
            itemBuilder: (context, index) {
              final item = state.ageGroupList[index];
              final id = item['id']?.toString() ?? '';
              final label =
                  item['age_group']?.toString() ??
                      item['name']?.toString() ??
                      '';

              if (id.isEmpty || label.isEmpty) return const SizedBox.shrink();

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: GestureDetector(
                  onTap: () => goto(
                    context,
                    RecipeCategoryVideoPage(
                      id: id,
                      categoryName: label,
                      ageGroup: id,
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 6, horizontal: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: isDark
                          ? Colors.grey[900]
                          : Colors.grey[200],
                    ),
                    alignment: Alignment.center,
                    child: Text(label, style: const TextStyle(fontSize: 16)),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  // ================= CAROUSEL =================
  Widget _buildCarousel(
      VideoPageState state, BuildContext context, bool hasPremium) {
    if (state.recipeCarouselList.isEmpty) return const SizedBox.shrink();
    final carouselItems =
        state.recipeCarouselList.take(_maxCarouselItems).toList(growable: false);

    return CustomCarousel(
      items: carouselItems,
      itemBuilder: (context, item, _) {
        final card = Padding(
          padding: const EdgeInsets.all(8),
          child: SizedBox(
            width: 300,
            height: 200,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CustomImage(
                imageUrl: item.image,
                fit: BoxFit.contain,
                width: 300,
                height: 200,
                memCacheWidth: 720,
                memCacheHeight: 480,
              ),
            ),
          ),
        );

        final shouldShowCarouselAd = _isFreePrice(item.price) && !hasPremium;

        if (shouldShowCarouselAd) {
          return InterstitialAdWidget(
            onAdClosed: () => _openCarouselRecipe(context, item, hasPremium),
            shouldShowAd: true,
            child: card,
          );
        }

        return GestureDetector(
          onTap: () => _openCarouselRecipe(context, item, hasPremium),
          child: card,
        );
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
            'Recipe Collection',
            () {
              goto(
                context,
                AllRecipeCategoryPage(
                  allRecipeCategoryList: state.allRecipeCategoryList,
                ),
              );
            },
          ),
          SizedBox(
            height: 70,
            child: ListView.builder(
              cacheExtent: _isLowEndDevice ? 160 : null,
              addAutomaticKeepAlives: !_isLowEndDevice,
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

  // ================= HEADER =================
  Widget _sectionHeader(String title, VoidCallback? onViewAll) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style:
            const TextStyle(fontWeight: FontWeight.w500, fontSize: 19)),
        if (onViewAll != null)
          TextButton(
            onPressed: onViewAll,
            child: Text(
              'View all',
              style: TextStyle(
                color: Color(AppColor.primaryColor),
                fontSize: 14,
              ),
            ),
          ),
      ],
    );
  }

  // =============================================================
  Widget _buildRecommendation(
      VideoPageState state, BuildContext context, bool hasPremium) {
    if (state.isLoading && state.recommendationRecipeList.isEmpty) {
      return _buildRecipeSkeletonSection(title: 'Recommendation', cardHeight: 255);
    }

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
              cacheExtent: _isLowEndDevice ? 220 : null,
              addAutomaticKeepAlives: !_isLowEndDevice,
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

                if (_shouldShowAd(item.priceType,hasPremium)) {
                  return InterstitialAdWidget(
                    onAdClosed: () =>
                        _openRecommendation(context, item, hasPremium),
                    shouldShowAd: true,
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
    final canOpenDirectly = _canOpenDirectly(item.priceType ?? '', hasPremium);
    if (item.type == 'playlist') {
      canOpenDirectly
          ? goto(context,
          RecipePlaylistScreen(playlistId: item.id.toString()))
          : goto(
        context,
        PlaylistCheckoutPage(
          id: _asInt(item.id),
          title: item.name ?? '',
          thumbnail: item.videoThumbnail ?? '',
          amount: item.price ?? '',
          mainPrice: item.mainPrice ?? '',
          totalVideo: item.totalVideos ?? '',
          description: item.description ?? '',
        ),
      );
    } else {
      canOpenDirectly
          ? goto(context,
          RecipeDetailScreen(videoId: item.id.toString()))
          : goto(
        context,
        VideoCheckoutPage(
          id: _asInt(item.id),
          title: item.videoTitle ?? '',
          thumbnail: item.videoThumbnail ?? '',
          amount: item.price ?? '',
          mainPrice: item.mainPrice ?? '',
        ),
      );
    }
  }

  void _openCarouselRecipe(BuildContext context, dynamic item, bool hasPremium) {
    if (_isFreePrice(item.price) || hasPremium) {
      goto(context, RecipeDetailScreen(videoId: item.id.toString()));
      return;
    }

    goto(
      context,
      VideoCheckoutPage(
        id: _asInt(item.id),
        title: item.title ?? '',
        thumbnail: item.thumbnail ?? '',
        amount: item.price ?? '',
        mainPrice: item.mainPrice ?? '',
      ),
    );
  }

  // =============================================================
  Widget _buildRecipePlaylist(
      VideoPageState state, BuildContext context, bool hasPremium) {
    if (state.isLoading && state.recipeAllPlaylistList.isEmpty) {
      return _buildRecipeSkeletonSection(title: 'Superfood Category', cardHeight: 255);
    }

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
            'Superfood Category',
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
              cacheExtent: _isLowEndDevice ? 220 : null,
              addAutomaticKeepAlives: !_isLowEndDevice,
              scrollDirection: Axis.horizontal,
              itemCount:
              state.recipeAllPlaylistList.length.clamp(0, 5),
              itemBuilder: (context, index) {
                final item = state.recipeAllPlaylistList[index];
                final card = Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: AllPlaylistCard(recipe: item),
                );

                if (_shouldShowAd(item.priceType, hasPremium)) {
                  return InterstitialAdWidget(
                    onAdClosed: () => _openPlaylist(context, item, hasPremium),
                    shouldShowAd: true,
                    child: card,
                  );
                }

                return GestureDetector(
                  onTap: () => _openPlaylist(context, item, hasPremium),
                  child: card,
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
    if (state.isLoading && state.allRecipeVideoList.isEmpty) {
      return _buildRecipeSkeletonSection(title: 'Recipe Of The Week', cardHeight: 170);
    }

    if (state.allRecipeVideoList.isEmpty) {
      return NoDataWidget(
        onPressed: () =>
            context.read<VideoPageCubit>().fetchAllRecipeVideo(),
      );
    }
    final weekRecipes =
        state.allRecipeVideoList.take(_maxWeekRecipeItems).toList(growable: false);

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
              cacheExtent: _isLowEndDevice ? 220 : null,
              addAutomaticKeepAlives: !_isLowEndDevice,
              scrollDirection: Axis.horizontal,
              itemCount: weekRecipes.length,
              itemBuilder: (context, index) {
                final item = weekRecipes[index];
                final card = Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: WeekRecipeCard(
                    recipe: item,
                    hasPremiumAccess: hasPremium,
                  ),
                );

                if (_shouldShowAd(item.priceType,hasPremium)) {
                  return InterstitialAdWidget(
                    onAdClosed: () => _openWeekRecipe(context, item, hasPremium),
                    shouldShowAd: true,
                    child: card,
                  );
                }

                return GestureDetector(
                  onTap: () => _openWeekRecipe(context, item, hasPremium),
                  child: card,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _openPlaylist(BuildContext context, dynamic item, bool hasPremium) {
    if (_canOpenDirectly(item.priceType, hasPremium)) {
      goto(
        context,
        RecipePlaylistScreen(playlistId: item.id.toString()),
      );
      return;
    }

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

  void _openWeekRecipe(BuildContext context, dynamic item, bool hasPremium) {
    if (_canOpenDirectly(item.priceType, hasPremium)) {
      goto(
        context,
        RecipeDetailScreen(videoId: item.id.toString()),
      );
      return;
    }

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

  Widget _buildRecipeSkeletonSection({
    required String title,
    required double cardHeight,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(title, null),
          SizedBox(
            height: cardHeight,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 4,
              separatorBuilder: (_, __) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                return Container(
                  width: 155,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
