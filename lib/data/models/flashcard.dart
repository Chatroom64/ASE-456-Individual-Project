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

  // Add this factory method
  factory Flashcard.fromMap(Map<String, dynamic> map) {
  return Flashcard(
    id: map['id'] ?? '',
    question: map['question'] ?? '',
    answer: map['answer'] ?? '',
    createdAt: map['createdAt'] != null
        ? DateTime.parse(map['createdAt'])
        : DateTime.now(),
    updatedAt: map['updatedAt'] != null
        ? DateTime.parse(map['updatedAt'])
        : DateTime.now(),
  );
}


  // Optional: toMap for saving back to Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question': question,
      'answer': answer,
    };
  }

}
