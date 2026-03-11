import 'package:flutter/cupertino.dart';
import 'package:tinydroplets/common/widgets/custom_expansion_tile.dart';
import 'package:tinydroplets/common/widgets/loader.dart';
import 'package:tinydroplets/core/constant/app_export.dart';
import 'package:tinydroplets/core/services/ad_service/interstitial_ad/interstitial_ad_widget.dart';
import 'package:tinydroplets/core/services/sharing_handler.dart';
import 'package:tinydroplets/features/components/report_content/report_content.dart';
import 'package:tinydroplets/features/presentation/pages/feed_page/widget/expandable_text.dart';
import 'package:tinydroplets/features/presentation/pages/video_page/model/recipe_detail_model.dart';
import 'package:tinydroplets/features/presentation/pages/video_page/widget/ingredient_item.dart';
import 'package:tinydroplets/features/presentation/pages/video_page/widget/recipe_matrics.dart';
import 'package:tinydroplets/features/presentation/pages/video_page/widget/video_rating/video_rating_sheet.dart';

import '../../../../core/services/payment_service.dart';
import '../video_player/flick_video_player/flick_custom_video_player.dart';

class RecipeDetailScreen extends StatefulWidget {
  final String videoId;
  const RecipeDetailScreen({super.key, required this.videoId});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  final DioClient _dioClient = DioClient();
  late final Future<RecipeDetailDataModel> _future;
  bool _isPlaying = false;
  String? _isSaved;
  String? title;
  String? description;

  // final GlobalKey<FlickCustomVideoPlayerState> videoKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _future = _fetchRecipeDetail();
  }

  Future<RecipeDetailDataModel> _fetchRecipeDetail() async {
    try {
      final response = await _dioClient.sendPostRequest(
        ApiEndpoints.recipeDetail,
        {'video_id': widget.videoId},
      );

      print("Recipe Details : ${response.statusMessage} ${response.statusCode} , ${response.data}");

      if (response.data['status'] != 1) {
        throw Exception(response.data['message'] ?? 'Failed to load data');
      }

      final recipeDetail = RecipeDetailModel.fromJson(response.data);
      if (recipeDetail.data == null) {
        throw Exception('No recipe data found');
      }

      return recipeDetail.data!;
    } catch (e) {
      debugPrint('Error fetching recipe detail: $e');
      throw Exception('Failed to load recipe details: $e');
    }
  }

  Future<void> _saveVideo() async {
    try {
      final response = await _dioClient.sendPostRequest(
        ApiEndpoints.saveVideo,
        {"video_id": widget.videoId},
      );
      if (response.data['status'] == 1) {
        setState(() {
          _isSaved = '1';
        });
        if (mounted) {
          CommonMethods.showSnackBar(context, 'Video saved');
        }
      } else {
        if (mounted) {
          CommonMethods.showSnackBar(context, 'Failed to save video');
        }
        debugPrint('Failed to load data: ${response.data['message']}');
      }
    } catch (e) {
      if (mounted) {
        CommonMethods.showSnackBar(context, e.toString());
      }
      debugPrint('Error fetching ebook review: $e');
    }
  }

  // Add rating

  int _userRating = 0;
  String _userComment = '';
  bool _isLoading = false;

  // Submit rating using the existing API method
  Future<void> _submitRating(int rating, String review) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Using your existing API method
      final response = await dioClient
          .sendPostRequest(ApiEndpoints.videoRating, {
            "video_id": widget.videoId.toString(),
            "rating": rating.toString(),
            "review": review,
          });

      CommonMethods.devLog(logName: 'Rating response', message: response.data);

      if (response.data['status'] == 1) {
        setState(() {
          _userRating = rating;
          _userComment = review;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rating submitted successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to submit rating: ${response.data['message']}',
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error submitting video rating: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error submitting rating: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(
                  _isSaved == '1'
                      ? CupertinoIcons.bookmark_solid
                      : CupertinoIcons.bookmark,
                ),
                onPressed: () async {
                  if (_isSaved == '0') {
                    await _saveVideo();
                  } else {
                    if (mounted) {
                      CommonMethods.showSnackBar(context, 'Already saved');
                    }
                  }
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(CupertinoIcons.share_up),
                onPressed: () async {
                  await SharingHandler.commonShare(
                    int.parse(widget.videoId),
                    title ?? '',
                    description ?? '',
                    context,
                  );
                },
              ),
            ),
          ),
        ],
      ),
      body: FutureBuilder<RecipeDetailDataModel>(
        future: _future,
        builder: (context, snapshot) {
          CommonMethods.devLog(
            logName: 'This is the response ',
            message: snapshot.data.toString(),
          );
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Loader();
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final videoData = snapshot.data!;
          if (videoData.video == null) {
            return Center(child: Text('Video not available'));
          }

          if (videoData.video?.isSaved == '1') {
            _isSaved = "1";
          } else {
            _isSaved = "0";
          }

          final video = videoData.video;
          if (video != null) {
            title = video.title ?? '';
            title = video.description ?? '';
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [_buildBodyContent(context, videoData)],
              ),
            );
          }
          return SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildBodyContent(
    BuildContext context,
    RecipeDetailDataModel videoData,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitleRow(context, videoData),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // const SizedBox(height: 8),
              // _buildAuthorText(videoData),
              const SizedBox(height: 20),
              _buildRecipeMetrics(videoData),
              const SizedBox(height: 24),
              _buildDescriptionSection(videoData),
              const SizedBox(height: 24),
              // _buildIngredientsSection(videoData),
              const SizedBox(height: 24),

              // _videoStep(videoData),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTitleRow(BuildContext context, RecipeDetailDataModel videoData) {
    final height = MediaQuery.of(context).size.height;
    final videoUrl = CommonMethods.sanitizeVideoUrl(
      videoData.video!.uploadVideo,
    );
    debugPrint('VID URL ${videoUrl}');
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            videoUrl.isNotEmpty
                ? SizedBox(
                  height:
                      videoData.video?.videoType == "Portrait"
                          ? null
                          : height * 0.7,
                  child: FlickCustomVideoPlayer(videoUrl: videoUrl),
                )
                : Container(
                  height: 220,
                  width: double.infinity,
                  color: Theme.of(context).cardColor,
                  child:
                      videoData.video?.thumbnail != null
                          ? CustomImage(imageUrl: videoData.video?.thumbnail)
                          : SizedBox.shrink(),
                ),
          ],
        ),
        SizedBox(height: 10),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  videoData.video?.title ?? 'Title not available',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              /* GestureDetector(
                onTap: () {
                  showVideoRatingSheet(
                    context,
                    videoId: int.parse(widget.videoId),
                    initialRating:
                        videoData.video?.avgRating?.toInt() ?? _userRating,
                    initialComment: _userComment,
                    onSubmit: _submitRating,
                  );
                },
                child: Row(
                  children: List.generate(5, (index) {
                    final rating = videoData.video?.avgRating?.toInt() ?? 0;
                    return Icon(
                      index < rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                    );
                  }),
                ),
              ),*/

              /* Row(
                children: [
                  Icon(Icons.star, color: Color(AppColor.primaryColor)),
                  const SizedBox(width: 4),
                  Text(
                    videoData.video?.avgRating?.toStringAsFixed(1) ?? '',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),*/
              ReportContentWidget(
                contentId: int.parse(widget.videoId),
                contentType: 'e_video',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAuthorText(RecipeDetailDataModel videoData) {
    return Text(
      'By ${videoData.video?.adminName}' ?? '',
      style: const TextStyle(fontSize: 14),
    );
  }

  Widget _buildRecipeMetrics(RecipeDetailDataModel videoData) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          RecipeMetric(
            icon: Icons.timer,
            label: videoData.video?.timeDuration ?? '',
          ),
          const SizedBox(width: 24),

          RecipeMetric(
            icon: Icons.local_fire_department,
            label: '${videoData.video?.calories} cal' ?? '',
          ),
          // const SizedBox(width: 24),
          // RecipeMetric(
          //   icon: Icons.child_care_outlined,
          //   label: '${videoData.video?.ageGroupName} year' ?? '',
          // ),
          if (videoData.video?.categoryName != null)
            Row(
              children: [
                const SizedBox(width: 24),
                RecipeMetric(
                  icon: Icons.category_sharp,
                  label: videoData.video?.categoryName ?? '',
                ),
              ],
            ),

          const SizedBox(width: 24),
          RecipeMetric(
            icon: Icons.subject_outlined,
            label: videoData.video?.subcatName ?? '',
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection(RecipeDetailDataModel videoData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Description', style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 8),
        ExpandableTextWidget(text: videoData.video?.description ?? ''),

        const SizedBox(height: 16),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ingredients', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 16),
            if (videoData.ingrediants.isEmpty)
              const Text(
                'No ingredients listed',
                style: TextStyle(fontSize: 15),
              )
            else
              ...videoData.ingrediants.map(
                (ingredient) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: IngredientItem(
                    name: ingredient.name ?? '',
                    amount: ingredient.weight ?? '',
                    imgUrl: ingredient.image ?? '',
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(height: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Step by step', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 16),
            if (videoData.videoSteps.isEmpty)
              const Text(
                'No Video Step available',
                style: TextStyle(fontSize: 15),
              )
            else
              ...videoData.videoSteps.asMap().entries.map((entry) {
                final index = entry.key + 1; // Start from 1
                final videoStep = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 0),
                  child: RecipeStepTile(
                    color: Theme.of(context).cardColor,
                    stepNumber: index,
                    title: videoStep.title ?? '',
                    description: videoStep.description ?? '',
                  ),
                );
              }),
          ],
        ),
        const SizedBox(height: 16),

        if (videoData.video?.howToServe?.isNotEmpty == true)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'How to serve',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              ExpandableTextWidget(
                text: videoData.video?.howToServe ?? 'Not available',
              ),
            ],
          ),

        // Text(
        //   videoData.video?.description ?? '',
        //   style: TextStyle(
        //     color: Colors.grey[600],
        //     height: 1.5,
        //   ),
        // ),
      ],
    );
  }

  void showVideoRatingSheet(
    BuildContext context, {
    required int videoId,
    int initialRating = 0,
    String initialComment = '',
    required Function(int rating, String comment) onSubmit,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        return VideoRatingBottomSheet(
          initialRating: initialRating,
          initialComment: initialComment,
          onSubmit: onSubmit,
          videoId: videoId,
        );
      },
    );
  }
}
