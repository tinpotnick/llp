import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/flashcard_provider.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final flashcardProvider = FlashcardProvider();
  await flashcardProvider.loadFromStorage(); // Load saved flashcards

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => flashcardProvider),
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
      theme: ThemeData(primarySwatch: Colors.deepOrange),
      home: HomeScreen(),
    );
  }
}
