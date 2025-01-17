
import 'package:audioplayers/audioplayers.dart';

import 'package:flutter/material.dart';
import 'package:llp/models/usercard.dart';
import 'package:provider/provider.dart';
import 'package:llp/providers/usercard_provider.dart';
import 'package:llp/providers/podcast_provider.dart';
import 'package:llp/services/audio_player_manager.dart';

class FlashcardTile extends StatefulWidget {
  final UserFlashcardStatus flashcard;
  final UserCardProvider userCardProvider;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const FlashcardTile({
    super.key,
    required this.userCardProvider,
    required this.flashcard,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  State<FlashcardTile> createState() => _FlashcardTileState();
}

class _FlashcardTileState extends State<FlashcardTile> {
  bool _isPlaying = false;
  bool _isRevealed = false;

  @override
  void initState() {
    super.initState();

    AudioPlayerManager().onPlayerStateChanged.listen( ( state ) {
      setState(() {
        _isPlaying = state == PlayerState.playing;
      });
    } );
  }

  Future<void> _playPause() async {
    if (_isPlaying) {
      await AudioPlayerManager().pause();
    } else {
      final flashcard =
          widget.userCardProvider.getFlashcardForUserCard(widget.flashcard);

      if (flashcard == null) return;

      final podcast = Provider.of<PodcastProvider>(context, listen: false)
                              .getPodcast(flashcard.podcastUrl);
      final episode = Provider.of<PodcastProvider>(context, listen: false)
                              .getPodcastEpisode(podcast, flashcard.episodeUrl);

      if(episode.isEmpty()) return;

      await AudioPlayerManager().play(episode, flashcard);
    }
  }

  Future<void> _gradeCard(int interval) async {
    if (_isPlaying) {
      await AudioPlayerManager().pause();
      _isPlaying = false;
    }

    widget.flashcard.attempts += 1;

    if (interval == 0) {
      widget.flashcard.interval = 0;
      widget.flashcard.nextDue = DateTime.now();
    } else {
      widget.flashcard.interval = widget.flashcard.interval + interval;
      widget.flashcard.nextDue = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
      ).add(Duration(days: widget.flashcard.interval));
    }

    widget.flashcard.lastReviewed = DateTime.now();

    setState(() {
      Provider.of<UserCardProvider>(context, listen: false)
          .updateCard(widget.flashcard);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final flashcard =
        widget.userCardProvider.getFlashcardForUserCard(widget.flashcard);

    if (flashcard == null) {
      return Card();
    }

    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Playback controls
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                      onPressed: _playPause,
                    ),
                    if (!_isRevealed)
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _isRevealed = true;
                          });
                        },
                        icon: Icon(Icons.remove_red_eye),
                      )
                  ],
                ),
              ],
            ),
            SizedBox(height: 8),
            // View button and revealed content
            if (_isRevealed)
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
