

import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:llp/models/podcast.dart';
import 'package:llp/models/flashcard.dart';
import 'package:llp/providers/flashcard_provider.dart';


class TranscribedItem {
  final String original;
  final String translated;
  final double seek;
  final Duration start;
  final Duration end;

  TranscribedItem({
    required this.original,
    required this.translated,
    required this.seek,
    required this.start,
    required this.end,
  });

  factory TranscribedItem.fromJson(Map<String, dynamic> json) {
    return TranscribedItem(
      original: json['original'],
      translated: json['translated'],
      start: (json['start'] is int) ? (Duration(seconds: json['start'])) : Duration(milliseconds: json['start'] * 1000 ),
      end: (json['end'] is int) ? (Duration(seconds: json['end'])) : Duration(milliseconds: json['end'] * 1000 ),
      seek: (json['seek'] is int) ? (json['seek'] as int).toDouble() : json['seek'] as double,
    );
  }
}

class Endpoints {
  final String putUrl;
  final String getUrl;

  // Constructor for creating an ApiUrls object
  Endpoints({required this.putUrl, required this.getUrl});

  // Factory method to create an ApiUrls object from JSON
  factory Endpoints.fromJson(Map<String, dynamic> json) {
    return Endpoints(
      putUrl: json['puturl'] as String,
      getUrl: json['geturl'] as String,
    );
  }
}

String normalizeString(String input) {
  return utf8.decode(input.runes.toList());
}

/*
[{"id":0,"original":"مرحباً وأهلاً وسهلاً فيكم بالموسم الرابع من بودكاست ديوان","translated":"Hello and welcome to the fourth season of the Diwan podcast.","start":0,"end":5}
*/
class TranscribeService {

  static Future<Endpoints> fetchApiUrls(String apiEndpoint, String format) async {
    final url = Uri.parse(apiEndpoint);

    final urlWithParams = url.replace(queryParameters: {
      "format": format
    });

    final response = await http.post(urlWithParams);

    // Check if the response is successful (status code 200)
    if (response.statusCode == 200) {
      // Parse the JSON response
      final Map<String, dynamic> data = json.decode(response.body);

      // Ensure the JSON object contains the expected fields
      if (!data.containsKey('puturl') || !data.containsKey('geturl')) {
        throw Exception('Invalid JSON response: puturl or geturl missing.');
      }

      // Create and return an ApiUrls object
      return Endpoints.fromJson(data);
    } else {
      // Throw an exception if the API call failed
      throw Exception('Failed to fetch API URLs. Status code: ${response.statusCode}');
    }
  }

  static Future<void> uploadFileToUrl(String filePath, String presignedUrl) async {
    final file = File(filePath);

    // Check if the file exists
    if (!file.existsSync()) {
      throw Exception('File does not exist at path: $filePath');
    }

    // Read the file as bytes
    final fileBytes = await file.readAsBytes();

    // Perform an HTTP PUT request to upload to the pre-signed S3 URL
    final response = await http.put(
      Uri.parse(presignedUrl),
      headers: {
        'Content-Type': 'application/octet-stream', // General file content type
      },
      body: fileBytes,
    );

    // Check response status
    if (response.statusCode == 200) {
      print('File successfully uploaded!');
    } else {
      throw Exception('Failed to upload file. Status code: ${response.statusCode}');
    }
  }

  // Fetch the podcast list from a podcast directory API
  static Future<List<TranscribedItem>> fetchTranslations(String transcriptionUrl) async {
    final url = Uri.parse(transcriptionUrl);

    const maxRetryDuration = Duration(minutes: 15);
    const retryDelay = Duration(seconds: 5); // Delay between retries
    final startTime = DateTime.now();

    while (true) {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // Parse and return the response if successful
        final data = json.decode(response.body);
        return (data as List)
            .map((chunk) => TranscribedItem.fromJson(chunk))
            .toList();
      } else if (response.statusCode == 404) {
        // Retry logic for 404 only
        final elapsedTime = DateTime.now().difference(startTime);
        if (elapsedTime >= maxRetryDuration) {
          throw Exception('Max retry duration reached. Failed to fetch translations (404).');
        }

        // Wait and retry
        await Future.delayed(retryDelay);
      } else {
        // Throw an error for other status codes
        throw Exception('Failed to fetch translations. Status code: ${response.statusCode}');
      }
    }
  }

  ///
  /// Taking a podcast url and episode url,
  /// 1. obtain upload and download urls
  /// 2. upload file (and check it falls with workable params)
  /// 3. periodically check for outout
  /// 4. download then parse and add to list
  /// 5. check for duplicates
  ///
  static Future<List<TranscribedItem>> transcribePodcast(PodcastEpisode episode, String localfile,  FlashcardProvider provideor, String format) async {

    // 1.
    //if(false) {

    
    final devapi = "http://localhost:4566/restapis/myid123/prod/_user_request_/get-upload-url";
    final endpoints = await TranscribeService.fetchApiUrls( devapi, format );
    print(endpoints.putUrl);
    print(endpoints.getUrl);
    // 2.
    await TranscribeService.uploadFileToUrl(localfile, endpoints.putUrl);
    //}
    // 3&4. 
    
    final transcribedItems = await TranscribeService.fetchTranslations(endpoints.getUrl);

    for (var item in transcribedItems) {
      print(item.translated);
      provideor.addCard(Flashcard(
        origional: normalizeString(item.original),
        translation: normalizeString(item.translated),
        podcastUrl: episode.podcastUrl,
        episodeUrl: episode.audioUrl,
        start: item.start,
        end: item.end
      ));
    }

    return transcribedItems;
  }
}