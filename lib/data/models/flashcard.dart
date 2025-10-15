import 'dart:convert';

class Flashcard {
  final String id;
  String question;
  String answer;
  DateTime createdAt;
  DateTime updatedAt;

  Flashcard({
    required this.id,
    required this.question,
    required this.answer,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'answer': answer,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Flashcard.fromJson(Map<String, dynamic> json) {
    return Flashcard(
      id: json['id'],
      question: json['question'] ?? '',
      answer: json['answer'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  String toRawJson() => jsonEncode(toJson());
  factory Flashcard.fromRawJson(String str) => Flashcard.fromJson(jsonDecode(str));
}
