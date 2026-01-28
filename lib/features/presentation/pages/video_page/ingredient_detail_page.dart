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
  final int ingredientId;
  final String categoryName;

  const IngredientDetailPage({
    super.key,
    required this.ingredientId,
    required this.categoryName,
  });

  @override
  State<IngredientDetailPage> createState() => _IngredientDetailPageState();
}

class _IngredientDetailPageState extends State<IngredientDetailPage> {

  SubscriptionStatus _subscriptionStatus = SubscriptionStatus.free;

  bool get _hasPremiumAccess =>
      SubscriptionStateManager.hasPremiumAccess(_subscriptionStatus);


  @override
  void initState() {
    super.initState();
    context.read<IngredientDetailCubit>().fetchAll(widget.ingredientId);
    _resolveSubscription();
    // context.read<IngredientDetailCubit>().fetchAll(widget.ingredientId);
  }

  Future<void> _resolveSubscription() async {
    final status = await SubscriptionStateManager.resolve();
    if (mounted) {
      setState(() {
        _subscriptionStatus = status;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: BlocBuilder<IngredientDetailCubit, IngredientDetailState>(
          builder: (context, state) {
            if (state is IngredientDetailLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is IngredientDetailLoadedWithVideos) {
              return Column(
                children: [
                  _buildIngredientDetailView(state.ingredientData),

                  if (state.allRecipeVideoList.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Related Recipes",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 170,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: state.allRecipeVideoList.length,
                        itemBuilder:
                            (context, index) => _buildWeekRecipeCard(
                              context,
                              state.allRecipeVideoList[index],
                            ),
                      ),
                    ),
                    SizedBox(height: 50),
                  ],
                ],
              );
            } else if (state is IngredientDetailError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('Error: ${state.message}'),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed:
                          () => context.read<IngredientDetailCubit>().fetchAll(
                            widget.ingredientId,
                          ),
                      child: Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            // Initial state
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildIngredientDetailView(IngredientDetailDataModel ingredientData) {
    final descriptionTitles = [
      "Why it's Great for your Baby",
      "Nutritional Benefits For babies",
      "When to Introduce",
      "How to prepare and serve",
      "Allergies and side effects",
      "Storage and safety",
    ];

    // Map descriptions to their corresponding fields
    final descriptionMap = {
      descriptionTitles[0]: ingredientData.description,
      descriptionTitles[1]: ingredientData.description1,
      descriptionTitles[2]: ingredientData.description2,
      descriptionTitles[3]: ingredientData.description3,
      descriptionTitles[4]: ingredientData.description4,
      descriptionTitles[5]: ingredientData.description5,
    };

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Full width image with fixed height
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 250,
            child: CustomImage(
              imageUrl: ingredientData.image,
              fit: BoxFit.cover,
            ),
          ),

          // Divider below image
          const Divider(height: 1, thickness: 1),

          // Title section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  ingredientData.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ReportContentWidget(
                  contentId: ingredientData.id,
                  contentType: 'ingredient',
                ),
              ],
            ),
          ),

          const Divider(height: 1, thickness: 1),
          const SizedBox(height: 16),

          ...descriptionMap.entries.toList().asMap().entries.map(
            (entry) => _buildDescriptionSection(
              title: entry.value.key,
              description: entry.value.value,
              index: entry.key,
            ),
          ),

          // (ingredientData.ingrediantsSteps != null && ingredientData.ingrediantsSteps.isNotEmpty) ?
          //  Padding(
          //    padding: const EdgeInsets.all(16.0),
          //    child: Column(
          //      crossAxisAlignment: CrossAxisAlignment.start,
          //      children: [
          //        ...(ingredientData.ingrediantsSteps?.asMap().entries.map(
          //              (entry) => _buildIngredientStep(
          //            step: entry.value,
          //            index: entry.key + 6,
          //          ),
          //        ) ?? []),
          //      ],
          //    ),
          //  ) : SizedBox.shrink(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(ingredientData.ingrediantsSteps.length, (
                i,
              ) {
                return (ingredientData.ingrediantsSteps != null &&
                        ingredientData.ingrediantsSteps.isNotEmpty)
                    ? _buildIngredientStep(
                      step: ingredientData.ingrediantsSteps[i],
                      index: i + 6,
                    )
                    : SizedBox.shrink();
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientStep({
    required IngrediantsStep step,
    required int index,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  step.description,
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
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
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
                  description.isEmpty
                      ? 'No information available'
                      : description,
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

  Widget _buildWeekRecipeCard(
      BuildContext context,
      AllRecipeVideoDataModel item,
      ) {
    debugPrint("🏗️ Building card for: ${item.title} (ID: ${item.id})");

    final bool isUnlocked =
        item.priceType == 'free' || _hasPremiumAccess;

    debugPrint(
      "🔐 isUnlocked: $isUnlocked | priceType: ${item.priceType} | subscription: $_subscriptionStatus",
    );

    final childCard = Container(
      width: 150,
      margin: const EdgeInsets.only(right: 16.0),
      child: WeekRecipeCard(recipe: item),
    );

    // Keep ads ONLY for free content
    if (item.priceType == 'free') {
      return InterstitialAdWidget(
        onAdClosed: () {
          debugPrint('🎯 Ad closed for item ${item.id}');
          _navigateToWeekRecipeDestination(context, item);
        },
        child: childCard,
      );
    }

    return GestureDetector(
      onTap: () {
        debugPrint('👆 Tapped week recipe ${item.id}');
        _navigateToWeekRecipeDestination(context, item);
      },
      child: childCard,
    );
  }


  void _navigateToWeekRecipeDestination(
      BuildContext context,
      AllRecipeVideoDataModel item,
      ) {
    debugPrint('➡️ Navigating item ${item.id}');
    debugPrint('🔐 Subscription status: $_subscriptionStatus');

    final bool canWatch =
        item.priceType == 'free' || _hasPremiumAccess;

    if (canWatch) {
      debugPrint('▶️ Navigating to RecipeDetailScreen');
      goto(
        context,
        RecipeDetailScreen(videoId: item.id.toString()),
      );
    } else {
      debugPrint('💳 Navigating to VideoCheckoutPage');
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
  }
}
