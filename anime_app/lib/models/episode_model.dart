class Episode {
  final int id;
  final int episodeNumber;
  final String embedUrl;
  final String title;
  final String thumbnail;
  final String releaseDate;

  Episode({
    required this.id,
    required this.episodeNumber,
    required this.embedUrl,
    required this.title,
    required this.thumbnail,
    required this.releaseDate,
  });

  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      id: int.parse(json['id']),
      episodeNumber: int.parse(json['episode_number']),
      embedUrl: json['embed'],
      title: json['title'],
      thumbnail: json['thumbnail'],
      releaseDate: json['release_date'],
    );
  }
}
