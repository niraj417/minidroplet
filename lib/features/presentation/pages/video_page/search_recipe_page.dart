import 'package:flutter/material.dart';
import 'package:tinydroplets/common/navigation/navigation_service.dart';
import 'package:tinydroplets/common/widgets/custom_image.dart';
import 'package:tinydroplets/features/presentation/pages/video_page/all_recipe_page.dart';
import 'package:tinydroplets/features/presentation/pages/video_page/model/recipe_detail_model.dart';
import 'package:tinydroplets/features/presentation/pages/video_page/model/recipe_filter_model.dart';
import 'package:tinydroplets/features/presentation/pages/video_page/recipe_detail_page.dart';
import 'package:tinydroplets/features/presentation/pages/video_page/video_checkout_page.dart';

import '../../../../common/widgets/loader.dart';
import '../../../../common/widgets/no_data_widget.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/services/payment_service.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../core/utils/common_methods.dart';

class RecipeSearchFilterScreen extends StatefulWidget {
  const RecipeSearchFilterScreen({super.key});

  @override
  State<RecipeSearchFilterScreen> createState() =>
      _RecipeSearchFilterScreenState();
}

class _RecipeSearchFilterScreenState extends State<RecipeSearchFilterScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _recipes = [];
  bool _isLoading = false;
  Map<String, List<String>> selectedFilters = {
    'category': [],
    'sub_category': [],
    'age_group': [],
    'ingredient': [],
  };
  double _minPrice = 0;
  double _maxPrice = 20000;

  @override
  void initState() {
    super.initState();
    _fetchRecipes().then((value) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showFilterBottomSheet(context);
      });
    });
  }

  Future<void> _fetchRecipes() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final queryParameters = {
        if (_searchController.text.isNotEmpty) 'search': _searchController.text,
        if (selectedFilters['category']!.isNotEmpty)
          'category': selectedFilters['category']!.join(','),
        if (selectedFilters['sub_category']!.isNotEmpty)
          'sub_category': selectedFilters['sub_category']!.join(','),
        if (selectedFilters['age_group']!.isNotEmpty)
          'age_group': selectedFilters['age_group']!.join(','),
        if (selectedFilters['ingredient']!.isNotEmpty)
          'ingredient': selectedFilters['ingredient']!.join(','),
        'min_price': _minPrice.toString(),
        'max_price': _maxPrice.toString(),
      };

      final response = await dioClient.sendPostRequest(
        ApiEndpoints.searchRecipeVideo,
        queryParameters,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status'] == 1) {
          setState(() {
            _recipes = List<Map<String, dynamic>>.from(data['data']);
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching recipes: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextField(
          controller: _searchController,
          maxLines: 1,
          keyboardType: TextInputType.text,
          autofocus: true,
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.symmetric(
              vertical: 5.0,
              horizontal: 20.0,
            ),
            hintText: 'Search Recipes',
            hintStyle: TextStyle(color: Colors.grey),
            border: InputBorder.none,
          ),
          onChanged: (value) {
            _fetchRecipes();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => showFilterBottomSheet(context),
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: Loader())
              : _recipes.isEmpty
              ? NoDataWidget(onPressed: _fetchRecipes)
              : Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 10.0,
                  horizontal: 5,
                ),
                child: ListView.builder(
                  itemCount: _recipes.length,
                  shrinkWrap: true,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final recipe = _recipes[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: GestureDetector(
                        onTap: () {
                          if (recipe['is_buy'] == '0') {
                            goto(
                              context,
                              VideoCheckoutPage(
                                id: recipe['id'],
                                title: recipe['title'],
                                thumbnail: recipe['cover_image'],
                                amount: recipe['price'],
                                mainPrice: recipe['main_price'],
                              ),
                            );
                          } else {
                            goto(
                              context,
                              RecipeDetailScreen(
                                videoId: recipe['id'].toString(),
                              ),
                            );
                          }
                        },
                        child: Card(
                          color: Theme.of(context).cardColor,
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Thumbnail
                                Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: CustomImage(
                                        imageUrl:
                                            recipe['cover_image'].toString(),
                                        height: 180,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        fit: BoxFit.cover,
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
                                    if (recipe['is_buy'] == '0')
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
                                              recipe['is_buy'] == '0'
                                                  ? 'Paid'
                                                  : '',
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 10),

                                if (recipe['price_type'] == 'paid')
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          recipe['title'],
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Text(
                                        CommonMethods.formatRupees(
                                          recipe['price'],
                                        ),
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ],
                                  ),

                                Text(
                                  recipe['title'] ?? '',
                                  style: TextStyle(
                                    fontSize: 23,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  recipe['description'] ?? '',
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),

                                // _buildCategoryWidget('Age Group',
                                //     recipe['age_group'] ?? 'Not Available'),
                                // _buildCategoryWidget(
                                //     'Ingredients',
                                //     recipe['ingrediant_names'] ??
                                //         'Not Available'),
                                // _buildCategoryWidget(
                                //     'Subcategory',
                                //     recipe['subcat_names'] ??
                                //         'Not Available'),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
    );
  }

  Row _buildCategoryWidget(String name, String text) {
    return Row(
      children: [
        Text(
          "$name: ",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
          ),
        ),
      ],
    );
  }

  void showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => FilterBottomSheet(
            onApplyFilter: (
              Map<String, List<String>> filters,
              double minPrice,
              double maxPrice,
            ) {
              setState(() {
                selectedFilters = filters;
                _minPrice = minPrice;
                _maxPrice = maxPrice;
              });
              _fetchRecipes();
            },
            initialFilters: selectedFilters,
            initialMinPrice: _minPrice,
            initialMaxPrice: _maxPrice,
          ),
    );
  }
}

class FilterBottomSheet extends StatefulWidget {
  final Function(Map<String, List<String>>, double, double) onApplyFilter;
  final Map<String, List<String>> initialFilters;
  final double initialMinPrice;
  final double initialMaxPrice;

  const FilterBottomSheet({
    super.key,
    required this.onApplyFilter,
    required this.initialFilters,
    required this.initialMinPrice,
    required this.initialMaxPrice,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late Map<String, List<String>> selectedFilters;
  late double _currentMinPrice;
  late double _currentMaxPrice;
  String _selectedSection = 'Category';

  List<Category> categories = [];
  List<SubCategory> subCategories = [];
  List<Category> ingredients = [];
  List<AgeGroup> ageGroups = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    selectedFilters = Map.from(widget.initialFilters);
    _currentMinPrice = widget.initialMinPrice;
    _currentMaxPrice = widget.initialMaxPrice;
    _fetchFilterData();
  }

  Future<void> _fetchFilterData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await dioClient.sendGetRequest(
        ApiEndpoints.recipeFilter,
      );
      if (response.statusCode == 200) {
        final recipeFilter = RecipeFilterModel.fromJson(response.data);
        if (recipeFilter.status == 1) {
          setState(() {
            categories = recipeFilter.data?.category ?? [];
            subCategories = recipeFilter.data?.subCategory ?? [];
            ingredients = recipeFilter.data?.ingrediants ?? [];
            ageGroups = recipeFilter.data?.ageGroup ?? [];
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching filter options: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child:
          _isLoading
              ? const Loader()
              : Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: Row(
                      children: [
                        _buildLeftPanel(),
                        const VerticalDivider(thickness: 1),
                        _buildRightPanel(),
                      ],
                    ),
                  ),
                  _buildBottomButtons(),
                ],
              ),
    );
  }

  Widget _buildLeftPanel() {
    return SizedBox(
      width: 120,
      child: ListView(
        children: [
          _buildLeftPanelItem('Category'),
          _buildLeftPanelItem('Sub Category'),
          _buildLeftPanelItem('Age Group'),
          _buildLeftPanelItem('Ingredient'),
          _buildLeftPanelItem('Price Range'),
        ],
      ),
    );
  }

  Widget _buildRightPanel() {
    switch (_selectedSection) {
      case 'Category':
        return _buildFilterList(
          items: categories,
          filterKey: 'category',
          itemBuilder: (Category item) => Text(item.name),
          getId: (item) => item.id.toString(),
        );
      case 'Sub Category':
        return _buildFilterList(
          items: subCategories,
          filterKey: 'sub_category',
          itemBuilder: (SubCategory item) => Text(item.name),
          getId: (item) => item.id.toString(),
        );
      case 'Age Group':
        return _buildFilterList(
          items: ageGroups,
          filterKey: 'age_group',
          itemBuilder: (AgeGroup item) => Text(item.ageGroup),
          getId: (item) => item.id.toString(),
        );
      case 'Ingredient':
        return _buildFilterList(
          items: ingredients,
          filterKey: 'ingredient',
          itemBuilder: (Category item) => Text(item.name),
          getId: (item) => item.id.toString(),
        );
      case 'Price Range':
        return _buildPriceRangeOptions();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildFilterList<T>({
    required List<T> items,
    required String filterKey,
    required Widget Function(T item) itemBuilder,
    required String Function(T item) getId,
  }) {
    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          final id = getId(item);
          final isSelected = selectedFilters[filterKey]!.contains(id);

          return ListTile(
            title: itemBuilder(item),
            trailing: Switch(
              value: isSelected,
              onChanged: (bool value) {
                setState(() {
                  if (value) {
                    selectedFilters[filterKey]!.add(id);
                  } else {
                    selectedFilters[filterKey]!.remove(id);
                  }
                });
              },
              activeColor: Color(AppColor.primaryColor),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPriceRangeOptions() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Price Range: ₹${_currentMinPrice.round()} - ₹${_currentMaxPrice.round()}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            RangeSlider(
              values: RangeValues(_currentMinPrice, _currentMaxPrice),
              min: 0,
              max: 20000,
              divisions: 200,
              labels: RangeLabels(
                '₹${_currentMinPrice.round()}',
                '₹${_currentMaxPrice.round()}',
              ),
              onChanged: (RangeValues values) {
                setState(() {
                  _currentMinPrice = values.start;
                  _currentMaxPrice = values.end;
                });
              },
              activeColor: Color(AppColor.primaryColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Filter Options',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildLeftPanelItem(String title) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedSection = title;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color:
              _selectedSection == title
                  ? Colors.purple.withOpacity(0.1)
                  : Colors.transparent,
          border: Border(
            left: BorderSide(
              color:
                  _selectedSection == title
                      ? Color(AppColor.primaryColor)
                      : Colors.transparent,
              width: 4,
            ),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color:
                _selectedSection == title ? Color(AppColor.primaryColor) : null,
            fontWeight:
                _selectedSection == title ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                setState(() {
                  selectedFilters = {
                    'category': [],
                    'sub_category': [],
                    'age_group': [],
                    'ingredient': [],
                  };
                  _currentMinPrice = 1;
                  _currentMaxPrice = 20000;
                });
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(color: Color(AppColor.primaryColor)),
              ),
              child: Text(
                'Clear All',
                style: TextStyle(color: Color(AppColor.primaryColor)),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                widget.onApplyFilter(
                  selectedFilters,
                  _currentMinPrice,
                  _currentMaxPrice,
                );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(AppColor.primaryColor),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Apply Filter',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
