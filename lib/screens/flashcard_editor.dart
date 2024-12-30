import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/flashcard_provider.dart';

class FlashcardEditorScreen extends StatefulWidget {
  final int index;
  final Flashcard flashcard;

  const FlashcardEditorScreen({
    required this.index,
    required this.flashcard,
  });

  @override
  _FlashcardEditorScreenState createState() => _FlashcardEditorScreenState();
}

class _FlashcardEditorScreenState extends State<FlashcardEditorScreen> {
  late TextEditingController _translationController;
  late TextEditingController _startController;
  late TextEditingController _endController;

  @override
  void initState() {
    super.initState();
    _translationController =
        TextEditingController(text: widget.flashcard.translation);
    _startController = TextEditingController(
        text: widget.flashcard.start.inSeconds.toString());
    _endController =
        TextEditingController(text: widget.flashcard.end.inSeconds.toString());
  }

  @override
  void dispose() {
    _translationController.dispose();
    _startController.dispose();
    _endController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Flashcard')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _translationController,
              decoration: InputDecoration(labelText: 'Translation'),
            ),
            TextField(
              controller: _startController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Start (seconds)'),
            ),
            TextField(
              controller: _endController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'End (seconds)'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final newStart =
                    Duration(seconds: int.parse(_startController.text));
                final newEnd =
                    Duration(seconds: int.parse(_endController.text));

                if (newStart >= newEnd) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Start time must be before end time.')),
                  );
                  return;
                }

                Provider.of<FlashcardProvider>(context, listen: false)
                    .updateCard(
                  widget.index,
                  Flashcard(
                    text: widget.flashcard.text,
                    translation: _translationController.text,
                    audioUrl: widget.flashcard.audioUrl,
                    start: newStart,
                    end: newEnd,
                  ),
                );

                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
