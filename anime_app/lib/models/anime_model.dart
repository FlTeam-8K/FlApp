class Anime {
  final int id;
  final String titleRomaji;
  final String titleEnglish;
  final String titleJapanese;
  final String titleIndonesian;
  final String thumbnail;
  final String cover;
  final String synopsis;
  final String type;
  final String source;
  final String status;
  final String airingFrom;
  final String? airingTo; // Nullable karena airing_to bisa kosong
  final String duration;
  final String rating;
  final double score;
  final String season;
  final int year;
  final List<String> producers;
  final List<String> licensors;
  final List<String> studios;
  final List<String> genres;
  final List<String> explicitGenres;
  final List<String> demographics;
  final List<String> themes;

  Anime({
    required this.id,
    required this.titleRomaji,
    required this.titleEnglish,
    required this.titleJapanese,
    required this.titleIndonesian,
    required this.thumbnail,
    required this.cover,
    required this.synopsis,
    required this.type,
    required this.source,
    required this.status,
    required this.airingFrom,
    this.airingTo,
    required this.duration,
    required this.rating,
    required this.score,
    required this.season,
    required this.year,
    required this.producers,
    required this.licensors,
    required this.studios,
    required this.genres,
    required this.explicitGenres,
    required this.demographics,
    required this.themes,
  });

  factory Anime.fromJson(Map<String, dynamic> json) {
    // Helper function to parse comma-separated strings into lists
    List<String> parseList(String? value) {
      if (value == null || value.isEmpty) {
        return [];
      }
      return value.split(',').map((item) => item.trim()).toList();
    }

    return Anime(
      id: int.parse(json['id']),
      titleRomaji: json['title_romaji'] ?? 'Unknown Title',
      titleEnglish: json['title_english'] ?? 'Unknown Title',
      titleJapanese: json['title_japanese'] ?? 'Unknown Title',
      titleIndonesian: json['title_indonesian'] ?? 'Unknown Title',
      thumbnail: json['thumbnail_url'] ?? '',
      cover: json['cover_url'] ?? '',
      synopsis: json['synopsis'] ?? 'No synopsis available.',
      type: json['type'] ?? 'Unknown',
      source: json['source'] ?? 'Unknown',
      status: json['status'] ?? 'Unknown',
      airingFrom: json['airing_from'] ?? 'Unknown',
      airingTo: json['airing_to'],
      duration: json['duration'] ?? 'Unknown',
      rating: json['rating'] ?? 'Unknown',
      score: double.tryParse(json['score']?.toString() ?? '0') ?? 0.0,
      season: json['season'] ?? 'Unknown',
      year: int.parse(json['year'] ?? '0'),
      producers: parseList(json['producers']),
      licensors: parseList(json['licensors']),
      studios: parseList(json['studios']),
      genres: parseList(json['genres']),
      explicitGenres: parseList(json['explicit_genres']),
      demographics: parseList(json['demographics']),
      themes: parseList(json['themes']),
    );
  }
}
