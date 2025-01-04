import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:provider/provider.dart';

import '../models/flashcard.dart';
import '../providers/flashcard_provider.dart';

import 'flashcard_editor.dart';

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
        if (!mounted) return;
        setState(() {
          _currentPosition = position;
        });
      });

      _audioPlayer.onDurationChanged.listen((duration) {
        if (!mounted) return;
        setState(() {
          _totalDuration = duration;
        });
      });

      _audioPlayer.onPlayerComplete.listen((event) {
        if (!mounted) return;
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

  Future<void> _rewind() {
    final newPosition = Duration(
      milliseconds: _currentPosition.inMilliseconds - 10000,
    );
    return _audioPlayer.seek(newPosition);
  }

  Future<void> _fastForward() {
    final newPosition = Duration(
      milliseconds: _currentPosition.inMilliseconds + 10000,
    );
    return _audioPlayer.seek(newPosition);
  }

  Future<void> _addFlashcard() async {
    if (_isPlaying) {
      await _playPause();
    }

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FlashcardEditorScreen(
          flashcard: Flashcard(
              text: '',
              translation: '',
              audioUrl: widget.audioUrl,
              start: _currentPosition - Duration(seconds: 5),
              end: _currentPosition),
        ),
      ),
    );
  }

  Future<void> _editFlashcard(BuildContext context, Flashcard flashcard) async {
    if (_isPlaying) {
      await _playPause();
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FlashcardEditorScreen(
          flashcard: flashcard,
        ),
      ),
    );
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
                  icon: Icon(Icons.replay_10),
                  iconSize: 40,
                  onPressed: _rewind,
                ),
                IconButton(
                  icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                  iconSize: 40,
                  onPressed: _playPause,
                ),
                IconButton(
                  icon: Icon(Icons.forward_10),
                  iconSize: 40,
                  onPressed: _fastForward,
                ),
                IconButton(
                  icon: Icon(Icons.add_task),
                  iconSize: 40,
                  onPressed: _addFlashcard,
                ),
              ],
            ),
            SizedBox(height: 20),
            // Display flashcards
            Expanded(
              child: Consumer<FlashcardProvider>(
                builder: (context, flashcardProvider, child) {
                  final flashcards = flashcardProvider
                      .getFlashcardsForEpisode(widget.audioUrl);
                  return ListView.builder(
                    itemCount: flashcards.length,
                    itemBuilder: (context, index) {
                      final flashcard = flashcards[index];
                      return ListTile(
                        title: Text(flashcard.text),
                        subtitle: Text(flashcard.translation),
                        onTap: () => _editFlashcard(context, flashcard),
                        trailing: Text(
                          '${flashcard.start.inMinutes}:${flashcard.start.inSeconds.remainder(60).toString().padLeft(2, '0')} - '
                          '${flashcard.end.inMinutes}:${flashcard.end.inSeconds.remainder(60).toString().padLeft(2, '0')}',
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
