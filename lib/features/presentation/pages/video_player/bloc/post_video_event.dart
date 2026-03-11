part of 'post_video_bloc.dart';


abstract class VideoEvent {
  const VideoEvent();
}

class InitializeVideo extends VideoEvent {
  final String videoUrl;
  const InitializeVideo(this.videoUrl);
}

class PlayVideo extends VideoEvent {
  const PlayVideo();
}

class PauseVideo extends VideoEvent {
  const PauseVideo();
}

class ToggleVolume extends VideoEvent {
  const ToggleVolume();
}

class ToggleControls extends VideoEvent {
  const ToggleControls();
}

class NavigateToFullscreen extends VideoEvent {
  const NavigateToFullscreen();
}

class StopVideo extends VideoEvent {
  const StopVideo();
}

class UpdatePosition extends VideoEvent {
  final Duration position;
  const UpdatePosition(this.position);
}

class SeekPosition extends VideoEvent {
  final Duration position;
  const SeekPosition(this.position);
}
