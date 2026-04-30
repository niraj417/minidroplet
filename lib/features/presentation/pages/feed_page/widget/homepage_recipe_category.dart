import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../common/widgets/custom_image.dart';
import '../../../../../common/widgets/loader.dart';
import '../../../../../core/utils/common_methods.dart';
import '../bloc/homepage_recipe_slider_bloc/homepage_recipe_slider_bloc.dart';


class HomepageRecipeCategory extends StatefulWidget {
  final Function(Map<String, dynamic>) onCategoryTap;

  const HomepageRecipeCategory({
    super.key,
    required this.onCategoryTap,
  });

  @override
  State<HomepageRecipeCategory> createState() =>
      _HomepageRecipeCategoryState();
}

class _HomepageRecipeCategoryState
    extends State<HomepageRecipeCategory> {
  @override
  void initState() {
    super.initState();
    context
        .read<HomepageRecipeSliderCubit>()
        .fetchHomepageRecipeCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          child: Text(
            'Recipe Categories',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 19,
            ),
          ),
        ),

        BlocConsumer<HomepageRecipeSliderCubit,
            HomepageRecipeSliderState>(
          listener: (context, state) {
            if (state is HomepageRecipeSliderError) {
              CommonMethods.showSnackBar(
                context,
                state.message,
              );
            }
          },
          builder: (context, state) {
            if (state is HomepageRecipeSliderLoading) {
              return const SizedBox(
                height: 100,
                child: Loader(),
              );
            }

            if (state is HomepageRecipeSliderLoaded) {
              if (state.categories.isEmpty) {
                return const SizedBox.shrink();
              }

              return SizedBox(
                height: 110,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: state.categories.length,
                  itemBuilder: (context, index) {
                    final category = state.categories[index];

                    return Padding(
                      padding: EdgeInsets.only(
                        right: index <
                            state.categories.length - 1
                            ? 8
                            : 0,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          InkWell(
                            onTap: () =>
                                widget.onCategoryTap(category),
                            borderRadius:
                            BorderRadius.circular(45),
                            child: CircleAvatar(
                              radius: 35,
                              backgroundColor:
                              Theme.of(context)
                                  .primaryColorLight,
                              child: ClipOval(
                                child: CustomImage(
                                  imageUrl:
                                  category['imageUrl'],
                                  width: 70,
                                  height: 70,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: 80,
                            child: Text(
                              category['name'],
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }
}
