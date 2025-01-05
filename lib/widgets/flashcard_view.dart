import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/usercard.dart';
import 'package:provider/provider.dart';
import '../providers/usercard_provider.dart';
import 'dart:math' as math;

class FlashcardTile extends StatefulWidget {
  final UserFlashcardStatus flashcard;
  final UserCardProvider userCardProvider;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const FlashcardTile({
    required this.userCardProvider,
    required this.flashcard,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  _FlashcardTileState createState() => _FlashcardTileState();
}

class _FlashcardTileState extends State<FlashcardTile> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  Duration _currentPosition = Duration.zero;
  bool _isRevealed =
      false; // Controls whether the translation and buttons are shown

  Future<void> _playPause() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      final flashcard =
          widget.userCardProvider.getFlashcardForUserCard(widget.flashcard);

      if (flashcard == null) {
        return;
      }

      await _audioPlayer.play(UrlSource(flashcard.audioUrl));
      _audioPlayer.seek(flashcard.start);
    }

    setState(() {
      _isPlaying = !_isPlaying;
    });

    _audioPlayer.onPositionChanged.listen((position) {
      if (!mounted) return;
      final flashcard =
          widget.userCardProvider.getFlashcardForUserCard(widget.flashcard);

      if (flashcard == null) {
        return;
      }

      if (position >= flashcard.end) {
        _audioPlayer.pause();
        setState(() {
          _isPlaying = false;
          _currentPosition = flashcard.start;
        });
      } else {
        setState(() {
          _currentPosition = position;
        });
      }
    });
  }

  _gradeCard(int interval) {
    widget.flashcard.attempts += 1;

    if (interval == 0) {
      widget.flashcard.interval = 0;
    } else {
      widget.flashcard.interval = widget.flashcard.interval + interval;
    }

    widget.flashcard.lastReviewed = DateTime.now();
    widget.flashcard.nextDue = DateTime.now().add(
      Duration(days: widget.flashcard.interval),
    );

    setState(() {
      Provider.of<UserCardProvider>(context, listen: false)
          .updateCard(widget.flashcard);
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final flashcard =
        widget.userCardProvider.getFlashcardForUserCard(widget.flashcard);

    if (flashcard == null) {
      return Card();
    }

    final snippetDuration = flashcard.end - flashcard.start;

    // Ensure slider value is within range
    final sliderValue = math.max(
      0,
      math.min(
        (_currentPosition - flashcard.start).inMilliseconds.toDouble(),
        snippetDuration.inMilliseconds.toDouble(),
      ),
    );

    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              flashcard.text,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(height: 8),

            // Playback controls
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Slider(
                  value: sliderValue.toDouble(),
                  min: 0,
                  max: snippetDuration.inMilliseconds.toDouble(),
                  onChanged: (_) {}, // Slider is read-only for now
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                      onPressed: _playPause,
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 8),

            // View button and revealed content
            if (!_isRevealed)
              IconButton(
                onPressed: () {
                  setState(() {
                    _isRevealed = true;
                  });
                },
                icon: Icon(Icons.remove_red_eye),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Translation: ${flashcard.translation}'),
                  SizedBox(height: 8),
                  OverflowBar(
                    children: [
                      IconButton(
                        onPressed: () => _gradeCard(0),
                        icon: Icon(Icons.thumb_down),
                      ),
                      IconButton(
                        onPressed: () => _gradeCard(1),
                        icon: Icon(Icons.thumbs_up_down),
                      ),
                      IconButton(
                        onPressed: () => _gradeCard(2),
                        icon: Icon(Icons.thumb_up),
                      ),
                      IconButton(
                        onPressed: () => _gradeCard(3),
                        icon: Icon(Icons.sentiment_very_satisfied),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton.icon(
                        onPressed: widget.onEdit,
                        icon: Icon(Icons.edit),
                        label: Text('Edit'),
                      ),
                      ElevatedButton.icon(
                        onPressed: widget.onDelete,
                        icon: Icon(Icons.delete),
                        label: Text('Delete'),
                      ),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
