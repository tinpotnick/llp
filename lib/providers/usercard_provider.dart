import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'flashcard_provider.dart';
import '../models/flashcard.dart';
import '../models/usercard.dart';

class UserCardProvider with ChangeNotifier {
  Map<String, UserFlashcardStatus> _userStatus = {};

  Map<String, UserFlashcardStatus> get userCards => _userStatus;

  final FlashcardProvider flashcardProvider;

  UserCardProvider(this.flashcardProvider);

  UserFlashcardStatus getUserCard(Flashcard card) {
    return _userStatus[card.uuid]!;
  }

  void addCard(Flashcard card) {
    _userStatus[card.uuid] = UserFlashcardStatus(
      flashcardUuid: card.uuid,
      lastReviewed: DateTime.now(),
      nextDue: DateTime.now(),
    );
    _saveToStorage();
    notifyListeners();
  }

  void updateCard(UserFlashcardStatus card) {
    _userStatus[card.flashcardUuid] = card;
    _saveToStorage();
    notifyListeners();
  }

  void removeCard(UserFlashcardStatus card) {
    _userStatus.remove(card.flashcardUuid);
    _saveToStorage();
    notifyListeners();
  }

  Flashcard? getFlashcardForUserCard(UserFlashcardStatus userCard) {
    return flashcardProvider.getCard(userCard.flashcardUuid);
  }

  Future<void> _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final cardsJson = _userStatus.values.map((card) => card.toJson()).toList();
    await prefs.setString('usercards', json.encode(cardsJson));
  }

  Future<void> loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final cardsJsonString = prefs.getString('usercards');
    if (cardsJsonString == null) {
      return;
    }

    final List<dynamic> decoded = json.decode(cardsJsonString);
    _userStatus = {};

    for (var json in decoded) {
      final usercard = UserFlashcardStatus.fromJson(json);
      _userStatus[usercard.flashcardUuid] = usercard;
    }

    notifyListeners();
  }
}
