import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class FileLinkList extends StatefulWidget {
  final String phoneNumber; // Pass phone number for filtering

  const FileLinkList({super.key, required this.phoneNumber});

  @override
  _FileLinkListState createState() => _FileLinkListState();
}

class _FileLinkListState extends State<FileLinkList> {
  late Future<List<Map<String, String>>> _documentData;

  @override
  void initState() {
    super.initState();
    _documentData = fetchDocuments(); // Fetch documents based on phone number
  }

  Future<List<Map<String, String>>> fetchDocuments() async {
    try {
      // Query Firestore to get document messages filtered by phone number
      final snapshot = await FirebaseFirestore.instance
          .collection('conversation')
          .where('from',
              isEqualTo: widget.phoneNumber) // Filter by phone number
          .where('type', isEqualTo: 'document') // Filter by type: document
          .get();

      // Map the Firestore data to a list of maps with strict String types
      return snapshot.docs
          .map((doc) => {
                "id": doc.id,
                "name": (doc["fileName"] ?? "Unknown Document")
                    .toString(), // Ensure a String value
              })
          .toList();
    } catch (e) {
      print("Error fetching documents: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Documents"),
        backgroundColor: const Color(0xff0F0F0F),
      ),
      body: FutureBuilder<List<Map<String, String>>>(
        future: _documentData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text("Error loading documents"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No Documents Found"));
          } else {
            final data = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(0.0),
              child: Container(
                color: const Color(0xff0F0F0F),
                child: ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final item = data[index];
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF242424),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: const Color(0xFF8A8A8A),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Center(
                                child: FaIcon(
                                  FontAwesomeIcons.file,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                item['name']!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
