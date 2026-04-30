import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tinydroplets/common/widgets/loader.dart';
import 'package:tinydroplets/common/widgets/no_data_widget.dart';
import 'package:tinydroplets/core/utils/shared_pref_key.dart';
import 'package:tinydroplets/features/presentation/pages/video_page/recipe_detail_page.dart';
import 'package:tinydroplets/features/presentation/pages/video_page/video_checkout_page.dart';

import '../../../../core/constant/app_export.dart';
import '../../../../core/services/ad_service/interstitial_ad/interstitial_ad_widget.dart';
import 'bloc/recipe_category_video_bloc/recipe_category_video_bloc.dart';
import 'model/all_recipe_video_model.dart';
import 'model/recipe_subcategory_model.dart';

class RecipeCategoryVideoPage extends StatefulWidget {
  final String id;
  final String categoryName;
  final String? ageGroup;
  final bool isFromHome;

  const RecipeCategoryVideoPage({
    super.key,
    required this.id,
    required this.categoryName,
    this.ageGroup,
    this.isFromHome = false,
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

  late final bool _hasPremium;

  @override
  void initState() {
    super.initState();

    print("ID : ${widget.id}, Category Name : ${widget.categoryName}, ageGroup : ${widget.ageGroup}");

    _hasPremium =
        SharedPref.getBool(SharedPrefKeys.hasPremiumAccess) ?? false;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadInitialData();
    });
  }

  // =============================================================
  // INITIAL LOAD
  // =============================================================
  Future<void> _loadInitialData() async {
    try {
      bool showSubcategorySetting;

      if (widget.ageGroup != null && widget.ageGroup!.isNotEmpty) {
        showSubcategorySetting = await _fetchShowSubCategorySetting();
      } else {
        showSubcategorySetting = true;
      }

      await _fetchSubcategories();

      if (_subcategoryList.isNotEmpty) {
        _currentCategoryId = _subcategoryList.first.id;
        await _loadVideosForSubcategory(_currentCategoryId.toString());
      } else {
        await _loadVideosForMainCategory();
      }

      setState(() {
        _showSubCategory = showSubcategorySetting;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  // =============================================================
  // DATA FETCHING
  // =============================================================
  Future<void> _loadVideosForMainCategory() async {
    final videos = await _fetchRecipeVideos("0");
    setState(() {
      _displayedVideos = videos;
      _currentCategoryId = null;
    });
  }

  Future<void> _loadVideosForSubcategory(String subId) async {
    final videos = await _fetchRecipeVideos(subId);
    setState(() {
      _displayedVideos = videos;
      _currentCategoryId = int.tryParse(subId);
    });
  }

  Future<void> _fetchSubcategories() async {
    final requestData =
    widget.ageGroup != null && widget.ageGroup!.isNotEmpty
        ? {"age_group": widget.ageGroup}
        : {"category_id": widget.id};

    final response = await _dioClient.sendPostRequest(
      ApiEndpoints.subcategoryList,
      requestData,
    );

    final model = RecipeSubcategoryModel.fromJson(response.data);

    setState(() {
      _subcategoryList = model.status == 1 ? model.data : [];
    });
  }

  Future<List<AllRecipeVideoDataModel>> _fetchRecipeVideos(
      String subcatId,
      ) async {
    String url = '${ApiEndpoints.allRecipeVideos}?subcat_id=$subcatId';

    print("FetchRecipeVideos : $url");

    if (widget.ageGroup != null && widget.ageGroup!.isNotEmpty) {
      url += '&age_group=${widget.ageGroup}';
    } else {
      url += '&category_id=${widget.id}';
    }

    final response = await _dioClient.sendGetRequest(url);
    final model = AllRecipeVideoModel.fromJson(response.data);

    return model.data ?? [];
  }

  Future<bool> _fetchShowSubCategorySetting() async {

    print("API Called For Fetch!!");
    final response =
    await _dioClient.sendGetRequest(ApiEndpoints.showSubcategories);

    print("Response of SubCategories : ${response.statusCode}, ${response.statusMessage} ");

    return response.data['status'] == 1 &&
        response.data['data']['show_sub_category'] == "1";
  }

  // =============================================================
  // UI
  // =============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.categoryName)),
      body: _isLoading
          ? const Center(child: Loader())
          : Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            if(!widget.isFromHome)
              if (_showSubCategory && _subcategoryList.isNotEmpty)
                SizedBox(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _subcategoryList.length,
                    itemBuilder: (_, index) {
                      final sub = _subcategoryList[index];
                      final selected = _currentCategoryId == sub.id;

                      return Padding(
                        padding:
                        const EdgeInsets.symmetric(horizontal: 4),
                        child: ChoiceChip(
                          label: Text(sub.name ?? ''),
                          selected: selected,
                          onSelected: (_) => _loadVideosForSubcategory(
                              sub.id.toString()),
                          selectedColor:
                          Color(AppColor.primaryColor),
                          labelStyle: TextStyle(
                            color:
                            selected ? Colors.white : Colors.black,
                          ),
                        ),
                      );
                    },
                  ),
                ),
            const SizedBox(height: 10),
            Expanded(
              child: _displayedVideos.isEmpty
                  ? NoDataWidget(onPressed: _loadInitialData)
                  : GridView.builder(
                padding: const EdgeInsets.all(4),
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 2,
                  childAspectRatio: 0.9,
                ),
                itemCount: _displayedVideos.length,
                itemBuilder: (_, index) {
                  final video = _displayedVideos[index];
                  final isFree =
                      video.priceType == 'free';

                  final card = _buildVideoCard(video);

                  if (isFree && !_hasPremium) {
                    return InterstitialAdWidget(
                      onAdClosed: () =>
                          _openVideo(video),
                      child: card,
                    );
                  }

                  return GestureDetector(
                    onTap: () => _openVideo(video),
                    child: card,
                  );
                },
              ),
            ),
            SizedBox(height: 50,)
          ],
        ),
      ),
    );
  }

  // =============================================================
  // VIDEO CARD (UI UNCHANGED)
  // =============================================================
  Widget _buildVideoCard(AllRecipeVideoDataModel video) {
    final showLocked =
        !_hasPremium && video.priceType != 'free';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 110,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Theme.of(context).cardColor,
                ),
                clipBehavior: Clip.hardEdge,
                child: CustomImage(imageUrl: video.thumbnail),
              ),
              Container(
                height: 110,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.black.withOpacity(0.2),
                ),
              ),
              if (showLocked)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.lock, color: Colors.black87,size: 20,),
                  ),
                ),
              const Positioned.fill(
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
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            video.description,
            style: TextStyle(
              fontSize: 13,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // =============================================================
  // NAVIGATION
  // =============================================================
  void _openVideo(AllRecipeVideoDataModel video) {
    if (video.priceType == 'free' || _hasPremium) {
      goto(context,
          RecipeDetailScreen(videoId: video.id.toString()));
    } else {
      goto(
        context,
        VideoCheckoutPage(
          id: video.id,
          title: video.title,
          thumbnail: video.thumbnail,
          amount: video.price,
          mainPrice: video.mainPrice,
        ),
      );
    }
  }
}
