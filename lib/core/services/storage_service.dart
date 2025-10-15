import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _deckIndexKey = 'decks_index';
  static const String _deckKeyPrefix = 'deck_';
  late SharedPreferences _prefs;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    _initialized = true;
  }

  Future<void> saveDeck(String deckId, Map<String, dynamic> deckData) async {
    await init();
    final raw = jsonEncode(deckData);
    await _prefs.setString('$_deckKeyPrefix$deckId', raw);

    final ids = _prefs.getStringList(_deckIndexKey) ?? [];
    if (!ids.contains(deckId)) {
      ids.add(deckId);
      await _prefs.setStringList(_deckIndexKey, ids);
    }
  }

  Map<String, dynamic>? getDeck(String deckId) {
    if (!_initialized) return null;
    final raw = _prefs.getString('$_deckKeyPrefix$deckId');
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  Future<void> deleteDeck(String deckId) async {
    await init();
    await _prefs.remove('$_deckKeyPrefix$deckId');
    final ids = _prefs.getStringList(_deckIndexKey) ?? [];
    ids.remove(deckId);
    await _prefs.setStringList(_deckIndexKey, ids);
  }

  List<Map<String, dynamic>> getAllDecks() {
    if (!_initialized) return [];
    final ids = _prefs.getStringList(_deckIndexKey) ?? [];
    final List<Map<String, dynamic>> decks = [];
    for (final id in ids) {
      final raw = _prefs.getString('$_deckKeyPrefix$id');
      if (raw != null) {
        decks.add(jsonDecode(raw) as Map<String, dynamic>);
      }
    }
    return decks;
  }
}
