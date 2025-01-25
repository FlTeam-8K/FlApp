class Episode {
  final int id;
  final int episodeNumber;
  final String url144p;
  final String url240p;
  final String url360p;
  final String url480p;
  final String url720p;
  final String title;
  final String thumbnail;
  final String releaseDate;

  Episode({
    required this.id,
    required this.episodeNumber,
    required this.url144p,
    required this.url240p,
    required this.url360p,
    required this.url480p,
    required this.url720p,
    required this.title,
    required this.thumbnail,
    required this.releaseDate,
  });

  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      id: int.parse(json['id']),
      episodeNumber: int.parse(json['episode_number']),
      url144p: json['url144p'],
      url240p: json['url240p'],
      url360p: json['url360p'],
      url480p: json['url480p'],
      url720p: json['url720p'],
      title: json['title'],
      thumbnail: json['thumbnail'],
      releaseDate: json['release_date'],
    );
  }
}
