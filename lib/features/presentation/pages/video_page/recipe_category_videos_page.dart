import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tinydroplets/common/widgets/loader.dart';
import 'package:tinydroplets/common/widgets/no_data_widget.dart';
import 'package:tinydroplets/features/presentation/pages/video_page/recipe_detail_page.dart';
import '../../../../core/constant/app_export.dart';
import '../../../../core/services/ad_service/interstitial_ad/interstitial_ad_widget.dart';
import 'bloc/recipe_category_video_bloc/recipe_category_video_bloc.dart';
import 'model/all_recipe_video_model.dart';
import 'model/recipe_subcategory_model.dart';

class RecipeCategoryVideoPage extends StatefulWidget {
  final String id;
  final String categoryName;
  final String? ageGroup;
  const RecipeCategoryVideoPage({
    super.key,
    required this.id,
    required this.categoryName,
    this.ageGroup,
  });

  @override
  State<RecipeCategoryVideoPage> createState() =>
      _RecipeCategoryVideoPageState();
}

class _RecipeCategoryVideoPageState extends State<RecipeCategoryVideoPage> {
  final DioClient _dioClient = DioClient();
  List<AllRecipeVideoDataModel> _displayedVideos = [];
  List<RecipeSubcategoryDataModel> _subcategoryList = [];
  int? _currentCategoryId;
  bool _isLoading = true;
  bool _showSubCategory = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadInitialData();
    });
  }

  Future<void> _loadInitialData() async {
    try {
      // Determine if we should show subcategories based on the context
      bool showSubcategorySetting;

      if (widget.ageGroup != null && widget.ageGroup!.isNotEmpty) {
        // For age group: Check API setting
        showSubcategorySetting = await _fetchShowSubCategorySetting();
        debugPrint('Age group mode: subcategory visibility from API = $showSubcategorySetting');
      } else {
        // For category: Always show subcategories
        showSubcategorySetting = true;
        debugPrint('Category mode: subcategories always visible');
      }

      // Fetch subcategories
      await _fetchSubcategories();

      // Set the initial selected subcategory if there are subcategories
      if (_subcategoryList.isNotEmpty) {
        // Select the first subcategory by default
        setState(() {
          _currentCategoryId = _subcategoryList[0].id;
        });

        // Load videos for the first subcategory
        await _loadVideosForSubcategory(_subcategoryList[0].id.toString());
      } else {
        // If no subcategories, load videos for the main category/age group
        await _loadVideosForMainCategory();
      }

      setState(() {
        _showSubCategory = showSubcategorySetting;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error in _loadInitialData: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadVideosForMainCategory() async {
    try {
      // For main category, pass "0" as subcatId to get all videos
      final videos = await _fetchRecipeVideos("0");
      setState(() {
        _displayedVideos = videos;
        _currentCategoryId = null; // No subcategory selected
      });
    } catch (e) {
      debugPrint('Error loading videos for main category: $e');
      setState(() {
        _displayedVideos = [];
      });
    }
  }

  Future<void> _loadVideosForSubcategory(String subcategoryId) async {
    try {
      final videos = await _fetchRecipeVideos(subcategoryId);
      setState(() {
        _displayedVideos = videos;
        _currentCategoryId = int.parse(subcategoryId);
      });
    } catch (e) {
      debugPrint('Error loading videos for subcategory: $e');
      setState(() {
        _displayedVideos = [];
      });
    }
  }

  Future<void> _fetchSubcategories() async {
    debugPrint('_fetchSubcategories() -> Started');
    try {
      final requestData =
      (widget.ageGroup != null && widget.ageGroup!.isNotEmpty)
          ? {"age_group": widget.ageGroup}
          : {"category_id": widget.id};

      CommonMethods.devLog(
        logName: 'API Request',
        message: requestData.toString(),
      );

      final response = await _dioClient.sendPostRequest(
        ApiEndpoints.subcategoryList,
        requestData,
      );

      CommonMethods.devLog(logName: 'API Response', message: response.data);

      final model = RecipeSubcategoryModel.fromJson(response.data);

      if (model.status == 1) {
        debugPrint('_fetchSubcategories() -> Status 1 received');
        debugPrint(
          '_fetchSubcategories() -> Subcategory list length: ${model.data.length}',
        );

        setState(() {
          _subcategoryList = model.data;
        });

        CommonMethods.devLog(
          logName: 'Subcategories Added',
          message: _subcategoryList.toString(),
        );
      } else {
        debugPrint('_fetchSubcategories() -> Status is not 1');
        throw Exception(model.message);
      }
    } catch (e) {
      debugPrint('Error fetching subcategories: $e');
      setState(() {
        _subcategoryList = [];
      });
      throw Exception('Failed to load subcategories');
    } finally {
      debugPrint('_fetchSubcategories() -> Completed');
    }
  }

  Future<List<AllRecipeVideoDataModel>> _fetchRecipeVideos(
      String subcatId, {
        String? categoryId,
      }) async {
    try {
      String url = '${ApiEndpoints.allRecipeVideos}?subcat_id=$subcatId';

      // Add either category_id or age_group based on where we came from
      if (widget.ageGroup != null && widget.ageGroup!.isNotEmpty) {
        url += '&age_group=${widget.ageGroup}';
        CommonMethods.devLog(
          logName: 'Fetching videos',
          message: 'Age Group: ${widget.ageGroup}, Subcat ID: $subcatId',
        );
      } else {
        final catId = categoryId ?? widget.id;
        url += '&category_id=$catId';
        CommonMethods.devLog(
          logName: 'Fetching videos',
          message: 'Category ID: $catId, Subcat ID: $subcatId',
        );
      }

      final response = await _dioClient.sendGetRequest(url);

      CommonMethods.devLog(
        logName: 'Video API Response',
        message: response.data,
      );

      if (response.data['status'] == 1) {
        final data = AllRecipeVideoModel.fromJson(response.data);
        return data.data ?? [];
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load data');
      }
    } catch (e) {
      debugPrint('Error fetching videos: $e');
      throw Exception('Failed to load recipe videos');
    }
  }

  Future<bool> _fetchShowSubCategorySetting() async {
    try {
      CommonMethods.devLog(
        logName: 'Fetching subcategory visibility setting',
        message: 'Called for age group: ${widget.ageGroup}',
      );

      final response = await _dioClient.sendGetRequest(
        ApiEndpoints.showSubcategories,
      );

      CommonMethods.devLog(
        logName: 'Settings API Response',
        message: response.data,
      );

      if (response.data['status'] == 1) {
        final showSubCategory =
            response.data['data']['show_sub_category'] == "1";
        debugPrint('Show subcategory setting from API: $showSubCategory');
        return showSubCategory;
      } else {
        debugPrint(
          'Failed to get show subcategory setting, defaulting to true',
        );
        return true;
      }
    } catch (e) {
      debugPrint('Error fetching show subcategory setting: $e');
      return true; // Default to showing subcategories if there's an error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.categoryName)),
      body:
          _isLoading
              ? const Center(child: Loader())
              : Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    if (_showSubCategory && _subcategoryList.isNotEmpty)
                      SizedBox(
                        height: 50,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _subcategoryList.length,
                          itemBuilder: (context, index) {
                            final subCategory = _subcategoryList[index];
                            final isSelected =
                                _currentCategoryId == subCategory.id;

                            // return Padding(
                            //   padding: const EdgeInsets.symmetric(
                            //     horizontal: 4.0,
                            //   ),
                            //   child: ChoiceChip(
                            //     // checkmarkColor: Colors.white,
                            //     label: Text(subCategory.name ?? ''),
                            //     selected: isSelected,
                            //     onSelected: (_) async {
                            //       await _loadVideosForSubcategory(
                            //         subCategory.id.toString(),
                            //       );
                            //     },
                            //     selectedColor:
                            //         isSelected
                            //             ? Color(AppColor.primaryColor)
                            //             : Colors.black,
                            //     labelStyle: TextStyle(
                            //       // color: isSelected ? Colors.white : null,
                            //     ),
                            //   ),
                            // );
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4.0),
                              child: ChoiceChip(
                                checkmarkColor: isSelected ? Colors.white : Colors.black,
                                label: Text(subCategory.name ?? ''),
                                selected: isSelected,
                                onSelected: (_) async {
                                  await _loadVideosForSubcategory(subCategory.id.toString());
                                },
                                selectedColor: Color(AppColor.primaryColor),
                                backgroundColor: Theme.of(context).brightness == Brightness.light
                                    ? Colors.grey[100]
                                    : Colors.grey[400],
                                labelStyle: TextStyle(
                                  color: isSelected ? Colors.white : Colors.black,
                                ),
                              ),
                            );

                          },
                        ),
                      ),
                    const SizedBox(height: 10),
                    Expanded(
                      child:
                          _displayedVideos.isEmpty
                              ? NoDataWidget(
                                onPressed: () {
                                  _loadInitialData();
                                },
                              )
                              : GridView.builder(
                            padding: const EdgeInsets.all(8),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: 0.8,
                            ),
                            itemCount: _displayedVideos.length,
                            itemBuilder: (context, index) {
                              final video = _displayedVideos[index];
                              final shouldShowAd = video.priceType == 'free';

                              return shouldShowAd
                                  ? InterstitialAdWidget(
                                onAdClosed: () {
                                  print('Ad closed for video ${video.id}');
                                  goto(
                                    context,
                                    RecipeDetailScreen(
                                      videoId: video.id.toString(),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 2,
                                    horizontal: 10,
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Stack(
                                        children: [
                                          Container(
                                            height: 110,
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(12),
                                              color: Theme.of(context).cardColor,
                                            ),
                                            clipBehavior: Clip.hardEdge,
                                            child: CustomImage(
                                              imageUrl: video.thumbnail,
                                            ),
                                          ),
                                          Container(
                                            height: 110,
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(12),
                                              color: Colors.black.withOpacity(0.2),
                                            ),
                                            clipBehavior: Clip.hardEdge,
                                          ),
                                          Positioned(
                                            top: 5,
                                            right: 5,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: Text(
                                                video.priceType == 'paid' ? 'Paid' : 'Free',
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const Positioned(
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
                                        ],
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        video.title,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        video.description,
                                        style: const TextStyle(
                                          fontSize: 14,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              )
                                  : GestureDetector(
                                onTap: () {
                                  goto(
                                    context,
                                    RecipeDetailScreen(
                                      videoId: video.id.toString(),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 2,
                                    horizontal: 10,
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Stack(
                                        children: [
                                          Container(
                                            height: 110,
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(12),
                                              color: Theme.of(context).cardColor,
                                            ),
                                            clipBehavior: Clip.hardEdge,
                                            child: CustomImage(
                                              imageUrl: video.thumbnail,
                                            ),
                                          ),
                                          Container(
                                            height: 110,
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(12),
                                              color: Colors.black.withOpacity(0.2),
                                            ),
                                            clipBehavior: Clip.hardEdge,
                                          ),
                                          Positioned(
                                            top: 5,
                                            right: 5,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: Text(
                                                video.priceType == 'paid' ? 'Paid' : 'Free',
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const Positioned(
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
                                        ],
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        video.title,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        video.description,
                                        style: const TextStyle(
                                          fontSize: 14,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),

                    ),
                  ],
                ),
              ),
    );
  }
}
