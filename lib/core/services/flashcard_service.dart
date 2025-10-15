import 'dart:async';
import '../../data/models/deck.dart';
import '../../data/models/flashcard.dart';
import 'storage_service.dart';


class FlashcardService {
  final StorageService _storage;

  FlashcardService(this._storage);
  

  Future<void> init() => _storage.init();

  Future<void> addDeck(Deck deck) async {
    await _storage.saveDeck(deck.id, deck.toJson());
  }

  /// Update an existing deck (saves the deck JSON at its id)
  Future<void> updateDeck(Deck deck) async {
    await _storage.saveDeck(deck.id, deck.toJson());
  }
  // Attempt to delete a single card
  Future<void> deleteCard(String deckId, String cardId) async {
  final current = await getDeckById(deckId);
  if (current == null) return;
  current.removeCard(cardId); // removes only that card
  await updateDeck(current);
  }


  Future<List<Deck>> getAllDecks() async {
    final raw = _storage.getAllDecks(); // List<Map<String,dynamic>>
    return raw.map((m) => Deck.fromJson(m)).toList();
  }

  Future<Deck?> getDeckById(String deckId) async {
    final map = _storage.getDeck(deckId);
    if (map == null) return null;
    return Deck.fromJson(map);
  }

  Future<void> deleteDeck(String deckId) async {
    await _storage.deleteDeck(deckId);
  }

  // convenience: add a flashcard to an existing deck and persist
  Future<void> addCardToDeck(String deckId, Flashcard card) async {
    final current = await getDeckById(deckId);
    if (current == null) return;
    current.addCard(card);
    await updateDeck(current);
  }
}
