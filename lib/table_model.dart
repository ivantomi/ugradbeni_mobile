import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Album {
  final String userId;
  final String name;
  final String lastAccessed;

  const Album({
    required this.userId,
    required this.name,
    required this.lastAccessed,
  });

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      userId: json['userId'],
      name: json['name'],
      lastAccessed: json['lastAccessed'],
    );
  }
}

Future<List<Album>> fetchAlbums() async {
  final response = await http
      .get(Uri.parse('https://6561a305dcd355c0832401ab.mockapi.io/demo/album'));

  if (response.statusCode == 200) {
    Iterable list = json.decode(response.body);
    return List<Album>.from(list.map((model) => Album.fromJson(model)));
  } else {
    throw Exception('Failed to load albums');
  }
}
