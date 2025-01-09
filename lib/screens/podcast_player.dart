import 'package:flutter/material.dart';
import '../widgets/podcast_player_widget.dart';
import '../widgets/flashcard_list_widget.dart';

class PodcastPlayerScreen extends StatelessWidget {
  final String audioUrl;
  final String episodeTitle;

  const PodcastPlayerScreen({super.key, 
    required this.audioUrl,
    required this.episodeTitle,
  });

  @override
  Widget build(BuildContext context) {
    Duration currentPosition = Duration.zero;

    return Scaffold(
      appBar: AppBar(
        title: Text(episodeTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            PodcastPlayerWidget(
                audioUrl: audioUrl,
                onPositionChanged: (position) {
                  currentPosition = position;
                }),
            const SizedBox(height: 20),
            Expanded(
              child: FlashcardListWidget(
                audioUrl: audioUrl,
                getPosition: () => currentPosition,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
