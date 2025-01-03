import 'package:flutter/material.dart';
import 'podcast_detail_screen.dart';

import '../services/podcast_service.dart';

class PodcastBrowserScreen extends StatefulWidget {
  @override
  _PodcastBrowserScreenState createState() => _PodcastBrowserScreenState();
}

class _PodcastBrowserScreenState extends State<PodcastBrowserScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _podcasts = [];
  bool _isLoading = false;

  Future<void> _searchPodcasts(String query) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final pdcsts = await PodcastService.fetchPodcastList(query);
      setState(() {
        _podcasts = pdcsts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch podcasts: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Podcast Browser'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search Podcasts',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    _searchPodcasts(_searchController.text);
                  },
                ),
              ],
            ),
            if (_isLoading)
              Center(child: CircularProgressIndicator())
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _podcasts.length,
                  itemBuilder: (context, index) {
                    final podcast = _podcasts[index];
                    return FutureBuilder(
                        future: PodcastService.fetchPodcastDetails(podcast),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return ListTile(
                              leading: CircularProgressIndicator(),
                              title: Text('Loading...'),
                              subtitle: Text('Please wait'),
                            );
                          } else if (snapshot.hasError) {
                            return ListTile(
                              leading: Icon(Icons.error, size: 40.0),
                              title: Text('Error loading podcast'),
                              subtitle: Text('${snapshot.error}'),
                            );
                          } else if (snapshot.hasData) {
                            return ListTile(
                                leading: snapshot.hasData &&
                                        snapshot.data?.imageUrl != null
                                    ? Image.network(snapshot.data!.imageUrl)
                                    : Icon(Icons.place, size: 40.0),
                                title: Text(podcast.collectionName ??
                                    'Unknown Podcast'),
                                subtitle: Text(
                                    podcast.artistName ?? 'Unknown Artist'),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => FutureBuilder(
                                        future:
                                            PodcastService.fetchPodcastDetails(
                                                _podcasts[index]),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            // Show a loading indicator while the data is being fetched
                                            return Center(
                                                child:
                                                    CircularProgressIndicator());
                                          } else if (snapshot.hasError) {
                                            // Handle any errors
                                            return Center(
                                                child: Text(
                                                    'Error: ${snapshot.error}'));
                                          } else if (snapshot.hasData) {
                                            // Pass the fetched podcast to the PodcastDetailScreen
                                            return PodcastDetailScreen(
                                                podcast: snapshot.data);
                                          } else {
                                            // Handle the case where there's no data
                                            return Center(
                                                child: Text('No data found'));
                                          }
                                        },
                                      ),
                                    ),
                                  );
                                });
                          } else {
                            return ListTile(
                              leading: Icon(Icons.info, size: 40.0),
                              title: Text('No data available'),
                              subtitle:
                                  Text('Podcast details could not be found'),
                            );
                          }
                        });
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
