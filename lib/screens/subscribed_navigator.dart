import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'podcast_detail_screen.dart';

class SubscribedNavigator extends StatefulWidget {
  @override
  _SubscribedNavigatorState createState() => _SubscribedNavigatorState();
}

class _SubscribedNavigatorState extends State<SubscribedNavigator> {
  List<Map<String, dynamic>> _subscriptions = [];

  Future<void> _loadSubscriptions() async {
    final prefs = await SharedPreferences.getInstance();
    final subscriptionList = prefs.getStringList('subscriptions') ?? [];

    final subscriptions = subscriptionList
        .map((subscriptionJson) {
          try {
            // Decode JSON string to Map<String, dynamic>
            return jsonDecode(subscriptionJson) as Map<String, dynamic>;
          } catch (e) {
            // Handle corrupted or invalid data gracefully
            print('Error decoding subscription: $e');
            return null; // Skip invalid entries
          }
        })
        .where((element) => element != null)
        .toList();

    setState(() {
      _subscriptions = subscriptions.cast<Map<String, dynamic>>();
    });
  }

  Future<void> _removeSubscription(Map<String, dynamic> podcast) async {
    final prefs = await SharedPreferences.getInstance();
    final subscriptionList = prefs.getStringList('subscriptions') ?? [];
    final podcastJson = jsonEncode(podcast);
    subscriptionList.remove(podcastJson);
    await prefs.setStringList('subscriptions', subscriptionList);
    _loadSubscriptions();
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
      body: _subscriptions.isEmpty
          ? Center(child: Text('No subscriptions yet!'))
          : ListView.builder(
              itemCount: _subscriptions.length,
              itemBuilder: (context, index) {
                final podcast = _subscriptions[index];
                return ListTile(
                  leading: podcast['artworkUrl600'] != null
                      ? Image.network(podcast['artworkUrl600'])
                      : Icon(Icons.library_music),
                  title: Text(podcast['collectionName'] ?? 'Unknown Podcast'),
                  subtitle: Text(podcast['artistName'] ?? 'Unknown Artist'),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removeSubscription(podcast),
                  ),
                  onTap: () async {
                    final updated = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            PodcastDetailScreen(podcast: podcast),
                      ),
                    );
                    if (updated == true) {
                      // Reload subscriptions when returning
                      _loadSubscriptions();
                    }
                  },
                );
              },
            ),
    );
  }
}
