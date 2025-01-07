import 'dart:async';
import 'package:audioplayers/audioplayers.dart';

class AudioPlayerManager {
  // Singleton instance
  static final AudioPlayerManager _instance = AudioPlayerManager._internal();
  factory AudioPlayerManager() => _instance;

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

  // Streams
  Stream<Duration> get onPositionChanged => _positionController.stream;
  Stream<Duration> get onDurationChanged => _durationController.stream;
  Stream<PlayerState> get onPlayerStateChanged => _stateController.stream;
  Stream<void> get onPlayerComplete => _completionController.stream;

  AudioPlayerManager._internal() {
    // Listen to AudioPlayer events and broadcast via streams
    _audioPlayer.onPositionChanged.listen((position) {
      _positionController.add(position);
    });

    _audioPlayer.onDurationChanged.listen((duration) {
      _durationController.add(duration);
    });

    _audioPlayer.onPlayerStateChanged.listen((state) {
      _stateController.add(state);
    });

    _audioPlayer.onPlayerComplete.listen((event) {
      _completionController.add(null); // Broadcast completion event
    });
  }

  Future<void> play(source) async {
    await _audioPlayer.play(source);
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
