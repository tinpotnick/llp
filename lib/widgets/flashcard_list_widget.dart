import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:llp/models/flashcard.dart';
import 'package:llp/models/podcast.dart';
import 'package:llp/providers/flashcard_provider.dart';
import 'package:llp/screens/flashcard_editor.dart';

class FlashcardListWidget extends StatelessWidget {
  final PodcastEpisode episode;
  final Duration Function() getPosition;

  const FlashcardListWidget({
    super.key, 
    required this.episode,
    required this.getPosition,
  });

  void _editFlashcard(BuildContext context, Flashcard flashcard) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FlashcardEditorScreen(flashcard: flashcard, episode: episode),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Consumer<FlashcardProvider>(
            builder: (context, flashcardProvider, child) {
              final flashcards =
                  flashcardProvider.getFlashcardsForEpisode(episode);
              if (flashcards.isEmpty) {
                return const Center(
                  child: Text("No flashcards added yet."),
                );
              }
              return ListView.builder(
                itemCount: flashcards.length,
                itemBuilder: (context, index) {
                  final flashcard = flashcards[index];
                  return ListTile(
                    title: Text(""),
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
    );
  }
}
