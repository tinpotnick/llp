import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/flashcard_provider.dart';
import 'providers/podcast_provider.dart';
import 'providers/usercard_provider.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final flashcardProvider = FlashcardProvider();
  final podcastProvider = PodcastProvider();
  final usercardProvider = UserCardProvider(flashcardProvider);
  await flashcardProvider.loadFromStorage();
  await podcastProvider.loadFromStorage();
  await usercardProvider.loadFromStorage();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => flashcardProvider),
        ChangeNotifierProvider(create: (_) => podcastProvider),
        ChangeNotifierProvider(create: (_) => usercardProvider),
      ],
      child: LanguageLearningApp(),
    ),
  );
}

class LanguageLearningApp extends StatelessWidget {
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
