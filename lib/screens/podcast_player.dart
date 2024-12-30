import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:provider/provider.dart';
import '../providers/flashcard_provider.dart';

class PodcastPlayerScreen extends StatefulWidget {
  final String audioUrl;
  final String episodeTitle;

  const PodcastPlayerScreen({
    required this.audioUrl,
    required this.episodeTitle,
  });

  @override
  _PodcastPlayerScreenState createState() => _PodcastPlayerScreenState();
}

class _PodcastPlayerScreenState extends State<PodcastPlayerScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final TextEditingController _translationController = TextEditingController();
  bool _isPlaying = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  Duration? _startTimestamp;
  Duration? _endTimestamp;

  @override
  void initState() {
    super.initState();
    _initAudio();
  }

  Future<void> _initAudio() async {
    try {
      _audioPlayer.onPositionChanged.listen((position) {
        setState(() {
          _currentPosition = position;
        });
      });

      _audioPlayer.onDurationChanged.listen((duration) {
        setState(() {
          _totalDuration = duration;
        });
      });

      _audioPlayer.onPlayerComplete.listen((event) {
        setState(() {
          _isPlaying = false;
          _currentPosition = Duration.zero;
        });
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error initializing audio: $e')),
      );
    }
  }

  Future<void> _playPause() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play(UrlSource(widget.audioUrl));
    }
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  Future<void> _stop() async {
    await _audioPlayer.stop();
    setState(() {
      _isPlaying = false;
      _currentPosition = Duration.zero;
    });
  }

  void _markStart() {
    setState(() {
      _startTimestamp = _currentPosition;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Start point marked: $_startTimestamp')),
    );
  }

  void _markEnd() {
    setState(() {
      _endTimestamp = _currentPosition;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('End point marked: $_endTimestamp')),
    );
  }

  void _saveFlashcard(BuildContext context) {
    if (_startTimestamp == null || _endTimestamp == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please mark both start and end timestamps.')),
      );
      return;
    }

    Provider.of<FlashcardProvider>(context, listen: false).addCard(
      Flashcard(
        text: widget.episodeTitle,
        translation: _translationController.text,
        audioUrl: widget.audioUrl,
        start: _startTimestamp!,
        end: _endTimestamp!,
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Flashcard saved!')),
    );

    // Clear the translation input and timestamps
    setState(() {
      _translationController.clear();
      _startTimestamp = null;
      _endTimestamp = null;
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _translationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.episodeTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Display playback progress
            Slider(
              value: _currentPosition.inMilliseconds.toDouble(),
              max: _totalDuration.inMilliseconds.toDouble(),
              onChanged: (value) {
                final newPosition = Duration(milliseconds: value.toInt());
                _audioPlayer.seek(newPosition);
                setState(() {
                  _currentPosition = newPosition;
                });
              },
            ),
            Text(
              '${_currentPosition.inMinutes}:${_currentPosition.inSeconds.remainder(60).toString().padLeft(2, '0')} / '
              '${_totalDuration.inMinutes}:${_totalDuration.inSeconds.remainder(60).toString().padLeft(2, '0')}',
            ),
            SizedBox(height: 20),

            // Playback controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.stop),
                  iconSize: 40,
                  onPressed: _stop,
                ),
                IconButton(
                  icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                  iconSize: 40,
                  onPressed: _playPause,
                ),
              ],
            ),
            SizedBox(height: 20),

            // Flashcard controls
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _markStart,
                  child: Text('Mark Start'),
                ),
                ElevatedButton(
                  onPressed: _markEnd,
                  child: Text('Mark End'),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Translation input
            TextField(
              controller: _translationController,
              decoration: InputDecoration(
                labelText: 'Translation',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),

            // Save flashcard button
            ElevatedButton(
              onPressed: () => _saveFlashcard(context),
              child: Text('Save Flashcard'),
            ),
          ],
        ),
      ),
    );
  }
}
