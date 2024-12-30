import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'episode_browser.dart';

class SubscribedPodcastsScreen extends StatefulWidget {
  @override
  _SubscribedPodcastsScreenState createState() =>
      _SubscribedPodcastsScreenState();
}

class _SubscribedPodcastsScreenState extends State<SubscribedPodcastsScreen> {
  List<String> _subscriptions = [];

  Future<void> _loadSubscriptions() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _subscriptions = prefs.getStringList('subscriptions') ?? [];
    });
  }

  @override
  void initState() {
    super.initState();
    _loadSubscriptions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Subscribed Podcasts'),
      ),
      body: ListView.builder(
        itemCount: _subscriptions.length,
        itemBuilder: (context, index) {
          final podcastId = _subscriptions[index];
          return ListTile(
            title: Text('Podcast ID: $podcastId'),
            onTap: () {
              // Navigate to episode browser for the podcast
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EpisodeBrowserScreen(
                    feedUrl: 'https://feeds.example.com/$podcastId',
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
