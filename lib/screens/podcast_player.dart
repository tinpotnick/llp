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

  void _addCard() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FlashcardEditorScreen(
          flashcard: Flashcard(
              audioUrl: widget.audioUrl,
              text: widget.episodeTitle,
              translation: '',
              start: _currentPosition - Duration(seconds: 5),
              end: _currentPosition),
        ),
      ),
    );
  }

  Future<void> _addFlashcard(BuildContext context, Flashcard flashcard) async {
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
                IconButton(
                  icon: Icon(Icons.add_task),
                  iconSize: 40,
                  onPressed: _addCard,
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
                        onTap: () => _addFlashcard(context, flashcard),
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
