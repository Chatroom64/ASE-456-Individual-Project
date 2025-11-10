import 'package:flutter/material.dart';
import '../features/deck_list/deck_list_screen.dart';
import '../core/services/auth/auth_screen.dart';
import '../features/deck_detail/deck_detail_screen.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/login': (context) => const AuthScreen(),
  '/decks': (context) => const DeckListScreen(),
};
