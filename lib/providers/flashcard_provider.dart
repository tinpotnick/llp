import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Flashcard {
  final String text;
  final String translation;
  final String audioUrl;
  final Duration start;
  final Duration end;
  String status;

  Flashcard({
    required this.text,
    required this.translation,
    required this.audioUrl,
    required this.start,
    required this.end,
    this.status = 'Review',
  });

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'translation': translation,
      'audioUrl': audioUrl,
      'start': start.inMilliseconds,
      'end': end.inMilliseconds,
      'status': status,
    };
  }

  static Flashcard fromJson(Map<String, dynamic> json) {
    return Flashcard(
      text: json['text'],
      translation: json['translation'],
      audioUrl: json['audioUrl'],
      start: Duration(milliseconds: json['start']),
      end: Duration(milliseconds: json['end']),
      status: json['status'] ?? 'Review',
    );
  }
}

class FlashcardProvider with ChangeNotifier {
  List<Flashcard> _allCards = [];

  List<Flashcard> get cards => _allCards;

  void addCard(Flashcard card) {
    _allCards.add(card);
    _saveToStorage();
    notifyListeners();
  }

  void removeCard(int index) {
    _allCards.removeAt(index);
    _saveToStorage();
    notifyListeners();
  }

  void updateCard(int index, Flashcard updatedCard) {
    if (index < 0 || index > _allCards.length) {
      return;
    }

    _allCards[index] = updatedCard;
    notifyListeners(); // Notify listeners about the update
    _saveToStorage(); // Save the updated list to storage
  }

  void updateCardStatus(int index, String newStatus) {
    _allCards[index].status = newStatus;
    _saveToStorage();
    notifyListeners();
  }

  List<Flashcard> filteredCards(String status) {
    if (status == 'All') {
      return _allCards;
    }
    return _allCards.where((card) => card.status == status).toList();
  }

  Future<void> _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final cardsJson = _allCards.map((card) => card.toJson()).toList();
    await prefs.setString('flashcards', json.encode(cardsJson));
  }

  Future<void> loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final cardsJsonString = prefs.getString('flashcards');
    if (cardsJsonString != null) {
      final List<dynamic> decoded = json.decode(cardsJsonString);
      _allCards = decoded.map((json) => Flashcard.fromJson(json)).toList();
      notifyListeners();
    }
  }
}
