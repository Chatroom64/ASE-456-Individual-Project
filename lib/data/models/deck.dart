import 'dart:convert';
import 'flashcard.dart';

class Deck {
  final String id;
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
  })  : cards = cards ?? [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // Map Deck and cards
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'cards': cards.map((card) => card.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Deck.fromJson(Map<String, dynamic> json) {
    return Deck(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      cards: (json['cards'] as List<dynamic>?)
              ?.map((c) => Flashcard.fromJson(c))
              .toList() ??
          [],
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  // JSON encode and decode for extra utility
  String toRawJson() => jsonEncode(toJson());
  factory Deck.fromRawJson(String str) => Deck.fromJson(jsonDecode(str));

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
