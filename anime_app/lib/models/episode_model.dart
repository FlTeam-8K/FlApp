class Episode {
  final int id;
  final int episodeNumber;
  final String videoUrl360p;
  final String videoUrl480p;
  final String videoUrl720p;
  final String title;
  final String thumbnail;
  final String releaseDate;

  Episode({
    required this.id,
    required this.episodeNumber,
    required this.videoUrl360p,
    required this.videoUrl480p,
    required this.videoUrl720p,
    required this.title,
    required this.thumbnail,
    required this.releaseDate,
  });

  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      id: int.parse(json['id']),
      episodeNumber: int.parse(json['episode_number']),
      videoUrl360p: json['360p_url'],
      videoUrl480p: json['480p_url'],
      videoUrl720p: json['720p_url'],
      title: json['title'],
      thumbnail: json['thumbnail'],
      releaseDate: json['release_date'],
    );
  }
}
