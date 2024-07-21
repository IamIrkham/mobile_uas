// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:music_player/model/playlist_provider.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';

import '../model/song_model.dart';
import 'song.dart';
import 'video_page.dart';
import 'camera_screen.dart';

class HomeView extends StatefulWidget {
  final List<CameraDescription> cameras;
  const HomeView({super.key, required this.cameras});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late final PlaylistProvider playlistProvider;
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    playlistProvider = Provider.of<PlaylistProvider>(context, listen: false);
    _pages = [
      PlaylistPage(),
      VideoPlayersScreen(),
      CameraScreen(cameras: widget.cameras),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(
          'MyApp',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 4, 0, 233),
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _pages[_selectedIndex],
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.music_note_rounded),
            label: 'Music',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.video_library_rounded),
            label: 'Library',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: 'Camera',
          ),
        ],
      ),
    );
  }
}

class PlaylistPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<PlaylistProvider>(builder: (context, value, child) {
      final List<Song> playlist = value.getPlaylist;
      return ListView.builder(
        itemCount: playlist.length,
        itemBuilder: (context, index) {
          final Song song = playlist[index];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 15),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.all(10),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  song.albumArtImagePath,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),
              title: Text(
                song.songName,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Text(song.artistName),
              trailing: Icon(Icons.play_arrow_rounded,
                  color: Theme.of(context).primaryColor),
              onTap: () {
                final playlistProvider =
                    Provider.of<PlaylistProvider>(context, listen: false);
                playlistProvider.setCurrentSongIndex = index;
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => SongView()));
              },
            ),
          );
        },
      );
    });
  }
}
