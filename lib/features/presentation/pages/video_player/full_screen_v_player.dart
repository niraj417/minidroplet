
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';
import '../../../../common/widgets/loader.dart';
import '../../../../core/constant/app_export.dart';
import 'bloc/post_video_bloc.dart';


class FullScreenVideoPlayer extends StatelessWidget {
  final String videoUrl;
  final Duration initialPosition;

  const FullScreenVideoPlayer({
    super.key,
    required this.videoUrl,
    required this.initialPosition,
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
    return WillPopScope(
      onWillPop: () async {
        // Reset orientation before popping
        await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
        await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
        return true;
      },
      child: BlocProvider(
        create: (context) {
          final bloc = VideoBloc()..add(InitializeVideo(videoUrl));
          // Seek to initial position after initialization
          bloc.stream.listen((state) {
            if (state is VideoPlaying && state.position == Duration.zero) {
              bloc.add(SeekPosition(initialPosition));
              bloc.add(const PlayVideo());
            }
          });
          return bloc;
        },
        child: BlocBuilder<VideoBloc, VideoState>(
          builder: (context, state) {
            if (state is VideoLoading) {
              return const Scaffold(
                body: Center(child: Loader()),
              );
            }

            if (state is VideoPlaying) {
              return Scaffold(
                backgroundColor: Colors.black,
                appBar: AppBar(
                  backgroundColor: Colors.transparent,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () async {
                      context.read<VideoBloc>().add(const StopVideo());
                      Navigator.of(context).pop();
                    },
                  ),
                ),
                body: Stack(
                  alignment: Alignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => context.read<VideoBloc>().add(const ToggleControls()),
                      child: Center(
                        child: AspectRatio(
                          aspectRatio: 16 / 9,
                          child: VideoPlayer(context.read<VideoBloc>().videoController!),
                        ),
                      ),
                    ),
                    if (state.isShowing) ...[
                      Positioned(
                        right: 16,
                        top: 16,
                        child: IconButton(
                          color: Colors.white,
                          onPressed: () => context.read<VideoBloc>().add(const ToggleVolume()),
                          icon: Icon(
                            state.isVolumeZero
                                ? CupertinoIcons.speaker_slash
                                : CupertinoIcons.speaker_2,
                          ),
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
                          context.read<VideoBloc>().add(
                            state.isPlaying ? const PauseVideo() : const PlayVideo(),
                          );
                        },
                      ),
                      Positioned(
                        width: MediaQuery.of(context).size.width,
                        bottom: 0,
                        child: Container(
                          color: Colors.black.withOpacity(0.5),
                          padding: const EdgeInsets.all(7.0),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _formatDuration(state.position),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      _formatDuration(state.duration),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  activeTrackColor: Colors.white,
                                  inactiveTrackColor: Colors.white.withOpacity(0.4),
                                  thumbColor: Colors.white,
                                  overlayShape: SliderComponentShape.noOverlay,
                                ),
                                child: Slider(
                                  value: state.position.inSeconds.toDouble(),
                                  max: state.duration.inSeconds.toDouble(),
                                  onChanged: (value) {
                                    context.read<VideoBloc>().add(
                                      SeekPosition(Duration(seconds: value.toInt())),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
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
}
