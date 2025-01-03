import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/podcast.dart';

class ItunePodcast {
  final String name;
  final String artistName;
  final String artworkUrl100;
  final String artworkUrl600;
  final String feedUrl;
  final int collectionId;
  final String collectionName;

  ItunePodcast({
    required this.name,
    required this.artistName,
    required this.artworkUrl100,
    required this.artworkUrl600,
    required this.feedUrl,
    required this.collectionId,
    required this.collectionName,
  });

  factory ItunePodcast.fromJson(Map<String, dynamic> json) {
    return ItunePodcast(
      name: json['collectionName'],
      artistName: json['artistName'],
      artworkUrl100: json['artworkUrl100'],
      artworkUrl600: json['artworkUrl600'],
      feedUrl: json['feedUrl'],
      collectionId: json['collectionId'],
      collectionName: json['collectionName'],
    );
  }
}

class PodcastService {
  // Fetch the podcast list from a podcast directory API
  static Future<List<ItunePodcast>> fetchPodcastList(query) async {
    final url =
        Uri.parse('https://itunes.apple.com/search?term=$query&media=podcast');

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch podcast list');
    }

    final data = json.decode(response.body);
    return (data['results'] as List)
        .map((podcast) => ItunePodcast.fromJson(podcast))
        .toList();
  }

  static Future<Podcast> fetchPodcastDetails(ipod) async {
    if (ipod is Podcast) {
      return ipod;
    }

    if (ipod is! ItunePodcast) {
      throw Exception('Invalid podcast type');
    }

    final response = await http.get(Uri.parse(ipod.feedUrl));

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch podcast details');
    }

    return Podcast.fromRss(ipod.feedUrl, response.body);
  }
}
