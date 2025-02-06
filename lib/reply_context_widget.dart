import 'package:flutter/material.dart';
import 'package:whatapp/audio.dart';
import 'package:whatapp/video_player.dart';

class ReplyContextWidget extends StatelessWidget {
  final Map<String, dynamic> swipedMessage;
  final VoidCallback onClose;

  const ReplyContextWidget({
    super.key,
    required this.swipedMessage,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    if (swipedMessage.isEmpty) return const SizedBox.shrink();

    Widget replyContent;
    print(swipedMessage['content']);
    // Dynamically display the content based on the type
    switch (swipedMessage['type']) {
      case 'text':
        replyContent = Text(
          'Replying to: ${swipedMessage['content']}',
          style: const TextStyle(color: Colors.white70),
        );
        break;

      case 'image':
        // replyContent =
        replyContent = Row(
          children: [
            const Icon(Icons.image,
                color: Colors.white70, size: 24), // Video icon
            const SizedBox(width: 5), // Spacer
            const Text(
              'Images',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),

            const Spacer(), // Push the video box to the right
            Image.network(
              swipedMessage['content'],
              width: 50,
              height: 50,
              fit: BoxFit.contain,
            )
          ],
        );
        break;

      case 'video':
        replyContent = Row(
          children: [
            const Icon(Icons.videocam,
                color: Colors.white70, size: 24), // Video icon
            const SizedBox(width: 5), // Spacer
            const Text(
              'Video',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const Spacer(), // Push the video box to the right
            SizedBox(
              width: 60,
              height: 60,
              child: VideoPlayerWidget(videoUrl: swipedMessage['content']),
            ),
          ],
        );
        break;

      case 'audio':
        replyContent = SizedBox(
          width: 100,
          height: 42,
          child: AudioPlayerWidget(audioUrl: swipedMessage['content']),
        );
        break;

      case 'document':
        replyContent = Row(
          children: [
            const Icon(Icons.insert_drive_file, color: Colors.white70),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                swipedMessage['fileName'],
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
      bottom: 200, // Adjust this distance as needed
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
              onPressed: onClose,
            ),
          ],
        ),
      ),
    );
  }
}
