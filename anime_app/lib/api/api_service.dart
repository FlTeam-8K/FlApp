import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/anime_model.dart';
import '../models/episode_model.dart';

class ApiService {
  static const String baseUrl = "https://fansubloader.my.id/anime_api";

  /// Mengambil daftar anime dari API
  static Future<List<Anime>> fetchAnimeList() async {
    final response = await http.get(Uri.parse("$baseUrl/get_animes.php"));

    if (response.statusCode == 200) {
      final List<dynamic> animeData = json.decode(response.body);
      return animeData.map((json) => Anime.fromJson(json)).toList();
    } else {
      throw Exception("Failed to load anime list");
    }
  }

  /// Mengambil data anime dan episode berdasarkan anime ID
  static Future<Map<String, dynamic>> fetchEpisode(int animeId) async {
    final response = await http
        .get(Uri.parse("$baseUrl/get_episodes.php?anime_id=$animeId"));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final anime = Anime.fromJson(data['anime']);
      final episodes = (data['episodes'] as List<dynamic>)
          .map((json) => Episode.fromJson(json))
          .toList();

      return {
        'anime': anime,
        'episodes': episodes,
      };
    } else {
      throw Exception("Failed to load anime and episodes");
    }
  }

  /// Mengambil daftar episode berdasarkan anime ID
  static Future<List<Episode>> fetchEpisodes(int animeId) async {
    final response = await http
        .get(Uri.parse("$baseUrl/get_episodes.php?anime_id=$animeId"));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => Episode.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load episodes");
    }
  }
}
