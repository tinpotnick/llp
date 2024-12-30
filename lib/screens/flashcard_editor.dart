import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math' as math;
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

    _audioPlayer.onPositionChanged.listen((position) {
      if (!mounted) return; // Prevent setState if widget is disposed
      setState(() {
        _currentPosition = position;
      });

      final start = _getDurationFromController(_startController);
      final end = _getDurationFromController(_endController);

      if (_currentPosition >= end || _currentPosition < start) {
        _audioPlayer.pause();
        if (mounted) {
          setState(() {
            _isPlaying = false;
          });
        }
      }
    });
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
    final start = _getDurationFromController(_startController);
    final end = _getDurationFromController(_endController);

    if (_isPlaying) {
      await _audioPlayer.pause();
      setState(() {
        _isPlaying = false;
      });
    } else {
      await _audioPlayer.play(UrlSource(widget.flashcard.audioUrl));
      _audioPlayer.seek(start);
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

  @override
  Widget build(BuildContext context) {
    final start = double.tryParse(_startController.text) ?? 0.0;
    final end = double.tryParse(_endController.text) ?? 0.0;
    final snippetDuration = math.max(0, end - start).toDouble();

    // Ensure slider value is within bounds
    final sliderValue = math
        .max(
          0,
          math.min(
            (_currentPosition.inMilliseconds / 1000.0 - start),
            snippetDuration,
          ),
        )
        .toDouble();

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
                  child: TextField(
                    controller: _startController,
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Start (seconds)',
                      border: OutlineInputBorder(),
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
                  child: TextField(
                    controller: _endController,
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'End (seconds)',
                      border: OutlineInputBorder(),
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
              value: sliderValue,
              min: 0.0,
              max: snippetDuration,
              onChanged: (_) {},
            ),
            Text(
              'Position: ${_currentPosition.inMilliseconds / 1000.0}s',
            ),
            SizedBox(height: 8),

            // Play/Pause Button
            Row(
              children: [
                ElevatedButton(
                  onPressed: _playPause,
                  child: Text(_isPlaying ? 'Pause' : 'Play'),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Save Button
            ElevatedButton(
              onPressed: () {
                final newStart = _getDurationFromController(_startController);
                final newEnd = _getDurationFromController(_endController);

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
