import 'package:flashcard_app/app/routes.dart';
import 'package:flutter/material.dart';
import 'app/app.dart';
import 'core/services/storage_service.dart';
import 'core/services/flashcard_service.dart';
import 'core/services/auth/auth_service.dart';
import 'core/services/auth/auth_screen.dart';

final storageService = StorageService();
final flashcardService = FlashcardService(storageService);

Future<void> setup() async {
  await storageService.init();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setup();
  runApp(const FlashcardApp());
}


class FlashcardApp extends StatelessWidget {
  const FlashcardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flashcard App',
      routes: appRoutes,
    );
  }
}