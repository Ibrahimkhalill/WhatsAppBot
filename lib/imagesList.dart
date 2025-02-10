import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cargpt/dowload.dart'; // Firestore dependency

class ImagesList extends StatefulWidget {
  final String phoneNumber; // Pass phone number for filtering

  const ImagesList({Key? key, required this.phoneNumber}) : super(key: key);

  @override
  _ImagesListState createState() => _ImagesListState();
}

class _ImagesListState extends State<ImagesList> {
  late Future<List<Map<String, String>>> _imageData;

  @override
  void initState() {
    super.initState();
    _imageData = fetchImages(); // Fetch images based on phone number
  }

  Future<List<Map<String, String>>> fetchImages() async {
    try {
      // Query Firestore to get messages filtered by phone number and type
      final snapshot = await FirebaseFirestore.instance
          .collection('conversation')
          .where('from',
              isEqualTo: widget.phoneNumber) // Filter by phone number
          .where('type', isEqualTo: 'image') // Filter by type: image
          .get();

      // Map the Firestore documents to a list of maps with strict String types
      return snapshot.docs
          .map((doc) => {
                "id": doc.id, // Document ID
                "image": doc.data()["public_url"]
                    as String, // Explicitly cast to String
              })
          .toList();
    } catch (e) {
      print("Error fetching images: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Images"),
        backgroundColor: Colors.black87,
      ),
      body: Container(
        color: Colors.black87,
        child: FutureBuilder<List<Map<String, String>>>(
          future: _imageData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // Show shimmer effect while loading
              return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // Number of columns
                  crossAxisSpacing: 10.0, // Space between columns
                  mainAxisSpacing: 10.0, // Space between rows
                ),
                itemCount: 9, // Placeholder count for shimmer
                itemBuilder: (context, index) {
                  return Shimmer.fromColors(
                    baseColor: Colors.grey,
                    highlightColor: Colors.grey.shade100,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                },
              );
            } else if (snapshot.hasError) {
              return const Center(
                child: Text("Error loading images"),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text("No Images Found"),
              );
            } else {
              final data = snapshot.data!;
              return Padding(
                padding: const EdgeInsets.all(10.0),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, // Number of columns
                    crossAxisSpacing: 10.0, // Space between columns
                    mainAxisSpacing: 10.0, // Space between rows
                  ),
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final item = data[index];
                    return GestureDetector(
                      onTap: () => downloadAndOpenDocument(
                          item['image']!), // Handle image tap
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          item['image']!,
                          fit: BoxFit
                              .cover, // Ensures the image covers the container
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) {
                              return child; // Image fully loaded
                            }
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        (loadingProgress.expectedTotalBytes ??
                                            1)
                                    : null,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child:
                                  Icon(Icons.broken_image, color: Colors.red),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
