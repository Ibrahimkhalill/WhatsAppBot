import 'package:cargpt/video_list.dart';
import 'package:flutter/material.dart';
import 'package:get_thumbnail_video/index.dart';
import 'package:get_thumbnail_video/video_thumbnail.dart';
import 'package:cargpt/audio.dart';
import 'package:cargpt/video_player.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class ReplyContextWidget extends StatefulWidget {
  final Map<String, dynamic> swipedMessage;
  final VoidCallback onClose;

  const ReplyContextWidget({
    super.key,
    required this.swipedMessage,
    required this.onClose,
  });

  @override
  _ReplyContextWidgetState createState() => _ReplyContextWidgetState();
}

class _ReplyContextWidgetState extends State<ReplyContextWidget> {
  String? _videoThumbnailPath;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.swipedMessage['type'] == 'video') {
      _generateVideoThumbnail(widget.swipedMessage['content']);
    }
  }

  // Generate a video thumbnail using get_thumbnail_video
  Future<void> _generateVideoThumbnail(String videoUrl) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final thumbnailFile = await VideoThumbnail.thumbnailFile(
        video: videoUrl,
        thumbnailPath: tempDir.path,
        imageFormat: ImageFormat.WEBP,
        maxHeight: 100, // specify the height of the thumbnail
        quality: 75,
      );

      if (thumbnailFile != null) {
        setState(() {
          _videoThumbnailPath = thumbnailFile.path;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("❌ Error generating thumbnail: $e");
      setState(() {
        _isLoading = false; // Stop loading in case of error
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.swipedMessage.isEmpty) return const SizedBox.shrink();

    Widget replyContent;

    switch (widget.swipedMessage['type']) {
      case 'text':
        replyContent = Text(
          'Replying to: ${widget.swipedMessage['content']}',
          style: const TextStyle(color: Colors.white70),
        );
        break;

      case 'image':
        replyContent = Row(
          children: [
            const Icon(Icons.image, color: Colors.white70, size: 24),
            const SizedBox(width: 5),
            const Text('Images',
                style: TextStyle(color: Colors.white70, fontSize: 14)),
            const Spacer(),
            Image.network(
              widget.swipedMessage['content'],
              width: 50,
              height: 50,
              fit: BoxFit.contain,
            ),
          ],
        );
        break;

      case 'video':
        // Show video thumbnail first only
        replyContent = Row(
          children: [
            const Icon(Icons.videocam, color: Colors.white70, size: 24),
            const SizedBox(width: 5),
            const Text('Video',
                style: TextStyle(color: Colors.white70, fontSize: 14)),
            const Spacer(),
            _isLoading
                ? SizedBox(
                    width: 24, // Set the width
                    height: 24, // Set the height
                    child: const CircularProgressIndicator(),
                  )
                : GestureDetector(
                    onTap: () {
                      // When tapped, open the video player
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VideoPlayerWidget(
                              videoUrl: widget.swipedMessage['content']),
                        ),
                      );
                    },
                    child: SizedBox(
                      width: 60,
                      height: 60,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: _videoThumbnailPath != null
                            ? Image.file(
                                File(_videoThumbnailPath!),
                                fit: BoxFit.cover,
                              )
                            : Container(
                                color: Colors.black,
                                child: const Icon(Icons.videocam,
                                    color: Colors.white),
                              ),
                      ),
                    ),
                  ),
          ],
        );
        break;

      case 'audio':
        replyContent = SizedBox(
          width: 100,
          height: 42,
          child: AudioPlayerWidget(audioUrl: widget.swipedMessage['content']),
        );
        break;

      case 'document':
        replyContent = Row(
          children: [
            const Icon(Icons.insert_drive_file, color: Colors.white70),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                widget.swipedMessage['fileName'],
                style: const TextStyle(
                    color: Colors.white70, overflow: TextOverflow.ellipsis),
              ),
            ),
          ],
        );
        break;
      case 'template':
        replyContent = Row(
          children: [
            const Icon(Icons.document_scanner_outlined, color: Colors.white70),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                widget.swipedMessage['content'],
                style: const TextStyle(
                    color: Colors.white70, overflow: TextOverflow.ellipsis),
              ),
            ),
          ],
        );
        break;

      default:
        replyContent = const Text(
          'Unsupported type',
          style: TextStyle(color: Colors.white70),
        );
    }

    return Positioned(
      bottom: 200,
      left: 10,
      right: 10,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(child: replyContent),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white70),
              onPressed: widget.onClose,
            ),
          ],
        ),
      ),
    );
  }
}
