import 'package:flutter/material.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';

class FlickCustomVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final void Function(Duration, Duration)? onProgress;

  const FlickCustomVideoPlayer({
    super.key,
    required this.videoUrl,
    this.onProgress, // OPTIONAL
  });

  @override
  State<FlickCustomVideoPlayer> createState() => _FlickCustomVideoPlayerState();
}

class _FlickCustomVideoPlayerState extends State<FlickCustomVideoPlayer> {
  late FlickManager flickManager;
  late VideoPlayerController _controller;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  void _attachProgressListener() {
    if (widget.onProgress == null) return;

    _controller.addListener(() {
      if (!_controller.value.isInitialized) return;

      final position = _controller.value.position;
      final duration = _controller.value.duration;

      widget.onProgress?.call(position, duration);
    });
  }

  Future<void> _initializePlayer() async {
    try {
      // CRITICAL FIX: Create controller with iOS-specific configuration
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
        httpHeaders: {
          'User-Agent':
              'Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X) AppleWebKit/605.1.15',
          'Accept': 'video/mp4,video/x-msvideo,video/*,*/*;q=0.9',
          'Accept-Encoding': 'identity', // Important for iOS
          'Range': 'bytes=0-', // Enable partial content for iOS
        },
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: false,
          allowBackgroundPlayback: false,
          webOptions: const VideoPlayerWebOptions(
            allowContextMenu: false,
            allowRemotePlayback: false,
          ),
        ),

      );

      // CRITICAL: Add listener BEFORE initialization
      _controller.addListener(_videoListener);

      // Initialize and wait for completion
      await _controller.initialize();
      //     .then((_) {
      //   setState(() {});
      //   _attachProgressListener(); // SAFE
      // });

      // Verify the video is actually loaded
      if (_controller.value.hasError) {
        throw Exception(
          'Video initialization failed: ${_controller.value.errorDescription}',
        );
      }

      if (!_controller.value.isInitialized) {
        throw Exception('Video failed to initialize properly');
      }

      if (!mounted) return;

      // Create FlickManager only after successful initialization
      flickManager = FlickManager(
        videoPlayerController: _controller,
        autoPlay: false,
        autoInitialize: false, // We already initialized
      );

      setState(() {
        _isLoading = false;
      });

      // iOS SPECIFIC: Small delay then attempt to play
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted && _controller.value.isInitialized) {
        // Test if video can play by attempting a small seek
        await _controller.seekTo(const Duration(seconds: 0));
      }
    } catch (e) {
      debugPrint('Video initialization error: $e');
      if (mounted) {
        debugPrint('ERRROR VID ${e.toString()}');
        setState(() {
          _error = 'Failed to load video: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  void _videoListener() {
    if (_controller.value.hasError) {
      debugPrint('Video player error: ${_controller.value.errorDescription}');
      if (mounted) {
        setState(() {
          _error = _controller.value.errorDescription ?? 'Unknown video error';
          _isLoading = false;
        });
      }
    }
    _controller.addListener(() {
      if (!_controller.value.isInitialized) return;

      final position = _controller.value.position;
      final duration = _controller.value.duration;

      widget.onProgress?.call(position, duration);
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_videoListener);
    if (!_isLoading && _error == null) {
      flickManager.dispose();
    }
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        height: 200,
        color: Colors.black,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 16),
              Text('Loading video...', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return Container(
        height: 300,
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                'Video Error:\n$_error',
                style: const TextStyle(color: Colors.white, fontSize: 12),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _error = null;
                    _isLoading = true;
                  });
                  _initializePlayer();
                },
                child: const Text('Retry'),
              ),
              const SizedBox(height: 8),
              // Debug button to test video URL in browser
              TextButton(
                onPressed: () {
                  debugPrint('Test this URL in Safari: ${widget.videoUrl}');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Test URL in Safari: ${widget.videoUrl}'),
                      duration: const Duration(seconds: 5),
                    ),
                  );
                },
                child: const Text(
                  'Test URL in Safari',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      color: Colors.black,
      child: Center(
        child: AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: FlickVideoPlayer(
            flickManager: flickManager,
            flickVideoWithControls: FlickVideoWithControls(
              controls: const FlickPortraitControls(),
              // controls: Platform.isIOS ? const IOSVideoControls() : const FlickPortraitControls(),
              videoFit: BoxFit.contain,
              playerErrorFallback: Container(
                color: Colors.black,
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.play_circle_outline, color: Colors.white, size: 64),
                      SizedBox(height: 16),
                      Text(
                        'Video failed to load\nTap retry above',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            flickVideoWithControlsFullscreen: const FlickVideoWithControls(
              controls: FlickLandscapeControls(),
              videoFit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}

// iOS-specific video controls with better touch handling
class IOSVideoControls extends StatelessWidget {
  const IOSVideoControls({super.key});

  @override
  Widget build(BuildContext context) {
    return FlickShowControlsAction(
      child: FlickSeekVideoAction(
        child: Center(
          child: FlickVideoBuffer(
            child: FlickAutoHideChild(
              showIfVideoNotInitialized: false,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Large centered play button
                  Expanded(
                    child: Center(
                      child: FlickPlayToggle(
                        size: 30,
                        color: Colors.white,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(color: Colors.white24, width: 2),
                        ),
                      ),
                    ),
                  ),
                  // Bottom controls
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black54],
                      ),
                    ),
                    child: Column(
                      children: [
                        // Progress bar
                        FlickVideoProgressBar(
                          flickProgressBarSettings: FlickProgressBarSettings(
                            height: 6,
                            handleRadius: 8,
                            padding: const EdgeInsets.symmetric(horizontal: 0),
                            backgroundColor: Colors.white24,
                            bufferedColor: Colors.white38,
                            playedColor: Colors.blue,
                            handleColor: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Time and controls
                        Row(
                          children: [
                            FlickCurrentPosition(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                            const Spacer(),
                            FlickSoundToggle(
                              size: 24,
                              color: Colors.white,
                              padding: const EdgeInsets.all(8),
                            ),
                            const SizedBox(width: 16),
                            FlickFullScreenToggle(
                              size: 24,
                              color: Colors.white,
                              padding: const EdgeInsets.all(8),
                            ),
                            const SizedBox(width: 8),
                            FlickTotalDuration(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
