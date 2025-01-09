import 'package:flutter/material.dart';
import 'podcast_browser.dart';
import 'subscribed_navigator.dart';
import 'flashcard_deck.dart';
import 'settings.dart';

import 'package:llp/widgets/podcast_player_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _isPlaying = true;

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
      body: Stack(
        children: [
          // The selected screen content
          _screens[_selectedIndex],

          // PodcastPlayerWidget placed above the BottomNavigationBar
          if (true) // Replace 'true' with your condition for showing the player
            Positioned(
              left: 0,
              right: 0,
              bottom: kBottomNavigationBarHeight, // Position above the BottomNavigationBar
              child: PodcastPlayerWidget(
                audioUrl: "",
                onPositionChanged: (position) => {},
              ),
            ),
        ],
      ),

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
