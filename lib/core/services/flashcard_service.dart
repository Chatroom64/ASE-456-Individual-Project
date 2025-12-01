import 'dart:async';
import '../../data/models/deck.dart';
import '../../data/models/flashcard.dart';
import 'storage_service.dart';

class FlashcardService {
  final StorageService _storage;

  FlashcardService(this._storage);

  Future<void> init() => _storage.init();

  Future<void> addDeck(Deck deck) async {
    await _storage.saveDeck(deck.id, deck.toMap());
  }

  /// Update an existing deck (saves the deck map at its id)
  Future<void> updateDeck(Deck deck) async {
    await _storage.saveDeck(deck.id, deck.toMap());
  }

  /// Delete a single card from a deck
  Future<void> deleteCard(String deckId, String cardId) async {
    final current = await getDeckById(deckId);
    if (current == null) return;
    current.removeCard(cardId);
    await updateDeck(current);
  }

  Future<List<Deck>> getAllDecks() async {
    final raw = await _storage.getAllDecks(); // List<Map<String,dynamic>>
    return raw.map((m) => Deck.fromMap(m)).toList();
  }

  Future<Deck?> getDeckById(String deckId) async {
    final map = await _storage.getDeck(deckId);
    if (map == null) return null;
    return Deck.fromMap(map);
  }

  Future<void> deleteDeck(String deckId) async {
    await _storage.deleteDeck(deckId);
  }

  /// Convenience: add a flashcard to an existing deck and persist
  Future<void> addCardToDeck(String deckId, Flashcard card) async {
    final current = await getDeckById(deckId);
    if (current == null) return;
    current.addCard(card);
    await updateDeck(current);
  }
}
