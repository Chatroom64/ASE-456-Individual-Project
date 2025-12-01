import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../main.dart' show flashcardService;
import '../../features/quiz/quiz_screen.dart';
import '../../data/models/deck.dart';
import '../../data/models/flashcard.dart';
import '../editor/editor_screen.dart';


// Use the same services from deck_list_screen

class DeckDetailScreen extends StatefulWidget {
  final Deck deck;

  const DeckDetailScreen({super.key, required this.deck});

  @override
  State<DeckDetailScreen> createState() => _DeckDetailScreenState();
}

class _DeckDetailScreenState extends State<DeckDetailScreen> {
  bool showAnswer = false;

  void _toggleCard() {
    setState(() {
      showAnswer = !showAnswer;
    });
  }

  void _addFlashcard() async {
    final newCard = Flashcard(
      id: const Uuid().v4(),
      question: 'New question?',
      answer: 'New answer!',
    );

    widget.deck.addCard(newCard);
    await flashcardService.updateDeck(widget.deck);

    setState(() {});
  }

  void _deleteFlashcard(Flashcard card) async {
  await flashcardService.deleteCard(widget.deck.id, card.id);
  setState(() {
    widget.deck.cards.removeWhere((c) => c.id == card.id);
  });
  }
  void _shareDeck(Deck deck) async {
  final controller = TextEditingController();

  final email = await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Share Deck'),
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(labelText: 'Recipient email'),
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, controller.text.trim()),
          child: const Text('Share'),
        ),
      ],
    ),
  );

  if (email == null || email.isEmpty) return;

  // For now, just print or store the email
  print('Deck "${deck.title}" shared with: $email');

  // Later, this is where you would update a shared list in Firestore
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Deck shared with $email')),
  );
}



  @override
  Widget build(BuildContext context) {
    final deck = widget.deck;
    return Scaffold(
      appBar: AppBar(
        title: Text(deck.title),
        actions: [
          if (deck.toJson().containsKey('highScore'))
            Text('High score: ${deck.toJson()['highScore']}',
            style: const TextStyle(fontSize: 16)),

          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => QuizScreen(deck: deck),
                ),
              );
            },
            child: const Text('Quiz Me!'),
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareDeck(deck),
          )
        ],
        
      ),
      body: deck.cards.isEmpty
          ? const Center(
              child: Text('No flashcards yet. Tap + to add one.'),
            )
          : ListView.builder(
              itemCount: deck.cards.length,
              itemBuilder: (context, index) {
                final card = deck.cards[index];
                return GestureDetector(
                  onTap: _toggleCard,
                  onLongPress: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditorScreen(
                          deck: widget.deck,
                          existingCard: card,
                        ),
                      ),
                    );
                    if (result == true) setState(() {});
                  },
                  child: Card(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            showAnswer ? 'Answer:' : 'Question:',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            showAnswer ? card.answer : card.question,
                            style: const TextStyle(fontSize: 18),
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _deleteFlashcard(card),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EditorScreen(deck: widget.deck),
            ),
          );
          if (result == true) setState(() {});
        },
        child: const Icon(Icons.add),
      ),
      
    );
    
  }
}
