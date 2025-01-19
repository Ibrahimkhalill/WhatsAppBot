import 'package:flutter/material.dart';
import 'package:whatapp/audio.dart';

class AudioList extends StatelessWidget {
  final List<Map<String, String>> data = [
    {'id': '1', 'day': 'Sunday', 'duration': '0:15'},
    {'id': '2', 'day': 'Monday', 'duration': '0:15'},
    {'id': '3', 'day': 'Monday', 'duration': '0:15'},
    {'id': '4', 'day': 'Monday', 'duration': '0:15'},
    {'id': '5', 'day': 'Monday', 'duration': '0:15'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0F0F0F),
      appBar: AppBar(
        title: const Text('Audio List'),
        backgroundColor: const Color(0xff0F0F0F), // Solid color
        elevation: 0, // Removes shadow
      ),
      body: ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            decoration: BoxDecoration(
              color: const Color(0xff0F0F0F),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data[index]['day'] ?? '',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.4),
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: AudioPlayerWidget(
                        audioUrl:
                            'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
