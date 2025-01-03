import 'package:flutter/material.dart';
import 'podcast_player.dart';

import 'package:provider/provider.dart';
import '../models/podcast.dart';
import '../providers/podcast_provider.dart';
import '../services/podcast_service.dart';

class PodcastDetailScreen extends StatefulWidget {
  final dynamic podcast;

  const PodcastDetailScreen({required this.podcast});

  @override
  _PodcastDetailScreenState createState() => _PodcastDetailScreenState();
}

class _PodcastDetailScreenState extends State<PodcastDetailScreen> {
  bool _isLoading = true;
  Podcast? _podcast;

  @override
  void initState() {
    super.initState();
    _fetchEpisodes();
  }

  Future<void> _fetchEpisodes() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _podcast = await PodcastService.fetchPodcastDetails(widget.podcast);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error fetching episodes: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _podcast == null) {
      return Center(child: CircularProgressIndicator());
    }

    final sanitizedDescription = extractPlainText(widget.podcast.description);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.podcast.title),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Image.network(
                        widget.podcast.imageUrl,
                        height: 150,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      sanitizedDescription,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Artist: ${widget.podcast.author}',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Feed URL: ${widget.podcast.url}',
                      style: TextStyle(fontSize: 16),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (_podcast == null) {
                          return;
                        }

                        Provider.of<PodcastProvider>(context, listen: false)
                            .addPodcast(_podcast!);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  'Subscribed to ${widget.podcast.title}')),
                        );
                      },
                      child: Text('Subscribe'),
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
                      itemCount: _podcast?.episodes.length,
                      itemBuilder: (context, index) {
                        final episode = _podcast?.episodes[index];

                        final String episodeTitle = episode?.title ?? '';

                        return ListTile(
                          title: Text(
                            episodeTitle,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PodcastPlayerScreen(
                                  audioUrl: episode?.audioUrl ?? '',
                                  episodeTitle: episode?.title ?? '',
                                ),
                              ),
                            );
                          },
                          subtitle: Text('Published on: ${episode?.pubDate}'),
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
