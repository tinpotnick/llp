import 'package:uuid/uuid.dart';
import 'dart:math';

/// A flashcard represents a single card in a deck - this defines the actual
/// url of the audio file, the text and translation of the card and the start

class Flashcard {
  final String uuid;
  final String translation;
  /* the rss feed */
  final String podcastUrl;
  /* the content - ussually mp3 */
  final String episodeUrl;
  final Duration start;
  final Duration end;

  Flashcard({
    String? uuid,
    required this.translation,
    required this.podcastUrl,
    required this.episodeUrl,
    required start,
    required end,
  })  : uuid = uuid ?? Uuid().v4(),
        start = Duration(milliseconds: max(0, start.inMilliseconds)),
        end = Duration(milliseconds: max(0, end.inMilliseconds));

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'translation': translation,
      'podcastUrl': podcastUrl,
      'episodeUrl': episodeUrl,
      'start': start.inMilliseconds,
      'end': end.inMilliseconds,
    };
  }

  static Flashcard fromJson(Map<String, dynamic> json) {
    return Flashcard(
        uuid: json['uuid'],
        translation: json['translation'] ?? '',
        podcastUrl: json['podcastUrl'] ?? '',
        episodeUrl: json['episodeUrl'] ?? '',
        start: Duration(milliseconds: json['start'] ?? 0),
        end: Duration(milliseconds: json['end'] ?? 0));
  }
}
