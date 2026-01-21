import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tinydroplets/common/widgets/no_data_widget.dart';
import 'package:tinydroplets/core/constant/app_vector.dart';
import 'package:tinydroplets/core/services/ad_service/ad_view.dart';
import 'package:tinydroplets/core/services/ad_service/banner_ad/banner_ad_widget.dart';
import 'package:tinydroplets/core/services/sharing_handler.dart';
import 'package:tinydroplets/core/utils/url_opener.dart';
import 'package:tinydroplets/features/presentation/pages/feed_page/bloc/feed_bloc.dart';
import 'package:tinydroplets/features/presentation/pages/feed_page/model/feed_post_model.dart';
import 'package:tinydroplets/features/presentation/pages/feed_page/widget/activity_grid_widget.dart';
import 'package:tinydroplets/features/presentation/pages/feed_page/widget/feed_carousel_shimmer.dart';
import 'package:tinydroplets/features/presentation/pages/feed_page/widget/feed_post_shimmer.dart';
import 'package:tinydroplets/features/presentation/pages/feed_page/widget/homepage_carousel_widget.dart';
import 'package:tinydroplets/features/presentation/pages/feed_page/widget/homepage_recipe_category.dart';
import 'package:tinydroplets/features/presentation/pages/feed_page/widget/post_widget.dart';
import 'package:tinydroplets/core/constant/app_export.dart';
import 'package:tinydroplets/features/presentation/pages/my_account/profile_completion/profile_completion_cubit.dart';
import 'package:tinydroplets/features/presentation/pages/subscription/subscription_screen.dart';
import '../../../../common/widgets/custom_caraousel.dart';
import '../../../../core/services/subscription_service.dart';
import '../ebook_page/ebook_list/bloc/ebook_bloc.dart';
import '../ebook_page/ebook_list/bloc/ebook_state.dart';
import '../ebook_page/ebook_list/ebook_all_page.dart';
import '../my_account/profile_bloc/profile_cubit.dart';
import '../my_account/profile_bloc/profile_state.dart';
import '../my_account/profile_completion/profile_completion_widget.dart';
import '../video_page/model/recipe_all_playlist_model.dart';
import '../video_page/recipe_all_playlist_page.dart';
import '../video_page/recipe_category_videos_page.dart';
import '../video_page/widget/ingredient_category.dart';
import 'bloc/feed_activity_bloc/feed_activity_cubit.dart';
import 'bloc/homepage_carousel_bloc/homepage_carousel_bloc.dart';
import 'bloc/homepage_recipe_slider_bloc/homepage_recipe_slider_bloc.dart';

  class FeedPage extends StatefulWidget {
    const FeedPage({super.key});

    @override
    State<FeedPage> createState() => _FeedPageState();
  }

  class _FeedPageState extends State<FeedPage> {
    bool isLiked = false;
    final TextEditingController _comment = TextEditingController();
    TextEditingController replyController = TextEditingController();
    final DioClient dioClient = GetIt.instance<DioClient>();

    /// 🔐 Subscription state (raw)
    bool _isSubscribed = false;
    bool _isTrial = false;
    bool _trialAvailed = false;
    DateTime? _trialExpiry;

    @override
    void initState() {
      // TODO: implement initState
      super.initState();
      _loadSubscriptionState();
    }

    // =============================================================
    // SUBSCRIPTION STATE LOADER
    // =============================================================
    Future<void> _loadSubscriptionState() async {
      try {
        _isSubscribed = await SharedPref.getBool('isSubscribed') ?? false;
        _isTrial = await SharedPref.getBool('isTrial') ?? false;
        _trialAvailed = await SharedPref.getBool('trialAvailed') ?? false;

        final expiryStr = await SharedPref.getString('trialExpiry');
        _trialExpiry =
        expiryStr != null && expiryStr.isNotEmpty
            ? DateTime.tryParse(expiryStr)
            : null;

        setState(() {});
      } catch (e) {
        debugPrint('FeedPage subscription load error: $e');
      }
    }

    // =============================================================
    // DERIVED STATE (SINGLE SOURCE OF TRUTH)
    // =============================================================
    bool get hasActiveSubscription => _isSubscribed;

    bool get hasActiveTrial {
      if (!_isTrial || _trialExpiry == null) return false;
      return _trialExpiry!.isAfter(DateTime.now());
    }

    bool get shouldShowTrialBanner => !hasActiveSubscription;

    int get remainingTrialDays {
      if (_trialExpiry == null) return 0;
      final diff = _trialExpiry!.difference(DateTime.now()).inDays;
      return diff < 0 ? 0 : diff;
    }

    // =============================================================
    // TRIAL BANNER TEXT
    // =============================================================
    String getTrialBannerTitle() {
      if (!hasActiveTrial) return "Free Trial";

      if (remainingTrialDays == 0) {
        return "Free Trial has ended!";
      } else if (remainingTrialDays == 1) {
        return "Trial ends tomorrow!";
      } else {
        return "Trial ends in $remainingTrialDays days";
      }
    }

    String getTrialBannerSubtitle() {
      if (!hasActiveTrial) {
        return "Click to unlock 2000+ recipes & expert meal plans.";
      }
      return "Enjoy premium access before your trial expires.";
    }



    @override
    Widget build(BuildContext context) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: CustomAppBar(title: 'Home'),
        body: BlocBuilder<FeedBloc, FeedState>(
          builder: (context, state) {

            print('🔍 FeedBloc State Analysis:');
            print('   - State type: ${state.runtimeType}');
            print('   - Has error: ${state.error != null}');
            print('   - Error: ${state.error}');
            print('   - Is post loading: ${state.isPostLoading}');
            print('   - Post data: ${state.postData}');
            print('   - Post data length: ${state.postData?.length ?? 0}');
            print('   - Is carousel loading: ${state.isCarouselLoading}');
            print('   - Carousel data: ${state.carouselData}');
            print('   - Carousel data length: ${state.carouselData?.length ?? 0}');

            // Add this temporary debug widget to see what's happening
            if (state.postData != null && state.postData!.isNotEmpty) {
              print('✅ POST DATA FOUND: ${state.postData!.length} posts');
              print('   First post title: ${state.postData![0].title}');
              print('   First post description: ${state.postData![0].description}');
            } else {
              print('❌ NO POST DATA or empty');
            }

            if (state.error != null) {
              // return Center(child: Text(state.error!));
              return SizedBox.shrink();
              return NoDataWidget(
                onPressed: () => context.read<FeedBloc>().refreshFeed(),
              );
            }

            return RefreshIndicator(
              backgroundColor: Color(AppColor.primaryColor),
              color: Colors.white,

              onRefresh: () async {
                context.read<FeedBloc>().refreshFeed();
                context.read<FeedActivityCubit>().fetchFeedActivityData();
                context.read<ProfileCompletionCubit>().getProfileCompletion();
                //context.read<HomepageCarouselCubit>().fetchHomepageCarousels();
              },
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    //ProfileCompletionCard(),

                    if (state.isCarouselLoading)
                      const FeedCarouselShimmer()
                    else if (state.carouselData != null)
                      CustomCarousel(
                        items: state.carouselData!,
                        itemBuilder: (context, feedSliderItem, index) {
                          return GestureDetector(
                          onTap: () {
                            // if (feedSliderItem.link.isNotEmpty &&
                            //     feedSliderItem.link != null) {
                            //   UrlOpener.launchURL(feedSliderItem.link);
                            // } else {
                            //   return;
                            // }
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: CustomImage(
                                fit: BoxFit.contain,
                                imageUrl: feedSliderItem.image,
                                //width: 300,
                                //height: 200,
                              ),
                            ),
                          ),
                        );
                      },
                    )
                  else if (state.carouselData == null)
                    SizedBox.shrink(),
                  // NoDataWidget(
                  //   onPressed:
                  //       () =>
                  //           context.read<FeedBloc>().add(FeedCarouselData()),
                  // ),
                  //const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Align(
                          //   alignment: AlignmentDirectional.topStart,
                          //   child: Text(
                          //     'For Your Baby',
                          //     style: TextStyle(
                          //       fontWeight: FontWeight.bold,
                          //       fontSize: 20,
                          //     ),
                          //   ),
                          // ),
                          //BannerAdWidget(),
                          ActivityGridWidget(),
                        ],
                      ),
                    ),
                    if (state.playlistData != null && state.playlistData!.isNotEmpty)
                      premiumPlaylistBanner(
                        onTap: () {
                          goto(
                            context,
                            RecipeAllPlaylistPage(
                              recipeAllPlaylistList: state.playlistData!,
                            ),
                          );
                        }, context: context,
                      ),
                    BlocProvider(
                      create: (_) =>
                          HomepageRecipeSliderCubit(dioClient),
                      child: HomepageRecipeCategory(
                        onCategoryTap: (category) {
                          goto(
                            context,
                            RecipeCategoryVideoPage(
                              id: category['video_cat_id'].toString(),
                              categoryName: category['name'],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 10,),
                    exploreEbookBanner(
                      onTap: () {
                        final ebookState = context.read<EbookBloc>().state;

                        if (ebookState.allEbookItems.isEmpty) {
                          context.read<EbookBloc>().add(FetchAllEbookData());
                        }

                        goto(
                          context,
                          EbookAllPage(allEbookData: ebookState.allEbookItems),
                        );
                      },
                    ),

                    const SizedBox(height: 10,),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2.0),
                      child:  HomepageCarouselWidget(
                        carousels: state.homepageCarousels ?? [],
                        isLoading: state.isHomepageCarouselLoading,
                        error: state.error,
                      ),
                    ),

                    if(shouldShowTrialBanner)
                      trialStatusBanner(
                        onTap: () {
                          // 🔥 Navigate to subscription / open bottom sheet
                          //_openSubscriptionPage();
                          goto(context, SubscriptionPage());
                        },
                      ),
                    const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Column(
                        children: [
                          if (state.isPostLoading) PostWidgetShimmer(),
                          if (state.postData != null)
                            AnimatedWrapper(
                              direction: AnimationDirection.fadeIn,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Feed',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  //BannerAdWidget(),
                                  ListView.builder(
                                    itemCount: state.postData!.length,
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      final postData = state.postData![index];
                                      CommonMethods.devLog(logName: 'Comment Count', message: postData.commentCount);
                                      return Column(
                                        children: [
                                          // AdView.bannerAd(context) ?? SizedBox.shrink(),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 8.0,
                                            ),
                                            child: PostWidget(
                                              avatarUrl: postData.profile,
                                              type: postData.type,
                                              imageUrl: postData.image,
                                              companyName: postData.title,
                                              userName: postData.name,
                                              shareDate: postData.postDate,
                                              text: postData.description,

                                              //  videoUrl:  postData.type == 'video' ? postData.image : ,
                                              isLiked: postData.isLike == '1',
                                              onLike: () {
                                                context.read<FeedBloc>().add(
                                                  FeedLikeData(
                                                    postId: postData.id,
                                                  ),
                                                );
                                              },
                                              onComment: () {
                                                _showCommentSheet(
                                                  context,
                                                  postData.allComments,
                                                  postData.id,
                                                );

                                                // _showCommentSheet(context, comment, postData.id)
                                              },
                                              onShare: () async {
                                                await SharingHandler.handleFeedShare(
                                                  postData.id,
                                                  postData.title,
                                                  postData.description,
                                                  context,
                                                );
                                              },
                                              onDoubleTap: () {
                                                context.read<FeedBloc>().add(
                                                  FeedLikeData(
                                                    postId: postData.id,
                                                  ),
                                                );
                                              },
                                              likeCount:
                                                  postData.likeCount.toString(),
                                              commentCount:
                                                  postData.commentCount
                                                      .toString(),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                ),
                              ],
                            ),
                          ),
                        if (state.postData == null)
                          NoDataWidget(
                            onPressed:
                                () => context.read<FeedBloc>().add(
                                  FeedPostData(),
                                ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showCommentSheet(
    BuildContext context,
    List<Comment> comment,
    int postId,
  ) async {
    final data = SharedPref.getLoginData();
    String? profile = data?.data?.profile;
    int? replyingToCommentId;
    String? replyingToName;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => StatefulBuilder(
            builder: (context, StateSetter updateState) {
              return BlocBuilder<FeedBloc, FeedState>(
                builder: (context, state) {
                  List<Comment>? updatedComments = [];
                  if (state is FeedLoaded) {
                    final post = state.postData?.firstWhere(
                      (post) => post.id == postId,
                    );
                    updatedComments = post?.allComments;
                  } else {
                    updatedComments = comment;
                  }
                  return FractionallySizedBox(
                    heightFactor: 0.7,
                    child: Padding(
                      padding: EdgeInsets.only(
                        bottom:
                            MediaQuery.of(
                              context,
                            ).viewInsets.bottom, // Adjust for keyboard
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Comments',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.close),
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ],
                            ),
                          ),
                          Divider(),
                          comment.isEmpty
                              ? Expanded(
                                child: Center(
                                  child: Icon(
                                    CupertinoIcons.chat_bubble_2,
                                    size: 150,
                                    color: Colors.grey.shade200,
                                  ),
                                ),
                              )
                              : Expanded(
                                child: ListView.builder(
                                  itemCount: updatedComments?.length,
                                  itemBuilder: (context, index) {
                                    return Column(
                                      children: [
                                        ListTile(
                                          leading: Container(
                                            padding: EdgeInsets.all(1.0),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: Color(
                                                  AppColor.primaryColor,
                                                ),
                                                width: 1,
                                              ),
                                            ),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                              ),
                                              height: 30,
                                              width: 30,
                                              clipBehavior: Clip.hardEdge,
                                              child: CustomImage(
                                                imageUrl:
                                                    updatedComments![index]
                                                        .profile,
                                                fit: BoxFit.fill,
                                              ),
                                            ),
                                          ),
                                          title: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                padding: EdgeInsets.all(5),
                                                decoration: BoxDecoration(
                                                  // color: Colors.grey.shade100,
                                                  color:
                                                      Theme.of(
                                                        context,
                                                      ).cardColor,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        9.0,
                                                      ),
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      updatedComments![index]
                                                          .name,
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Expanded(
                                                          child: Text(
                                                            updatedComments[index]
                                                                .comment,
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets.all(
                                                                4.0,
                                                              ),
                                                          child: InkWell(
                                                            onTap: () {
                                                              updateState(() {
                                                                replyingToCommentId =
                                                                    updatedComments?[index]
                                                                        .id;
                                                                replyingToName =
                                                                    updatedComments?[index]
                                                                        .name;
                                                                _comment
                                                                    .clear();
                                                              });
                                                            },
                                                            child: Text(
                                                              'Reply',
                                                              style: TextStyle(
                                                                fontStyle:
                                                                    FontStyle
                                                                        .italic,
                                                                fontSize: 13,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    // Adding a list of replies
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.all(
                                                  2.0,
                                                ),
                                                child: Text(
                                                  updatedComments[index]
                                                      .commentDate,
                                                  style: TextStyle(
                                                    fontStyle: FontStyle.italic,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (updatedComments[index]
                                            .replyComments
                                            .isNotEmpty)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              left: 18.0,
                                            ),
                                            child: ListView.builder(
                                              shrinkWrap:
                                                  true, // Important to avoid infinite height
                                              physics:
                                                  NeverScrollableScrollPhysics(),
                                              itemCount:
                                                  updatedComments[index]
                                                      .replyComments
                                                      .length,
                                              itemBuilder: (
                                                context,
                                                replyIndex,
                                              ) {
                                                return ListTile(
                                                  leading: Container(
                                                    padding: EdgeInsets.all(
                                                      1.0,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      border: Border.all(
                                                        color: Color(
                                                          AppColor.primaryColor,
                                                        ),
                                                        width: 1,
                                                      ),
                                                    ),
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                      ),
                                                      height: 30,
                                                      width: 30,
                                                      clipBehavior:
                                                          Clip.hardEdge,
                                                      child: CustomImage(
                                                        imageUrl:
                                                            updatedComments![index]
                                                                .replyComments[replyIndex]
                                                                .profile,
                                                        fit: BoxFit.fill,
                                                      ),
                                                    ),
                                                  ),
                                                  title: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Container(
                                                        padding: EdgeInsets.all(
                                                          5,
                                                        ),
                                                        decoration: BoxDecoration(
                                                          // color: Colors.grey.shade100,
                                                          color:
                                                              Theme.of(
                                                                context,
                                                              ).cardColor,
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                9.0,
                                                              ),
                                                        ),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              updatedComments[index]
                                                                  .replyComments[replyIndex]
                                                                  .name,
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Text(
                                                                  updatedComments[index]
                                                                      .replyComments[replyIndex]
                                                                      .comment,
                                                                ),
                                                              ],
                                                            ),
                                                            // Adding a list of replies
                                                          ],
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets.all(
                                                              2.0,
                                                            ),
                                                        child: Text(
                                                          updatedComments[index]
                                                              .commentDate,
                                                          style: TextStyle(
                                                            fontStyle:
                                                                FontStyle
                                                                    .italic,
                                                            fontSize: 13,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                          Divider(),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 8.0,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(1.0),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Color(AppColor.primaryColor),
                                      width: 1,
                                    ),
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                    ),
                                    height: 30,
                                    width: 30,
                                    clipBehavior: Clip.hardEdge,
                                    child: CustomImage(
                                      imageUrl: profile,
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: TextField(
                                    controller: _comment,
                                    decoration: InputDecoration(
                                      hintText:
                                          replyingToCommentId != null
                                              ? 'Write a reply...'
                                              : 'Write a comment...',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        borderSide: BorderSide.none,
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey[200],
                                    ),
                                    onChanged: (value) => updateState(() {}),
                                  ),
                                ),
                                SizedBox(width: 10),
                                IconButton(
                                  icon: Icon(
                                    Icons.send,
                                    color:
                                        _comment.text.isNotEmpty
                                            ? Color(AppColor.primaryColor)
                                            : null,
                                  ),
                                  onPressed:
                                      _comment.text.isEmpty
                                          ? null
                                          : () {
                                            if (replyingToCommentId != null) {
                                              // Handle reply
                                              final newReply = Comment(
                                                id:
                                                    DateTime.now()
                                                        .millisecondsSinceEpoch,
                                                postId: postId,
                                                userId: data?.data?.id ?? 0,
                                                replyId: replyingToCommentId!,
                                                comment: _comment.text,
                                                createdAt: DateTime.now(),
                                                updatedAt: DateTime.now(),
                                                name: data?.data?.name ?? "You",
                                                profile: profile ?? "",
                                                commentDate: "Just now",
                                                replyComments: [],
                                              );

                                              context.read<FeedBloc>().add(
                                                FeedPostReplyCommentData(
                                                  newReply,
                                                  commentId:
                                                      replyingToCommentId!,
                                                  comment: _comment.text,
                                                ),
                                                /* FeedPostReplyCommentData(
                                      commentId: replyingToCommentId!,
                                      comment: _comment.text,
                                      localComment: newReply,
                                    ),*/
                                              );

                                              updateState(() {
                                                replyingToCommentId = null;
                                                replyingToName = null;
                                              });
                                            } else {
                                              // Handle main comment
                                              final newComment = Comment(
                                                id:
                                                    DateTime.now()
                                                        .millisecondsSinceEpoch,
                                                postId: postId,
                                                userId: data?.data?.id ?? 0,
                                                replyId: 0,
                                                comment: _comment.text,
                                                createdAt: DateTime.now(),
                                                updatedAt: DateTime.now(),
                                                name: data?.data?.name ?? "You",
                                                profile: profile ?? "",
                                                commentDate: "Just now",
                                                replyComments: [],
                                              );

                                              context.read<FeedBloc>().add(
                                                FeedPostCommentData(
                                                  postId: postId,
                                                  comment: _comment.text,
                                                  newComment,
                                                ),
                                              );
                                            }

                                            _comment.clear();
                                          },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
    );
  }

    Widget trialStatusBanner({
      required VoidCallback onTap,
    }) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFFCEEEE),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                height: 42,
                width: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFE6E7EB),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.workspace_premium,
                  color: Color(0xFF6C6C6C),
                  size: 22,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      getTrialBannerTitle(),
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      getTrialBannerSubtitle(),
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: const Color(0xFF4A4A4A),
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                height: 32,
                width: 32,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFD54F),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      );
    }

    Widget exploreEbookBanner({
      required VoidCallback onTap,
    }) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFB3E5FC),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                height: 42,
                width: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFE6E7EB),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.chrome_reader_mode_sharp,
                  color: Color(0xFF6C6C6C),
                  size: 22,
                ),
              ),

              const SizedBox(width: 12),

              Text(
                "Explore Our Ebook Collection",
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 8,),

              Container(
                height: 32,
                width: 32,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFD54F),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      );
    }
    Widget premiumPlaylistBanner({
      required BuildContext context,
      required VoidCallback onTap,
    }) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        height: 170,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          //color: const Color(0xFFE6F59D), // fallback color
        ),
        clipBehavior: Clip.antiAlias, // ✅ ensures rounded corners
        child: Stack(
          children: [
            /// 🔹 Background Image (left aligned, no cropping)
            Positioned.fill(
              child: Image.asset(
                AppVector.homepageBanner, // your asset
                fit: BoxFit.cover, // ✅ no height/width crop
                alignment: Alignment.centerLeft,
              ),
            ),

            /// 🔹 Text + Button Overlay
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(150, 20, 10, 0),
                  child: Text(
                    'Grow Healthy, Grow Smart\nwith Premium Super Foods',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                Padding(
                  padding: const EdgeInsets.fromLTRB(161, 0, 6,0),
                  child: Text(
                    'Nourish your little ones with our premium super food recipes designed for optimal growth and health.',
                    style: GoogleFonts.poppins(
                      fontSize: 9,
                      color: Colors.black87,
                      height: 1.3,
                    ),
                  ),
                ),

                const SizedBox(height: 4),

                /// 🔘 Button
                Padding(
                  padding: const EdgeInsets.fromLTRB(220, 0, 10, 0),
                  child: InkWell(
                    onTap: onTap,
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF7A7F23),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Discover',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }
  }