import 'dart:io';
import 'package:flutter/material.dart';

import 'package:llp/services/audio_player_manager.dart';
import 'package:llp/services/podcast_service.dart';
import 'package:llp/models/podcast.dart';

import 'package:llp/widgets/subselectslider.dart';

class PodcastPlayerWidget extends StatefulWidget {
  final PodcastEpisode podcastEpisode;
  final ValueChanged<Duration> onPositionChanged;

  const PodcastPlayerWidget({super.key, 
    required this.podcastEpisode,
    required this.onPositionChanged,
  });

  @override
  PodcastPlayerWidgetState createState() => PodcastPlayerWidgetState();
}

class PodcastPlayerWidgetState extends State<PodcastPlayerWidget> {
  bool _isDownloaded = false;
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;

  Duration _selectedStart = Duration.zero;
  Duration _selectedEnd = Duration.zero;

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
      setState(() {});
    });

    AudioPlayerManager().onFlashcardUpdate.listen((card) {
      print(card.start);
      _selectedStart = card.start;
      _selectedEnd = card.end;

      if(_selectedStart >= _totalDuration) _selectedStart = _totalDuration;
      if(_selectedEnd >= _totalDuration || _selectedEnd >= _selectedStart) _totalDuration = _totalDuration;

      if (!mounted) return;
      setState(() {});
    });

    _isDownloaded = await PodcastService.hasDownload(widget.podcastEpisode.audioUrl);
    setState(() {});
  }

  Future<void> _playPause() async {
    if (AudioPlayerManager().isPlaying()) {
      await AudioPlayerManager().pause();
    } else {
      await AudioPlayerManager().play(widget.podcastEpisode);
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
          await PodcastService.getLocalPodcastFilePath(widget.podcastEpisode.audioUrl);
      final file = File(filePath);
      if (await file.exists()) await file.delete();
      setState(() => _isDownloaded = false);
    } else {
      setState(() => _isDownloading = true);
      await PodcastService.downloadPodcast(widget.podcastEpisode.audioUrl,
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentPosition > _totalDuration) {
      _currentPosition = _totalDuration;
    }

    return Column(
      mainAxisSize: MainAxisSize.min, // Ensures the column takes only the size of its children
      children: [
        Flexible(
          // Constrains the Center widget
          child: Center(
            child: Container(
              decoration: BoxDecoration(
                // color: Colors.white, // Background color
                border: Border.all(
                  color: Colors.black, // Border color
                  width: 1.0, // Border width
                ),
                borderRadius: BorderRadius.circular(5),
              ),
              child: SizedBox(
                height: 90,
                child: Row( // Main Row containing the image and all controls
                  crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch image to fill height
                  children: [
                    // Add Image on the Left Spanning All Rows
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(5),
                        bottomLeft: Radius.circular(5),
                      ), // Optional rounded corners
                      child: Image.network(
                        widget.podcastEpisode.imageUrl,
                        width: 90, // Fixed width for the image
                        fit: BoxFit.cover, // Ensure the image fills its container
                      ),
                    ),
                    Expanded(
                      // Remaining content
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: MediaQuery.of(context).size.width * 0.85, // Adjust for image width
                                  maxHeight: 30,
                                ),
                                child: SliderWithCustomTrack(
                                  value: _currentPosition.inMilliseconds.toDouble(),
                                  min: _selectedStart.inMilliseconds.toDouble(),
                                  max: _selectedEnd.inMilliseconds.toDouble(),
                                  duration: _totalDuration.inMilliseconds.toDouble(),
                                  onChanged: (value) {
                                    final newPosition = Duration(milliseconds: value.toInt());
                                    AudioPlayerManager().seek(newPosition);
                                  },
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.replay_10),
                                onPressed: _rewind,
                              ),
                              IconButton(
                                icon: Icon(AudioPlayerManager().isPlaying()
                                    ? Icons.pause
                                    : Icons.play_arrow),
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
                                      _isDownloaded ? Icons.download_done : Icons.download,
                                    ),
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
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  IconButton(
                                    onPressed: () {},
                                    icon: Icon(Icons.crop, size: 10),
                                  ),
                                  IconButton(
                                    onPressed: () {},
                                    icon: Icon(Icons.repeat),
                                  ),
                                ],
                              ),
                              IconButton(onPressed: () {}, icon: Icon(Icons.repeat)),
                            ],
                          ),
                          Text(
                            '${_currentPosition.inMinutes}:${(_currentPosition.inSeconds % 60).toString().padLeft(2, '0')} / '
                            '${_totalDuration.inMinutes}:${(_totalDuration.inSeconds % 60).toString().padLeft(2, '0')}',
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
      ],
    );
  }
}
