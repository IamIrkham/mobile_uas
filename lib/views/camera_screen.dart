// ignore_for_file: unused_field, unused_import

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'dart:io';
import 'package:path/path.dart' as p;

class CameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  const CameraScreen({Key? key, required this.cameras}) : super(key: key);

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  late String videoPath;
  bool _isRecordingVideo = false;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.cameras[0],
      ResolutionPreset.medium,
    );
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    try {
      await _initializeControllerFuture;

      final XFile picture = await _controller.takePicture();

      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/${DateTime.now().toIso8601String()}.png';

      File(picture.path).copySync(path);
      await GallerySaver.saveImage(path);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Picture saved to gallery'),
        ),
      );
    } catch (e) {
      print(e);
    }
  }

  Future<void> _startVideoRecording() async {
    try {
      await _initializeControllerFuture;

      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final path = '${directory.path}/$timestamp.mp4';

      await _controller.startVideoRecording();
      setState(() {
        _isRecordingVideo = true;
        videoPath = path;
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> _stopVideoRecording() async {
    try {
      if (!_isRecordingVideo) return;

      final XFile video = await _controller.stopVideoRecording();
      setState(() {
        _isRecordingVideo = false;
      });

      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/${DateTime.now().toIso8601String()}.mp4';

      File(video.path).copySync(path);
      await GallerySaver.saveVideo(path);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Video saved to gallery'),
        ),
      );
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return CameraPreview(_controller);
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: Align(
        alignment: Alignment.bottomCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FloatingActionButton(
              onPressed: _isRecordingVideo
                  ? _stopVideoRecording
                  : _startVideoRecording,
              child: Icon(_isRecordingVideo ? Icons.stop : Icons.videocam),
            ),
            SizedBox(width: 20),
            FloatingActionButton(
              onPressed: _takePicture,
              child: const Icon(Icons.camera_alt),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
