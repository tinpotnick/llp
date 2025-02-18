import 'package:flutter/material.dart';
import 'package:llp/models/podcast.dart';
import 'package:provider/provider.dart';
import 'package:llp/models/flashcard.dart';
import 'package:llp/models/usercard.dart';
import 'package:llp/providers/flashcard_provider.dart';
import 'package:llp/providers/usercard_provider.dart';

import 'package:llp/services/audio_player_manager.dart';

class FlashcardEditorScreen extends StatefulWidget {
  final PodcastEpisode episode;
  final Flashcard flashcard;

  const FlashcardEditorScreen({super.key, 
    required this.episode,
    required this.flashcard,
  });

  @override
  FlashcardEditorScreenState createState() => FlashcardEditorScreenState();
}

class FlashcardEditorScreenState extends State<FlashcardEditorScreen> {
  late TextEditingController _origionalController;
  late TextEditingController _translationController;
  late TextEditingController _startController;
  late TextEditingController _endController;

  bool _isPlaying = false;
  Duration _currentPosition = Duration.zero;

  @override
  void initState() {
    super.initState();
    _origionalController =
        TextEditingController(text: widget.flashcard.origional);
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
      AudioPlayerManager().onDurationChanged.listen((duration) {
        if (!mounted) return;
        setState(() {});
      });

      AudioPlayerManager().onPositionChanged.listen((position) {
        if (!mounted) return;
        setState(() {
          _currentPosition = position;
          final endpos = _getDurationFromController(_endController);
          if (_currentPosition > endpos) {
            _currentPosition = _getDurationFromController(_startController);
            AudioPlayerManager().seek(_currentPosition);
          }
        });
      });

      AudioPlayerManager().onPlayerComplete.listen((event) {
        if (!mounted) return;
        setState(() {
          _isPlaying = false;
        });
      });

      await AudioPlayerManager().play(widget.episode, widget.flashcard);

      _currentPosition = _getDurationFromController(_startController);
      AudioPlayerManager().seek(_currentPosition);
      if (mounted) {
        setState(() {
          _isPlaying = true;
        });
      }
    } catch (e) {
      if(!mounted) return;
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
    _origionalController.dispose();
    _translationController.dispose();
    _startController.dispose();
    _endController.dispose();
    super.dispose();
  }

  Future<void> _playPause() async {
    if (!mounted) return;
    if (_isPlaying) {
      await AudioPlayerManager().pause();
      setState(() {
        _isPlaying = false;
      });
    } else {
      await AudioPlayerManager().play(widget.episode, widget.flashcard);
      if (mounted) {
        setState(() {
          _isPlaying = true;
        });
      }
    }
  }

  void _adjustTime(TextEditingController controller, double adjustment) {
    final current = double.tryParse(controller.text) ?? 0.0;
    double adjusted = current + adjustment;
    if (adjusted < 0) adjusted = 0;

    controller.text = adjusted.toStringAsFixed(2);
    setState(() {});
  }

  void _setTime(TextEditingController controller) {
    controller.text =
        (_currentPosition.inMilliseconds / 1000.0).toStringAsFixed(2);
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

    final flashcardprovider =
        Provider.of<FlashcardProvider>(context, listen: false);

    if (flashcardprovider.hasCard(widget.flashcard.uuid)) {
      flashcardprovider.updateCard(Flashcard(
        uuid: widget.flashcard.uuid,
        origional: _origionalController.text,
        translation: _translationController.text,
        podcastUrl: widget.flashcard.podcastUrl,
        episodeUrl: widget.flashcard.episodeUrl,
        start: newStart,
        end: newEnd,
      ));
    } else {
      final newcard = Flashcard(
        uuid: widget.flashcard.uuid,
        origional: _origionalController.text,
        translation: _translationController.text,
        podcastUrl: widget.episode.podcastUrl,
        episodeUrl: widget.episode.audioUrl,
        start: newStart,
        end: newEnd,
      );

      flashcardprovider.addCard(newcard);
      Provider.of<UserCardProvider>(context, listen: false).addCard(newcard);
    }

    Navigator.pop(context);
  }

  void _starFlashcard() {
    setState(() {
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
    });
  }

  void _removeFlashcard() {
    try {
      UserFlashcardStatus userflashcard =
          Provider.of<UserCardProvider>(context, listen: false)
              .getUserCard(widget.flashcard);

      Provider.of<UserCardProvider>(context, listen: false)
          .removeCard(userflashcard);
    } catch (e) {
      /* silent */
    }

    Provider.of<FlashcardProvider>(context, listen: false)
        .removeCard(widget.flashcard.uuid);

    Navigator.pop(context);
  }

  double _getStart() {
    final start = double.tryParse(_startController.text) ?? 0.0;
    return start * 1000;
  }

  double _getEnd() {
    double end = double.tryParse(_endController.text) ?? 0.0;
    final start = double.tryParse(_startController.text) ?? 0.0;

    if (start >= end) {
      _endController.text = (start + 1).toStringAsFixed(2);
      end = start + 1;
      setState(() {
        _endController.text = end.toStringAsFixed(2);
      });
    }

    return end * 1000;
  }

  @override
  Widget build(BuildContext context) {
    final start = double.tryParse(_startController.text) ?? 0.0;
    double end = double.tryParse(_endController.text) ?? 0.0;

    if (start >= end) {
      end = start + 1;
      _endController.text = end.toStringAsFixed(2);
    }

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
              controller: _origionalController,
              maxLines: 5,
              minLines: 3,
              decoration: InputDecoration(
                labelText: 'Origional',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
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

            // Dynamic layout for controls and slider
            LayoutBuilder(
              builder: (context, constraints) {
                bool isSmallScreen = constraints.maxWidth < 600;

                return Column(
                  children: [
                    if (isSmallScreen)
                      Column(
                        children: [
                          // Start and End Controls on one row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Start Control
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.replay_5),
                                    onPressed: () =>
                                        _adjustTime(_startController, -5),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.crop),
                                    onPressed: () => _setTime(_startController),
                                  ),
                                  Text(
                                    _startController.text,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 16.0),
                                  ),
                                ],
                              ),
                              // End Control
                              Row(
                                children: [
                                  Text(
                                    _endController.text,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 16.0),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.flag),
                                    onPressed: () => _setTime(_endController),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.forward_5),
                                    onPressed: () =>
                                        _adjustTime(_endController, 5),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 16), // Space between rows
                          // Slider in its own row
                          Slider(
                            value: _currentPosition.inMilliseconds.toDouble(),
                            min: _getStart(),
                            max: _getEnd(),
                            onChanged: (value) {
                              final newPosition =
                                  Duration(milliseconds: value.toInt());
                              AudioPlayerManager().seek(newPosition);
                              setState(() {
                                _currentPosition = newPosition;
                              });
                            },
                          ),
                        ],
                      )
                    else
                      // Wide Screen Layout
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Start Control
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.replay_5),
                                onPressed: () =>
                                    _adjustTime(_startController, -5),
                              ),
                              IconButton(
                                icon: Icon(Icons.crop),
                                onPressed: () => _setTime(_startController),
                              ),
                              Text(
                                _startController.text,
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 16.0),
                              ),
                            ],
                          ),
                          // Playback Slider
                          Expanded(
                            child: Slider(
                              value: _currentPosition.inMilliseconds.toDouble(),
                              min: start * 1000,
                              max: end * 1000,
                              onChanged: (value) {
                                final newPosition =
                                    Duration(milliseconds: value.toInt());
                                AudioPlayerManager().seek(newPosition);
                                setState(() {
                                  _currentPosition = newPosition;
                                });
                              },
                            ),
                          ),
                          // End Control
                          Row(
                            children: [
                              Text(
                                _endController.text,
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 16.0),
                              ),
                              IconButton(
                                icon: Icon(Icons.flag),
                                onPressed: () => _setTime(_endController),
                              ),
                              IconButton(
                                icon: Icon(Icons.forward_5),
                                onPressed: () => _adjustTime(_endController, 5),
                              ),
                            ],
                          ),
                        ],
                      ),
                  ],
                );
              },
            ),
            SizedBox(height: 16),
            Text(
              'Position: ${_currentPosition.inMilliseconds / 1000.0}s',
            ),
            SizedBox(height: 8),

            // Play/Pause Button
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
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
                IconButton(
                  onPressed: _removeFlashcard,
                  icon: Icon(Icons.delete_forever),
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
