part of 'post_video_bloc.dart';

abstract class VideoState {
  const VideoState();
}

class VideoInitial extends VideoState {
  const VideoInitial();
}

class VideoLoading extends VideoState {
  const VideoLoading();
}

class VideoError extends VideoState {
  final String error;
  const VideoError({required this.error});
}
class VideoPlaying extends VideoState {
  final String videoUrl;
  final bool isPlaying;
  final bool isShowing;
  final bool isVolumeZero;
  final bool isFullscreen;
  final Duration position;
  final Duration duration;

  const VideoPlaying({
    required this.videoUrl,
    required this.isPlaying,
    required this.isShowing,
    required this.isVolumeZero,
    required this.isFullscreen,
    required this.position,
    required this.duration,
  });

  List<Object> get props => [
    videoUrl,
    isPlaying,
    isShowing,
    isVolumeZero,
    isFullscreen,
    position,
    duration,
  ];

  VideoPlaying copyWith({
    String? videoUrl,
    bool? isPlaying,
    bool? isShowing,
    bool? isVolumeZero,
    bool? isFullscreen,
    Duration? position,
    Duration? duration,
  }) {
    return VideoPlaying(
      videoUrl: videoUrl ?? this.videoUrl,
      isPlaying: isPlaying ?? this.isPlaying,
      isShowing: isShowing ?? this.isShowing,
      isVolumeZero: isVolumeZero ?? this.isVolumeZero,
      isFullscreen: isFullscreen ?? this.isFullscreen,
      position: position ?? this.position,
      duration: duration ?? this.duration,
    );
  }
}
