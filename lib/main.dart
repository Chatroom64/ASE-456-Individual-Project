import 'package:flashcard_app/app/routes.dart';
import 'package:flutter/material.dart';
import 'app/app.dart';
import 'core/services/storage_service.dart';
import 'core/services/flashcard_service.dart';
import 'core/services/auth/auth_service.dart';
import 'core/services/auth/auth_screen.dart';
import '../../../features/deck_list/deck_list_screen.dart';

final storageService = StorageService();
final flashcardService = FlashcardService(storageService);

Future<void> setup() async {
  final authService = AuthService();
  await authService.init();
  await storageService.init();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final authService = AuthService();
  await authService.init();

  final loggedIn = await authService.isLoggedIn();

  runApp(FlashcardApp(isLoggedIn: loggedIn));
}


class FlashcardApp extends StatelessWidget {
  final bool isLoggedIn;
  const FlashcardApp({super.key, required this.isLoggedIn});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flashcard App',
      routes: appRoutes,
      home: isLoggedIn ? const DeckListScreen() : const AuthScreen(),
    );
  }
}