import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tinydroplets/common/widgets/custom_image.dart';
import 'package:tinydroplets/common/widgets/loader.dart';
import 'package:tinydroplets/core/constant/app_export.dart';

import '../bloc/ingredient_bloc/ingredient_cubit.dart';

class IngredientCategory extends StatefulWidget {
  final String? title;
  final Function(Map<String, dynamic>)? onCategoryTap;
  final String? imageUrl;
  final String? categoryName;
  final double? size;
  final Color? backgroundColor;
  final Color? textColor;
  final bool isSingleItem;

  // Constructor for single category item
  const IngredientCategory.item({
    super.key,
    required this.imageUrl,
    required this.categoryName,
    this.onCategoryTap,
    this.size = 80.0,
    this.backgroundColor,
    this.textColor,
  }) : isSingleItem = true,
       title = null;

  // Constructor for horizontal list
  const IngredientCategory.horizontalList({
    super.key,
    this.title = 'Categories',
    this.onCategoryTap,
  }) : isSingleItem = false,
       imageUrl = null,
       categoryName = null,
       size = 70.0,
       backgroundColor = null,
       textColor = null;

  @override
  State<IngredientCategory> createState() => _IngredientCategoryState();
}

class _IngredientCategoryState extends State<IngredientCategory> {
  @override
  void initState() {
    super.initState();
    if (!widget.isSingleItem) {
      // Only fetch categories when showing the list
      context.read<IngredientCategoryCubit>().fetchIngredientCategories();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Return single item or list based on constructor used
    return widget.isSingleItem ? _buildSingleItem() : _buildCategoryList();
  }

  // Build a single category item
  Widget _buildSingleItem() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap:
              widget.onCategoryTap != null
                  ? () => widget.onCategoryTap!({
                    'imageUrl': widget.imageUrl,
                    'name': widget.categoryName,
                  })
                  : null,
          borderRadius: BorderRadius.circular(widget.size! / 2 + 10),
          child: CircleAvatar(
            radius: widget.size! / 2,
            backgroundColor:
                widget.backgroundColor ?? Theme.of(context).primaryColorLight,
            child: ClipOval(
              child: CustomImage(
                imageUrl: widget.imageUrl!,
                width: widget.size!,
                height: widget.size!,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.categoryName!,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color:
                widget.textColor ??
                Theme.of(context).textTheme.bodyLarge?.color,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // Build the horizontal list of categories
  Widget _buildCategoryList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.title != null && widget.title!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            child: Text(
              widget.title!,
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 19),
            ),
          ),

        BlocConsumer<IngredientCategoryCubit, IngredientCategoryState>(
          listener: (context, state) {
            if (state is IngredientCategoryError) {
              CommonMethods.showSnackBar(context, state.message);
            }
          },
          builder: (context, state) {
            if (state is IngredientCategoryLoading) {
              return const SizedBox(height: 100, child: Loader());
            } else if (state is IngredientCategoryLoaded) {
              final categories = state.categories;

              if (categories.isEmpty) {
                return const SizedBox.shrink();
              }

              return SizedBox(
                height: 110,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];

                    return Padding(
                      padding: EdgeInsets.only(
                        right: index < categories.length - 1 ? 16.0 : 0,
                      ),
                      child: IngredientCategory.item(
                        imageUrl: category['imageUrl'],
                        categoryName: category['name'],
                        size: 70.0,
                        onCategoryTap: (_) {
                          if (widget.onCategoryTap != null) {
                            widget.onCategoryTap!(category);
                          }
                        },
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
