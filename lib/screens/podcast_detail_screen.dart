import 'package:flutter/material.dart';
import 'podcast_player.dart';

import 'package:provider/provider.dart';
import 'package:llp/models/podcast.dart';
import 'package:llp/providers/podcast_provider.dart';
import 'package:llp/services/podcast_service.dart';

class PodcastDetailScreen extends StatefulWidget {
  final dynamic podcast;

  const PodcastDetailScreen({super.key, required this.podcast});

  @override
  PodcastDetailScreenState createState() => PodcastDetailScreenState();
}

class PodcastDetailScreenState extends State<PodcastDetailScreen> {
  bool _isLoading = true;
  bool _isSubscribed = false;
  Podcast? _podcast;

  @override
  void initState() {
    super.initState();
    _fetchEpisodes();

    _isSubscribed = Provider.of<PodcastProvider>(context, listen: false)
        .hasPodcast(widget.podcast.url);

    setState(() {});
    if (_isSubscribed) return;

    _fetchEpisodes();
  }

  Future<void> _fetchEpisodes() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _podcast = await PodcastService.fetchPodcastDetails(widget.podcast);
    } catch (e) {
      if(!mounted) return;
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
    if (_isLoading || _podcast == null || _podcast?.episodes == null ) {
      return Center(child: CircularProgressIndicator());
    }

    final sanitizedDescription = extractPlainText(widget.podcast.description);
    final podcast = _podcast!;
    final episodes = podcast.episodes;

    return Scaffold(
      appBar: AppBar(
        title: Text(podcast.title),
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
                        podcast.imageUrl,
                        height: 150,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      sanitizedDescription,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Artist: ${podcast.author}',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Feed URL: ${podcast.url}',
                      style: TextStyle(fontSize: 16),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _isSubscribed ? Colors.green : Colors.grey,
                      ),
                      onPressed: () async {
                        if (!_isSubscribed) {
                          Provider.of<PodcastProvider>(context, listen: false)
                              .addPodcast(podcast);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  Text('Subscribed to ${widget.podcast.title}'),
                            ),
                          );
                        }
                        setState(() {
                          _isSubscribed = !_isSubscribed;
                        });
                      },
                      child: Text(_isSubscribed ? 'Subscribed' : 'Subscribe'),
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
                      itemCount: episodes.length,
                      itemBuilder: (context, index) {
                        final episode = episodes[index];

                        return ListTile(
                          title: Text(
                            episode.title,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PodcastPlayerScreen(podcastEpisode: episode),
                              ),
                            );
                          },
                          subtitle: Text('Published on: ${episode.pubDate}'),
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
