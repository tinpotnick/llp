import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:llp/models/flashcard.dart';
import 'package:llp/models/podcast.dart';
import 'package:llp/models/usercard.dart';
import 'package:llp/providers/flashcard_provider.dart';
import 'package:llp/providers/usercard_provider.dart';
import 'package:llp/screens/flashcard_editor.dart';

class FlashcardListWidget extends StatefulWidget {
  final PodcastEpisode episode;
  final Duration Function() getPosition;

  const FlashcardListWidget({
    super.key,
    required this.episode,
    required this.getPosition,
  });

  @override
  FlashcardListWidgetState createState() => FlashcardListWidgetState();
}

class FlashcardListWidgetState extends State<FlashcardListWidget> {
  // No additional fields for state are needed in this case since the original
  // code relies on Provider for state management. If needed,
  // you can introduce internal variables or states here.

  void _editFlashcard(BuildContext context, Flashcard flashcard) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FlashcardEditorScreen(
          flashcard: flashcard,
          episode: widget.episode,
        ),
      ),
    );
  }

  Future<void> _removeFlashcard(BuildContext context, Flashcard flashcard) async {
    try {
      UserFlashcardStatus userflashcard =
          Provider.of<UserCardProvider>(context, listen: false)
              .getUserCard(flashcard);

      Provider.of<UserCardProvider>(context, listen: false)
          .removeCard(userflashcard);
    } catch (e) {
      /* silent */
    }

    Provider.of<FlashcardProvider>(context, listen: false)
        .removeCard(flashcard.uuid);

    setState(() {});
  }

  Future<void> _starFlashcard(BuildContext context, Flashcard flashcard) async {
    UserFlashcardStatus userflashcard;

    try {
      userflashcard = Provider.of<UserCardProvider>(context, listen: false)
          .getUserCard(flashcard);
    } catch (e) {
      Provider.of<UserCardProvider>(context, listen: false)
          .addCard(flashcard);
      return;
    }
    Provider.of<UserCardProvider>(context, listen: false)
        .removeCard(userflashcard);

    setState(() {});
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
                  flashcardProvider.getFlashcardsForEpisode(widget.episode);

              if (flashcards.isEmpty) {
                return const Center(
                  child: Text("No flashcards added yet."),
                );
              }
              return ListView.builder(
                itemCount: flashcards.length,
                itemBuilder: (context, index) {
                  final flashcard = flashcards[index];

                  bool isStarred = Provider.of<UserCardProvider>(context).hasCard(flashcard);

                  return ListTile(
                    title: Text(""),
                    subtitle: Text(flashcard.translation),
                    onTap: () => _editFlashcard(context, flashcard),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min, // Ensures the row takes up only as much space as it needs
                      children: [
                        Text(
                          '${flashcard.start.inMinutes}:${flashcard.start.inSeconds.remainder(60).toString().padLeft(2, '0')} - '
                          '${flashcard.end.inMinutes}:${flashcard.end.inSeconds.remainder(60).toString().padLeft(2, '0')}',
                        ),
                        const SizedBox(width: 8), // Add some spacing between the text and the button
                        IconButton(
                          onPressed: () => _starFlashcard(context, flashcard),
                          icon: Icon(
                            isStarred ? Icons.star : Icons.star_border_outlined,
                          ),
                        ),
                        const SizedBox(width: 8), // Add some spacing between the text and the button
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removeFlashcard(context, flashcard),
                        ),
                      ],
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