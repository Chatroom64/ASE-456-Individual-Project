import 'package:cloud_firestore/cloud_firestore.dart';

class DeckService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Collection reference
  CollectionReference get _decks => _firestore.collection('decks');

  /// Add a new deck
  Future<void> addDeck(String title) async {
    await _decks.add({
      'title': title,
      'createdAt': FieldValue.serverTimestamp(),
      'cards': [], // empty list for cards
    });
  }

  /// Get all decks as a stream
  Stream<QuerySnapshot> getDecksStream() {
    return _decks.orderBy('createdAt', descending: true).snapshots();
  }

  /// Update deck (e.g., add/remove cards)
  Future<void> updateDeck(String id, Map<String, dynamic> data) async {
    await _decks.doc(id).update(data);
  }

  /// Delete a deck
  Future<void> deleteDeck(String id) async {
    await _decks.doc(id).delete();
  }
}
