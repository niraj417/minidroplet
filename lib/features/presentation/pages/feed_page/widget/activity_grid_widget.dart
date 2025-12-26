import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tinydroplets/common/widgets/loader.dart';
import 'package:tinydroplets/features/presentation/pages/feed_page/feed_activity_page.dart';
import 'package:tinydroplets/features/presentation/pages/feed_page/feed_affiliate_page.dart';
import 'package:tinydroplets/features/presentation/pages/video_page/recipe_category_videos_page.dart';
import 'package:tinydroplets/features/presentation/pages/video_page/recipe_playlist_screen.dart';
import '../../../../../core/constant/app_export.dart';
import '../../ebook_page/buy_ebook/ebook_buy_page.dart';
import '../../ebook_page/purchased_ebook/purchased_ebook_detail_page.dart';
import '../bloc/feed_activity_bloc/feed_activity_cubit.dart';
import '../bloc/feed_activity_bloc/feed_activity_state.dart';

class ActivityGridWidget extends StatefulWidget {
  final double? height;
  final double? width;

  const ActivityGridWidget({super.key, this.height, this.width});

  @override
  State<ActivityGridWidget> createState() => _ActivityGridWidgetState();
}

class _ActivityGridWidgetState extends State<ActivityGridWidget> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FeedActivityCubit>().fetchFeedActivityData();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FeedActivityCubit, FeedActivityState>(
      builder: (context, state) {
        if (state is FeedActivityLoading) {
          return const Loader();
        } else if (state is FeedActivityLoaded) {
          final int itemCount = state.feedActivityDataList.length;
          final int crossAxisCount = 4;
          final int rows = (itemCount / crossAxisCount).ceil();

          final double calculatedHeight = (rows * 100) + 20;

          return Container(
            height: calculatedHeight,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: false,
              itemCount: state.feedActivityDataList.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 12.0,
                crossAxisSpacing: 8.0,
                mainAxisExtent: 100,
              ),
              itemBuilder: (context, index) {
                final data = state.feedActivityDataList[index];
                return GestureDetector(
                  onTap: () {
                    switch (index) {
                      case 0:
                        goto(
                          context,
                          FeedActivityPage(
                            id: data.id ?? 0,
                            name: data.name ?? '',
                            image: data.image,
                            fromLegacy: true,
                            PageName: "milestone",
                          ),
                        );
                        break;
                      case 1:
                        goto(
                          context,
                          FeedActivityPage(
                            id: data.id ?? 0,
                            name: data.name ?? '',
                            image: data.image,
                            fromLegacy: true,
                            PageName: "Activity",
                          ),
                        );
                        break;
                      case 2:
                        goto(
                          context,
                          FeedAffiliatePage(
                            id: data.id ?? 0,
                            name: data.name ?? '',
                            image: data.image,

                          ),
                        );
                        break;
                      case 3:
                        if (data.isBuy == '1') {
                          if (data.dataId != null ||
                              data.dataId.toString().isNotEmpty) {
                            CommonMethods.devLog(logName: 'Ebook id in activity', message: data.id);
                            goto(
                              context,
                              PurchasedEbookBuyDetailPage(
                                ebookId: int.parse(data.dataId ?? ''),
                              ),
                            );
                          }
                        } else {
                          if (data.dataId != null ||
                              data.dataId.toString().isNotEmpty) {
                            goto(
                              context,
                              EbookBuyDetailPage(ebookId: int.parse(data.dataId ?? '')),
                            );
                          }
                        }

                        break;
                      case 4:
                        if (data.dataId != null) {
                          goto(
                            context,
                            RecipeCategoryVideoPage(
                              id: data.dataId ?? '',
                              categoryName: 'Videos',
                            ),
                          );
                        }
                        break;
                      case 5:
                        if (data.dataId != null) {
                          goto(
                            context,
                            RecipePlaylistScreen(
                              playlistId: data.dataId.toString(),
                            ),
                          );
                        }

                        break;
                      default:
                        break;
                    }
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          height: 70,
                          width: 70,
                          color: Theme.of(context).cardColor,
                          // padding: EdgeInsets.all(20.0),
                          child: CustomImage(
                            imageUrl: data.image ?? DummyData.bookCover,
                          ),
                        ),
                      ),
                      SizedBox(height: 2),

                      Expanded(
                        child: Text(
                          data.name ?? '',
                          style: const TextStyle(fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        } else if (state is FeedActivityError) {
          return Center(child: Text(state.message));
        }
        return const SizedBox.shrink();
      },
    );
  }
}
