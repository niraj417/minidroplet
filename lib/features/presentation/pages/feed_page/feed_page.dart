import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:tinydroplets/common/widgets/no_data_widget.dart';
import 'package:tinydroplets/core/services/ad_service/ad_view.dart';
import 'package:tinydroplets/core/services/ad_service/banner_ad/banner_ad_widget.dart';
import 'package:tinydroplets/core/services/sharing_handler.dart';
import 'package:tinydroplets/core/utils/url_opener.dart';
import 'package:tinydroplets/features/presentation/pages/feed_page/bloc/feed_bloc.dart';
import 'package:tinydroplets/features/presentation/pages/feed_page/model/feed_post_model.dart';
import 'package:tinydroplets/features/presentation/pages/feed_page/widget/activity_grid_widget.dart';
import 'package:tinydroplets/features/presentation/pages/feed_page/widget/feed_carousel_shimmer.dart';
import 'package:tinydroplets/features/presentation/pages/feed_page/widget/feed_post_shimmer.dart';
import 'package:tinydroplets/features/presentation/pages/feed_page/widget/post_widget.dart';
import 'package:tinydroplets/core/constant/app_export.dart';
import 'package:tinydroplets/features/presentation/pages/my_account/profile_completion/profile_completion_cubit.dart';
import '../../../../common/widgets/custom_caraousel.dart';
import '../my_account/profile_bloc/profile_cubit.dart';
import '../my_account/profile_bloc/profile_state.dart';
import '../my_account/profile_completion/profile_completion_widget.dart';
import 'bloc/feed_activity_bloc/feed_activity_cubit.dart';

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
              },
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ProfileCompletionCard(),

                    if (state.isCarouselLoading)
                      const FeedCarouselShimmer()
                    else if (state.carouselData != null)
                      CustomCarousel(
                        items: state.carouselData!,
                        itemBuilder: (context, feedSliderItem, index) {
                          return GestureDetector(
                          onTap: () {
                            if (feedSliderItem.link.isNotEmpty &&
                                feedSliderItem.link != null) {
                              UrlOpener.launchURL(feedSliderItem.link);
                            } else {
                              return;
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
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
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: AlignmentDirectional.topStart,
                          child: Text(
                            'For Your Baby',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 23,
                            ),
                          ),
                        ),
                        BannerAdWidget(),
                        ActivityGridWidget(),
                      ],
                    ),
                  ),
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
                                      fontSize: 23,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  BannerAdWidget(),
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
}
