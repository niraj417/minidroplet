import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tinydroplets/core/constant/app_export.dart';
import 'package:tinydroplets/features/presentation/pages/ebook_player/widget/audio_player_palette.dart';
import '../ebook_page/model/purchased_ebook_model.dart';
import 'bloc/ebook_player_bloc.dart';

class AudioPlayerScreen extends StatelessWidget {
  final PurchasedEbookDataModel purchasedEbookDataModel;

  const AudioPlayerScreen({
    super.key,
    required this.purchasedEbookDataModel,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AudioPlayerBloc()..add(InitAudioPlayer(purchasedEbookDataModel)),
      child: const AudioPlayerView(),
    );
  }
}

class AudioPlayerView extends StatelessWidget {
  const AudioPlayerView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
      builder: (context, state) {
        if (state.chapters.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final currentChapter = state.chapters[state.currentIndex];

        return Stack(
          children: [
            AudioPlayerPalette(imagePath: currentChapter.coverImage),
            Scaffold(
              backgroundColor: Colors.transparent,
              appBar: _buildAppBar(context),
              body: Stack(
                children: [
                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          _buildCoverArt(currentChapter),
                          const SizedBox(height: 30),
                          _buildChapterInfo(currentChapter),
                          const SizedBox(height: 20),
                          const AudioProgressBar(),
                          const SizedBox(height: 20),
                          const AudioControls(),
                        ],
                      ),
                    ),
                  ),
                  if (state.isChapterListVisible) const ChapterListSheet(),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  BoxDecoration _buildGradientDecoration() {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [Colors.pink.shade100, Colors.deepOrange],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.keyboard_arrow_down),
        onPressed: () => Navigator.pop(context),
        color: Colors.white,
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.list),
          color: Colors.white,
          onPressed: () =>
              context.read<AudioPlayerBloc>().add(ToggleChapterList()),
        ),
      ],
    );
  }

  Widget _buildCoverArt(ChapterAudioModel chapter) {
    return Container(
      height: 300,
      width: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          chapter.coverImage,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[300],
              child: const Icon(
                Icons.broken_image,
                size: 50,
                color: Colors.grey,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildChapterInfo(ChapterAudioModel chapter) {
    return Column(
      children: [
        Text(
          chapter.chapterName,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          chapter.authorName,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}

// lib/features/audio_player/presentation/widgets/progress_bar.dart
class AudioProgressBar extends StatelessWidget {
  const AudioProgressBar({Key? key}) : super(key: key);

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
      builder: (context, state) {
        return Column(
          children: [
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: Colors.white,
                inactiveTrackColor: Colors.white.withOpacity(0.3),
                thumbColor: Colors.white,
                trackHeight: 4,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                overlayShape: SliderComponentShape.noOverlay,
              ),
              child: Slider(
                value: state.position.inSeconds.toDouble(),
                max: state.duration.inSeconds.toDouble(),
                onChanged: (value) {
                  context.read<AudioPlayerBloc>().add(
                        SeekAudioTo(Duration(seconds: value.toInt())),
                      );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDuration(state.position),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    _formatDuration(state.duration),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

// lib/features/audio_player/presentation/widgets/audio_controls.dart
class AudioControls extends StatelessWidget {
  const AudioControls({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
      builder: (context, state) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildShuffleButton(context, state),
            _buildPreviousButton(context),
            _buildPlayPauseButton(context, state),
            _buildNextButton(context),
            _buildRepeatButton(context, state),
          ],
        );
      },
    );
  }

  Widget _buildShuffleButton(BuildContext context, AudioPlayerState state) {
    return IconButton(
      icon: Icon(
        state.isShuffleEnabled ? Icons.shuffle : Icons.shuffle_outlined,
        color: Colors.white,
      ),
      onPressed: () =>
          context.read<AudioPlayerBloc>().add(ToggleAudioShuffle()),
    );
  }

  Widget _buildPreviousButton(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.skip_previous, color: Colors.white),
      onPressed: () =>
          context.read<AudioPlayerBloc>().add(PlayPreviousChapter()),
    );
  }

  Widget _buildPlayPauseButton(BuildContext context, AudioPlayerState state) {
    final isPlaying = state.playbackState == AudioPlaybackState.playing;
    return IconButton(
      iconSize: 64,
      icon: Icon(
        isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
        color: Colors.white,
      ),
      onPressed: () {
        if (isPlaying) {
          context.read<AudioPlayerBloc>().add(PauseAudio());
        } else {
          context.read<AudioPlayerBloc>().add(ResumeAudio());
        }
      },
    );
  }

  Widget _buildNextButton(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.skip_next, color: Colors.white),
      onPressed: () => context.read<AudioPlayerBloc>().add(PlayNextChapter()),
    );
  }

  Widget _buildRepeatButton(BuildContext context, AudioPlayerState state) {
    IconData iconData;
    switch (state.repeatMode) {
      case AudioRepeatMode.none:
        iconData = Icons.repeat_outlined;
        break;
      case AudioRepeatMode.single:
        iconData = Icons.repeat_one;
        break;
      case AudioRepeatMode.all:
        iconData = Icons.repeat;
        break;
    }

    return IconButton(
      icon: Icon(iconData, color: Colors.white),
      onPressed: () => context.read<AudioPlayerBloc>().add(ToggleAudioRepeat()),
    );
  }
}

// lib/features/audio_player/presentation/widgets/chapter_list_sheet.dart
class ChapterListSheet extends StatelessWidget {
  const ChapterListSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.2,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
          builder: (context, state) {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildDragHandle(),
                  _buildHeader(context),
                  Expanded(
                    child: _buildChapterList(
                      context,
                      state,
                      scrollController,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDragHandle() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Chapters',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () =>
                context.read<AudioPlayerBloc>().add(ToggleChapterList()),
          ),
        ],
      ),
    );
  }

  Widget _buildChapterList(
    BuildContext context,
    AudioPlayerState state,
    ScrollController scrollController,
  ) {
    return ListView.builder(
      controller: scrollController,
      itemCount: state.chapters.length,
      itemBuilder: (context, index) {
        final chapter = state.chapters[index];
        final isPlaying = index == state.currentIndex &&
            state.playbackState == AudioPlaybackState.playing;

        return ListTile(
          leading: _buildChapterLeading(isPlaying),
          title: Text(
            chapter.chapterName,
            style: TextStyle(
              fontWeight: isPlaying ? FontWeight.bold : FontWeight.normal,
              color: isPlaying ? Colors.pink : null,
            ),
          ),
          subtitle: Text(
            'Chapter ${index + 1}',
            style: TextStyle(
              color: isPlaying ? Colors.pink.withOpacity(0.7) : Colors.grey,
            ),
          ),
          onTap: () {
            context.read<AudioPlayerBloc>().add(PlayAudioChapter(index));
            context.read<AudioPlayerBloc>().add(ToggleChapterList());
          },
        );
      },
    );
  }

  Widget _buildChapterLeading(bool isPlaying) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: isPlaying ? Colors.pink.shade100 : Colors.grey[200],
      ),
      child: Icon(
        isPlaying ? Icons.pause : Icons.play_arrow,
        color: isPlaying ? Colors.pink : Colors.grey[600],
      ),
    );
  }
}


/*
import 'package:flutter/cupertino.dart';
import '../../../../core/constant/app_export.dart';
import '../../../../core/constant/app_vector.dart';

class AudioPlayer extends StatefulWidget {
  final String imageUrl;

  const AudioPlayer({super.key, required this.imageUrl});

  @override
  State<AudioPlayer> createState() => _AudioPlayerState();
}

class _AudioPlayerState extends State<AudioPlayer> {
  double sliderValue = 0.5;
  Duration duration = Duration(minutes: 3, seconds: 30);
  Duration position = Duration(minutes: 1, seconds: 45);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          // colors: [Colors.pink, Colors.red],
          colors: [Colors.pink.shade100, Colors.deepOrange],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Scaffold(
          backgroundColor: AppColor.transparentColor,
          appBar: AppBar(
            backgroundColor: AppColor.transparentColor,
            leading: Transform.translate(
              offset: const Offset(-15, 0),
              child: InkWell(
                onTap: () => backTo(context),
                highlightColor: AppColor.transparentColor,
                focusColor: AppColor.transparentColor,
                splashColor: AppColor.transparentColor,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Image.asset(
                    AppVector.pullDownArrow,
                    color: AppColor.whiteColor,
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                  onPressed: () {
                    //  goto(context, AboutScreen());
                  },
                  icon: const Icon(Icons.settings_rounded))
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  height: 300,
                  width: 200,
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: CustomImage(
                    imageUrl: widget.imageUrl,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Chapter: 1',
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: const TextStyle(
                                      color: AppColor.whiteColor,
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700),
                                ),
                                Text(
                                  'Author Name',
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                          const Expanded(child: SizedBox()),
                          IconButton(
                            onPressed: () async {
                              // await ref
                              //     .read(homeViewModelProvider.notifier)
                              //     .favSong(songId: currentSong.id);
                            },
                            icon: Icon(
                                // userFavorites
                                //     .where((element) =>
                                // element.song_id == currentSong.id)
                                //     .toList()
                                //     .isNotEmpty

                                //   ?
                                CupertinoIcons.heart_fill,
                                //: CupertinoIcons.heart,
                                color: AppColor.whiteColor),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      */
/* StreamBuilder(
                          stream: songNotifier.audioPlayer!.positionStream,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const SizedBox();
                            }
                            final position = snapshot.data;
                            final duration = songNotifier.audioPlayer!.duration;

                            double sliderValue = 0.0;
                            if (position != null && duration != null) {
                              sliderValue = position.inMilliseconds /
                                  duration.inMilliseconds;
                            }
                            return Column(
                              children: [
                                SliderTheme(
                                  data: SliderTheme.of(context).copyWith(
                                      activeTrackColor: AppColor.whiteColor,
                                      inactiveTrackColor: AppColor.whiteColor
                                          .withOpacity(0.117),
                                      thumbColor: AppColor.whiteColor,
                                      trackHeight: 4,
                                      overlayShape:
                                          SliderComponentShape.noOverlay),
                                  child: Slider(
                                    value: sliderValue,
                                    onChanged: (value) {
                                      sliderValue = value;
                                    },
                                    min: 0,
                                    max: 1,
                                    onChangeEnd: (value) {},
                                    //  onChangeEnd: songNotifier.seek,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      //'${position!.inMinutes}:${position.inSeconds}',
                                      'Song position',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w300,
                                      ),
                                    ),
                                    const Expanded(child: SizedBox()),
                                    Text(
                                      '${duration!.inMinutes}:${duration.inSeconds}',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w300,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          }),*/ /*


                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: Colors.white,
                              inactiveTrackColor: Colors.white38,
                              thumbColor: Colors.white,
                              // activeTrackColor: Color(AppColor.primaryColor),
                              // inactiveTrackColor: Color(AppColor.primaryColor).withValues(alpha: 0.3),
                              // thumbColor:Color(AppColor.primaryColor),
                              // trackHeight: 4,
                              overlayShape: SliderComponentShape.noOverlay,
                            ),
                            child: Slider(

                              value: sliderValue,
                              onChanged: (value) {
                                setState(() {
                                  sliderValue = value;
                                  position = duration * sliderValue;
                                });
                              },
                              min: 0,
                              max: 1,
                            ),
                          ),
                          SizedBox(height: 5.0,),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Row(
                              children: [
                                Text(
                                  '${position.inMinutes}:${(position.inSeconds % 60).toString().padLeft(2, '0')}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                                const Expanded(child: SizedBox()),
                                Text(
                                  '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Image.asset(
                              AppVector.shuffle,
                              color: AppColor.whiteColor,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Image.asset(
                              AppVector.previousSong,
                              color: AppColor.whiteColor,
                            ),
                          ),
                          IconButton(
                            onPressed: () {},
                            //    onPressed: songNotifier.playPause,
                            iconSize: 80,
                            color: AppColor.whiteColor,
                            icon: Icon(
                                //songNotifier.isPlaying ? CupertinoIcons.pause_circle_fill :
                                CupertinoIcons.play_circle_fill),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Image.asset(
                              AppVector.nextSong,
                              color: AppColor.whiteColor,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Image.asset(
                              AppVector.repeat,
                              color: AppColor.whiteColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Image.asset(
                              AppVector.connectDevice,
                              color: AppColor.whiteColor,
                            ),
                          ),
                          const Expanded(child: SizedBox()),
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Image.asset(
                              AppVector.playlist,
                              color: AppColor.whiteColor,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
*/