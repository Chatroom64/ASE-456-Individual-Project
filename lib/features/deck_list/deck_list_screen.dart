import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../main.dart' show flashcardService, storageService;
import '../../data/models/deck.dart';
import '../../data/models/flashcard.dart';
import '../../features/deck_detail/deck_detail_screen.dart';

class DeckListScreen extends StatefulWidget {
  const DeckListScreen({super.key});

  @override
  State<DeckListScreen> createState() => _DeckListScreenState();
}

class _DeckListScreenState extends State<DeckListScreen> {
  late Future<List<Deck>> _decksFuture = Future.value([]);
  List<Deck> _latestDeckList = [];

  String _searchQuery = '';
  String _sortOption = 'title_asc';

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await storageService.init();
    final decks = await flashcardService.getAllDecks();
    setState(() {
      _decksFuture = Future.value(decks);
    });
  }

  Future<void> _refreshDecks() async {
    final decks = await flashcardService.getAllDecks();
    setState(() {
      _decksFuture = Future.value(decks);
    });
  }

  Future<void> _addNewDeck() async {
    final controller = TextEditingController();
    final title = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
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
      ),
    );

    if (title == null || title.isEmpty) return;

    final newDeck = Deck(
      id: const Uuid().v4(),
      title: title,
      description: 'A new deck of flashcards',
    );

    await flashcardService.addDeck(newDeck);
    await _refreshDecks();
  }

  Future<void> _deleteDeck(Deck deck) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete deck?"),
        content: Text(
            "Are you sure you want to delete \"${deck.title}\"? This cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await flashcardService.deleteDeck(deck.id);
      await _refreshDecks();
    }
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          decoration: const InputDecoration(
            hintText: 'Search decks...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white60),
          ),
          style: const TextStyle(color: Colors.white),
          onChanged: (value) {
            setState(() {
              _searchQuery = value.toLowerCase();
            });
          },
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (value) {
              setState(() {
                _sortOption = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'title_asc', child: Text('Title A–Z')),
              const PopupMenuItem(value: 'title_desc', child: Text('Title Z–A')),
              const PopupMenuItem(value: 'date_new', child: Text('Newest First')),
              const PopupMenuItem(value: 'date_old', child: Text('Oldest First')),
              const PopupMenuItem(value: 'quiz_most', child: Text('Most Quizzed')),
              const PopupMenuItem(value: 'quiz_least', child: Text('Least Quizzed')),
            ],
          ),
        ],
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

          List<Deck> filteredDecks = decks.where((deck) {
            return deck.title.toLowerCase().contains(_searchQuery) ||
                (deck.description?.toLowerCase().contains(_searchQuery) ?? false);
          }).toList();
          _latestDeckList = filteredDecks;


          switch (_sortOption) {
            case 'title_asc':
              filteredDecks.sort((a, b) => a.title.compareTo(b.title));
              break;
            case 'title_desc':
              filteredDecks.sort((a, b) => b.title.compareTo(a.title));
              break;
            case 'date_new':
              filteredDecks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
              break;
            case 'date_old':
              filteredDecks.sort((a, b) => a.createdAt.compareTo(b.createdAt));
              break;
            case 'quiz_most':
              filteredDecks.sort((a, b) => (b.quizCount).compareTo(a.quizCount));
              break;
            case 'quiz_least':
              filteredDecks.sort((a, b) => (a.quizCount).compareTo(b.quizCount));
              break;
          }

          return RefreshIndicator(
            onRefresh: _refreshDecks,
            child: ListView.builder(
              itemCount: filteredDecks.length,
              itemBuilder: (context, index) {
                final deck = filteredDecks[index];
                return ListTile(
                  title: Text(deck.title),
                  subtitle: Text("${deck.cards.length} cards"),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _deleteDeck(deck),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DeckDetailScreen(deck: deck),
                      ),
                    ).then((_) => _refreshDecks());
                  },
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton(
        heroTag: 'random',
        onPressed: _openRandomDeck,
        child: const Icon(Icons.casino),
        tooltip: "Random Deck",
        ),
          FloatingActionButton(
            onPressed: _addNewDeck,
          child: const Icon(Icons.add),
        ),
      ]
      ),
    );
  }
  void _openRandomDeck() {
  if (_latestDeckList.isEmpty) return;

  final random = DateTime.now().millisecondsSinceEpoch % _latestDeckList.length;
  final deck = _latestDeckList[random];

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => DeckDetailScreen(deck: deck),
      ),
    );
  }
}

