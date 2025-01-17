import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:llp/providers/usercard_provider.dart';
import 'package:llp/widgets/flashcard_view.dart';

class FlashcardDeckScreen extends StatefulWidget {
  const FlashcardDeckScreen({super.key});

  @override
  FlashcardDeckScreenState createState() => FlashcardDeckScreenState();
}

class FlashcardDeckScreenState extends State<FlashcardDeckScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flashcard Deck'),
      ),
      body: Consumer<UserCardProvider>(
        builder: (context, usercardProvider, child) {
          final flashcardList = usercardProvider.getDueCards();

          if (flashcardList.isEmpty) {
            return Center(child: Text('No flashcards available.'));
          }

          return ListView.builder(
            itemCount: flashcardList.length,
            itemBuilder: (context, index) {
              final flashcard = flashcardList[index];

              return FlashcardTile(
                key: ValueKey(flashcard.uuid),
                userCardProvider: usercardProvider,
                flashcard: flashcard,
                onDelete: () {
                  usercardProvider.removeCard(flashcard);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Flashcard deleted.')),
                  );
                },
                onEdit: () {
                  final flshcard =
                      usercardProvider.getFlashcardForUserCard(flashcard);
                  if (flshcard == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Flashcard not found.')),
                    );
                    return;
                  }

                },
              );
            },
          );
        },
      ),
    );
  }
}
