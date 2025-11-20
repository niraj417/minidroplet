import 'package:tinydroplets/common/widgets/loader.dart';
import 'package:tinydroplets/common/widgets/no_data_widget.dart';
import 'package:tinydroplets/core/services/payment_service.dart';

import '../../../../../core/constant/app_export.dart';
import '../buy_ebook/ebook_buy_page.dart';
import '../purchased_ebook/purchased_ebook_detail_page.dart';
import 'bloc/ebook_filter_cubit.dart';
import 'category_widget.dart';
import 'package:flutter/material.dart';


class EbookSearchFilterScreen extends StatefulWidget {
  const EbookSearchFilterScreen({super.key});

  @override
  State<EbookSearchFilterScreen> createState() => _EbookSearchFilterScreenState();
}

class _EbookSearchFilterScreenState extends State<EbookSearchFilterScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _books = [];
  bool _isLoading = false;
  Map<String, List<String>> selectedFilters = {
    'category': [],
    'age_group': [],
  };
  double _minPrice = 0;
  double _maxPrice = 20000;

  @override
  void initState() {
    super.initState();
    _fetchBooks().then(
      (value) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showFilterBottomSheet(context);
        });
      },
    );
  }

  Future<void> _fetchBooks() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final queryParameters = {
        if (_searchController.text.isNotEmpty) 'search': _searchController.text,
        if (selectedFilters['category']!.isNotEmpty)
          'category': selectedFilters['category']!.join(','),
        if (selectedFilters['age_group']!.isNotEmpty)
          'age_group': selectedFilters['age_group']!.join(','),
        'min_price': _minPrice.toString(),
        'max_price': _maxPrice.toString(),
      };

      final response = await dioClient.sendPostRequest(
          ApiEndpoints.searchEbook, queryParameters);

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status'] == 1) {
          setState(() {
            _books = List<Map<String, dynamic>>.from(data['data']);
          });
        }
      }
    } catch (e) {
      print('Error fetching books: $e');
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
            contentPadding:
                EdgeInsets.symmetric(vertical: 5.0, horizontal: 20.0),
            hintText: 'Search Ebooks',
            hintStyle: TextStyle(color: Colors.grey),
            border: InputBorder.none,
          ),
          onChanged: (value) {
            _fetchBooks();
          },
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
          : _books.isEmpty
              ? NoDataWidget(
                  onPressed: _fetchBooks,
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 18),
                  child: ListView.builder(
                    itemCount: _books.length,
                    shrinkWrap: true,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final book = _books[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: InkWell(
                          onTap: () {
                            if (book['is_buy'] == '1') {
                              goto(
                                  context,
                                  PurchasedEbookBuyDetailPage(
                                      ebookId: book['id']));
                            } else {
                              goto(context,
                                  EbookBuyDetailPage(ebookId: book['id']));
                            }
                          },
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomImage(
                                imageUrl: book['cover_image'],
                                width: 100,
                                height: 150,
                                fit: BoxFit.cover,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      book['title'] ?? 'Unknown Title',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                        "Author: ${book['admin_name'] ?? 'Unknown'}"),
                                    if (book['category_name'] != null)
                                      Column(
                                        children: [
                                          const SizedBox(height: 2),
                                          Text(
                                              "Category: ${book['category_name'] ?? 'Unknown'}"),
                                          const SizedBox(height: 2),
                                        ],
                                      ),
                                    Text("Price: ${book['price'] ?? 'Free'}"),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  void showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => FilterBottomSheet(
        onApplyFilter: (Map<String, List<String>> filters, double minPrice,
            double maxPrice) {
          setState(() {
            selectedFilters = filters;
            _minPrice = minPrice;
            _maxPrice = maxPrice;
          });
          _fetchBooks();
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

  List<Map<String, dynamic>> categories = [];
  List<Map<String, dynamic>> ageGroups = [];
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
      final response =
          await dioClient.sendGetRequest(ApiEndpoints.ebookCategory);
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status'] == 1) {
          setState(() {
            categories =
                List<Map<String, dynamic>>.from(data['data']['category']);
            ageGroups =
                List<Map<String, dynamic>>.from(data['data']['age_group']);
          });
        }
      }
    } catch (e) {
      if (mounted) {
        CommonMethods.showSnackBar(context, e.toString());
      }
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Filter Options',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildLeftPanel() {
    return SizedBox(
      width: 120,
      child: Column(
        children: [
          _buildLeftPanelItem('Category'),
          _buildLeftPanelItem('Age Group'),
          _buildLeftPanelItem('Price Range'),
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

  Widget _buildRightPanel() {
    switch (_selectedSection) {
      case 'Category':
        return _buildCategoryOptions();
      case 'Age Group':
        return _buildAgeGroupOptions();
      case 'Price Range':
        return _buildPriceRangeOptions();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildCategoryOptions() {
    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected =
              selectedFilters['category']!.contains(category['id'].toString());

          return ListTile(
            title: Text(category['name']),
            trailing: Switch(
                value: isSelected,
                onChanged: (bool value) {
                  setState(() {
                    if (value) {
                      selectedFilters['category']!
                          .add(category['id'].toString());
                    } else {
                      selectedFilters['category']!
                          .remove(category['id'].toString());
                    }
                  });
                },
                activeColor: Color(AppColor.primaryColor)),
          );
        },
      ),
    );
  }

  Widget _buildAgeGroupOptions() {
    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: ageGroups.length,
        itemBuilder: (context, index) {
          final ageGroup = ageGroups[index];
          final isSelected =
              selectedFilters['age_group']!.contains(ageGroup['id'].toString());

          return ListTile(
            title: Text(ageGroup['age_group']),
            trailing: Switch(
                value: isSelected,
                onChanged: (bool value) {
                  setState(() {
                    if (value) {
                      selectedFilters['age_group']!
                          .add(ageGroup['id'].toString());
                    } else {
                      selectedFilters['age_group']!
                          .remove(ageGroup['id'].toString());
                    }
                  });
                },
                activeColor: Color(AppColor.primaryColor)),
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
                labels: RangeLabels('\$${_currentMinPrice.round()}',
                    '\$${_currentMaxPrice.round()}'),
                onChanged: (RangeValues values) {
                  setState(() {
                    _currentMinPrice = values.start;
                    _currentMaxPrice = values.end;
                  });
                },
                activeColor: Color(AppColor.primaryColor)),
          ],
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
                    'age_group': [],
                  };
                  _currentMinPrice = 1;
                  _currentMaxPrice = 20000;
                });
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side:  BorderSide(color: Color(AppColor.primaryColor)),
              ),
              child:  Text(
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
