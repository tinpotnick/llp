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

  UserFlashcardStatus getUserCard(String uuid) {
    return _userStatus[uuid]!;
  }

  void addOrUpdateCard(UserFlashcardStatus card) {
    _userStatus[card.uuid] = card;
    _saveToStorage();
    notifyListeners();
  }

  void addCard(UserFlashcardStatus card) => addOrUpdateCard(card);
  void updateCard(UserFlashcardStatus card) => addOrUpdateCard(card);

  void removeCard(UserFlashcardStatus card) {
    _userStatus.remove(card.uuid);
    _saveToStorage();
    notifyListeners();
  }

  Flashcard? getFlashcardForUserCard(UserFlashcardStatus userCard) {
    return flashcardProvider.getCard(userCard.flashcardUuid);
  }

  Future<void> _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final cardsJson = _userStatus.values.map((card) => card.toJson()).toList();
    await prefs.setString('flashcards', json.encode(cardsJson));
  }

  Future<void> loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final cardsJsonString = prefs.getString('usercards');
    if (cardsJsonString != null) {
      final List<dynamic> decoded = json.decode(cardsJsonString);

      _userStatus = {
        for (var json in decoded)
          Flashcard.fromJson(json).uuid: UserFlashcardStatus.fromJson(json)
      };

      notifyListeners();
    }
  }
}
