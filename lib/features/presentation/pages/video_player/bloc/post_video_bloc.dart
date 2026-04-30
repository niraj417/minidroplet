import 'dart:async';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';
import '../../../../../core/constant/app_export.dart';
import '../../../../../main.dart';
import '../full_screen_v_player.dart';

part 'post_video_event.dart';
part 'post_video_state.dart';

class VideoBloc extends Bloc<VideoEvent, VideoState> {
  static VideoBloc? _currentPlayingBloc;
   VideoPlayerController? videoController;
  Timer? _controlsTimer;

  VideoPlayerController? get controller => videoController;

  VideoBloc() : super(const VideoInitial()) {
    on<InitializeVideo>(_onInitializeVideo);
    on<PlayVideo>(_onPlayVideo);
    on<PauseVideo>(_onPauseVideo);
    on<ToggleVolume>(_onToggleVolume);
    on<ToggleControls>(_onToggleControls);
    on<UpdatePosition>(_onUpdatePosition);
    on<SeekPosition>(_onSeekPosition);
    on<NavigateToFullscreen>(_onNavigateToFullscreen);
    on<StopVideo>(_onStopVideo);
  }

  // Future<void> _onInitializeVideo(InitializeVideo event, Emitter<VideoState> emit) async {
  //   emit(const VideoLoading());
  //   controller = VideoPlayerController.networkUrl(Uri.parse(event.videoUrl))
  //     ..addListener(() {
  //
  //       add(UpdatePosition(controller.value.position));
  //     })
  //     ..setLooping(true);
  //
  //   await controller.initialize();
  //   emit(VideoPlaying(
  //     videoUrl: event.videoUrl,
  //     isPlaying: false,
  //     isShowing: false,
  //     isVolumeZero: false,
  //     isFullscreen: false,
  //     position: Duration.zero,
  //     duration: controller.value.duration,
  //   ));
  // }


  Future<void> _onInitializeVideo(InitializeVideo event, Emitter<VideoState> emit) async {
    emit(const VideoLoading());
    try {
      await Future.delayed(Duration(milliseconds: 1000));
      videoController = VideoPlayerController.networkUrl(Uri.parse(event.videoUrl))
        ..addListener(() {
          if (!videoController!.value.isPlaying) {
            add(UpdatePosition(videoController!.value.position));
          }
        })
        ..setLooping(true);

      await videoController?.initialize();
      emit(VideoPlaying(
        videoUrl: event.videoUrl,
        isPlaying: false,
        isShowing: false,
        isVolumeZero: false,
        isFullscreen: false,
        position: Duration.zero,
        duration: videoController!.value.duration,
      ));
    } catch (e) {
      print('Error initializing video: $e');
      emit(VideoError(error: e.toString()));
    }
  }
  Future<void> _onPlayVideo(PlayVideo event, Emitter<VideoState> emit) async {
    if (state is VideoPlaying) {
      if (_currentPlayingBloc != null && _currentPlayingBloc != this) {
        _currentPlayingBloc!.add(const PauseVideo());
      }
      _currentPlayingBloc = this;

      await videoController!.play();
      emit((state as VideoPlaying).copyWith(isPlaying: true));
    }
  }

  Future<void> _onPauseVideo(PauseVideo event, Emitter<VideoState> emit) async {
    if (state is VideoPlaying) {
      await videoController!.pause();
      emit((state as VideoPlaying).copyWith(isPlaying: false));
      if (_currentPlayingBloc == this) {
        _currentPlayingBloc = null;
      }
    }
  }

  void _onToggleVolume(ToggleVolume event, Emitter<VideoState> emit) {
    if (state is VideoPlaying) {
      final currentState = state as VideoPlaying;
      final newVolumeZero = !currentState.isVolumeZero;
      videoController!.setVolume(newVolumeZero ? 0.0 : 100.0);
      emit(currentState.copyWith(isVolumeZero: newVolumeZero));
    }
  }

  void _onToggleControls(ToggleControls event, Emitter<VideoState> emit) {
    if (state is VideoPlaying) {
      final currentState = state as VideoPlaying;
      final newShowing = !currentState.isShowing;
      emit(currentState.copyWith(isShowing: newShowing));

      _controlsTimer?.cancel();
      if (newShowing) {
        _controlsTimer = Timer(const Duration(seconds: 4), () {
          add(const ToggleControls());
        });
      }
    }
  }



  // void _onUpdatePosition(UpdatePosition event, Emitter<VideoState> emit) {
  //   if (state is VideoPlaying) {
  //     emit((state as VideoPlaying).copyWith(position: event.position));
  //   }
  // }




  // Future<void> _onSeekPosition(SeekPosition event, Emitter<VideoState> emit) async {
  //   if (state is VideoPlaying) {
  //     await controller.seekTo(event.position);
  //   }
  // }

  void _onUpdatePosition(UpdatePosition event, Emitter<VideoState> emit) {
    if (state is VideoPlaying && videoController != null && videoController!.value.isInitialized) {
      final currentState = state as VideoPlaying;
      if (currentState.position != event.position) {
        emit(currentState.copyWith(
          position: event.position,
          duration: videoController!.value.duration,
        ));
      }
    }
  }

  Future<void> _onSeekPosition(SeekPosition event, Emitter<VideoState> emit) async {
    if (state is VideoPlaying && videoController != null && videoController!.value.isInitialized) {
      try {
        final Duration targetPosition = Duration(
          milliseconds: min(
            event.position.inMilliseconds,
            videoController!.value.duration.inMilliseconds,
          ),
        );

        await videoController!.seekTo(targetPosition);

        if (state is VideoPlaying) {
          emit((state as VideoPlaying).copyWith(
            position: targetPosition,
          ));
        }
      } catch (e) {
        print('Error during seek: $e');
      }
    }
  }

  Future<void> _onNavigateToFullscreen(NavigateToFullscreen event, Emitter<VideoState> emit) async {
    if (state is VideoPlaying) {
      final currentState = state as VideoPlaying;
      final currentPosition = videoController!.value.position;

      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.landscapeRight,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
      ]);

      Navigator.of(navigatorKey.currentContext!).push(
        MaterialPageRoute(
          builder: (context) => FullScreenVideoPlayer(
            videoUrl: currentState.videoUrl,
            initialPosition: currentPosition,
          ),
        ),
      );
    }
  }

  Future<void> _onStopVideo(StopVideo event, Emitter<VideoState> emit) async {
    await videoController!.pause();
    if (_currentPlayingBloc == this) {
      _currentPlayingBloc = null;
    }
    emit(VideoInitial());
  }

  @override
  Future<void> close() {
    videoController!.dispose();
    if (_currentPlayingBloc == this) {
      _currentPlayingBloc = null;
    }
    _controlsTimer?.cancel();
    return super.close();
  }
}
