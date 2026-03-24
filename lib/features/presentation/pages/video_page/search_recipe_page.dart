import 'dart:async';

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
import '../../../../core/services/subscription_state_manager.dart';
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

  SubscriptionStatus _subscriptionStatus = SubscriptionStatus.free;

  Map<String, List<String>> selectedFilters = {
    'category': [],
    'sub_category': [],
    'age_group': [],
    'ingredient': [],
  };

  double _minPrice = 0;
  double _maxPrice = 20000;

  // ✅ NEW: debounce + request control
  Timer? _debounce;
  int _requestId = 0;

  bool get _hasPremiumAccess =>
      SubscriptionStateManager.hasPremiumAccess(_subscriptionStatus);

  @override
  void initState() {
    super.initState();
    _resolveSubscription();
    _fetchRecipes().then((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showFilterBottomSheet(context);
      });
    });
  }

  @override
  void dispose() {
    _debounce?.cancel(); // ✅ prevent memory leak
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _resolveSubscription() async {
    final status = await SubscriptionStateManager.resolve();
    if (mounted) {
      setState(() {
        _subscriptionStatus = status;
      });
    }
  }

  // ✅ UPDATED FETCH (race condition safe)
  Future<void> _fetchRecipes() async {
    final searchText = _searchController.text.trim();

    // ✅ ignore very short search
    if (searchText.isNotEmpty && searchText.length < 2) {
      setState(() => _recipes = []);
      return;
    }

    final currentRequest = ++_requestId;

    setState(() {
      _isLoading = true;
    });

    try {
      final queryParameters = {
        if (searchText.isNotEmpty) 'search': searchText,
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

      // ❗ ignore outdated responses
      if (currentRequest != _requestId) return;

      if (response.statusCode == 200 &&
          response.data['status'] == 1 &&
          mounted) {
        setState(() {
          _recipes = List<Map<String, dynamic>>.from(response.data['data']);
        });
      }
    } catch (e) {
      debugPrint('Error fetching recipes: $e');
    } finally {
      if (mounted && currentRequest == _requestId) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ✅ NEW: debounce handler
  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 400), () {
      _fetchRecipes();
    });
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
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search Recipes',
            border: InputBorder.none,
          ),
          onChanged: _onSearchChanged, // ✅ FIXED HERE
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => showFilterBottomSheet(context),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: Loader())
          : _recipes.isEmpty
          ? NoDataWidget(onPressed: _fetchRecipes)
          : ListView.builder(
        itemCount: _recipes.length,
        itemBuilder: (context, index) {
          final recipe = _recipes[index];

          return Padding(
            padding: const EdgeInsets.all(8),
            child: GestureDetector(
              onTap: () {
                if (_hasPremiumAccess) {
                  goto(
                    context,
                    RecipeDetailScreen(
                      videoId: recipe['id'].toString(),
                    ),
                  );
                } else {
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
                }
              },
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: CustomImage(
                              imageUrl: recipe['cover_image'],
                              height: 180,
                              width: MediaQuery.of(context).size.width,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const Positioned.fill(
                            child: Icon(
                              Icons.play_circle_fill_outlined,
                              size: 42,
                              color: Colors.white,
                            ),
                          ),
                          if (!_hasPremiumAccess)
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                  BorderRadius.circular(6),
                                ),
                                child: const Icon(
                                  Icons.lock,
                                  size: 16,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        recipe['title'] ?? '',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        recipe['description'] ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => FilterBottomSheet(
        onApplyFilter: (filters, min, max) {
          setState(() {
            selectedFilters = filters;
            _minPrice = min;
            _maxPrice = max;
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
      child: _isLoading
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
          color: _selectedSection == title
              ? Colors.purple.withOpacity(0.1)
              : Colors.transparent,
          border: Border(
            left: BorderSide(
              color: _selectedSection == title
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
