import 'package:flutter_test/flutter_test.dart';
import 'package:uuid/uuid.dart';

import '../lib/data/models/flashcard.dart';
import '../lib/data/models/deck.dart';
import '../lib/services/flashcard_service/flashcard_service.dart';
import '../lib/services/flashcard_service/storage_service.dart';

// A fake in-memory StorageService for testing.
class FakeStorage extends StorageService {
  final Map<String, Map<String, dynamic>> _db = {};

  @override
  Future<void> init() async {}

  @override
  Future<void> saveDeck(String id, Map<String, dynamic> deckJson) async {
    _db[id] = deckJson;
  }

  @override
  Map<String, dynamic>? getDeck(String id) => _db[id];

  @override
  List<Map<String, dynamic>> getAllDecks() => _db.values.toList();

  @override
  Future<void> deleteDeck(String id) async {
    _db.remove(id);
  }
}

void main() {
  group('FLASHCARD MODEL TESTS', () {
    test('Flashcard constructor assigns fields correctly', () {
      final card = Flashcard(id: '1', front: 'A', back: 'B');
      expect(card.id, '1');
      expect(card.front, 'A');
      expect(card.back, 'B');
    });

    test('Flashcard toJson returns correct map', () {
      final card = Flashcard(id: '123', front: 'Q', back: 'A');
      expect(card.toJson(), {
        'id': '123',
        'front': 'Q',
        'back': 'A',
      });
    });

    test('Flashcard equality: two identical cards are equal', () {
      final a = Flashcard(id: '1', front: 'X', back: 'Y');
      final b = Flashcard(id: '1', front: 'X', back: 'Y');
      expect(a == b, true);
    });

    test('Flashcard equality: ids differ → not equal', () {
      final a = Flashcard(id: '1', front: 'X', back: 'Y');
      final b = Flashcard(id: '2', front: 'X', back: 'Y');
      expect(a == b, false);
    });

    test('Flashcard copyWith can replace fields', () {
      final card = Flashcard(id: '1', front: 'Old', back: 'OldB');
      final updated = card.copyWith(front: 'New');
      expect(updated.front, 'New');
      expect(updated.back, 'OldB');
    });

    test('Flashcard copyWith without changes keeps same values', () {
      final card = Flashcard(id: '1', front: 'F', back: 'B');
      final copy = card.copyWith();
      expect(copy.front, 'F');
      expect(copy.back, 'B');
    });
  });

  // ---------------------------------------------------------------
  // DECK TESTS
  // ---------------------------------------------------------------
  group('DECK MODEL TESTS', () {
    test('Deck initializes correctly', () {
      final deck = Deck(id: 'd1', title: 'My Deck', cards: []);
      expect(deck.id, 'd1');
      expect(deck.title, 'My Deck');
      expect(deck.cards.length, 0);
    });

    test('Deck fromJson reconstructs correctly', () {
      final json = {
        'id': 'd1',
        'title': 'Test Deck',
        'cards': [
          {'id': '1', 'front': 'A', 'back': 'B'},
        ]
      };
      final deck = Deck.fromJson(json);
      expect(deck.title, 'Test Deck');
      expect(deck.cards.length, 1);
      expect(deck.cards.first.front, 'A');
    });

    test('Deck toJson converts cards properly', () {
      final deck = Deck(
        id: 'd1',
        title: 'T',
        cards: [
          Flashcard(id: '1', front: 'Q', back: 'A'),
        ],
      );
      final json = deck.toJson();
      expect(json['cards'].length, 1);
      expect(json['cards'][0]['front'], 'Q');
    });

    test('Deck addCard inserts a card', () {
      final deck = Deck(id: 'd', title: 'T', cards: []);
      final card = Flashcard(id: 'c', front: 'F', back: 'B');
      deck.addCard(card);
      expect(deck.cards.length, 1);
    });

    test('Deck removeCard removes correct card', () {
      final deck = Deck(id: 'd', title: 'T', cards: [
        Flashcard(id: '1', front: 'A', back: 'B'),
        Flashcard(id: '2', front: 'C', back: 'D'),
      ]);
      deck.removeCard('1');
      expect(deck.cards.length, 1);
      expect(deck.cards.first.id, '2');
    });

    test('Deck copyWith updates fields', () {
      final deck = Deck(id: 'd1', title: 'Old', cards: []);
      final updated = deck.copyWith(title: 'New');
      expect(updated.title, 'New');
    });
  });

  // ---------------------------------------------------------------
  // FLASHCARD SERVICE TESTS
  // ---------------------------------------------------------------
  group('FLASHCARD SERVICE TESTS', () {
    late FakeStorage storage;
    late FlashcardService service;

    setUp(() {
      storage = FakeStorage();
      service = FlashcardService(storage);
    });

    test('addDeck saves deck to storage', () async {
      final deck = Deck(id: '1', title: 'Deck', cards: []);
      await service.addDeck(deck);

      final result = storage.getDeck('1');
      expect(result, isNotNull);
      expect(result!['title'], 'Deck');
    });

    test('getDeckById returns deck', () async {
      final deck = Deck(id: 'd', title: 'Hello', cards: []);
      await service.addDeck(deck);

      final loaded = await service.getDeckById('d');
      expect(loaded!.title, 'Hello');
    });

    test('getDeckById returns null for missing deck', () async {
      final result = await service.getDeckById('missing');
      expect(result, null);
    });

    test('updateDeck overwrites existing deck', () async {
      final deck = Deck(id: 'd', title: 'Old', cards: []);
      await service.addDeck(deck);

      final updated = Deck(id: 'd', title: 'New', cards: []);
      await service.updateDeck(updated);

      final loaded = await service.getDeckById('d');
      expect(loaded!.title, 'New');
    });

    test('deleteDeck removes deck', () async {
      final deck = Deck(id: 'd', title: 'Delete', cards: []);
      await service.addDeck(deck);

      await service.deleteDeck('d');
      expect(await service.getDeckById('d'), isNull);
    });

    test('addCardToDeck adds one card', () async {
      final deck = Deck(id: 'd', title: 'Deck', cards: []);
      await service.addDeck(deck);

      final card = Flashcard(id: 'c', front: 'Q', back: 'A');
      await service.addCardToDeck('d', card);

      final loaded = await service.getDeckById('d');
      expect(loaded!.cards.length, 1);
    });

    test('deleteCard removes only the matched card', () async {
      final deck = Deck(id: 'd', title: 'X', cards: [
        Flashcard(id: '1', front: 'A', back: 'B'),
        Flashcard(id: '2', front: 'C', back: 'D'),
      ]);
      await service.addDeck(deck);

      await service.deleteCard('d', '1');

      final loaded = await service.getDeckById('d');
      expect(loaded!.cards.length, 1);
      expect(loaded.cards.first.id, '2');
    });
  });

  // ---------------------------------------------------------------
  // STORAGE SERVICE TESTS (FakeStorage)
  // ---------------------------------------------------------------
  group('FAKE STORAGE TESTS', () {
    late FakeStorage storage;

    setUp(() {
      storage = FakeStorage();
    });

    test('saveDeck then getDeck returns same data', () async {
      await storage.saveDeck('1', {'title': 'Test'});
      expect(storage.getDeck('1')!['title'], 'Test');
    });

    test('getAllDecks lists all decks', () async {
      await storage.saveDeck('a', {'title': 'A'});
      await storage.saveDeck('b', {'title': 'B'});
      final all = storage.getAllDecks();
      expect(all.length, 2);
    });

    test('deleteDeck removes from storage', () async {
      await storage.saveDeck('x', {'title': 'X'});
      await storage.deleteDeck('x');
      expect(storage.getDeck('x'), isNull);
    });
  });

  // ---------------------------------------------------------------
  // INTEGRATION TESTS
  // ---------------------------------------------------------------
  group('INTEGRATION TESTS', () {
    late FakeStorage storage;
    late FlashcardService service;

    setUp(() {
      storage = FakeStorage();
      service = FlashcardService(storage);
    });

    test('Create → Add card → Save → Reload deck', () async {
      final deck = Deck(id: 'd', title: 'Lang', cards: []);
      await service.addDeck(deck);

      await service.addCardToDeck(
        'd',
        Flashcard(id: '1', front: 'Hello', back: 'Hola'),
      );

      final reloaded = await service.getDeckById('d');
      expect(reloaded!.cards.length, 1);
    });

    test('Multiple decks store independently', () async {
      await service.addDeck(Deck(id: '1', title: 'A', cards: []));
      await service.addDeck(Deck(id: '2', title: 'B', cards: []));

      final list = await service.getAllDecks();
      expect(list.length, 2);
    });

    test('Updated deck persists across reloads', () async {
      final deck = Deck(id: 'd', title: 'Old', cards: []);
      await service.addDeck(deck);

      await service.updateDeck(deck.copyWith(title: 'New'));

      final reloaded = await service.getDeckById('d');
      expect(reloaded!.title, 'New');
    });
  });
}
