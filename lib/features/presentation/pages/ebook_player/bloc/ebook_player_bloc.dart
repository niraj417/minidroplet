// lib/features/presentation/pages/ebook_player/audio_player_imports.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

import '../../ebook_page/model/purchased_ebook_model.dart';
// lib/features/presentation/bloc/audio_player_bloc.dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';




// audio_player/models/chapter_audio_model.dart
class ChapterAudioModel {
  final int id;
  final String chapterName;
  final String audioUrl;
  final String coverImage;
  final String authorName;
  final Duration duration;

  ChapterAudioModel({
    required this.id,
    required this.chapterName,
    required this.audioUrl,
    required this.coverImage,
    required this.authorName,
    this.duration = Duration.zero,
  });

  factory ChapterAudioModel.fromAllChapter(AllChapter chapter, PurchasedEbookDataModel ebook) {
    return ChapterAudioModel(
      id: chapter.id,
      chapterName: chapter.chapterName,
      audioUrl: chapter.audio,
      coverImage: ebook.coverImage,
      authorName: ebook.authorName,
    );
  }

  MediaItem toMediaItem() {
    return MediaItem(
      id: id.toString(),
      album: "Chapter $id",
      title: chapterName,
      artist: authorName,
      artUri: Uri.parse(coverImage),
      duration: duration,
    );
  }
}

// audio_player/bloc/audio_player_state.dart
enum AudioPlaybackState { initial, loading, playing, paused, completed, error }
enum AudioRepeatMode { none, single, all }

class AudioPlayerState {
  final PurchasedEbookDataModel? ebook;
  final List<ChapterAudioModel> chapters;
  final int currentIndex;
  final AudioPlaybackState playbackState;
  final Duration position;
  final Duration duration;
  final bool isShuffleEnabled;
  final AudioRepeatMode repeatMode;
  final String? error;
  final bool isChapterListVisible;

  const AudioPlayerState({
    this.ebook,
    this.chapters = const [],
    this.currentIndex = 0,
    this.playbackState = AudioPlaybackState.initial,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.isShuffleEnabled = false,
    this.repeatMode = AudioRepeatMode.none,
    this.error,
    this.isChapterListVisible = false,
  });

  AudioPlayerState copyWith({
    PurchasedEbookDataModel? ebook,
    List<ChapterAudioModel>? chapters,
    int? currentIndex,
    AudioPlaybackState? playbackState,
    Duration? position,
    Duration? duration,
    bool? isShuffleEnabled,
    AudioRepeatMode? repeatMode,
    String? error,
    bool? isChapterListVisible,
  }) {
    return AudioPlayerState(
      ebook: ebook ?? this.ebook,
      chapters: chapters ?? this.chapters,
      currentIndex: currentIndex ?? this.currentIndex,
      playbackState: playbackState ?? this.playbackState,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      isShuffleEnabled: isShuffleEnabled ?? this.isShuffleEnabled,
      repeatMode: repeatMode ?? this.repeatMode,
      error: error,
      isChapterListVisible: isChapterListVisible ?? this.isChapterListVisible,
    );
  }
}

// audio_player/bloc/audio_player_event.dart
abstract class AudioPlayerEvent {}

class InitAudioPlayer extends AudioPlayerEvent {
  final PurchasedEbookDataModel ebook;
  InitAudioPlayer(this.ebook);
}

class PlayAudioChapter extends AudioPlayerEvent {
  final int index;
  PlayAudioChapter(this.index);
}

class PauseAudio extends AudioPlayerEvent {}
class ResumeAudio extends AudioPlayerEvent {}

class SeekAudioTo extends AudioPlayerEvent {
  final Duration position;
  SeekAudioTo(this.position);
}

class PlayNextChapter extends AudioPlayerEvent {}
class PlayPreviousChapter extends AudioPlayerEvent {}
class ToggleAudioShuffle extends AudioPlayerEvent {}
class ToggleAudioRepeat extends AudioPlayerEvent {}
class ToggleChapterList extends AudioPlayerEvent {}

// audio_player/bloc/audio_player_bloc.dart
class AudioPlayerBloc extends Bloc<AudioPlayerEvent, AudioPlayerState> {
  final AudioPlayer _audioPlayer;
  final _playlist = ConcatenatingAudioSource(children: []);

  StreamSubscription<PlayerState>? _playerStateSubscription;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<Duration?>? _durationSubscription;
  StreamSubscription<int?>? _currentIndexSubscription;
  StreamSubscription<SequenceState?>? _sequenceStateSubscription;

  AudioPlayerBloc() :
        _audioPlayer = AudioPlayer(),
        super(const AudioPlayerState()) {
    _registerEventHandlers();
    _initializeStreams();
  }

  void _registerEventHandlers() {
    on<InitAudioPlayer>(_onInitAudioPlayer);
    on<PlayAudioChapter>(_onPlayAudioChapter);
    on<PauseAudio>(_onPauseAudio);
    on<ResumeAudio>(_onResumeAudio);
    on<SeekAudioTo>(_onSeekAudioTo);
    on<PlayNextChapter>(_onPlayNextChapter);
    on<PlayPreviousChapter>(_onPlayPreviousChapter);
    on<ToggleAudioShuffle>(_onToggleAudioShuffle);
    on<ToggleAudioRepeat>(_onToggleAudioRepeat);
    on<ToggleChapterList>(_onToggleChapterList);
  }

  void _initializeStreams() {
    _playerStateSubscription = _audioPlayer.playerStateStream.listen((playerState) {
      final isPlaying = playerState.playing;
      final processingState = playerState.processingState;

      AudioPlaybackState playbackState;
      switch (processingState) {
        case ProcessingState.loading:
        case ProcessingState.buffering:
          playbackState = AudioPlaybackState.loading;
          break;
        case ProcessingState.ready:
          playbackState = isPlaying ? AudioPlaybackState.playing : AudioPlaybackState.paused;
          break;
        case ProcessingState.completed:
          playbackState = AudioPlaybackState.completed;
          _handleAudioCompletion();
          break;
        default:
          playbackState = AudioPlaybackState.paused;
      }

      emit(state.copyWith(playbackState: playbackState));
    });

    _positionSubscription = _audioPlayer.positionStream.listen((position) {
      emit(state.copyWith(position: position));
    });

    _durationSubscription = _audioPlayer.durationStream.listen((duration) {
      emit(state.copyWith(duration: duration ?? Duration.zero));
    });

    _currentIndexSubscription = _audioPlayer.currentIndexStream.listen((index) {
      if (index != null && index != state.currentIndex) {
        emit(state.copyWith(currentIndex: index));
      }
    });

    _sequenceStateSubscription = _audioPlayer.sequenceStateStream.listen((sequenceState) {
      if (sequenceState != null) {
        emit(state.copyWith(isShuffleEnabled: sequenceState.shuffleModeEnabled));
      }
    });
  }

  Future<void> _onInitAudioPlayer(InitAudioPlayer event, Emitter<AudioPlayerState> emit) async {
    try {
      // Convert chapters to audio models
      final chapters = event.ebook.allChapters
          .map((chapter) => ChapterAudioModel.fromAllChapter(chapter, event.ebook))
          .toList();

      // Create audio sources for playlist
      final audioSources = chapters.map((chapter) =>
          AudioSource.uri(
            Uri.parse(chapter.audioUrl),
            tag: chapter.toMediaItem(),
          )
      ).toList();

      // Clear existing playlist and add new items
      await _playlist.clear();
      await _playlist.addAll(audioSources);

      // Set the audio source to the player
      await _audioPlayer.setAudioSource(_playlist, initialIndex: 0);

      emit(state.copyWith(
        ebook: event.ebook,
        chapters: chapters,
        currentIndex: 0,
        playbackState: AudioPlaybackState.paused,
      ));
    } catch (e) {
      emit(state.copyWith(
        error: 'Error initializing player: ${e.toString()}',
        playbackState: AudioPlaybackState.error,
      ));
    }
  }

  Future<void> _onPlayAudioChapter(PlayAudioChapter event, Emitter<AudioPlayerState> emit) async {
    if (event.index < 0 || event.index >= state.chapters.length) return;

    try {
      await _audioPlayer.seek(Duration.zero, index: event.index);
      await _audioPlayer.play();
    } catch (e) {
      emit(state.copyWith(
        error: 'Failed to play chapter: ${e.toString()}',
        playbackState: AudioPlaybackState.error,
      ));
    }
  }

  Future<void> _onPauseAudio(PauseAudio event, Emitter<AudioPlayerState> emit) async {
    await _audioPlayer.pause();
  }

  Future<void> _onResumeAudio(ResumeAudio event, Emitter<AudioPlayerState> emit) async {
    await _audioPlayer.play();
  }

  Future<void> _onSeekAudioTo(SeekAudioTo event, Emitter<AudioPlayerState> emit) async {
    await _audioPlayer.seek(event.position);
  }

  Future<void> _onPlayNextChapter(PlayNextChapter event, Emitter<AudioPlayerState> emit) async {
    await _audioPlayer.seekToNext();
  }

  Future<void> _onPlayPreviousChapter(PlayPreviousChapter event, Emitter<AudioPlayerState> emit) async {
    await _audioPlayer.seekToPrevious();
  }

  Future<void> _onToggleAudioShuffle(ToggleAudioShuffle event, Emitter<AudioPlayerState> emit) async {
    final enable = !state.isShuffleEnabled;
    if (enable) {
      await _audioPlayer.shuffle();
    }
    await _audioPlayer.setShuffleModeEnabled(enable);
  }

  Future<void> _onToggleAudioRepeat(ToggleAudioRepeat event, Emitter<AudioPlayerState> emit) async {
    LoopMode nextLoopMode;
    AudioRepeatMode nextRepeatMode;

    switch (_audioPlayer.loopMode) {
      case LoopMode.off:
        nextLoopMode = LoopMode.one;
        nextRepeatMode = AudioRepeatMode.single;
        break;
      case LoopMode.one:
        nextLoopMode = LoopMode.all;
        nextRepeatMode = AudioRepeatMode.all;
        break;
      case LoopMode.all:
        nextLoopMode = LoopMode.off;
        nextRepeatMode = AudioRepeatMode.none;
        break;
    }

    await _audioPlayer.setLoopMode(nextLoopMode);
    emit(state.copyWith(repeatMode: nextRepeatMode));
  }

  void _onToggleChapterList(ToggleChapterList event, Emitter<AudioPlayerState> emit) {
    emit(state.copyWith(isChapterListVisible: !state.isChapterListVisible));
  }

  Future<void> _handleAudioCompletion() async {
    if (state.repeatMode == AudioRepeatMode.single) {
      add(PlayAudioChapter(state.currentIndex));
    } else if (state.repeatMode == AudioRepeatMode.all &&
        state.currentIndex < state.chapters.length - 1) {
      add(PlayNextChapter());
    } else if (state.currentIndex < state.chapters.length - 1) {
      add(PlayNextChapter());
    }
  }

  @override
  Future<void> close() async {
    await _playerStateSubscription?.cancel();
    await _positionSubscription?.cancel();
    await _durationSubscription?.cancel();
    await _currentIndexSubscription?.cancel();
    await _sequenceStateSubscription?.cancel();
    await _audioPlayer.dispose();
    return super.close();
  }
}
