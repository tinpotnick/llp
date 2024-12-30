import 'package:flutter/material.dart';
import 'podcast_player.dart';
import 'podcast_browser.dart';
import 'subscribed_navigator.dart';
import 'flashcard_deck.dart';
import 'settings.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // List of screens corresponding to the BottomNavigationBar items
  final List<Widget> _screens = [
    SubscribedNavigator(),
    PodcastBrowserScreen(),
    FlashcardDeckScreen(),
    SettingsScreen(),
  ];

  // Change selected index when a tab is tapped
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex], // Display the selected screen
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white, // Background color of the bar
        selectedItemColor: Colors.blue, // Color of the selected icon
        unselectedItemColor: Colors.grey, // Color of unselected icons
        currentIndex: _selectedIndex,
        onTap: _onItemTapped, // Handle tap on a menu item
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.library_music),
            label: 'Play',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Browse',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books),
            label: 'Flashcards',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
