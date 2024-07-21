// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:music_player/components/neu_box.dart';
import 'package:music_player/model/playlist_provider.dart';
import 'package:provider/provider.dart';

class SongView extends StatelessWidget {
  const SongView({super.key});

  String formatTime(Duration duration) {
    String twoDigitSeconds =
        duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    String formattedTime = '${duration.inMinutes}:$twoDigitSeconds';
    return formattedTime;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PlaylistProvider>(builder: (context, value, child) {
      final playlist = value.playlists;
      final currentSong = playlist[value.currentSongIndex ?? 0];

      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.only(left: 25, right: 25, bottom: 25),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(Icons.arrow_back_ios_sharp),
                      ),
                      Spacer(),
                      Text(
                        'MUSIC',
                        style: TextStyle(fontSize: 20),
                      ),
                      Spacer(),
                    ],
                  ),
                  SizedBox(height: 35),
                  NeuBox(
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(currentSong.albumArtImagePath),
                        ),
                        Padding(
                          padding: EdgeInsets.all(15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    currentSong.songName,
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSecondary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                  Text(
                                    currentSong.artistName,
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSecondary,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                              Icon(Icons.favorite, color: Colors.red),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 35),
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(formatTime(value.currentDuration)),
                            Icon(Icons.shuffle),
                            Icon(Icons.repeat),
                            Text(formatTime(value.totalDuration)),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 5,
                          thumbShape:
                              RoundSliderThumbShape(enabledThumbRadius: 0),
                        ),
                        child: Slider(
                          value: value.currentDuration.inSeconds.toDouble(),
                          min: 0,
                          max: value.totalDuration.inSeconds.toDouble(),
                          activeColor: Color.fromARGB(255, 4, 0, 233),
                          onChanged: (double val) {
                            value.seek(Duration(seconds: val.toInt()));
                          },
                          onChangeEnd: (double val) {
                            value.seek(Duration(seconds: val.toInt()));
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            value.playPreviousSong();
                          },
                          child: NeuBox(child: Icon(Icons.skip_previous)),
                        ),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        flex: 2,
                        child: GestureDetector(
                          onTap: () {
                            value.pauseOrResume();
                          },
                          child: NeuBox(
                            child: Icon(
                              value.isPlaying ? Icons.pause : Icons.play_arrow,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            value.playNextSong();
                          },
                          child: NeuBox(child: Icon(Icons.skip_next)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
