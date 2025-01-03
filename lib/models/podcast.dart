import 'package:html/dom.dart';
import 'package:html/parser.dart' as html;

import 'dart:convert';

import 'package:html/parser.dart' as html_parser;

String cleanCDataGlobal(String content) {
  return content
      .replaceAll('<![CDATA[', '') // Remove starting CDATA tag
      .replaceAll(']]>', '') // Remove ending CDATA tag
      .trim(); // Remove extra whitespace
}

String extractPlainText(String htmlContent) {
  final document = html_parser.parse(cleanCDataGlobal(htmlContent));
  return document.body?.text ?? '';
}

String normalizeString(String input) {
  return utf8.decode(input.runes.toList());
}

class PodcastEpisode {
  final String title;
  final String audioUrl;
  final String pubDate;

  PodcastEpisode({
    required this.title,
    required this.audioUrl,
    required this.pubDate,
  });

  factory PodcastEpisode.fromJson(Map<String, dynamic> json) {
    return PodcastEpisode(
      title: json['title'],
      audioUrl: json['audioUrl'],
      pubDate: json['pubDate'],
    );
  }

  factory PodcastEpisode.fromRss(Element item) {
    final title = item.getElementsByTagName('title').first.text;
    final audioUrl = item.getElementsByTagName('enclosure').isNotEmpty
        ? item.getElementsByTagName('enclosure').first.attributes['url']
        : null;
    final pubDate = item.getElementsByTagName('pubDate').isNotEmpty
        ? item.getElementsByTagName('pubDate').first.text
        : 'Unknown Date';

    return PodcastEpisode(
      title: normalizeString(title),
      audioUrl: audioUrl ?? '',
      pubDate: pubDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'audioUrl': audioUrl,
      'pubDate': pubDate,
    };
  }
}

class Podcast {
  final String url;
  final String title;
  final String description;
  final String author;
  final String imageUrl;
  final List<PodcastEpisode> episodes;

  Podcast({
    required this.url,
    required this.title,
    required this.description,
    required this.author,
    required this.imageUrl,
    required this.episodes,
  });

  factory Podcast.fromJson(Map<String, dynamic> json) {
    var episodesJson = json['episodes'] as List<dynamic>;
    List<PodcastEpisode> episodes = episodesJson.map((episodeJson) {
      return PodcastEpisode.fromJson(episodeJson as Map<String, dynamic>);
    }).toList();

    return Podcast(
      url: json['url'],
      title: json['title'],
      description: json['description'],
      author: json['author'],
      imageUrl: json['imageUrl'],
      episodes: episodes,
    );
  }

  factory Podcast.fromRss(String url, String rssBody) {
    final document = html.parse(rssBody);
    final items = document.getElementsByTagName('item');

    final episodes = items.map((item) {
      return PodcastEpisode.fromRss(item);
    }).toList();

    String finalimageUrl = '';
    final imageElement = document.querySelector('itunes\\:image');
    if (imageElement != null) {
      final imageUrl = imageElement.attributes['href'];
      if (imageUrl != null) {
        finalimageUrl = imageUrl;
      }
    }

    return Podcast(
      url: url,
      title: normalizeString(document.getElementsByTagName('title').first.text),
      description: extractPlainText(
          document.getElementsByTagName('description').first.text),
      author: document.getElementsByTagName('itunes\\:author').first.text,
      imageUrl: finalimageUrl,
      episodes: episodes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'title': title,
      'description': description,
      'author': author,
      'imageUrl': imageUrl,
      'episodes': episodes,
    };
  }
}
