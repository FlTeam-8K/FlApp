import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:permission_handler/permission_handler.dart';
import 'api/api_service.dart';
import 'models/anime_model.dart';
import 'models/episode_model.dart';
import 'package:http/http.dart' as http;

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fansub Loader Anime',
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.blueGrey[900],
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blueGrey[900],
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.blueGrey[900],
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey[600],
        ),
      ),
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(),
    AnimeListScreen(),
    PlaceholderScreen(title: "Jadwal Rilis"),
    PlaceholderScreen(title: "User"),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.list), label: "Daftar Anime"),
          BottomNavigationBarItem(
              icon: Icon(Icons.schedule), label: "Jadwal Rilis"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "User"),
        ],
        selectedItemColor: Colors.deepPurple, // Warna saat aktif
        unselectedItemColor: Colors.grey, // Warna saat tidak aktif
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Home")),
      body: Center(
        child: Text(
          "Selamat Datang di Home!",
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }
}

class AnimeListScreen extends StatefulWidget {
  @override
  _AnimeListScreenState createState() => _AnimeListScreenState();
}

class _AnimeListScreenState extends State<AnimeListScreen> {
  late Future<List<Anime>> _animeListFuture;
  String selectedLetter = 'A';

  @override
  void initState() {
    super.initState();
    _animeListFuture = ApiService.fetchAnimeList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildAlphabetButtons(),
            Expanded(
              child: FutureBuilder<List<Anime>>(
                future: _animeListFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: Colors.deepPurple, // Match app theme
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: TextStyle(color: Colors.red),
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Text(
                        'No anime available.',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    );
                  } else {
                    // Filter anime by selected letter
                    List<Anime> filteredAnime = snapshot.data!.where((anime) {
                      return anime.titleRomaji
                          .toUpperCase()
                          .startsWith(selectedLetter);
                    }).toList();

                    if (filteredAnime.isEmpty) {
                      return Center(
                        child: Text(
                          'No anime found for this letter.',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      );
                    }

                    return Padding(
                      padding: const EdgeInsets.all(16.0), // Increased padding
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, // Reduced to 2 for better spacing
                          crossAxisSpacing: 16.0,
                          mainAxisSpacing: 16.0,
                          childAspectRatio:
                              0.7, // Adjusted for better proportions
                        ),
                        itemCount: filteredAnime.length,
                        itemBuilder: (context, index) {
                          Anime anime = filteredAnime[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EpisodeScreen(
                                    animeId: anime.id,
                                  ),
                                ),
                              );
                            },
                            child: Card(
                              elevation: 4, // Add shadow for depth
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(12.0),
                                      ),
                                      child: Image.network(
                                        anime.cover,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      anime.titleRomaji,
                                      maxLines:
                                          2, // Allow 2 lines for longer titles
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlphabetButtons() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      color: Colors.deepPurple.withOpacity(0.1), // Subtle background
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(26, (index) {
            String letter = String.fromCharCode(65 + index); // A-Z
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    selectedLetter = letter;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedLetter == letter
                      ? Colors.deepPurple
                      : Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: Text(
                  letter,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class EpisodeScreen extends StatelessWidget {
  final int animeId;

  const EpisodeScreen({required this.animeId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>>(
        future: ApiService.fetchEpisode(animeId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              appBar: AppBar(title: Text("Loading...")),
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (snapshot.hasError) {
            return Scaffold(
              appBar: AppBar(title: Text("Error")),
              body: Center(child: Text("Error: ${snapshot.error}")),
            );
          } else {
            final anime = snapshot.data!['anime'] as Anime;
            final episodes = snapshot.data!['episodes'] as List<Episode>;

            return DefaultTabController(
              length: 3, // 3 Tabs: Overview, Episodes, and Comments
              child: Scaffold(
                appBar: AppBar(
                  title:
                      Text(anime.titleRomaji), // Menampilkan judul Romaji anime
                  bottom: TabBar(
                    tabs: [
                      Tab(text: "Overview"),
                      Tab(text: "Episodes"),
                      Tab(text: "Comments"), // Placeholder for comments
                    ],
                  ),
                ),
                body: TabBarView(
                  children: [
                    // Overview Tab
                    SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.network(
                              anime.thumbnail,
                              height: 180,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                            SizedBox(height: 10),
                            Text(
                              anime.titleRomaji,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Genres: ${anime.genres.join(', ')}',
                              style: TextStyle(color: Colors.white70),
                            ),
                            SizedBox(height: 16),
                            Text(
                              anime.synopsis,
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Episodes Tab
                    SingleChildScrollView(
                      child: Column(
                        children: episodes.map((episode) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => WatchScreen(
                                    url144p: episode.url144p,
                                    url240p: episode.url240p,
                                    url360p: episode.url360p,
                                    url480p: episode.url480p,
                                    url720p: episode.url720p,
                                    title: episode.title,
                                    episodeNumber: episode.episodeNumber,
                                    episodes: episodes
                                        .map((e) => {
                                              'episodeNumber': e.episodeNumber,
                                              'title': e.title,
                                              'thumbnail': anime.thumbnail,
                                              'url144p': e.url144p,
                                              'url240p': e.url240p,
                                              'url360p': e.url360p,
                                              'url480p': e.url480p,
                                              'url720p': e.url720p,
                                            })
                                        .toList(),
                                  ),
                                ),
                              );
                            },
                            child: Card(
                              color: Colors.blueGrey[800],
                              margin: EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: Image.network(
                                      episode.thumbnail,
                                      width: double.infinity,
                                      height: 180,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      "Episode ${episode.episodeNumber}: ${episode.title}",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: Text(
                                      "Duration: 34 minutes",
                                      style: TextStyle(color: Colors.white70),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: Text(
                                      "Release Date: ${episode.releaseDate}",
                                      style: TextStyle(color: Colors.white70),
                                    ),
                                  ),
                                  SizedBox(height: 12),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    // Comments Tab
                    SingleChildScrollView(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            "Comments will be implemented later.",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}

class PlaceholderScreen extends StatelessWidget {
  final String title;

  const PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          "Halaman $title belum tersedia.",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

class WatchScreen extends StatefulWidget {
  final String url144p;
  final String url240p;
  final String url360p;
  final String url480p;
  final String url720p;
  final String title;
  final int episodeNumber;
  final List<Map<String, dynamic>> episodes;

  const WatchScreen({
    required this.url144p,
    required this.url240p,
    required this.url360p,
    required this.url480p,
    required this.url720p,
    required this.title,
    required this.episodeNumber,
    required this.episodes,
    Key? key,
  }) : super(key: key);

  @override
  State<WatchScreen> createState() => _WatchScreenState();
}

class _WatchScreenState extends State<WatchScreen> {
  late VideoPlayerController _videoPlayerController;
  late ChewieController _chewieController;

  List<String> _qualities = [];
  String? _selectedQuality;

  @override
  void initState() {
    super.initState();
    _qualities = [
      widget.url144p,
      widget.url240p,
      widget.url360p,
      widget.url480p,
      widget.url720p,
    ];
    _selectedQuality = _qualities.first; // Set kualitas default
    _initializePlayer(
        _selectedQuality!); // Inisialisasi player dengan kualitas pertama
  }

  void _initializePlayer(String url) {
    _videoPlayerController = VideoPlayerController.network(url);
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: true,
      looping: true,
    );
  }

  void _changeQuality(String qualityUrl) {
    _chewieController.dispose(); // Dispose the current controller
    _initializePlayer(qualityUrl); // Initialize with the new quality
    setState(() {
      _selectedQuality = qualityUrl; // Update selected quality
    });
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Jumlah tab
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Column(
            children: [
              // Chewie for Video Playback with 16:9 aspect ratio
              Expanded(
                child: Chewie(
                  controller: _chewieController,
                ),
              ),

              // Episode Title
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Episode ${widget.episodeNumber}: ${widget.title}",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),

              // Feature Buttons: Quality Selection and Download
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Dropdown untuk memilih kualitas
                  DropdownButton<String>(
                    value: _selectedQuality,
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        _changeQuality(newValue);
                      }
                    },
                    items: _qualities
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                            value.split('/').last), // Menampilkan nama kualitas
                      );
                    }).toList(),
                  ),

                  // Tombol Download
                  //ElevatedButton.icon(
                  // onPressed: _downloadCurrentVideo,
                  // icon: Icon(Icons.download),
                  // label: Text("Download"),
                  //),
                ],
              ),

              // TabBar
              TabBar(
                tabs: [
                  Tab(text: "Episodes"),
                  Tab(text: "Comments"),
                ],
                indicatorColor: Colors.blue,
              ),

              // TabBarView for Episodes and Comments
              Expanded(
                child: TabBarView(
                  children: [
                    // Episodes Tab
                    widget.episodes.isEmpty
                        ? Center(
                            child: Text(
                              "No episodes available",
                              style: TextStyle(color: Colors.white),
                            ),
                          )
                        : ListView.builder(
                            itemCount: widget.episodes.length,
                            itemBuilder: (context, index) {
                              final episode = widget.episodes[index];
                              return Card(
                                color: Colors.blueGrey[800],
                                margin: EdgeInsets.symmetric(
                                    horizontal: 8.0, vertical: 4.0),
                                child: ListTile(
                                  leading: ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: Image.network(
                                      episode['thumbnail'],
                                      width: 50,
                                      height: 75,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) => Icon(
                                              Icons.broken_image,
                                              color: Colors.white70,
                                              size: 50),
                                    ),
                                  ),
                                  title: Text(
                                    "Episode ${episode['episodeNumber']}: ${episode['title']}",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  onTap: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => WatchScreen(
                                          url144p: episode['url144p'],
                                          url240p: episode['url240p'],
                                          url360p: episode['url360p'],
                                          url480p: episode['url480p'],
                                          url720p: episode['url720p'],
                                          title: episode['title'],
                                          episodeNumber:
                                              episode['episodeNumber'],
                                          episodes: widget.episodes,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),

                    // Comments Tab
                    Center(
                      child: Text(
                        "Comments feature is under development!",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
