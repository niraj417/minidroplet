import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tinydroplets/features/presentation/pages/my_account/saved_bloc/saved_cubit.dart';

import '../../../../core/constant/app_export.dart';
import 'model/saved_item_model.dart';

class SavedItemsScreen extends StatelessWidget {
  const SavedItemsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SavedItemsView();
  }
}

class SavedItemsView extends StatelessWidget {
  const SavedItemsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Items'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildCategorySelector(),
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySelector() {
    return BlocBuilder<SavedItemsCubit, SavedItemsState>(
      builder: (context, state) {
        return SizedBox(
          height: 50,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: ItemType.values.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final type = ItemType.values[index];
              return ChoiceChip(
                checkmarkColor: Colors.white,
                label: Text(type.name.toUpperCase()),
                selected: state.selectedType == type,
                onSelected: (_) =>
                    context.read<SavedItemsCubit>().changeTab(type),
                selectedColor: Color(AppColor.primaryColor),
                // selectedColor: Theme.of(context).primaryColor,
                labelStyle: TextStyle(
                  color:
                      state.selectedType == type ? Colors.white : Colors.black,
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildContent() {
    return BlocBuilder<SavedItemsCubit, SavedItemsState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.error != null) {
          return Center(child: Text(state.error!));
        }

        return RefreshIndicator(
          backgroundColor: Color(AppColor.primaryColor),
          color: Colors.white,

          onRefresh: () => context.read<SavedItemsCubit>().loadInitialData(),
          child: ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: state.currentItems.length,
            itemBuilder: (context, index) {
              final item = state.currentItems[index];
              return Card(
                color: Theme.of(context).cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                elevation: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 140,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                      ),
                      clipBehavior: Clip.hardEdge,
                      child: CustomImage(imageUrl: item.coverImage),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => context
                                .read<SavedItemsCubit>()
                                .removeItem(item),
                            color: Colors.red,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
