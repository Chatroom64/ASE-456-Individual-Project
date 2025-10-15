import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/deck.dart';
import '../../data/models/flashcard.dart';
import '../../main.dart' show flashcardService;

class EditorScreen extends StatefulWidget {
  final Deck deck;
  final Flashcard? existingCard; // null = add mode

  const EditorScreen({
    super.key,
    required this.deck,
    this.existingCard,
  });

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _questionController;
  late TextEditingController _answerController;
  late bool _isEditing;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.existingCard != null;
    _questionController =
        TextEditingController(text: widget.existingCard?.question ?? '');
    _answerController =
        TextEditingController(text: widget.existingCard?.answer ?? '');
  }

  @override
  void dispose() {
    _questionController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  Future<void> _saveFlashcard() async {
    if (!_formKey.currentState!.validate()) return;

    final question = _questionController.text.trim();
    final answer = _answerController.text.trim();

    if (_isEditing) {
      // Update existing card
      final index = widget.deck.cards
          .indexWhere((c) => c.id == widget.existingCard!.id);
      if (index != -1) {
        widget.deck.cards[index] =
            Flashcard(id: widget.existingCard!.id, question: question, answer: answer);
      }
    } else {
      // Create new card
      final newCard = Flashcard(
        id: const Uuid().v4(),
        question: question,
        answer: answer,
      );
      widget.deck.addCard(newCard);
    }

    await flashcardService.updateDeck(widget.deck);
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Flashcard' : 'Add Flashcard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _questionController,
                decoration: const InputDecoration(
                  labelText: 'Question',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Enter a question' : null,
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _answerController,
                decoration: const InputDecoration(
                  labelText: 'Answer',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Enter an answer' : null,
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _saveFlashcard,
                icon: const Icon(Icons.save),
                label: const Text('Save'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
