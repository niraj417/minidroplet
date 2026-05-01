import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tinydroplets/features/components/report_content/report_content.dart';
import 'package:tinydroplets/features/presentation/pages/video_page/recipe_detail_page.dart';
import 'package:tinydroplets/features/presentation/pages/video_page/video_checkout_page.dart';
import 'package:tinydroplets/features/presentation/pages/video_page/widget/week_recipe_card.dart';

import '../../../../common/navigation/navigation_service.dart';
import '../../../../common/widgets/custom_image.dart';
import '../../../../core/services/ad_service/interstitial_ad/interstitial_ad_widget.dart';
import '../../../../core/services/subscription_state_manager.dart';
import 'bloc/ingredient_detail_bloc/ingredient_detail_cubit.dart';
import 'model/all_recipe_video_model.dart';
import 'model/ingredient_detail_model.dart';

class IngredientDetailPage extends StatefulWidget {
  const IngredientDetailPage({
    super.key,
    required this.ingredientId,
    required this.categoryName,
  });

  final int ingredientId;
  final String categoryName;

  @override
  State<IngredientDetailPage> createState() => _IngredientDetailPageState();
}

class _IngredientDetailPageState extends State<IngredientDetailPage> {
  static const double _heroImageHeight = 250;
  static const int _maxRelatedRecipesToRender = 10;

  SubscriptionStatus _subscriptionStatus = SubscriptionStatus.free;

  bool get _hasPremiumAccess =>
      SubscriptionStateManager.hasPremiumAccess(_subscriptionStatus);

  @override
  void initState() {
    super.initState();
    if (widget.ingredientId > 0) {
      context.read<IngredientDetailCubit>().fetchAll(widget.ingredientId);
    } else {
      debugPrint('IngredientDetailPage received invalid ingredientId');
    }
    _resolveSubscription();
  }

  Future<void> _resolveSubscription() async {
    final status = await SubscriptionStateManager.resolve();
    if (!mounted) {
      return;
    }
    setState(() {
      _subscriptionStatus = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.categoryName.trim().isEmpty
        ? 'Ingredient Details'
        : widget.categoryName.trim();

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: BlocBuilder<IngredientDetailCubit, IngredientDetailState>(
        builder: (context, state) {
          if (state is IngredientDetailLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is IngredientDetailError) {
            return _buildErrorState(context, state.message);
          }

          if (state is IngredientDetailLoadedWithVideos) {
            return _buildLoadedState(
              context,
              ingredientData: state.ingredientData,
              relatedRecipes: state.allRecipeVideoList,
            );
          }

          if (state is IngredientDetailLoaded) {
            return _buildLoadedState(
              context,
              ingredientData: state.ingredientData,
              relatedRecipes: const [],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildLoadedState(
    BuildContext context, {
    required IngredientDetailDataModel ingredientData,
    required List<AllRecipeVideoDataModel> relatedRecipes,
  }) {
    final descriptionSections = _buildDescriptionSections(ingredientData);
    final ingredientSteps = ingredientData.ingrediantsSteps;
    final safeRecipes = relatedRecipes
        .where((item) => item.id > 0 || item.title.trim().isNotEmpty)
        .take(_maxRelatedRecipesToRender)
        .toList(growable: false);

    debugPrint(
      'Rendering ingredient ${ingredientData.id} with ${ingredientSteps.length} steps and ${safeRecipes.length} related recipes',
    );

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: SizedBox(
            width: double.infinity,
            height: _heroImageHeight,
            child: CustomImage(
              imageUrl: ingredientData.image,
              fit: BoxFit.cover,
              height: _heroImageHeight,
              memCacheHeight: 900,
              memCacheWidth: 1440,
              placeholder: _buildImagePlaceholder(),
              errorWidget: _buildImageFallback(),
            ),
          ),
        ),
        const SliverToBoxAdapter(
          child: Divider(height: 1, thickness: 1),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    _fallbackText(
                      ingredientData.name,
                      fallback: 'Unnamed ingredient',
                    ),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                const SizedBox(width: 12),
                ReportContentWidget(
                  contentId: ingredientData.id,
                  contentType: 'ingredient',
                ),
              ],
            ),
          ),
        ),
        const SliverToBoxAdapter(
          child: Divider(height: 1, thickness: 1),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
        SliverList.separated(
          itemCount: descriptionSections.length,
          itemBuilder: (context, index) {
            final section = descriptionSections[index];
            return _buildDescriptionSection(
              title: section.$1,
              description: section.$2,
              index: index,
            );
          },
          separatorBuilder: (context, index) => const SizedBox(height: 8),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ingredientSteps.isEmpty
                ? _buildEmptyStateCard('No preparation steps available')
                : Column(
                    children: [
                      for (var i = 0; i < ingredientSteps.length; i++)
                        _buildIngredientStep(
                          step: ingredientSteps[i],
                          index: i + descriptionSections.length,
                        ),
                    ],
                  ),
          ),
        ),
        if (safeRecipes.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Text(
                'Related Recipes',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 190,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: safeRecipes.length,
                itemBuilder: (context, index) =>
                    _buildWeekRecipeCard(context, safeRecipes[index]),
              ),
            ),
          ),
        ] else
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: _buildEmptyStateCard('No related recipes available'),
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }

  List<(String, String)> _buildDescriptionSections(
    IngredientDetailDataModel ingredientData,
  ) {
    return [
      (
        "Why it's Great for your Baby",
        _fallbackText(ingredientData.description),
      ),
      (
        'Nutritional Benefits For babies',
        _fallbackText(ingredientData.description1),
      ),
      ('When to Introduce', _fallbackText(ingredientData.description2)),
      ('How to prepare and serve', _fallbackText(ingredientData.description3)),
      (
        'Allergies and side effects',
        _fallbackText(ingredientData.description4),
      ),
      ('Storage and safety', _fallbackText(ingredientData.description5)),
    ];
  }

  Widget _buildIngredientStep({
    required IngrediantsStep step,
    required int index,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepIndicator(index + 1),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _fallbackText(step.title, fallback: 'Step ${index + 1}'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  _fallbackText(step.description),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const Divider(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection({
    required String title,
    required String description,
    required int index,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepIndicator(index + 1),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const Divider(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int value) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '$value',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildWeekRecipeCard(
    BuildContext context,
    AllRecipeVideoDataModel item,
  ) {
    debugPrint('Building related recipe card for id=${item.id}');

    final childCard = SizedBox(
      width: 150,
      child: WeekRecipeCard(
        recipe: item,
        hasPremiumAccess: _hasPremiumAccess,
      ),
    );

    if (item.priceType == 'free') {
      return Padding(
        padding: const EdgeInsets.only(right: 16),
        child: InterstitialAdWidget(
          onAdClosed: () {
            debugPrint('Interstitial closed for recipeId=${item.id}');
            _navigateToWeekRecipeDestination(context, item);
          },
          child: childCard,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: GestureDetector(
        onTap: () => _navigateToWeekRecipeDestination(context, item),
        child: childCard,
      ),
    );
  }

  void _navigateToWeekRecipeDestination(
    BuildContext context,
    AllRecipeVideoDataModel item,
  ) {
    final recipeId = item.id;
    final title = _fallbackText(item.title, fallback: 'Untitled recipe');
    final thumbnail = item.thumbnail.trim();

    if (recipeId <= 0) {
      debugPrint('Blocked navigation because recipeId was invalid: $recipeId');
      _showMessage(context, 'This recipe is unavailable right now.');
      return;
    }

    final canWatch = item.priceType == 'free' || _hasPremiumAccess;
    debugPrint(
      'Navigating recipeId=$recipeId canWatch=$canWatch priceType=${item.priceType}',
    );

    if (canWatch) {
      goto(
        context,
        RecipeDetailScreen(videoId: recipeId.toString()),
      );
      return;
    }

    goto(
      context,
      VideoCheckoutPage(
        id: recipeId,
        title: title,
        thumbnail: thumbnail,
        amount: item.price.trim().isEmpty ? '0' : item.price,
        mainPrice: item.mainPrice.trim().isEmpty ? '0' : item.mainPrice,
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    final safeMessage = _fallbackText(
      message,
      fallback: 'Unable to load ingredient details.',
    );

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              safeMessage,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (widget.ingredientId > 0) {
                  context.read<IngredientDetailCubit>().fetchAll(
                        widget.ingredientId,
                      );
                }
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: Colors.grey.shade100,
      alignment: Alignment.center,
      child: const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

  Widget _buildImageFallback() {
    return Container(
      color: Colors.grey.shade200,
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_not_supported_outlined,
        color: Colors.grey,
        size: 36,
      ),
    );
  }

  Widget _buildEmptyStateCard(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }

  void _showMessage(BuildContext context, String message) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) {
      return;
    }
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  String _fallbackText(String? value, {String fallback = 'No information available'}) {
    final text = value?.trim() ?? '';
    return text.isEmpty ? fallback : text;
  }
}
