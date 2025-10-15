import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../main.dart' show flashcardService, storageService;
//import '../../core/services/flashcard_service.dart';
//import '../../core/services/storage_service.dart';
import '../../data/models/deck.dart';
import '../../data/models/flashcard.dart';
import '../../features/deck_detail/deck_detail_screen.dart';

// Access your global services from main.dart



class DeckListScreen extends StatefulWidget {
  const DeckListScreen({super.key});

  @override
  State<DeckListScreen> createState() => _DeckListScreenState();
}

class _DeckListScreenState extends State<DeckListScreen> {
  late Future<List<Deck>> _decksFuture;

  @override
  void initState() {
    super.initState();
    storageService.init();
    _decksFuture = flashcardService.getAllDecks();
  }

  Future<void> _refreshDecks() async {
    setState(() {
      _decksFuture = flashcardService.getAllDecks();
    });
  }

Future<void> _addNewDeck() async {
  final controller = TextEditingController();

  // Prompt the user for a title before creating the deck
  final title = await showDialog<String>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('New Deck'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Deck title'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Create'),
          ),
        ],
      );
    },
  );

  // If user cancels or leaves it blank, stop
  if (title == null || title.isEmpty) return;

  final newDeck = Deck(
    id: const Uuid().v4(),
    title: title,
    description: 'A new deck of flashcards',
  );

  // Optional: add a sample card (keep your existing behavior)
  final sampleCard = Flashcard(
    id: const Uuid().v4(),
    question: 'What is Flutter?',
    answer: 'A UI toolkit by Google for building cross-platform apps.',
  );

  newDeck.addCard(sampleCard);

  await flashcardService.addDeck(newDeck);
  _refreshDecks();
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Flashcard Decks'),
      ),
      body: FutureBuilder<List<Deck>>(
        future: _decksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final decks = snapshot.data ?? [];
          if (decks.isEmpty) {
            return const Center(child: Text('No decks yet. Tap + to add one.'));
          }
          return RefreshIndicator(
            onRefresh: _refreshDecks,
            child: ListView.builder(
              itemCount: decks.length,
              itemBuilder: (context, index) {
                final deck = decks[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    title: Text(deck.title),
                    subtitle: Text('${deck.cards.length} cards'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DeckDetailScreen(deck: deck),
                        ),
                      );
                    },

                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewDeck,
        child: const Icon(Icons.add),
      ),
    );
  }
}
