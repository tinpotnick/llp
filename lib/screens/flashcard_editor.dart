import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math' as math;
import 'package:provider/provider.dart';
import '../models/flashcard.dart';
import '../models/usercard.dart';
import '../providers/flashcard_provider.dart';
import '../providers/usercard_provider.dart';

class FlashcardEditorScreen extends StatefulWidget {
  final Flashcard flashcard;

  const FlashcardEditorScreen({
    required this.flashcard,
  });

  @override
  _FlashcardEditorScreenState createState() => _FlashcardEditorScreenState();
}

class _FlashcardEditorScreenState extends State<FlashcardEditorScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  late TextEditingController _translationController;
  late TextEditingController _startController;
  late TextEditingController _endController;

  bool _isPlaying = false;
  Duration _currentPosition = Duration.zero;

  @override
  void initState() {
    super.initState();
    _translationController =
        TextEditingController(text: widget.flashcard.translation);
    _startController = TextEditingController(
        text: (widget.flashcard.start.inMilliseconds / 1000.0)
            .toStringAsFixed(2));
    _endController = TextEditingController(
        text:
            (widget.flashcard.end.inMilliseconds / 1000.0).toStringAsFixed(2));

    _initAudio();
  }

  Future<void> _initAudio() async {
    try {
      _audioPlayer.onDurationChanged.listen((duration) {
        if (!mounted) return;
        setState(() {});
      });

      _audioPlayer.onPositionChanged.listen((position) {
        if (!mounted) return;
        setState(() {
          _currentPosition = position;
          final endpos = _getDurationFromController(_endController);
          if (_currentPosition > endpos) {
            _currentPosition = _getDurationFromController(_startController);
            _audioPlayer.seek(_currentPosition);
          }
        });
      });

      _audioPlayer.onPlayerComplete.listen((event) {
        setState(() {
          _isPlaying = false;
        });
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error initializing audio: $e')),
      );
    }

    _currentPosition = _getDurationFromController(_startController);
  }

  Duration _getDurationFromController(TextEditingController controller) {
    final seconds = double.tryParse(controller.text) ?? 0.0;
    return Duration(milliseconds: (seconds * 1000).toInt());
  }

  @override
  void dispose() {
    _audioPlayer.dispose(); // Dispose audio player
    _translationController.dispose();
    _startController.dispose();
    _endController.dispose();
    super.dispose();
  }

  Future<void> _playPause() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
      setState(() {
        _isPlaying = false;
      });
    } else {
      await _audioPlayer.play(UrlSource(widget.flashcard.audioUrl));
      _audioPlayer.seek(_currentPosition);
      if (mounted) {
        setState(() {
          _isPlaying = true;
        });
      }
    }
  }

  void _adjustTime(TextEditingController controller, double adjustment) {
    final current = double.tryParse(controller.text) ?? 0.0;
    controller.text = (current + adjustment).toStringAsFixed(2);
    setState(() {});
  }

  void _saveFlashcard() {
    final newStart = _getDurationFromController(_startController);
    final newEnd = _getDurationFromController(_endController);

    if (newStart >= newEnd) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Start time must be before end time.'),
        ),
      );
      return;
    }

    Provider.of<FlashcardProvider>(context, listen: false)
        .updateCard(widget.flashcard);

    Navigator.pop(context);
  }

  void _starFlashcard() {
    UserFlashcardStatus userflashcard;

    try {
      userflashcard = Provider.of<UserCardProvider>(context, listen: false)
          .getUserCard(widget.flashcard);
    } catch (e) {
      Provider.of<UserCardProvider>(context, listen: false)
          .addCard(widget.flashcard);
      return;
    }

    Provider.of<UserCardProvider>(context, listen: false)
        .removeCard(userflashcard);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final start = double.tryParse(_startController.text) ?? 0.0;
    final end = double.tryParse(_endController.text) ?? 0.0;

    _currentPosition = Duration(
        milliseconds: _currentPosition.inMilliseconds
            .toDouble()
            .clamp(
              start * 1000,
              end * 1000,
            )
            .toInt());

    bool isstarred = true;
    try {
      Provider.of<UserCardProvider>(context, listen: false)
          .getUserCard(widget.flashcard);
    } catch (e) {
      isstarred = false;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Flashcard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Translation field
            TextField(
              controller: _translationController,
              maxLines: 5,
              minLines: 3,
              decoration: InputDecoration(
                labelText: 'Translation',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),

            // Start and End Time Controls
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey, // Set the color of the border
                        width: 1.0, // Set the width of the border
                      ),
                      borderRadius: BorderRadius.circular(
                          4.0), // Mimic the rounded corners of OutlineInputBorder
                    ),
                    child: Text(
                      _startController.text,
                      style: TextStyle(fontSize: 16.0),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.remove),
                  onPressed: () => _adjustTime(_startController, -0.1),
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () => _adjustTime(_startController, 0.1),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey, // Set the color of the border
                        width: 1.0, // Set the width of the border
                      ),
                      borderRadius: BorderRadius.circular(
                          4.0), // Mimic the rounded corners of OutlineInputBorder
                    ),
                    child: Text(
                      _endController.text,
                      style: TextStyle(fontSize: 16.0),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.remove),
                  onPressed: () => _adjustTime(_endController, -0.1),
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () => _adjustTime(_endController, 0.1),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Playback Slider
            Slider(
              value: _currentPosition.inMilliseconds.toDouble(),
              min: start * 1000,
              max: end * 1000,
              onChanged: (value) {
                final newPosition = Duration(milliseconds: value.toInt());
                _audioPlayer.seek(newPosition);
                setState(() {
                  _currentPosition = newPosition;
                });
              },
            ),
            Text(
              'Position: ${_currentPosition.inMilliseconds / 1000.0}s',
            ),
            SizedBox(height: 8),

            // Play/Pause Button
            Row(
              children: [
                IconButton(
                  onPressed: _playPause,
                  icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                ),
                IconButton(
                  onPressed: _saveFlashcard,
                  icon: Icon(Icons.save),
                ),
                IconButton(
                  onPressed: _starFlashcard,
                  icon:
                      Icon(isstarred ? Icons.star : Icons.star_border_outlined),
                ),
              ],
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
