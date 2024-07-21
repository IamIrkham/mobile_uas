import 'dart:io';

import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:image_picker/image_picker.dart';

class VideoPlayersScreen extends StatefulWidget {
  const VideoPlayersScreen({Key? key}) : super(key: key);

  @override
  _VideoPlayersScreenState createState() => _VideoPlayersScreenState();
}

class _VideoPlayersScreenState extends State<VideoPlayersScreen> {
  final List<Map<String, dynamic>> _videos = [
    {
      'url': 'https://www.youtube.com/watch?v=73_1biulkYk',
      'title': 'Deadpool & Wolverine | Official Trailer | In Theaters July 26',
      'dataSourceType': DataSourceType.youtube,
    },
  ];

  File? _pickedImage;

  Future<void> _pickVideo() async {
    final ImagePicker picker = ImagePicker();
    final XFile? video = await picker.pickVideo(source: ImageSource.gallery);

    if (video != null) {
      setState(() {
        _videos.add({
          'url': video.path,
          'title': 'Picked Video',
          'dataSourceType': DataSourceType.asset,
        });
      });
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _pickedImage = File(image.path);
      });
    }
  }

  void _showFullScreenImage() {
    if (_pickedImage != null) {
      showDialog(
        context: context,
        builder: (context) => Dialog(
          child: Stack(
            children: [
              Positioned.fill(
                child: InteractiveViewer(
                  child: Image.file(
                    _pickedImage!,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                PickVideoButton(onPressed: _pickVideo),
                const SizedBox(height: 16),
                PickImageButton(onPressed: _pickImage),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _videos.length + 1, // Add 1 for the image
              itemBuilder: (context, index) {
                if (index < _videos.length) {
                  final video = _videos[index];
                  return Column(
                    children: [
                      VideoPlayerView(
                        url: video['url'],
                        title: video['title'],
                        dataSourceType: video['dataSourceType'],
                      ),
                      const SizedBox(height: 20),
                    ],
                  );
                } else if (_pickedImage != null) {
                  return GestureDetector(
                    onTap: _showFullScreenImage,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Image.file(
                        _pickedImage!,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                } else {
                  return SizedBox.shrink(); // Empty widget
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class VideoPlayerView extends StatefulWidget {
  const VideoPlayerView({
    Key? key,
    required this.url,
    required this.title,
    required this.dataSourceType,
  }) : super(key: key);

  final String url;
  final String title;
  final DataSourceType dataSourceType;

  @override
  State<VideoPlayerView> createState() => _VideoPlayerViewState();
}

class _VideoPlayerViewState extends State<VideoPlayerView> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  YoutubePlayerController? _youtubeController;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    debugPrint('Initializing video player for ${widget.url}');

    if (widget.dataSourceType == DataSourceType.network) {
      _videoPlayerController = VideoPlayerController.network(widget.url);
    } else if (widget.dataSourceType == DataSourceType.asset) {
      _videoPlayerController = VideoPlayerController.file(File(widget.url));
    } else if (widget.dataSourceType == DataSourceType.youtube) {
      _youtubeController = YoutubePlayerController(
        initialVideoId: YoutubePlayer.convertUrlToId(widget.url)!,
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
        ),
      );
      _isInitialized = true;
    } else {
      throw UnsupportedError("Unsupported data source type");
    }

    if (widget.dataSourceType != DataSourceType.youtube) {
      _videoPlayerController.initialize().then((_) {
        debugPrint('Video player initialized for ${widget.url}');
        setState(() {
          _chewieController = ChewieController(
            videoPlayerController: _videoPlayerController,
            aspectRatio: _videoPlayerController.value.aspectRatio,
            autoInitialize: true,
            looping: true,
            autoPlay: false,
            materialProgressColors: ChewieProgressColors(
              playedColor: Theme.of(context).primaryColor,
              handleColor: Theme.of(context).primaryColor,
              backgroundColor: Colors.grey,
              bufferedColor: Colors.lightGreen,
            ),
          );
          _isInitialized = true;
        });
      }).catchError((error) {
        debugPrint('Error initializing video player: $error');
        setState(() {
          _isInitialized = false;
        });
      });
    }
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    _youtubeController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              widget.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: _isInitialized
                  ? (widget.dataSourceType == DataSourceType.youtube
                      ? YoutubePlayer(controller: _youtubeController!)
                      : Chewie(controller: _chewieController!))
                  : const Center(child: CircularProgressIndicator()),
            ),
          ),
        ],
      ),
    );
  }
}

enum DataSourceType { network, asset, youtube }

class PickVideoButton extends StatelessWidget {
  final VoidCallback onPressed;

  const PickVideoButton({Key? key, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.video_library),
      label: const Text('Pick Video from Gallery'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
        textStyle: const TextStyle(fontSize: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}

class PickImageButton extends StatelessWidget {
  final VoidCallback onPressed;

  const PickImageButton({Key? key, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.photo_library),
      label: const Text('Pick Photo from Gallery'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
        textStyle: const TextStyle(fontSize: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
