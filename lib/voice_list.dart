import 'package:flutter/material.dart';
import 'package:whatapp/chat.dart';

class VideoList extends StatelessWidget {
  final List<Map<String, String>> data = [
    {
      "id": "1",
      "videoUrl": "https://www.w3schools.com/html/mov_bbb.mp4",
      "duration": "0:17",
      "timestamp": "11:52 pm",
    },
    {
      "id": "2",
      "videoUrl": "https://www.w3schools.com/html/mov_bbb.mp4",
      "duration": "0:17",
      "timestamp": "11:52 pm",
    },
    {
      "id": "3",
      "videoUrl": "https://www.w3schools.com/html/mov_bbb.mp4",
      "duration": "0:17",
      "timestamp": "11:52 pm",
    },
    {
      "id": "4",
      "videoUrl": "https://www.w3schools.com/html/mov_bbb.mp4",
      "duration": "0:17",
      "timestamp": "11:52 pm",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Video"),
        backgroundColor: const Color(0xff0F0F0F),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Number of columns
            crossAxisSpacing: 10.0, // Space between columns
            mainAxisSpacing: 10.0, // Space between rows
          ),
          itemCount: data.length,
          itemBuilder: (context, index) {
            final item = data[index];
            return _buildVideoBox(item['videoUrl']!);
          },
        ),
      ),
    );
  }

  Widget _buildVideoBox(String videoUrl) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade300, // Gray background
        borderRadius: BorderRadius.circular(10), // Rounded corners
        boxShadow: [
          BoxShadow(
            color: Colors.black26, // Slight shadow effect
            blurRadius: 5,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Center(
        child: VideoPlayerWidget(videoUrl: videoUrl),
      ),
    );
  }
}
