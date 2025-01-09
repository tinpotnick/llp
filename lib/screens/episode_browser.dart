import 'package:path_provider/path_provider.dart';

import 'package:dio/dio.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html;

class EpisodeBrowserScreen extends StatefulWidget {
  final String feedUrl;

  const EpisodeBrowserScreen({super.key, required this.feedUrl});

  @override
  EpisodeBrowserScreenState createState() => EpisodeBrowserScreenState();
}

class EpisodeBrowserScreenState extends State<EpisodeBrowserScreen> {
  List<Map<String, String>> _episodes = [];
  bool _isLoading = true;

  Future<void> _fetchEpisodes() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse(widget.feedUrl));
      if (response.statusCode == 200) {
        final document = html.parse(response.body);
        final items = document.getElementsByTagName('item');

        final episodes = items.map((item) {
          final title = item.getElementsByTagName('title').first.text;
          final audioUrl = item.getElementsByTagName('enclosure').isNotEmpty
              ? item.getElementsByTagName('enclosure').first.attributes['url']
              : null;
          return {
            'title': title,
            'audioUrl': audioUrl ?? '',
          };
        }).toList();

        setState(() {
          _episodes = episodes;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to fetch episodes')));
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _downloadEpisode(String audioUrl, String filename) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final filePath = '${dir.path}/$filename';

      Dio dio = Dio();
      await dio.download(audioUrl, filePath);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Downloaded: $filename')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Download failed')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchEpisodes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Episodes'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _episodes.length,
              itemBuilder: (context, index) {
                final episode = _episodes[index];
                return ListTile(
                  title: Text(episode['title'] ?? 'Unknown Title'),
                  trailing: IconButton(
                    icon: Icon(Icons.download),
                    onPressed: () => _downloadEpisode(
                      episode['audioUrl']!,
                      '${episode['title']}.mp3',
                    ),
                  ),
                );
              },
            ),
    );
  }
}
