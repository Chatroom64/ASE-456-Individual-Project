import 'dart:convert';
import 'flashcard.dart';

class Deck {
  final String id;
  int quizCount;
  String title;
  String? description;
  List<Flashcard> cards;
  DateTime createdAt;
  DateTime updatedAt;

Deck({
  required this.id,
  required this.title,
  this.description,
  List<Flashcard>? cards,
  DateTime? createdAt,
  DateTime? updatedAt,
  this.quizCount = 0,
})  : cards = cards ?? [],
      createdAt = createdAt ?? DateTime.now(),
      updatedAt = updatedAt ?? DateTime.now();

Map<String, dynamic> toJson() {
  return {
    'id': id,
    'title': title,
    'description': description,
    'cards': cards.map((card) => card.toJson()).toList(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'quizCount': quizCount,
  };
}

factory Deck.fromMap(Map<String, dynamic> map) {
  return Deck(
    id: map['id'] ?? '',
    title: map['title'] ?? '',
    description: map['description'],
    createdAt: map['createdAt'] != null
        ? DateTime.parse(map['createdAt'])
        : DateTime.now(),
    updatedAt: map['updatedAt'] != null
        ? DateTime.parse(map['updatedAt'])
        : DateTime.now(),
    quizCount: map['quizCount'] ?? 0,
    cards: map['cards'] != null
        ? List<Flashcard>.from(
            (map['cards'] as List<dynamic>).map((c) => Flashcard.fromMap(c)))
        : [],
  );
}


  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'quizCount': quizCount,
      'cards': cards.map((c) => c.toMap()).toList(),
    };
  }
  void addCard(Flashcard card) {
    cards.add(card);
    updatedAt = DateTime.now();
  }
  void removeCard(String cardId) {
    cards.removeWhere((c) => c.id == cardId);
    updatedAt = DateTime.now();
  }
  void shuffleCards() {
    cards.shuffle();
  }
}
