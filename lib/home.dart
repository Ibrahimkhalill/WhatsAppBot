import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart'; // For formatting timestamps
import 'package:whatapp/chat.dart';
import 'package:whatapp/contact_list.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Function to format timestamp
  String formatTimestamp(Timestamp timestamp) {
    final DateTime dateTime =
        timestamp.toDate(); // Convert Timestamp to DateTime
    return DateFormat('hh:mm a').format(dateTime); // e.g., "11:52 PM"
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            // Search Bar
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF222222),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF4CAF50)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  const Icon(Icons.search, color: Colors.grey, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: 'Search',
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Chat List (StreamBuilder with Icon Condition)
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: firestore
                    .collection('conversations')
                    .orderBy('timestamp', descending: true)
                    .snapshots(), // Realtime data stream
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                        child: Text('No Conversations Found',
                            style: TextStyle(color: Colors.white)));
                  }

                  // Map to store unique users
                  final Map<String, Map<String, dynamic>> uniqueUsers = {};

                  for (var doc in snapshot.data!.docs) {
                    final data = doc.data() as Map<String, dynamic>;
                    final from = data['from'];
                    if (!uniqueUsers.containsKey(from)) {
                      uniqueUsers[from] = {
                        'from': from,
                        'name': data['name'],
                        'lastMessage': data['content'] ?? data['type'],
                        'type':
                            data['type'], // Type of message (text, image, etc.)
                        'timestamp':
                            data['timestamp'], // Keep Timestamp as it is
                      };
                    }
                  }

                  // Convert map to list and sort by timestamp
                  final userList = uniqueUsers.values.toList()
                    ..sort((a, b) => (b['timestamp'] as Timestamp)
                        .compareTo(a['timestamp'] as Timestamp));

                  return ListView.builder(
                    itemCount: userList.length,
                    itemBuilder: (context, index) {
                      final user = userList[index];

                      // Determine the icon based on the message type
                      Widget? messageIcon;
                      if (user['type'] == 'image') {
                        messageIcon =
                            const Icon(Icons.image, color: Colors.grey);
                      } else if (user['type'] == 'audio') {
                        messageIcon =
                            const Icon(Icons.headphones, color: Colors.grey);
                      } else if (user['type'] == 'video') {
                        messageIcon =
                            const Icon(Icons.videocam, color: Colors.grey);
                      } else if (user['type'] == 'file') {
                        messageIcon =
                            const Icon(Icons.attach_file, color: Colors.grey);
                      } else {
                        messageIcon = null; // No icon for text messages
                      }

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Chat(
                                userId: user['from'],
                                userName: user['name'],
                              ),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(10), // Added padding
                          decoration: BoxDecoration(
                            color: const Color(0xFF242424),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              // Avatar
                              CircleAvatar(
                                backgroundColor: Colors.grey,
                                child: Text(
                                  user['name'][0].toUpperCase(),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              const SizedBox(width: 10),

                              // Chat Details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          user['name'],
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Text(
                                          formatTimestamp(user['timestamp']),
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      user['from'],
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 4),

                                    // Last message with icon
                                    Row(
                                      children: [
                                        if (messageIcon != null) ...[
                                          messageIcon,
                                          const SizedBox(width: 3),
                                        ],
                                        Expanded(
                                          child: Text(
                                            user['lastMessage'],
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 14,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // Forward Icon
                              const Icon(
                                Icons.arrow_forward_ios,
                                color: Color(0xFF04B616),
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF04B616),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          final PermissionStatus permission =
              await Permission.contacts.request();

          if (permission.isGranted) {
            Navigator.push(
              // ignore: use_build_context_synchronously
              context,
              MaterialPageRoute(
                builder: (context) => ContactListPage(),
              ),
            );
          } else if (permission.isDenied) {
            print('Contacts permission denied');
          } else if (permission.isPermanentlyDenied) {
            print(
                'Contacts permission permanently denied. Please enable it from settings.');
            openAppSettings();
          }
        },
      ),
    );
  }
}
