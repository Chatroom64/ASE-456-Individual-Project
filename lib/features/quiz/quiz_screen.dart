import 'package:flutter/material.dart';
import '../../data/models/deck.dart';
import '../../data/models/flashcard.dart';
import '../../core/services/storage_service.dart';

class QuizScreen extends StatefulWidget {
  final Deck deck;

  const QuizScreen({super.key, required this.deck});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late List<Flashcard> _cards;
  int _currentIndex = 0;
  int _score = 0;
  bool _showAnswer = false;
  bool _finished = false;

  final StorageService _storage = StorageService();
  int? _highScore;

  @override
  void initState() {
    super.initState();
    _initQuiz();
  }

  Future<void> _initQuiz() async {
    await _storage.init();
    setState(() {
      _cards = List.from(widget.deck.cards.reversed);
    });

    final stored = _storage.getDeck(widget.deck.id);
    if (stored != null && stored['highScore'] != null) {
      _highScore = stored['highScore'];
    }
  }

  void _handleAnswer(bool correct) async {
    if (correct) _score++;

    if (_currentIndex < _cards.length - 1) {
      setState(() {
        _currentIndex++;
        _showAnswer = false;
      });
    } else {
      setState(() {
        _finished = true;
      });

      // Save high score
      final deckData = widget.deck.toJson();
      if (_highScore == null || _score > _highScore!) {
        deckData['highScore'] = _score;
        await _storage.saveDeck(widget.deck.id, deckData);
        _highScore = _score;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_finished) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.deck.title)),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Quiz complete!',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              Text(
                'Score: $_score / ${_cards.length}',
                style: const TextStyle(fontSize: 20),
              ),
              if (_highScore != null)
                Text('High score: $_highScore', style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Back to Deck'),
              ),
            ],
          ),
        ),
      );
    }

    final card = _cards[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.deck.title),
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text('Score: $_score / ${_cards.length}'),
            ),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: GestureDetector(
            onTap: () => setState(() => _showAnswer = !_showAnswer),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Text(
                    _showAnswer ? card.answer : card.question,
                    style: const TextStyle(fontSize: 22),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: !_showAnswer
          ? null
          : Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _handleAnswer(true),
                    icon: const Icon(Icons.check),
                    label: const Text('Correct'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _handleAnswer(false),
                    icon: const Icon(Icons.close),
                    label: const Text('Incorrect'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  ),
                ],
              ),
            ),
    );
  }
}
