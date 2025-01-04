import 'dart:math' as math;
import 'package:uuid/uuid.dart';

///
/// A user card status storeds a users progress against a defined flash card
/// when it is next due for review and how many attempts have been made etc

class UserFlashcardStatus {
  final String uuid;
  final String flashcardUuid;
  DateTime lastReviewed;
  DateTime nextDue;
  int interval; // days
  int attempts;

  UserFlashcardStatus({
    String? uuid,
    required this.flashcardUuid,
    required this.lastReviewed,
    required this.nextDue,
    this.interval = 1,
    this.attempts = 0,
  }) : uuid = uuid ?? Uuid().v4();

  Map<String, dynamic> toJson() {
    return {
      'flashcardUuid': flashcardUuid,
      'lastReviewed': lastReviewed.toIso8601String(),
      'nextDue': nextDue.toIso8601String(),
      'interval': interval,
      'attempts': attempts
    };
  }

  factory UserFlashcardStatus.fromJson(Map<String, dynamic> json) {
    return UserFlashcardStatus(
      flashcardUuid: json['flashcardUuid'],
      lastReviewed: DateTime.parse(json['lastReviewed']),
      nextDue: DateTime.parse(json['nextDue']),
      interval: json['interval'] ?? 1,
      attempts: json['attempts'] ?? 0,
    );
  }

  // Update the status based on grading
  void updateStatus(String grade) {
    final now = DateTime.now();

    // Adjust interval based on grade
    switch (grade) {
      case 'Hard':
        interval = math.max(1, (interval / 2).floor()); // Halve interval
        break;
      case 'Good':
        interval = interval + 1; // Increment interval
        break;
      case 'Easy':
        interval = interval * 2; // Double interval
        break;
      default:
        throw ArgumentError('Invalid grade');
    }

    // Update review times
    lastReviewed = now;
    nextDue = now.add(Duration(days: interval));
  }
}
