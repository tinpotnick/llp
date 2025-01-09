import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/flashcard_provider.dart';
import 'providers/podcast_provider.dart';
import 'providers/usercard_provider.dart';
import 'screens/home_screen.dart';

Widget buildAppWithProviders({required Widget child}) {
  final flashcardProvider = FlashcardProvider();
  final podcastProvider = PodcastProvider();
  final usercardProvider = UserCardProvider(flashcardProvider);

  flashcardProvider.loadFromStorage();
  podcastProvider.loadFromStorage();
  usercardProvider.loadFromStorage();

  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => flashcardProvider),
      ChangeNotifierProvider(create: (_) => podcastProvider),
      ChangeNotifierProvider(create: (_) => usercardProvider),
    ],
    child: child,
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    buildAppWithProviders(
      child: LanguageLearningApp(),
    ),
  );
}

class LanguageLearningApp extends StatelessWidget {
  const LanguageLearningApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Language Learning Podcast',
      theme:
          ThemeData(primarySwatch: Colors.deepOrange, fontFamily: 'NotoSans'),
      home: HomeScreen(),
    );
  }
}
