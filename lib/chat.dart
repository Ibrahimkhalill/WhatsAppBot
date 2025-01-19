import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'package:video_player/video_player.dart';
import 'package:swipe_to/swipe_to.dart';
import 'package:image_picker/image_picker.dart';
import 'package:whatapp/Reaction.dart';
import 'package:whatapp/audio.dart';
import 'package:whatapp/audio_list.dart';
import 'package:whatapp/catalog.dart';
import 'package:whatapp/messges_templates.dart';
import 'package:whatapp/reply_context_widget.dart';
import 'voice_list.dart';
import 'fileList.dart';
import 'imagesList.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';

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

  final List<Map<String, dynamic>> _messages = [
    {'id': 1, 'type': 'text', 'content': 'Hi there!', 'sender': 'other'},
    {
      'id': 2,
      'type': 'text',
      'content': 'Hello! How can I help you?',
      'sender': 'user',
      'reaction': null
    },
    {
      'id': 3,
      'type': 'image',
      'content':
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR3GQS9166MDCo-__0ZqcKt4r9UbnqHLlOlvQ&s',
      'sender': 'other',
      'reaction': null
    },
    {
      'id': 4,
      'type': 'file',
      'fileName': 'Document.pdf',
      'fileSize': '2 MB',
      'sender': 'user',
      'reaction': null,
    },
    {
      'id': 5,
      'type': 'audio',
      'content':
          'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
      'sender': 'other',
      'reaction': null
    },
    {
      'id': 6,
      'type': 'text',
      'content': 'Helow bother',
      'sender': 'other',
      'reaction': null
    },
    {
      'id': 7,
      'type': "video",
      'content': "https://www.w3schools.com/html/mov_bbb.mp4",
      'sender': "user",
      'reaction': null
    },
    // Adding a message template
    // {
    //   'id': 8,
    //   'type': 'template',
    //   'content': {
    //     'mediaUrl': 'https://example.com/image.png',
    //     'title': 'Welcome to our service!',
    //     'body': 'Here is your invitation to join.',
    //     'footer': 'https://example.com',
    //   },
    //   'sender': 'user',
    //   'reaction': null
    // }
  ];

  void _sendMessage(String content) {
    if (content.trim().isEmpty) return;
    setState(() {
      _messages.add({
        'id': _messages.length + 1,
        'type': 'text',
        'content': content,
        'sender': 'user',
        'reaction': null,
        'reply_to': swipedMessage.isNotEmpty ? swipedMessage : null
      });
      swipedMessage = {};
    });

    _messageController.clear();
  }

  int? selectedMessageId; // To track the message for reaction box

  void _onLongPress(int messageId) {
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
        if (message['id'] == selectedMessageId) {
          message['reaction'] = reaction; // রিঅ্যাকশন সেট করা হচ্ছে
        }
        return _messages;
      }).toList();
      selectedMessageId = null; // রিঅ্যাকশন সিলেক্ট করার পরে বক্স বন্ধ করা
    });
    print('Selected Reaction 3: $_messages'); // For debugging
  }

  Map<String, dynamic> swipedMessage = {};

  Widget _buildMessage(Map<String, dynamic> message) {
    final bool isUser = message['sender'] == 'user';
    final String? reaction =
        message['reaction']; // Add reaction field in the message
    return GestureDetector(
      onLongPress: () => _onLongPress(message['id']),
      child: SwipeTo(
        key: Key(message['content'] ?? 'messageKey'), // Ensure key is unique
        iconOnLeftSwipe: Icons.arrow_forward,
        onRightSwipe: (details) {
          setState(() {
            swipedMessage = {
              'id': message['id'],
              'content': message['content'],
              'type': message['type']
            };
          });
        },
        child: Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                padding: const EdgeInsets.all(10),
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
                        margin: const EdgeInsets.only(bottom: 5),
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
                            ? Image.network(
                                message['content'],
                                width: 200,
                                height: 150,
                                fit: BoxFit.cover,
                              )
                            : message['type'] == 'file'
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Icon(Icons.insert_drive_file,
                                          color: Colors.white),
                                      Text(
                                        message['fileName'],
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                      Text(
                                        message['fileSize'],
                                        style:
                                            const TextStyle(color: Colors.grey),
                                      ),
                                    ],
                                  )
                                : message['type'] == 'video'
                                    ? SizedBox(
                                        width: 200,
                                        height: 122,
                                        child: VideoPlayerWidget(
                                            videoUrl: message['content']),
                                      )
                                    : message['type'] == 'audio'
                                        ? SizedBox(
                                            width: MediaQuery.sizeOf(context).width*0.8,   //260
                                            height: 42,
                                            child: AudioPlayerWidget(
                                                audioUrl: message['content']),
                                          )
                                        : const SizedBox.shrink(),
                  ],
                ),
              ),
              if (reaction != null)
                Positioned(
                  bottom: -10, // Position below the message container
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

      setState(() {
        _messages.add({
          'id': _messages.length + 1,
          'type': 'document',
          'fileName': file.name,
          'fileSize': '${(file.size / 1024).toStringAsFixed(2)} KB',
          'sender': 'user',
          'reaction': null,
        });
      });
    }
  }

  void _openGalleryPicker() async {
    final ImagePicker picker = ImagePicker();

    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    final XFile? video = await picker.pickVideo(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _messages.add({
          'type': 'image',
          'fileName': image.name,
          'filePath': image.path,
        });
      });
    } else if (video != null) {
      setState(() {
        _messages.add({
          'id': _messages.length + 1,
          'type': 'video',
          'fileName': video.name,
          'filePath': video.path,
          'sender': 'user',
          'reaction': null,
        });
      });
    } else {
      print('No image or video selected');
    }
  }

  void _openAudioPicker() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );

    if (result != null) {
      PlatformFile file = result.files.first;

      setState(() {
        _messages.add({
          'id': _messages.length + 1,
          'type': 'audio',
          'fileName': file.name,
          'fileSize': '${(file.size / 1024).toStringAsFixed(2)} KB',
          'sender': 'user',
          'reaction': null,
        });
      });
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
      String label, IconData icon, VoidCallback onTap) {
    return Column(
      children: [
        IconButton(
          onPressed: onTap,
          icon: Icon(icon, color: Colors.green),
          iconSize: 40,
        ),
        Text(label, style: const TextStyle(color: Colors.white)),
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
                      'Document', Icons.insert_drive_file, _openDocumentPicker),
                  _buildAttachmentButton(
                      'Gallery', Icons.photo, _openGalleryPicker),
                  _buildAttachmentButton(
                      'Audio', Icons.audiotrack, _openAudioPicker),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildAttachmentButton(
                      'Catalog', Icons.menu_book, _openCatalogPage),
                  _buildAttachmentButton(
                      'Templates', Icons.description, _openTemplatesPage),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _saveContact(BuildContext context) async {
    // Check for contact permissions
    if (await Permission.contacts.request().isGranted) {
      final contact = Contact(
        name: Name(first: 'Ferruccio', last: 'Lamborghini'),
        phones: [Phone('96235-5278')],
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
                                builder: (context) => AudioList()),
                          );
                        }),
                        _buildActionButton('Video File', Icons.videocam, () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => VideoList()),
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
                                builder: (context) => FileLinkList()),
                          );
                        }),
                        _buildActionButton('Image File', Icons.image, () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ImagesList()),
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
        setState(() {});
        _controller.setLooping(false);
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayback() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: _togglePlayback,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    ),
                    if (!_controller.value.isPlaying)
                      Icon(
                        Icons.play_arrow,
                        color: Colors.white.withOpacity(0.7),
                        size: 50,
                      ),
                  ],
                ),
              ),
              VideoProgressIndicator(
                _controller,
                allowScrubbing: true,
                colors: VideoProgressColors(
                  playedColor: Colors.green,
                  bufferedColor: Colors.grey,
                  backgroundColor: Colors.black,
                ),
              ),
            ],
          )
        : const Center(child: CircularProgressIndicator());
  }
}
