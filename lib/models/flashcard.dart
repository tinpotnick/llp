import 'package:uuid/uuid.dart';

/// A flashcard represents a single card in a deck - this defines the actual
/// url of the audio file, the text and translation of the card and the start

class Flashcard {
  final String uuid;
  final String text;
  final String translation;
  final String audioUrl;
  final Duration start;
  final Duration end;

  Flashcard({
    String? uuid,
    required this.text,
    required this.translation,
    required this.audioUrl,
    required this.start,
    required this.end,
  }) : uuid = uuid ?? Uuid().v4();

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'text': text,
      'translation': translation,
      'audioUrl': audioUrl,
      'start': start.inMilliseconds,
      'end': end.inMilliseconds,
    };
  }

//Arabic (Levantine) Language: Level 2 Part 1 - Evening Course
  static Flashcard fromJson(Map<String, dynamic> json) {
    return Flashcard(
        uuid: json['uuid'],
        text: json['text'],
        translation: json['translation'],
        audioUrl: json['audioUrl'],
        start: Duration(milliseconds: json['start']),
        end: Duration(milliseconds: json['end']));
  }
}
