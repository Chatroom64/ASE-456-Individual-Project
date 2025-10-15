import 'package:flutter/material.dart';
import '../features/deck_list/deck_list_screen.dart';
import '../features/deck_detail/deck_detail_screen.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/': (_) => const DeckListScreen(),
  //'/deck': (_) => const DeckDetailScreen(),
};
