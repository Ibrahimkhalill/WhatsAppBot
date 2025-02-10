import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cargpt/audio.dart';

class AudioList extends StatefulWidget {
  final String phoneNumber; // Pass phone number for filtering

  const AudioList({Key? key, required this.phoneNumber}) : super(key: key);

  @override
  _AudioListState createState() => _AudioListState();
}

class _AudioListState extends State<AudioList> {
  late Future<List<Map<String, String>>> _audioData;

  @override
  void initState() {
    super.initState();
    _audioData = fetchAudios(); // Fetch audio files based on phone number
  }

  Future<List<Map<String, String>>> fetchAudios() async {
    try {
      // Query Firestore to get audio messages filtered by phone number
      final snapshot = await FirebaseFirestore.instance
          .collection('conversation')
          .where('from',
              isEqualTo: widget.phoneNumber) // Filter by phone number
          .where('type', isEqualTo: 'audio') // Filter by type: audio
          .get();

      // Map the Firestore data to a list of maps
      return snapshot.docs
          .map((doc) => {
                "id": doc.id,
                "audioUrl": doc["public_url"] as String, // Cast to String
                "day": doc["timestamp"]
                    .toDate()
                    .toString()
                    .split(" ")
                    .first, // Extract day from timestamp
              })
          .toList();
    } catch (e) {
      print("Error fetching audios: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0F0F0F),
      appBar: AppBar(
        title: const Text('Audio List'),
        backgroundColor: const Color(0xff0F0F0F), // Solid color
        elevation: 0, // Removes shadow
      ),
      body: FutureBuilder<List<Map<String, String>>>(
        future: _audioData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text("Error loading audios"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No Audios Found"));
          } else {
            final data = snapshot.data!;
            return ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                return Container(
                  margin:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
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
                          style: const TextStyle(
                              color: Colors.white, fontSize: 16),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.4),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: AudioPlayerWidget(
                              audioUrl: data[index]['audioUrl']!,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
