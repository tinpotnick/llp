import 'package:uuid/uuid.dart';
import 'dart:math';

/// A flashcard represents a single card in a deck - this defines the actual
/// url of the audio file, the text and translation of the card and the start

class Flashcard {
  final String uuid;
  final String origional;
  final String translation;
  /* the rss feed */
  final String podcastUrl;
  /* the content - ussually mp3 */
  final String episodeUrl;
  final Duration start;
  final Duration end;

  Flashcard({
    String? uuid,
    required this.origional,
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
      'origional': origional,
      'translation': translation,
      'podcastUrl': podcastUrl,
      'episodeUrl': episodeUrl,
      'start': start.inMilliseconds,
      'end': end.inMilliseconds,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true; // Check if they are the same instance in memory
    if (other.runtimeType != runtimeType) return false; // Ensure the types match
    if (other is! Flashcard) return false; // Ensure the other object is a Flashcard
    return uuid == other.uuid &&
        origional == other.origional &&
        translation == other.translation &&
        podcastUrl == other.podcastUrl &&
        episodeUrl == other.episodeUrl &&
        start == other.start &&
        end == other.end;
  }

  // Overriding `hashCode` to work with collections like Set or Map
  @override
  int get hashCode => Object.hash(
        uuid,
        origional,
        translation,
        podcastUrl,
        episodeUrl,
        start,
        end,
      );

  static Flashcard fromJson(Map<String, dynamic> json) {
    return Flashcard(
        uuid: json['uuid'],
        origional: json['origional'] ?? '',
        translation: json['translation'] ?? '',
        podcastUrl: json['podcastUrl'] ?? '',
        episodeUrl: json['episodeUrl'] ?? '',
        start: Duration(milliseconds: json['start'] ?? 0),
        end: Duration(milliseconds: json['end'] ?? 0));
  }
}
