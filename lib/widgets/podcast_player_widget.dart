import 'dart:io';

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

import '../services/audio_player_manager.dart';
import '../services/podcast_service.dart';

class PodcastPlayerWidget extends StatefulWidget {
  final String audioUrl;
  final ValueChanged<Duration> onPositionChanged;

  const PodcastPlayerWidget({
    required this.audioUrl,
    required this.onPositionChanged,
  });

  @override
  _PodcastPlayerWidgetState createState() => _PodcastPlayerWidgetState();
}

class _PodcastPlayerWidgetState extends State<PodcastPlayerWidget> {
  bool _isPlaying = false;
  bool _isDownloaded = false;
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _initAudio();
  }

  Future<void> _initAudio() async {
    AudioPlayerManager().onPositionChanged.listen((position) {
      widget.onPositionChanged(position);
      if (!mounted) return;
      setState(() {
        _currentPosition = position;
      });
    });

    AudioPlayerManager().onDurationChanged.listen((duration) {
      if (!mounted) return;
      setState(() {
        _totalDuration = duration;
      });
    });

    AudioPlayerManager().onPlayerStateChanged.listen((state) {
      if (!mounted) return;
      setState(() {
        _isPlaying = state == PlayerState.playing;
      });
    });

    _isDownloaded = await PodcastService.hasDownload(widget.audioUrl);
    setState(() {});
  }

  Future<void> _playPause() async {
    if (_isPlaying) {
      await AudioPlayerManager().pause();
    } else {
      if (_isDownloaded) {
        final filePath =
            await PodcastService.getLocalPodcastFilePath(widget.audioUrl);
        await AudioPlayerManager().play(DeviceFileSource(filePath));
      } else {
        await AudioPlayerManager().play(UrlSource(widget.audioUrl));
      }
    }
  }

  Future<void> _rewind() async {
    final newPosition = _currentPosition - const Duration(seconds: 10);
    await AudioPlayerManager().seek(newPosition);
  }

  Future<void> _fastForward() async {
    final newPosition = _currentPosition + const Duration(seconds: 10);
    await AudioPlayerManager().seek(newPosition);
  }

  Future<void> _toggleDownload() async {
    if (!mounted) return;
    if (_isDownloaded) {
      final filePath =
          await PodcastService.getLocalPodcastFilePath(widget.audioUrl);
      final file = File(filePath);
      if (await file.exists()) await file.delete();
      setState(() => _isDownloaded = false);
    } else {
      setState(() => _isDownloading = true);
      await PodcastService.downloadPodcast(widget.audioUrl,
          onProgress: (progress) {
        setState(() => _downloadProgress = progress);
      });
      setState(() {
        _isDownloaded = true;
        _isDownloading = false;
      });
    }
  }

  @override
  void dispose() {
    AudioPlayerManager().pause();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentPosition > _totalDuration) {
      _currentPosition = _totalDuration;
    }

    return Column(
      children: [
        Slider(
          value: _currentPosition.inMilliseconds.toDouble(),
          min: 0,
          max: _totalDuration.inMilliseconds.toDouble(),
          onChanged: (value) {
            final newPosition = Duration(milliseconds: value.toInt());
            AudioPlayerManager().seek(newPosition);
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.replay_10),
              onPressed: _rewind,
            ),
            IconButton(
              icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
              onPressed: _playPause,
            ),
            IconButton(
              icon: const Icon(Icons.forward_10),
              onPressed: _fastForward,
            ),
            Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: Icon(
                      _isDownloaded ? Icons.download_done : Icons.download),
                  onPressed: _toggleDownload,
                ),
                if (_isDownloading)
                  SizedBox(
                    height: 48, // Match IconButton size
                    width: 48,
                    child: CircularProgressIndicator(
                      value: _downloadProgress,
                    ),
                  ),
              ],
            ),
          ],
        ),
        Text(
          '${_currentPosition.inMinutes}:${(_currentPosition.inSeconds % 60).toString().padLeft(2, '0')} / '
          '${_totalDuration.inMinutes}:${(_totalDuration.inSeconds % 60).toString().padLeft(2, '0')}',
        ),
      ],
    );
  }
}
