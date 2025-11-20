import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tinydroplets/common/widgets/loader.dart';
import 'package:tinydroplets/features/presentation/pages/video_page/recipe_detail_page.dart';
import 'package:tinydroplets/features/presentation/pages/video_page/video_checkout_page.dart';
import 'package:tinydroplets/features/presentation/pages/video_page/widget/playlist_pallete_card.dart';
import 'package:tinydroplets/features/presentation/pages/video_page/widget/recipe_playlist_card.dart';

import '../../../../common/widgets/guest_user_restriction.dart';
import '../../../../core/constant/app_export.dart';
import '../../../../core/services/ad_service/interstitial_ad/interstitial_ad_widget.dart';
import '../../../../core/services/sharing_handler.dart';
import 'bloc/recipe_playlist_bloc/recipe_playlist_bloc.dart';
import 'bloc/recipe_playlist_bloc/recipe_playlist_state.dart';

class RecipePlaylistScreen extends StatefulWidget {
  final String playlistId;
  const RecipePlaylistScreen({super.key, required this.playlistId});

  @override
  State<RecipePlaylistScreen> createState() => _RecipePlaylistScreenState();
}

class _RecipePlaylistScreenState extends State<RecipePlaylistScreen> {
  final DioClient _dioClient = DioClient();
  String? _isSaved;
  String? title;
  String? description;

  Future<void> _savePlaylist() async {
    try {
      final response = await _dioClient.sendPostRequest(
        ApiEndpoints.savePlaylist,
        {"playlist_id": widget.playlistId},
      );
      if (response.data['status'] == 1) {
        debugPrint('Playlist res $response');

        setState(() {
          _isSaved = '1';
        });
        if (mounted) {
          CommonMethods.showSnackBar(context, 'Playlist saved');
        }
      } else {
        if (mounted) {
          CommonMethods.showSnackBar(context, 'Failed to save playlist');
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

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) =>
              RecipePlaylistCubit(DioClient())..loadPlaylist(widget.playlistId),
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: true,
          surfaceTintColor: Colors.transparent,
          backgroundColor: Colors.transparent,
          actions: [
            IconButton(
              icon: const Icon(CupertinoIcons.share_up),
              onPressed: () async {
                await SharingHandler.commonShare(
                  int.parse(widget.playlistId),
                  title ?? '',
                  description ?? '',
                  context,
                );
              },
            ),
            IconButton(
              icon: Icon(
                _isSaved == '1'
                    ? CupertinoIcons.bookmark_solid
                    : CupertinoIcons.bookmark,
              ),
              onPressed: () async {
                if (_isSaved == '0') {
                  await _savePlaylist();
                } else {
                  if (mounted) {
                    CommonMethods.showSnackBar(context, 'Already saved');
                  }
                }
              },
            ),
          ],
        ),
        body: BlocBuilder<RecipePlaylistCubit, RecipePlaylistState>(
          builder: (context, state) {
            if (state is RecipePlaylistLoading) {
              return Loader();
            }

            if (state is RecipePlaylistError) {
              return Center(child: Text('Error: ${state.message}'));
            }

            if (state is RecipePlaylistLoaded) {
              title = state.title ?? '';
              description = state.description ?? '';
              return SingleChildScrollView(
                child: Column(
                  children: [
                    PlaylistPaletteCard(
                      imagePath: state.thumbnail,
                      onPressed: () {},
                      title: state.title,
                      description: state.description,
                      totalVideos: '${state.playlistVideos.length}',
                      totalLength: '1200',
                    ),
                    const SizedBox(height: 15),
                    ListView.builder(
                      itemCount: state.playlistVideos.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        final video = state.playlistVideos[index];
                        final isFree = video.priceType == 'free';

                        final childWidget = Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: RecipePlaylistCard(playlistVideo: video),
                        );

                        return isFree
                            ? InterstitialAdWidget(
                              onAdClosed: () {
                                if(SharedPref.isGuestUser()){
                                  GuestRestrictionDialog.show(context);
                                  return;
                                }
                                // _navigateToPlaylistVideoDestination(context, video);
                                goto(
                                  context,
                                  RecipeDetailScreen(
                                    videoId: video.id.toString() ?? '',
                                  ),
                                );
                              },
                              child: childWidget,
                            )
                            : InkWell(
                              onTap: () {
                                _navigateToPlaylistVideoDestination(
                                  context,
                                  video,
                                );
                              },
                              child: childWidget,
                            );
                      },
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  void _navigateToPlaylistVideoDestination(
    BuildContext context,
    dynamic video,
  ) {
    if (video.isBuy == '0') {
      debugPrint('Navigating to VideoCheckoutPage');
      goto(
        context,
        VideoCheckoutPage(
          id: video.id,
          title: video.title ?? video.videoTitle ?? '',
          thumbnail: video.thumbnail ?? video.videoThumbnail ?? '',
          amount: video.price ?? '',
          mainPrice: video.mainPrice ?? '',
        ),
      );
    } else {
      debugPrint('Navigating to RecipeDetailScreen');
      goto(context, RecipeDetailScreen(videoId: video.id?.toString() ?? ''));
    }
  }
}
