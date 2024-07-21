import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'song_model.dart';

class PlaylistProvider extends ChangeNotifier {
  final List<Song> playlists = [
    Song(
        songName: "So Sick",
        artistName: "Neyo",
        albumArtImagePath: "assets/images/1.png",
        audioPath: "audio/song.mp3"),
    Song(
        songName: "Acid Rap",
        artistName: "Chance The Rapper",
        albumArtImagePath: "assets/images/2.png",
        audioPath: "audio/song1.mp3"),
    Song(
        songName: "Pheonix",
        artistName: "ASAP Rocky",
        albumArtImagePath: "assets/images/3.png",
        audioPath: "audio/song2.mp3"),
  ];

  int? currentSongIndex;
  List<Song> get getPlaylist => playlists;
  int? get getCurrentSongIndex => currentSongIndex;
  bool get getIsPlaying => isPlaying;
  Duration get getCurrentDuration => currentDuration;
  Duration get getTotalDuration => totalDuration;

  set setCurrentSongIndex(int? index) {
    currentSongIndex = index;
    if (index != null) {
      play();
    }
    notifyListeners();
  }

  final audioPlayer = AudioPlayer();
  Duration currentDuration = Duration.zero;
  Duration totalDuration = Duration.zero;

  PlaylistProvider() {
    listenToDuration();
  }

  bool isPlaying = false;

  void play() async {
    String audioPath = playlists[currentSongIndex!].audioPath;
    await audioPlayer.play(AssetSource(audioPath));
    isPlaying = true;
    notifyListeners();
  }

  void pause() async {
    await audioPlayer.pause();
    isPlaying = false;
    notifyListeners();
  }

  void resume() async {
    await audioPlayer.resume();
    isPlaying = true;
    notifyListeners();
  }

  void pauseOrResume() {
    if (isPlaying) {
      pause();
    } else {
      resume();
    }
  }

  void seek(Duration position) async {
    await audioPlayer.seek(position);
  }

  void playNextSong() async {
    if (currentSongIndex != null) {
      currentSongIndex = (currentSongIndex! + 1) % playlists.length;
      play();
    }
  }

  void playPreviousSong() async {
    if (currentDuration.inSeconds > 2) {
      seek(Duration.zero);
    } else {
      if (currentSongIndex != null) {
        currentSongIndex =
            (currentSongIndex! - 1 + playlists.length) % playlists.length;
        play();
      }
    }
  }

  void listenToDuration() {
    audioPlayer.onDurationChanged.listen((newDuration) {
      totalDuration = newDuration;
      notifyListeners();
    });

    audioPlayer.onPositionChanged.listen((newPosition) {
      currentDuration = newPosition;
      notifyListeners();
    });

    audioPlayer.onPlayerComplete.listen((event) {
      playNextSong();
    });
  }
}
