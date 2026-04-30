import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tinydroplets/common/navigation/navigation_service.dart';
import 'package:tinydroplets/common/widgets/loader.dart';
import 'package:tinydroplets/features/presentation/pages/video_page/ingredient_detail_page.dart';

import '../../../../common/widgets/custom_image.dart';
import 'bloc/all_ingredient_bloc/all_ingredient_cubit.dart';

class IngredientPage extends StatefulWidget {
  final int categoryId;
  final String categoryName;

  const IngredientPage({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<IngredientPage> createState() => _IngredientPageState();
}

class _IngredientPageState extends State<IngredientPage> {
  @override
  void initState() {
    super.initState();
    context.read<IngredientCubit>().fetchIngredients(widget.categoryId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.categoryName)),
      body: BlocBuilder<IngredientCubit, IngredientState>(
        builder: (context, state) {
          if (state is IngredientLoading) {
            return Loader();
          } else if (state is IngredientLoaded) {
            return _buildIngredientGrid(state.ingredients);
          } else if (state is IngredientError) {
            return const SizedBox.shrink();
          }

          // Initial state
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildIngredientGrid(List<Map<String, dynamic>> ingredients) {
    if (ingredients.isEmpty) {
      // return const SizedBox.shrink();

      return Center(child: Text('No data'));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: ingredients.length,
      itemBuilder: (context, index) {
        final ingredient = ingredients[index];
        return InkWell(
          onTap: () {
            goto(
              context,
              IngredientDetailPage(
                ingredientId: ingredient['id'],
                categoryName: ingredient['name'],
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              // border: Border.all(color: Colors.white),
              // border: Border.all(color: Theme.of(context).cardColor),
              color: Theme.of(context).cardColor ,
              borderRadius: BorderRadius.circular(10),

              
            ),
            padding: EdgeInsets.all(10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
            
                  clipBehavior: Clip.hardEdge,
                  child: CustomImage(
                    imageUrl: ingredient['imageUrl'],
                    width: 120,
                    height: 120,
                    // width: 80,
                    // height: 80,
                  ),
                ),
            
                const SizedBox(height: 8),
            
                // Ingredient name
                Text(
                  ingredient['name'] ?? '',
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
