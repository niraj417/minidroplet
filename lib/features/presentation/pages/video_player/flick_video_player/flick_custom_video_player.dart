import 'package:flutter/material.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

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
  FlickManager? flickManager;
  VideoPlayerController? _controller;
  bool _isLoading = true;
  bool _isInitializing = false;
  bool _shouldDeferInitialization = false;
  bool _showSimplePlayer = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _preparePlayerMode();
  }

  void _attachProgressListener() {
    if (widget.onProgress == null) return;

    _controller?.addListener(() {
      final controller = _controller;
      if (controller == null || !controller.value.isInitialized) return;

      final position = controller.value.position;
      final duration = controller.value.duration;

      widget.onProgress?.call(position, duration);
    });
  }

  Future<void> _preparePlayerMode() async {
    try {
      bool isLowEnd = false;

      if (Platform.isAndroid) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        isLowEnd =
            androidInfo.isLowRamDevice || androidInfo.physicalRamSize <= 4096;
      } else if (Platform.isIOS) {
        final iosInfo = await DeviceInfoPlugin().iosInfo;
        isLowEnd = iosInfo.physicalRamSize <= 3072;
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _showSimplePlayer = isLowEnd;
        _shouldDeferInitialization = isLowEnd;
        _isLoading = !isLowEnd;
      });

      if (!isLowEnd) {
        await _initializePlayer();
      }
    } catch (e) {
      debugPrint('Video player device profiling failed: $e');
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = true;
      });
      await _initializePlayer();
    }
  }

  Future<void> _initializePlayer() async {
    if (_isInitializing) {
      return;
    }

    _isInitializing = true;

    if (mounted) {
      setState(() {
        _error = null;
        _isLoading = true;
      });
    }

    try {
      flickManager?.dispose();
      flickManager = null;
      if (_controller != null) {
        await _controller!.dispose();
        _controller = null;
      }

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
      _controller?.addListener(_videoListener);

      // Initialize and wait for completion
      await _controller?.initialize();
      //     .then((_) {
      //   setState(() {});
      //   _attachProgressListener(); // SAFE
      // });

      // Verify the video is actually loaded
      if (_controller == null || _controller!.value.hasError) {
        throw Exception(
          'Video initialization failed: ${_controller?.value.errorDescription}',
        );
      }

      if (!_controller!.value.isInitialized) {
        throw Exception('Video failed to initialize properly');
      }

      if (!mounted) return;

      if (!_showSimplePlayer) {
        // Create FlickManager only after successful initialization
        flickManager = FlickManager(
          videoPlayerController: _controller!,
          autoPlay: false,
          autoInitialize: false,
        );
      }

      setState(() {
        _isLoading = false;
        _shouldDeferInitialization = false;
      });
    } catch (e) {
      debugPrint('Video initialization error: $e');
      if (mounted) {
        debugPrint('ERRROR VID ${e.toString()}');
        setState(() {
          _error = 'Failed to load video: ${e.toString()}';
          _isLoading = false;
        });
      }
    } finally {
      _isInitializing = false;
    }
  }

  bool _wasPlayingBeforeBuffering = false;

  void _videoListener() {
    final controller = _controller;
    if (controller == null) {
      return;
    }
    final value = controller.value;

    if (value.hasError) {
      debugPrint('Video player error: ${value.errorDescription}');
      if (mounted) {
        setState(() {
          _error = value.errorDescription ?? 'Unknown video error';
          _isLoading = false;
        });
      }
      return;
    }

    // Detect buffering start
    if (value.isBuffering) {
      _wasPlayingBeforeBuffering = value.isPlaying;
    }

    // When buffering finishes, resume playback
    if (!value.isBuffering && _wasPlayingBeforeBuffering && !value.isPlaying) {
      // Don't auto-resume if the video reached the end
      if (value.duration > Duration.zero && value.position >= value.duration) {
        _wasPlayingBeforeBuffering = false;
      } else {
        controller.play();
      }
    }

    // Progress callback
    if (widget.onProgress != null && value.isInitialized) {
      widget.onProgress!(value.position, value.duration);
    }
  }

  @override
  void dispose() {
    _controller?.removeListener(_videoListener);
    flickManager?.dispose();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_shouldDeferInitialization) {
      return _buildDeferredPlayer();
    }

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
      return _buildErrorState();
    }

    if (_showSimplePlayer) {
      return _buildSimplePlayer();
    }

    return Container(
      color: Colors.black,
      child: Center(
          child: AspectRatio(
          aspectRatio: _controller?.value.aspectRatio ?? (16 / 9),
          child: FlickVideoPlayer(
            flickManager: flickManager!,
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

  Widget _buildDeferredPlayer() {
    return GestureDetector(
      onTap: _initializePlayer,
      child: Container(
        height: 220,
        color: Colors.black,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.play_circle_fill, color: Colors.white, size: 64),
              SizedBox(height: 12),
              Text(
                'Tap to load video',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              SizedBox(height: 6),
              Text(
                'Optimized for low-memory devices',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSimplePlayer() {
    final controller = _controller;
    final isPlaying = controller?.value.isPlaying ?? false;

    return Container(
      color: Colors.black,
      child: Center(
        child: AspectRatio(
          aspectRatio: controller?.value.aspectRatio ?? (16 / 9),
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (controller != null) VideoPlayer(controller),
              Positioned.fill(
                child: GestureDetector(
                  onTap: () async {
                    if (controller == null) {
                      return;
                    }
                    if (controller.value.isPlaying) {
                      await controller.pause();
                    } else {
                      await controller.play();
                    }
                    if (mounted) {
                      setState(() {});
                    }
                  },
                  child: Container(color: Colors.transparent),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: IconButton(
                  iconSize: 42,
                  color: Colors.white,
                  onPressed: () async {
                    if (controller == null) {
                      return;
                    }
                    if (controller.value.isPlaying) {
                      await controller.pause();
                    } else {
                      await controller.play();
                    }
                    if (mounted) {
                      setState(() {});
                    }
                  },
                  icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                ),
              ),
              if (controller != null)
                Positioned(
                  left: 12,
                  right: 12,
                  bottom: 8,
                  child: VideoProgressIndicator(
                    controller,
                    allowScrubbing: true,
                    colors: const VideoProgressColors(
                      playedColor: Colors.white,
                      bufferedColor: Colors.white38,
                      backgroundColor: Colors.white24,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
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
              child: Text(
                Platform.isIOS ? 'Test URL in Safari' : 'Copy video URL for testing',
                style: const TextStyle(color: Colors.blue),
              ),
            ),
          ],
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
