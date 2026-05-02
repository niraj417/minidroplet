import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tinydroplets/common/widgets/loader.dart';
import 'package:tinydroplets/core/constant/app_export.dart';
import 'package:video_player/video_player.dart';
import 'bloc/post_video_bloc.dart';

class VideoPlayerWidget extends StatelessWidget {
  final bool playNext;
  final bool playPrevious;
  final bool enableSeek;
  final bool fullScreen;
  final String videoUrl;

  const VideoPlayerWidget({
    super.key,
    required this.videoUrl,
    this.playNext = false,
    this.playPrevious = false,
    this.enableSeek = false,
    this.fullScreen = false,
  });

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return hours > 0
        ? '${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}'
        : '${twoDigits(minutes)}:${twoDigits(seconds)}';
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => VideoBloc()..add(InitializeVideo(videoUrl)),
      child: BlocBuilder<VideoBloc, VideoState>(
        builder: (context, state) {
          if (state is VideoLoading) {
            return Shimmer.fromColors(
                baseColor: Colors.grey.shade400,
                highlightColor: Colors.grey.shade200,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(color: Colors.white),
                  ),
                ));
          }

          if (state is VideoPlaying) {
            return Stack(
              alignment: Alignment.center,
              children: [
                GestureDetector(
                  onTap: () =>
                      context.read<VideoBloc>().add(const ToggleControls()),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child:
                        VideoPlayer(context.read<VideoBloc>().videoController!),
                  ),
                ),
                // if (state.isShowing) ...[
                Positioned(
                  right: 0,
                  top: 0,
                  child: Row(
                    children: [
                      IconButton(
                        color: Colors.white,
                        onPressed: () =>
                            context.read<VideoBloc>().add(const ToggleVolume()),
                        icon: Icon(
                          state.isVolumeZero
                              ? CupertinoIcons.speaker_slash
                              : CupertinoIcons.speaker_2,
                        ),
                      ),
                      if (fullScreen)
                        IconButton(
                          color: Colors.white,
                          onPressed: () => context
                              .read<VideoBloc>()
                              .add(const NavigateToFullscreen()),
                          icon: const Icon(CupertinoIcons.fullscreen),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  color: Colors.white,
                  iconSize: 50,
                  icon: Icon(
                    state.isPlaying
                        ? CupertinoIcons.pause_circle
                        : CupertinoIcons.play_circle,
                  ),
                  onPressed: () {
                    context.read<VideoBloc>().add(state.isPlaying
                        ? const PauseVideo()
                        : const PlayVideo());
                  },
                ),
                if (enableSeek)
                  Positioned(
                    width: MediaQuery.of(context).size.width,
                    bottom: 0,
                    child: Container(
                      color: Colors.white.withValues(alpha: 0.7),
                      padding: const EdgeInsets.all(7.0),
                      child: Column(
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _formatDuration(state.position),
                                  style: const TextStyle(fontSize: 12),
                                ),
                                Text(
                                  _formatDuration(state.duration),
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          SliderTheme(
                            data: const SliderThemeData(
                              thumbShape:
                                  RoundSliderThumbShape(enabledThumbRadius: 6),
                              trackHeight: 2,
                            ),
                            child: Slider(
                              value: min(
                                state.position.inMilliseconds.toDouble(),
                                state.duration.inMilliseconds.toDouble(),
                              ),
                              min: 0,
                              max: max(
                                state.duration.inMilliseconds.toDouble(),
                                state.position.inMilliseconds.toDouble(),
                              ),
                              activeColor: Colors.red,
                              inactiveColor: Colors.grey,
                              onChangeStart: (value) {
                                // Pause video when seeking starts
                                context
                                    .read<VideoBloc>()
                                    .add(const PauseVideo());
                              },
                              onChanged: (value) async {
                                final duration =
                                    Duration(milliseconds: value.toInt());
                                context
                                    .read<VideoBloc>()
                                    .add(SeekPosition(duration));
                              },
                              onChangeEnd: (value) {
                                // Resume playback after seeking
                                context
                                    .read<VideoBloc>()
                                    .add(const PlayVideo());
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
              ],
              //   ],
            );
          }

          if (state is VideoError) {
            return AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                color: Colors.black,
                alignment: Alignment.center,
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      CupertinoIcons.exclamationmark_triangle,
                      color: Colors.white,
                      size: 32,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      state.error,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
