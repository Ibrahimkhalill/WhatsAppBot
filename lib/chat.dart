import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'package:video_player/video_player.dart';
import 'package:swipe_to/swipe_to.dart';
import 'package:image_picker/image_picker.dart';
import 'package:whatapp/ImageDisplay.dart';
import 'package:whatapp/Reaction.dart';
import 'package:whatapp/audio.dart';
import 'package:whatapp/audio_list.dart';
import 'package:whatapp/catalog.dart';
import 'package:whatapp/dowload.dart';
import 'package:whatapp/messges_templates.dart';
import 'package:whatapp/reply_context_widget.dart';
import 'package:whatapp/sendMessges.dart';
import 'voice_list.dart';
import 'fileList.dart';
import 'imagesList.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_database/firebase_database.dart';

class Chat extends StatefulWidget {
  final String userId;
  final String userName;

  Chat({required this.userId, required this.userName});
  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final TextEditingController _messageController = TextEditingController();

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final DatabaseReference _databaseReference =
      FirebaseDatabase.instance.ref('conversations'); // Your table name here

  List<Map<String, dynamic>> _messages = [];
  final ScrollController _scrollController =
      ScrollController(); // ScrollController

  @override
  void initState() {
    super.initState();
    _filterMessagesByPhone();

    // Scroll to the bottom after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _filterMessagesByPhone() async {
    try {
      firestore
          .collection('conversations')
          .where('from', isEqualTo: widget.userId) // Firestore filter method
          .snapshots()
          .listen((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          // Print the raw data for debugging
          snapshot.docs.forEach((doc) {
            print('Fetched Document Data: ${doc.data()}'); // Debugging
          });

          setState(() {
            _messages = snapshot.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;

              // Convert Firestore Timestamp to DateTime
              data['timestamp'] = (data['timestamp'] as Timestamp).toDate();
              return data;
            }).toList();
          });

          // Sort messages by timestamp
          _messages.sort((a, b) {
            final timestampA = a['timestamp'] as DateTime;
            final timestampB = b['timestamp'] as DateTime;
            return timestampA.compareTo(timestampB); // Ascending order
          });

          // Scroll to the bottom after fetching and sorting messages
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollToBottom();
          });
        } else {
          print('No matching documents found.'); // Debugging
          setState(() {
            _messages = [];
          });
        }
      });
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

  void _sendMessage(String content) async {
    if (content.trim().isEmpty) {
      print('Message is empty');
      return;
    }
    print('Sending message: $content');

    setState(() {
      _messages.add({
        'id': _messages.length + 1,
        'type': 'text',
        'content': content,
        'sender': 'user',
        'reaction': null,
        'from': widget.userId,
        'reply_to': swipedMessage.isNotEmpty ? swipedMessage : null,
        'timestamp': DateTime.now(),
      });
      swipedMessage = {};
    });
    _messageController.clear();
    await sendTextMessage(content, widget.userId);
  }

  String? selectedMessageId; // To track the message for reaction box

  void _onLongPress(String messageId) {
    print(messageId);
    setState(() {
      selectedMessageId = messageId; // Set the long-pressed message
    });
    ReactionDialog.showReactionDialog(
      context: context,
      onReactionSelect: _onReactionSelect,
    );
  }

  void _onReactionSelect(String reaction) {
    setState(() {
      _messages.map((message) {
        if (message['message_id'] == selectedMessageId) {
          message['reaction'] = reaction; // রিঅ্যাকশন সেট করা হচ্ছে
        }
        return _messages;
      }).toList();
      selectedMessageId = null; // রিঅ্যাকশন সিলেক্ট করার পরে বক্স বন্ধ করা
    });
    print('Selected Reaction 3: $_messages'); // For debugging
  }

  String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B'; // Bytes
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)} KB'; // Kilobytes
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB'; // Megabytes
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB'; // Gigabytes
    }
  }

  Map<String, dynamic> swipedMessage = {};

  Widget _buildMessage(Map<String, dynamic> message) {
    final bool isUser = message['sender'] == 'user';
    final String? reaction =
        message['reaction']; // Add reaction field in the message
    return GestureDetector(
      onTap: () => downloadAndOpenDocument(message['public_url']),
      onLongPress: () => _onLongPress(message['message_id']),
      child: SwipeTo(
        key: Key(message['content'] ?? 'message_id'), // Ensure key is unique
        iconOnLeftSwipe: Icons.arrow_forward,
        onRightSwipe: (details) {
          setState(() {
            swipedMessage = {
              'id': message['message_id'] ?? 'unknown', // Default ID if null
              'content': message['fileName'] ??
                  message['content'] ??
                  message['public_url'] ??
                  'No content', // Default content if all are null
              'type': message['type'] ?? 'unknown' // Default type if null
            };
          });
        },
        child: Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                margin:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color:
                      isUser ? const Color(0xff244a37) : Colors.grey.shade800,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (message['reply_to'] != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade700,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Replying to: ${message['reply_to']['content']}',
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 12),
                        ),
                      ),
                    message['type'] == 'text'
                        ? Text(
                            message['content'],
                            style: const TextStyle(color: Colors.white),
                          )
                        : message['type'] == 'image'
                            ? buildImageWidget(message['public_url'])
                            : message['type'] == 'document'
                                ? SizedBox(
                                    width: MediaQuery.sizeOf(context).width *
                                        0.8, //260
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(Icons.insert_drive_file,
                                                color: Colors.white),
                                            const SizedBox(
                                                width:
                                                    10), // Add spacing between the icon and text
                                            Expanded(
                                              child: Text(
                                                message['fileName'] ??
                                                    'Unknown Document',
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16),
                                                overflow: TextOverflow
                                                    .ellipsis, // Truncate long file names
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                            height:
                                                5), // Add spacing between rows
                                        Text(
                                          formatFileSize(message['fileSize'] ??
                                              0), // Show file size
                                          style: const TextStyle(
                                              color: Colors.grey),
                                        ),
                                        const SizedBox(
                                            height:
                                                10), // Add spacing before the button
                                        // TextButton.icon(
                                        //   onPressed: () =>
                                        //       downloadAndOpenDocument(
                                        //           message['public_url']),
                                        //   icon: const Icon(Icons.download,
                                        //       color: Colors.green),
                                        //   label: const Text(
                                        //     'Download',
                                        //     style: TextStyle(color: Colors.green),
                                        //   ),
                                        // ),
                                      ],
                                    ),
                                  )
                                : message['type'] == 'sticker'
                                    ? Image.network(
                                        width: 50,
                                        height: 50,
                                        message['public_url'],
                                        fit: BoxFit
                                            .cover, // Adjust fit as needed
                                        loadingBuilder:
                                            (context, child, loadingProgress) {
                                          if (loadingProgress == null) {
                                            return child; // Image loaded successfully
                                          }
                                          return const Center(
                                            child:
                                                CircularProgressIndicator(), // Show loader while loading
                                          );
                                        },
                                      )
                                    : message['type'] == 'video'
                                        ? SizedBox(
                                            child: VideoPlayerWidget(
                                              videoUrl: message['public_url'],
                                            ),
                                          )
                                        : message['type'] == 'audio'
                                            ? SizedBox(
                                                width:
                                                    MediaQuery.sizeOf(context)
                                                            .width *
                                                        0.8, //260
                                                height: 42,
                                                child: AudioPlayerWidget(
                                                    audioUrl:
                                                        message['public_url']),
                                              )
                                            : const SizedBox.shrink(),
                  ],
                ),
              ),
              if (reaction != null)
                Positioned(
                  bottom: -5, // Position below the message container
                  right: 10, // Align to the bottom-right corner
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        reaction,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _clearReplyContext() {
    setState(() {
      swipedMessage = {}; // Clear the swiped message
    });
  }

  void _openDocumentPicker() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );

    if (result != null) {
      PlatformFile file = result.files.first;

      // Upload to backend and get public URL
      final publicUrl = await uploadFileToBackend(
          file.path!, 'document', file.name, widget.userId);

      if (publicUrl != null) {
        setState(() {
          _messages.add({
            'id': DateTime.now().millisecondsSinceEpoch.toString(),
            'type': 'document',
            'fileName': file.name,
            'fileSize': file.size,
            'sender': 'user',
            'reaction': null,
            'public_url': publicUrl,
            'timestamp': DateTime.now(),
          });
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });
      }
    }
  }

  void _openGalleryPicker() async {
    final ImagePicker picker = ImagePicker();

    // Ask the user whether they want to pick an image or a video
    final choice = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choose Media Type'),
          content: const Text('Do you want to select an image or a video?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, 'image'),
              child: const Text('Image'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, 'video'),
              child: const Text('Video'),
            ),
          ],
        );
      },
    );

    if (choice == 'image') {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        print('Selected an image');
        // Upload to backend and get public URL
        final publicUrl = await uploadFileToBackend(
          image.path,
          'image',
          image.name,
          widget.userId,
        );

        if (publicUrl != null) {
          setState(() {
            _messages.add({
              'id': DateTime.now().millisecondsSinceEpoch.toString(),
              'type': 'image',
              'fileName': image.name,
              'public_url': publicUrl,
              'timestamp': DateTime.now(),
              'reaction': null,
              'sender': 'user',
            });
          });
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollToBottom();
          });
        }
      }
    } else if (choice == 'video') {
      final XFile? video = await picker.pickVideo(source: ImageSource.gallery);
      if (video != null) {
        print('Selected a video');
        // Upload to backend and get public URL
        final publicUrl = await uploadFileToBackend(
          video.path,
          'video',
          video.name,
          widget.userId,
        );

        if (publicUrl != null) {
          setState(() {
            _messages.add({
              'id': DateTime.now().millisecondsSinceEpoch.toString(),
              'type': 'video',
              'fileName': video.name,
              'public_url': publicUrl,
              'timestamp': DateTime.now(),
              'reaction': null,
              'sender': 'user',
            });
          });
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollToBottom();
          });
        }
      }
    }
  }

  void _openAudioPicker() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );

    if (result != null) {
      PlatformFile file = result.files.first;

      // Upload to backend and get public URL
      final publicUrl = await uploadFileToBackend(
          file.path!, 'audio', file.name, widget.userId);

      if (publicUrl != null) {
        setState(() {
          _messages.add({
            'id': DateTime.now().millisecondsSinceEpoch.toString(),
            'type': 'audio',
            'fileName': file.name,
            'fileSize': '${(file.size / 1024).toStringAsFixed(2)} KB',
            'sender': 'user',
            'reaction': null,
            'public_url': publicUrl,
            'timestamp': DateTime.now(),
          });
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });
      }
    }
  }

  void _openCatalogPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Catalog()),
    );
  }

  void _openTemplatesPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TemplatesPage()),
    );
  }

  Widget _buildAttachmentButton(
      String label, IconData icon, Color iconColor, VoidCallback onTap) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.2), // Background color
            shape: BoxShape.circle, // Circular shape
          ),
          child: IconButton(
            onPressed: onTap,
            icon: Icon(icon, color: iconColor), // Use custom icon color
            iconSize: 25,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  void _openAttachmentMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildAttachmentButton(
                    'Document', // Label
                    Icons.insert_drive_file, // Icon
                    Colors.blue, // Icon color
                    () {
                      Navigator.pop(context); // Close modal
                      _openDocumentPicker(); // Perform action
                    },
                  ),
                  _buildAttachmentButton(
                    'Gallery',
                    Icons.photo,
                    Colors.purple,
                    () {
                      Navigator.pop(context); // Close modal
                      _openGalleryPicker(); // Perform action
                    },
                  ),
                  _buildAttachmentButton(
                    'Audio',
                    Icons.headphones,
                    Colors.orange,
                    () {
                      Navigator.pop(context); // Close modal
                      _openAudioPicker(); // Perform action
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildAttachmentButton(
                    'Catalog',
                    Icons.menu_book,
                    Colors.green,
                    () {
                      Navigator.pop(context); // Close modal
                      _openCatalogPage(); // Perform action
                    },
                  ),
                  _buildAttachmentButton(
                    'Templates',
                    Icons.description,
                    Colors.red,
                    () {
                      Navigator.pop(context); // Close modal
                      _openTemplatesPage(); // Perform action
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _saveContact(BuildContext context) async {
    try {
      // Check for contact permissions
      if (await Permission.contacts.request().isGranted) {
        // Check if the contact already exists
        final existingContacts = await FlutterContacts.getContacts(
          withProperties: true,
          withPhoto: false,
        );
        final contactExists = existingContacts.any((contact) =>
            contact.phones.any((phone) => phone.number == widget.userId));

        if (contactExists) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Contact already exists!')),
          );
          return; // Exit the function if contact exists
        }

        // Proceed to save the contact if it doesn't exist
        final contact = Contact(
          name: Name(first: widget.userName),
          phones: [Phone(widget.userId)],
        );

        // Open the phone's native Add Contact page
        final bool added =
            (await FlutterContacts.openExternalInsert(contact)) as bool;

        if (added) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Contact saved successfully!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to save contact!')),
          );
        }
      } else {
        // Permission denied
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contacts permission is required!')),
        );
      }
    } catch (e) {
      print("Error saving contact: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('An error occurred while saving contact!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: GestureDetector(
          onTap: () => _saveContact(context),
          child: Row(
            children: [
              const CircleAvatar(
                backgroundImage: NetworkImage(
                    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR3GQS9166MDCo-__0ZqcKt4r9UbnqHLlOlvQ&s'),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.userName, style: TextStyle(fontSize: 16)),
                  Text(widget.userId,
                      style: TextStyle(fontSize: 12, color: Colors.white70)),
                ],
              ),
            ],
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/images/background.jpg'),
                fit: BoxFit.cover)),
        child: Column(
          children: [
            // Action Buttons
            Container(
              color: Colors.black87,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Wrap(
                  spacing: 5,
                  runSpacing: 5,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildActionButton('Voice File', Icons.mic, () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AudioList(
                                      phoneNumber: widget.userId,
                                    )),
                          );
                        }),
                        _buildActionButton('Video File', Icons.videocam, () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => VideoList(
                                      phoneNumber: widget.userId,
                                    )),
                          );
                        }),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildActionButton('Link File', Icons.link, () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => FileLinkList(
                                      phoneNumber: widget.userId,
                                    )),
                          );
                        }),
                        _buildActionButton('Image File', Icons.image, () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ImagesList(
                                      phoneNumber: widget.userId,
                                    )),
                          );
                        }),
                        _buildActionButton('Chat File', Icons.chat, () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Chat(
                                      userId: '',
                                      userName: '',
                                    )),
                          );
                        }),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // if (swipedMessage.isNotEmpty) _buildReplyContext(),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _messages.length,
                itemBuilder: (context, index) =>
                    _buildMessage(_messages[index]),
              ),
            ),

            if (swipedMessage.isNotEmpty)
              ReplyContextWidget(
                swipedMessage: swipedMessage,
                onClose: _clearReplyContext,
              ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.attach_file, color: Colors.green),
                    onPressed: _openAttachmentMenu,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Type a message',
                        filled: true,
                        fillColor: Colors.grey.shade800,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 15),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.green),
                    onPressed: () => _sendMessage(_messageController.text),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, VoidCallback onTap) {
    return ElevatedButton.icon(
      onPressed: onTap, // Execute the navigation action
      icon: Icon(icon, color: Colors.green),
      label: Text(label, style: const TextStyle(color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xff222222),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      ),
    );
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerWidget({Key? key, required this.videoUrl}) : super(key: key);

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {}); // Refresh the UI once the video is initialized
        _controller.setLooping(false);
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      // Fallback box when video is not loaded
      return Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.black,
        ),
        child: const Center(
          child: CircularProgressIndicator(), // Loading indicator
        ),
      );
    }

    // Calculate the dynamic width and height based on the aspect ratio
    final screenWidth =
        MediaQuery.of(context).size.width * 0.5; // 50% of screen width
    final videoHeight =
        screenWidth / _controller.value.aspectRatio; // Maintain aspect ratio

    return Container(
      width: screenWidth, // Dynamic width limited to 50% of screen
      height: videoHeight, // Dynamic height based on aspect ratio
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.black,
      ),
      child: GestureDetector(
        onTap: () {
          setState(() {
            if (_controller.value.isPlaying) {
              _controller.pause();
            } else {
              _controller.play();
            }
          });
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            VideoPlayer(_controller),
            if (!_controller.value.isPlaying)
              Icon(
                Icons.play_arrow,
                color: Colors.white.withOpacity(0.7),
                size: 50,
              ),
          ],
        ),
      ),
    );
  }
}
