import 'package:flashcard_app/data/models/deck.dart';
import 'package:flashcard_app/data/models/flashcard.dart';
import 'package:flashcard_app/core/services/flashcard_service.dart';
import 'package:flashcard_app/core/services/storage_service.dart';
void main() async {
  final storage = StorageService();
  final flashcards = FlashcardService(storage);
  await storage.init();

  final newDeck = Deck(id: '1', title: 'Spanish Basics');
  newDeck.addCard(Flashcard(id: 'a1', question: 'Hola', answer: 'Hello'));
  await flashcards.addDeck(newDeck);

  final loadedDecks = await flashcards.getAllDecks();
  print(loadedDecks.first.title);
}
