// import 'package:video_player/video_player.dart';

// class VideoPlayerWidget extends StatefulWidget {
//   final String videoUrl;

//   const VideoPlayerWidget({Key? key, required this.videoUrl}) : super(key: key);

//   @override
//   _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
// }

// class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
//   late VideoPlayerController _controller;

//   @override
//   void initState() {
//     super.initState();
//     _controller = VideoPlayerController.network(widget.videoUrl)
//       ..initialize().then((_) {
//         setState(() {});
//         _controller.setLooping(false);
//       });
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   void _togglePlayback() {
//     setState(() {
//       if (_controller.value.isPlaying) {
//         _controller.pause();
//       } else {
//         _controller.play();
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return _controller.value.isInitialized
//         ? Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               GestureDetector(
//                 onTap: _togglePlayback,
//                 child: Stack(
//                   alignment: Alignment.center,
//                   children: [
//                     AspectRatio(
//                       aspectRatio: _controller.value.aspectRatio,
//                       child: VideoPlayer(_controller),
//                     ),
//                     if (!_controller.value.isPlaying)
//                       Icon(
//                         Icons.play_arrow,
//                         color: Colors.white.withOpacity(0.7),
//                         size: 50,
//                       ),
//                   ],
//                 ),
//               ),
//               VideoProgressIndicator(
//                 _controller,
//                 allowScrubbing: true,
//                 colors: VideoProgressColors(
//                   playedColor: Colors.green,
//                   bufferedColor: Colors.grey,
//                   backgroundColor: Colors.black,
//                 ),
//               ),
//             ],
//           )
//         : const Center(child: CircularProgressIndicator());
//   }
// }
