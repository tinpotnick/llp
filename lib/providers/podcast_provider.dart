import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/podcast.dart';

class PodcastProvider with ChangeNotifier {
  Map<String, Podcast> _podcasts = {};

  Map<String, Podcast> get podcasts => _podcasts;

  void addPodcast(Podcast podcast) {
    _podcasts[podcast.url] = podcast;
    _saveToStorage();
    notifyListeners();
  }

  PodcastEpisode getPodcastEpisode(Podcast podcast, String url) {
    if( podcast.isEmpty() ) {
      return PodcastEpisode.empty();
    }

    for (int i = 0; i < podcast.episodes.length; i++) {
      if( url == podcast.episodes[i].audioUrl ) {
        return podcast.episodes[i];
      }
    }

    return PodcastEpisode.empty();
  }

  Podcast getPodcast(String url) {
    if( _podcasts.containsKey(url) ) {
      final Podcast pd = _podcasts[url]!;
      return pd;
    }

    return Podcast.empty();
  }

  bool hasPodcast(String url) {
    return _podcasts.containsKey(url);
  }

  void removePodcast(Podcast podcast) {
    _podcasts.remove(podcast.url);
    _saveToStorage();
    notifyListeners();
  }

  void clearPodcasts() {
    _podcasts.clear();
    _saveToStorage();
    notifyListeners();
  }

  Future<void> _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final cardsJson = _podcasts.values.map((pcast) => pcast.toJson()).toList();
    await prefs.setString('podcasts', json.encode(cardsJson));
  }

  Future<void> loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final podcastsJsonstr = prefs.getString('podcasts');
    if (podcastsJsonstr == null) {
      return;
    }

    final List<dynamic> decoded = json.decode(podcastsJsonstr);
    _podcasts = {};

    for (var json in decoded) {
      final podcast = Podcast.fromJson(json);
      _podcasts[podcast.url] = podcast;
    }

    notifyListeners();
  }
}
