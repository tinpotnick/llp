import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../providers/podcast_provider.dart';
import '../models/podcast.dart';
import 'podcast_detail_screen.dart';

class SubscribedNavigator extends StatefulWidget {
  const SubscribedNavigator({super.key});

  @override
  SubscribedNavigatorState createState() => SubscribedNavigatorState();
}

class SubscribedNavigatorState extends State<SubscribedNavigator> {
  List<Podcast> _subscriptions = [];

  Future<void> _loadSubscriptions() async {
    Map<String, Podcast> mapofsubs =
        Provider.of<PodcastProvider>(context, listen: false).podcasts;

    _subscriptions = mapofsubs.values.toList();

    setState(() {});
  }

  Future<void> _removeSubscription(Podcast? podcast) async {}

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
                  leading: Image.network(podcast.imageUrl),
                  title: Text(podcast.title),
                  subtitle: Text(podcast.author),
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
