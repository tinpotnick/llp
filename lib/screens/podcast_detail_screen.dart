import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html;
import 'podcast_player.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class PodcastDetailScreen extends StatefulWidget {
  final dynamic podcast;

  const PodcastDetailScreen({required this.podcast});

  @override
  _PodcastDetailScreenState createState() => _PodcastDetailScreenState();
}

class _PodcastDetailScreenState extends State<PodcastDetailScreen> {
  bool _isLoading = true; // Tracks whether the episodes are being loaded
  List<Map<String, String>> _episodes = []; // Holds the episodes

  @override
  void initState() {
    super.initState();
    _fetchEpisodes(); // Load episodes when the screen initializes
  }

  Future<void> _fetchEpisodes() async {
    setState(() {
      _isLoading = true; // Set loading state
    });

    try {
      final response = await http.get(Uri.parse(widget.podcast['feedUrl']));
      if (response.statusCode == 200) {
        final document = html.parse(response.body);
        final items = document.getElementsByTagName('item');

        final episodes = items.map((item) {
          final title = item.getElementsByTagName('title').first.text;
          final audioUrl = item.getElementsByTagName('enclosure').isNotEmpty
              ? item.getElementsByTagName('enclosure').first.attributes['url']
              : null;
          final pubDate = item.getElementsByTagName('pubDate').isNotEmpty
              ? item.getElementsByTagName('pubDate').first.text
              : 'Unknown Date';

          return {
            'title': title,
            'audioUrl': audioUrl ?? '',
            'pubDate': pubDate,
          };
        }).toList();

        setState(() {
          _episodes = episodes; // Update the episodes list
        });
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to fetch episodes')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error fetching episodes: $e')));
    } finally {
      setState(() {
        _isLoading = false; // Reset loading state
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.podcast['collectionName'] ?? 'Podcast Details'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator()) // Show loading indicator
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.podcast['artworkUrl600'] != null)
                      Center(
                        child: Image.network(
                          widget.podcast['artworkUrl600'],
                          height: 150,
                        ),
                      ),
                    SizedBox(height: 16),
                    Text(
                      widget.podcast['collectionName'] ?? 'Unknown Podcast',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Artist: ${widget.podcast['artistName'] ?? 'Unknown Artist'}',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Feed URL: ${widget.podcast['feedUrl'] ?? 'No Feed URL Available'}',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Episodes',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: _episodes.length,
                      itemBuilder: (context, index) {
                        final episode = _episodes[index];
                        return ListTile(
                          title: Text(episode['title'] ?? 'Unknown Title'),
                          subtitle: Text('Published on: ${episode['pubDate']}'),
                          trailing: IconButton(
                            icon: Icon(Icons.play_arrow),
                            onPressed: () {
                              // Navigate to PodcastPlayerScreen with episode URL
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PodcastPlayerScreen(
                                    audioUrl: episode['audioUrl']!,
                                    episodeTitle: episode['title']!,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
