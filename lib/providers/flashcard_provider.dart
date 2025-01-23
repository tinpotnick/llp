import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:llp/models/flashcard.dart';
import 'package:llp/models/podcast.dart';

class FlashcardProvider with ChangeNotifier {
  Map<String, Flashcard> _allCards = {};

  Map<String, Flashcard> get cards => _allCards;

  Flashcard getCard(String uuid) {
    return _allCards[uuid]!;
  }

  List<Flashcard> getFlashcardsForEpisode(PodcastEpisode ep) {
    return _allCards.values.where((card) => card.episodeUrl == ep.audioUrl).toList();
  }

  void addOrUpdateCard(Flashcard card) {
    _allCards[card.uuid] = card;
    _saveToStorage();
    notifyListeners();
  }

  void addCard(Flashcard card) => addOrUpdateCard(card);
  void updateCard(Flashcard card) => addOrUpdateCard(card);

  bool hasCard(String uuid) {
    return _allCards.containsKey(uuid);
  }

  void removeCard(String uuid) {
    _allCards.remove(uuid);
    _saveToStorage();
    notifyListeners();
  }

  Future<void> _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final cardsJson = _allCards.values.map((card) => card.toJson()).toList();
    await prefs.setString('flashcards', json.encode(cardsJson));
  }

  Future<void> loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final cardsJsonString = prefs.getString('flashcards');
    if (cardsJsonString != null) {
      final List<dynamic> decoded = json.decode(cardsJsonString);

      // Populate _allCards as a Map using uuid as the key
      _allCards = {
        for (var json in decoded)
          Flashcard.fromJson(json).uuid: Flashcard.fromJson(json)
      };

      notifyListeners();
    }
  }
}
