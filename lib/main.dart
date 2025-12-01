import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart';
import 'core/services/auth/auth_screen.dart';
import 'features/deck_list/deck_list_screen.dart';

import 'core/services/flashcard_service.dart';
import 'core/services/storage_service.dart';

final storageService = StorageService();
final flashcardService = FlashcardService(storageService);
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const FlashcardApp());
}

class FlashcardApp extends StatelessWidget {
  const FlashcardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flashcard App',
      theme: ThemeData(primarySwatch: Colors.blue),
      // Directly load the deck list screen, bypassing login
      home: const DeckListScreen(),
    );
  }
}
