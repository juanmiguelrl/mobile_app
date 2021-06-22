import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class Status {
  final String type;
  final String text;

  Status({this.type, this.text});

  factory Status.fromJson(Map<String, dynamic> json) {
    return Status(
      type: json['type'],
      text: json['text'],
    );
  }
}

class Tag {
  final double confidence;
  final String tagName;

  Tag({this.confidence, this.tagName});

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      confidence: json['confidence'].toDouble(),
      tagName: json['tag']['en'],
    );
  }
}

class Response {
  final List<Tag> tags;
  final Status status;

  Response({this.tags, this.status});

  factory Response.fromJson(Map<String, dynamic> json) {
    var tagsList = json['result']['tags'] as List;

    return Response(
      tags: tagsList.map((i) => Tag.fromJson(i)).toList(),
      status: Status.fromJson(json['status']),
    );
  }
}

class ClientModel {
  static final String _apiUrl = 'https://api.imagga.com/v2/tags';
  static final String _apiKey = 'Basic YWNjXzllM2RkOTg3ZjQ1Mzk2ZjoxZTcwMzc5NzMzZDkzOWY1NGJjNGM1MGJmZmQ3MTMwMg==';
  static final int timeout = 30;  // in seconds

  static Future<Response> fetchResult(File file) async {
    final response = await http.post(
      _apiUrl,
      headers: {HttpHeaders.authorizationHeader: _apiKey},
      body: {"image_base64": base64Encode(file.readAsBytesSync())},
    ).timeout(
      Duration(seconds: timeout),
    );

    if (response.statusCode == 200) {
      return Response.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Failed to load tags (code=${response.statusCode}");
    }
  }
}
