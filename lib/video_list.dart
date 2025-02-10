import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore dependency
import 'package:cargpt/video_player.dart'; // Import VideoPlayerWidget

class VideoList extends StatefulWidget {
  final String phoneNumber; // Phone number for filtering

  const VideoList({super.key, required this.phoneNumber});

  @override
  _VideoListState createState() => _VideoListState();
}

class _VideoListState extends State<VideoList> {
  late Future<List<Map<String, String>>> _videoData;

  @override
  void initState() {
    super.initState();
    _videoData = fetchVideos(); // Fetch videos based on phone number
  }

  Future<List<Map<String, String>>> fetchVideos() async {
    try {
      // Query Firestore to filter by phone number and type: video
      final snapshot = await FirebaseFirestore.instance
          .collection('conversation')
          .where('from',
              isEqualTo: widget.phoneNumber) // Filter by phone number
          .where('type', isEqualTo: 'video') // Filter by type: video
          .get();

      // Map the Firestore data to a list of maps
      return snapshot.docs
          .map((doc) => {
                "id": doc.id,
                "videoUrl":
                    doc["public_url"] as String, // Explicitly cast to String
                "timestamp": doc["timestamp"]
                    .toDate()
                    .toString(), // Convert Firestore Timestamp to String
              })
          .toList();
    } catch (e) {
      print("Error fetching videos: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Videos"),
        backgroundColor: const Color(0xff0F0F0F),
      ),
      body: FutureBuilder<List<Map<String, String>>>(
        future: _videoData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text("Error loading videos"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No Videos Found"));
          } else {
            final data = snapshot.data!;
            return Padding(
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
            );
          }
        },
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
