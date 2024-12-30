import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'podcast_detail_screen.dart';

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

    final url =
        Uri.parse('https://itunes.apple.com/search?term=$query&media=podcast');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _podcasts = data['results'];
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch podcasts')),
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
                    return ListTile(
                      leading: podcast['artworkUrl100'] != null
                          ? Image.network(podcast['artworkUrl100'])
                          : Icon(Icons.library_music),
                      title:
                          Text(podcast['collectionName'] ?? 'Unknown Podcast'),
                      subtitle: Text(podcast['artistName'] ?? 'Unknown Artist'),
                      onTap: () {
                        // Navigate to PodcastDetailScreen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                PodcastDetailScreen(podcast: podcast),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
