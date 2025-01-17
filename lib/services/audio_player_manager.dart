import 'dart:async';
import 'package:audioplayers/audioplayers.dart';

import 'package:llp/models/flashcard.dart';
import 'package:llp/models/podcast.dart';

import 'package:llp/services/podcast_service.dart';

class AudioPlayerManager {
  // Singleton instance
  static final AudioPlayerManager _instance = AudioPlayerManager._internal();
  factory AudioPlayerManager() => _instance;

  PodcastEpisode? _podcastepisode;

  // AudioPlayer instance
  final AudioPlayer _audioPlayer = AudioPlayer();

  // StreamControllers for various events
  final StreamController<Duration> _positionController =
      StreamController<Duration>.broadcast();
  final StreamController<Duration> _durationController =
      StreamController<Duration>.broadcast();
  final StreamController<PlayerState> _stateController =
      StreamController<PlayerState>.broadcast();
  final StreamController<void> _completionController =
      StreamController<void>.broadcast();

  final StreamController<Flashcard> _flashcardController =
    StreamController<Flashcard>.broadcast();

  // Streams
  Stream<Duration> get onPositionChanged => _positionController.stream;
  Stream<Duration> get onDurationChanged => _durationController.stream;
  Stream<PlayerState> get onPlayerStateChanged => _stateController.stream;
  Stream<void> get onPlayerComplete => _completionController.stream;
  Stream<Flashcard> get onFlashcardUpdate => _flashcardController.stream;

  AudioPlayerManager._internal() {
    // Listen to AudioPlayer events and broadcast via streams
    _audioPlayer.onPositionChanged.listen((position) {
      _positionController.add(position);
    });

    _audioPlayer.onDurationChanged.listen((duration) {
      if (duration.inMilliseconds > 0) {
        _durationController.add(duration);
      }
    });

    _audioPlayer.onPlayerStateChanged.listen((state) {
      _stateController.add(state);
    });

    _audioPlayer.onPlayerComplete.listen((event) {
      _completionController.add(null);
    });
  }

  bool isPlaying() {
    return _audioPlayer.state == PlayerState.playing;
  }

  bool hasEpisode() {
    return _podcastepisode != null;
  }

  PodcastEpisode getEpisode() {
    return _podcastepisode ?? PodcastEpisode.empty();
  }

  void _updateFlashcardPositions(Flashcard card) {
    _flashcardController.add(card);
  }

  Future<void> play(PodcastEpisode podcastepisode, [ Flashcard? card ]) async {

    if( podcastepisode.isEmpty() ) return;

    _podcastepisode = podcastepisode;
    final isDownloaded = await PodcastService.hasDownload(podcastepisode.audioUrl);

    if (isDownloaded) {
      final filePath =
          await PodcastService.getLocalPodcastFilePath(podcastepisode.audioUrl);
      await  _audioPlayer.play(DeviceFileSource(filePath));
    } else {
      await  _audioPlayer.play(UrlSource(podcastepisode.audioUrl));
    }
    
    if( card != null ) {
      await _audioPlayer.seek(card.start);
      // TODO and do end

      _updateFlashcardPositions(card);
    }
  }

  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
  }

  Future<void> seek(position) async {
    await _audioPlayer.seek(position);
  }

  void dispose() {
    _positionController.close();
    _durationController.close();
    _stateController.close();
    _completionController.close();
  }
}
