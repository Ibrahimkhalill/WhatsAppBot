import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:get_thumbnail_video/index.dart';
import 'package:get_thumbnail_video/video_thumbnail.dart';
import 'package:flutter/foundation.dart'; // for kIsWeb
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerWidget({super.key, required this.videoUrl});

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool _isLoading = true;
  String? _videoThumbnailPath;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        _generateVideoThumbnail(widget.videoUrl); // Generate thumbnail
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openFullscreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            FullscreenVideoPlayer(videoController: _controller),
      ),
    );
  }

  /// Generate thumbnail from the video URL
  Future<void> _generateVideoThumbnail(String videoUrl) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final localVideoPath = '${tempDir.path}/temp_video.mp4';

      // Download the video file
      final response = await http.get(Uri.parse(videoUrl));
      if (response.statusCode == 200) {
        File videoFile = File(localVideoPath);
        await videoFile.writeAsBytes(response.bodyBytes);

        // Generate thumbnail
        XFile? thumbnailPath = await VideoThumbnail.thumbnailFile(
          video: localVideoPath,
          thumbnailPath: tempDir.path,
          imageFormat: ImageFormat.JPEG,
          maxHeight: 100,
          quality: 75,
        );

        // Check if the widget is still mounted before calling setState
        if (mounted && thumbnailPath != null) {
          setState(() {
            _videoThumbnailPath = thumbnailPath.path;
            _isLoading = false;
          });
          debugPrint("✅ Thumbnail generated at: $_videoThumbnailPath");
        }
      } else {
        debugPrint("❌ Failed to download video");
      }
    } catch (e) {
      debugPrint("❌ Error generating thumbnail: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final videoWidth = screenWidth * 0.7; // 70% of the screen width
    final videoHeight = _controller.value.isInitialized
        ? videoWidth / _controller.value.aspectRatio
        : 200.0; // Default height when loading

    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Video Thumbnail Preview
            _isLoading
                ? Container(
                    width: 200,
                    height: 200,
                    color: Colors.black,
                    child: const Center(child: CircularProgressIndicator()),
                  )
                : SizedBox(
                    width: videoWidth,
                    height: videoHeight,
                    child: kIsWeb
                        ? Image.network(_videoThumbnailPath!) // Web support
                        : Image.file(
                            File(_videoThumbnailPath!)), // Mobile support
                  ),

            // Play Icon Overlay
            if (!_isLoading)
              Positioned(
                child: GestureDetector(
                  onTap: () => _openFullscreen(context),
                  child: const Icon(
                    Icons.play_circle_fill,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class FullscreenVideoPlayer extends StatefulWidget {
  final VideoPlayerController videoController;

  const FullscreenVideoPlayer({super.key, required this.videoController});

  @override
  _FullscreenVideoPlayerState createState() => _FullscreenVideoPlayerState();
}

class _FullscreenVideoPlayerState extends State<FullscreenVideoPlayer> {
  late VideoPlayerController _controller;
  bool _isPlaying = true;

  @override
  void initState() {
    super.initState();
    _controller = widget.videoController;
    _controller.play(); // Start playback in fullscreen mode
    _controller.addListener(_updateState);
  }

  @override
  void dispose() {
    _controller.removeListener(_updateState);
    super.dispose();
  }

  void _updateState() {
    setState(() {
      _isPlaying = _controller.value.isPlaying;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Video Player
          Center(
            child: AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            ),
          ),

          // Seek Bar and Controls
          Positioned(
            bottom: 50,
            left: 16,
            right: 16,
            child: Column(
              children: [
                Slider(
                  value: _controller.value.position.inSeconds.toDouble(),
                  min: 0.0,
                  max: _controller.value.duration.inSeconds.toDouble(),
                  onChanged: (value) {
                    _controller.seekTo(Duration(seconds: value.toInt()));
                  },
                  activeColor: Colors.blue,
                  inactiveColor: Colors.grey,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Current Time
                    Text(
                      _formatDuration(_controller.value.position),
                      style: const TextStyle(color: Colors.white),
                    ),
                    // Remaining Time
                    Text(
                      '-${_formatDuration(_controller.value.duration - _controller.value.position)}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Play/Pause Button
          Positioned(
            bottom: 120,
            child: IconButton(
              onPressed: () {
                setState(() {
                  if (_controller.value.isPlaying) {
                    _controller.pause();
                  } else {
                    _controller.play();
                  }
                });
              },
              icon: Icon(
                _isPlaying ? Icons.pause : Icons.play_arrow,
                size: 40,
                color: Colors.white,
              ),
            ),
          ),

          // Back Button
          Positioned(
            top: 40,
            left: 16,
            child: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
