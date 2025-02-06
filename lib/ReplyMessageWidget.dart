import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // for kIsWeb
import 'package:get_thumbnail_video/index.dart';
import 'package:get_thumbnail_video/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';

class ReplyMessageWidget extends StatefulWidget {
  final Map<String, dynamic>? replyTo;

  const ReplyMessageWidget({super.key, required this.replyTo});

  @override
  _ReplyMessageWidgetState createState() => _ReplyMessageWidgetState();
}

class _ReplyMessageWidgetState extends State<ReplyMessageWidget> {
  String? _videoThumbnailPath;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.replyTo != null && widget.replyTo!['type'] == 'video') {
      _generateVideoThumbnail(widget.replyTo!['content']);
    }
  }

  /// **Generate a video thumbnail using `get_thumbnail_video`**
  Future<void> _generateVideoThumbnail(String videoUrl) async {
    try {
      // ✅ Step 2: Generate thumbnail from local file
      XFile thumbnailFile = await VideoThumbnail.thumbnailFile(
        video: videoUrl,
        thumbnailPath: (await getTemporaryDirectory()).path,
        imageFormat: ImageFormat.WEBP,
        maxHeight:
            64, // specify the height of the thumbnail, let the width auto-scaled to keep the source aspect ratio
        quality: 75,
      );
      if (thumbnailFile != null) {
        setState(() {
          _videoThumbnailPath = thumbnailFile.path as String?;
          isLoading = false;
        });
        debugPrint("✅ Thumbnail generated at: $_videoThumbnailPath");
      }
    } catch (e) {
      debugPrint("❌ Error generating thumbnail: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.replyTo == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade700,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 5),
          if (widget.replyTo!['type'] == 'text')
            Text(
              widget.replyTo!['content'] ?? "No content",
              style: const TextStyle(color: Colors.white, fontSize: 14),
            )
          else if (widget.replyTo!['type'] == 'image')
            _buildImagePreview(widget.replyTo!['content'])
          else if (widget.replyTo!['type'] == 'video')
            _buildVideoPreview(widget.replyTo!['content'])
          else if (widget.replyTo!['type'] == 'audio')
            _buildAudioPreview(widget.replyTo!['content'])
          else if (widget.replyTo!['type'] == 'document')
            _buildDocumentPreview(
                widget.replyTo!['content'], widget.replyTo!['fileName'])
          else
            const Text("Unsupported message type",
                style: TextStyle(color: Colors.red)),
        ],
      ),
    );
  }

  /// **🖼 Image Preview Widget**
  Widget _buildImagePreview(String? url) {
    print(' previw $url');
    return url != null
        ? ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              url,
              height: 100,
              width: 100,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.broken_image, color: Colors.white);
              },
            ),
          )
        : const Icon(Icons.broken_image, color: Colors.white);
  }

  /// **🎥 Video Preview Widget (Uses `get_thumbnail_video`)**
  Widget _buildVideoPreview(String? url) {
    if (url == null || url.isEmpty) {
      return const Icon(Icons.broken_image, color: Colors.white);
    }
    return Stack(
      alignment: Alignment.center,
      children: [
        _videoThumbnailPath != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: kIsWeb
                    ? Image.network(_videoThumbnailPath!) // Web support
                    : Image.file(File(_videoThumbnailPath!)), // Mobile support
              )
            : Container(
                width: 120,
                height: 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.black,
                ),
              ),
        const Icon(Icons.play_circle_fill, color: Colors.white, size: 32),
      ],
    );
  }

  /// **🔊 Audio Preview Widget**
  Widget _buildAudioPreview(String? url) {
    return Row(
      children: [
        const Icon(Icons.audiotrack, color: Colors.white),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            url != null ? "Audio message" : "No audio available",
            style: const TextStyle(color: Colors.white),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  /// **📄 Document Preview Widget (PDF, etc.)**
  Widget _buildDocumentPreview(String? url, String? fileName) {
    return Row(
      children: [
        const Icon(Icons.insert_drive_file, color: Colors.white),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            fileName ?? "Document",
            style: const TextStyle(color: Colors.white),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
