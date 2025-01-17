import 'package:flutter/material.dart';

import 'package:llp/widgets/podcast_player_widget.dart';
import 'package:llp/widgets/flashcard_list_widget.dart';

import 'package:llp/models/podcast.dart';

class PodcastPlayerScreen extends StatelessWidget {
  final PodcastEpisode podcastEpisode;

  const PodcastPlayerScreen({super.key, 
    required this.podcastEpisode
  });

  @override
  Widget build(BuildContext context) {
    Duration currentPosition = Duration.zero;

    return Scaffold(
      appBar: AppBar(
        title: Text(podcastEpisode.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            PodcastPlayerWidget(
                podcastEpisode: podcastEpisode,
                onPositionChanged: (position) {
                  currentPosition = position;
                }),
            const SizedBox(height: 20),
            Expanded(
              child: FlashcardListWidget(
                episode: podcastEpisode,
                getPosition: () => currentPosition,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
