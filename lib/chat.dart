import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:swipe_to/swipe_to.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cargpt/CircularDownloadIndicatorState.dart';
import 'package:cargpt/ImageDisplay.dart';
import 'package:cargpt/Reaction.dart';
import 'package:cargpt/ReplyMessageWidget.dart';
import 'package:cargpt/audio.dart';
import 'package:cargpt/audio_list.dart';
import 'package:cargpt/buildTemplateItem.dart';
import 'package:cargpt/dowload.dart';
import 'package:cargpt/reply_context_widget.dart';
import 'package:cargpt/sendMessges.dart';
import 'package:cargpt/templates.dart';
import 'package:cargpt/video_player.dart';
import 'video_list.dart';
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
      FirebaseDatabase.instance.ref('conversation'); // Your table name here

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
          .collection('conversation')
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

    // Store original message ID before resetting swipedMessage
    var originalMessageId =
        swipedMessage.isNotEmpty ? swipedMessage['id'] : null;

    print('Sending message: $originalMessageId');
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
        'status': false, // Message sent but not yet delivered/read
      });

      swipedMessage = {}; // Reset the swiped message
    });

    _messageController.clear();

    // Send reply message if swipedMessage exists
    if (originalMessageId != null) {
      await sendReplyMessges(
          content, widget.userId, widget.userName, originalMessageId);
    } else {
      await sendTextMessage(content, widget.userId, widget.userName);
    }
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

  String _formatTime(dynamic timestamp) {
    if (timestamp is DateTime) {
      return "${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}";
    }
    return "00:00"; // Default if timestamp is null
  }

  String _formatDateTime(DateTime timestamp) {
    // Format date as "10 Oct"
    String formattedDate = DateFormat('d MMM yy').format(timestamp);

    // Format time as "11:52 PM"

    // Combine date and time
    return "$formattedDate "; // e.g., "10 Oct 11:52 PM"
  }

  String _formatMessageDate(dynamic timestamp) {
    if (timestamp is DateTime) {
      return _formatDateTime(
          timestamp); // Use the combined date and time format
    }
    return "00:00"; // Default if timestamp is null or invalid
  }

  void _onReactionSelect(String reaction) async {
    setState(() {
      _messages.map((message) {
        if (message['message_id'] == selectedMessageId) {
          message['reaction'] = reaction; // রিঅ্যাকশন সেট করা হচ্ছে
        }
        return _messages;
      }).toList();
    });
    await sendReactionMessges(
        reaction, widget.userId, widget.userName, selectedMessageId!);
    setState(() {
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
    double screenWidth =
        MediaQuery.of(context).size.width; // Get full screen width
    double maxWidth = screenWidth * 0.8; // Limit width to 60% of screen
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
              'content': message['content'] ??
                  message['template_name'] ??
                  message['public_url'] ??
                  'No content', // Default content if all are null
              'fileName': message['fileName'] ?? 'unknown',

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
                constraints: BoxConstraints(maxWidth: maxWidth),
                margin:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 10),

                padding: const EdgeInsets.only(
                    bottom: 20,
                    left: 5,
                    right: 5,
                    top:
                        5), // Adjusted bottom padding to give space for reaction
                decoration: BoxDecoration(
                  color:
                      isUser ? const Color(0xff244a37) : Colors.grey.shade800,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (message['reply_to'] != null)
                        ReplyMessageWidget(replyTo: message['reply_to']),
                      message['type'] == 'text'
                          ? ConstrainedBox(
                              constraints: BoxConstraints(
                                minWidth: 75, // Minimum width of the text box
                                maxWidth: MediaQuery.of(context).size.width *
                                    0.7, // Max width (70% of screen)
                              ),
                              child: Container(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Text(
                                  message['content'],
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            )
                          : message['type'] == 'image'
                              ? buildImageWidget(message['public_url'])
                              : message['type'] == 'template'
                                  ? TemplatePreviewWidget(
                                      templateName: message['template_name'])
                                  : message['type'] == 'document'
                                      ? SizedBox(
                                          width:
                                              MediaQuery.sizeOf(context).width *
                                                  0.8, //260
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  const Icon(
                                                      Icons.insert_drive_file,
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
                                                formatFileSize(
                                                    message['fileSize'] ??
                                                        0), // Show file size
                                                style: const TextStyle(
                                                    color: Colors.grey),
                                              ),
                                              const SizedBox(
                                                  height:
                                                      10), // Add spacing before the button
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
                                              loadingBuilder: (context, child,
                                                  loadingProgress) {
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
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.5,
                                                  child: VideoPlayerWidget(
                                                    videoUrl:
                                                        message['public_url'],
                                                  ),
                                                )
                                              : message['type'] == 'audio'
                                                  ? SizedBox(
                                                      width: MediaQuery.sizeOf(
                                                                  context)
                                                              .width *
                                                          0.8, //260
                                                      height: 42,
                                                      child: AudioPlayerWidget(
                                                          audioUrl: message[
                                                              'public_url']),
                                                    )
                                                  : message['type'] ==
                                                          'uploading'
                                                      ? TenMinuteProgress()
                                                      : const SizedBox.shrink(),
                    ],
                  ),
                ),
              ),
              if (isUser || !isUser) // Show status only for sent messages
                Positioned(
                  bottom: 18, // Align to bottom-right

                  right: 15,
                  child: Row(
                    children: [
                      // Display Time
                      Text(
                        _formatTime(
                            message['timestamp']), // Format timestamp to HH:mm
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white70, // Adjust color as needed
                        ),
                      ),
                      const SizedBox(
                          width: 5), // Space between time and checkmarks

                      // Checkmarks
                      message['status'] == true
                          ? Stack(
                              children: [
                                // First checkmark
                                Icon(
                                  Icons.check,
                                  color: Colors.grey,
                                  size: 16,
                                ),
                                // Second checkmark (Overlapping the first)
                                Positioned(
                                  left:
                                      5, // Slightly shift the second checkmark to the right
                                  child: Icon(
                                    Icons.check,
                                    color: Colors.grey,
                                    size: 16,
                                  ),
                                ),
                              ],
                            )
                          : Icon(Icons.check,
                              color: Colors.grey, size: 16), // Single check
                    ],
                  ),
                ),
              if (reaction != null)
                Positioned(
                  bottom: -1, // Ensure space for reaction
                  right: 20, // Align to the bottom-right corner
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
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'type': 'document',
          'fileName': file.name,
          'fileSize': file.size,
          'sender': 'user',
          'reaction': null,
          'public_url': file.path,
          'timestamp': DateTime.now(),
          'status': false
        });
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
      // Upload to backend and get public URL
      await uploadFileToBackend(
          file.path!, 'document', file.name, widget.userId, widget.userName);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    }
  }

  void _openGalleryPicker() async {
    final ImagePicker picker = ImagePicker();

    // Ask the user whether they want to pick an image or a video

    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final fileSize = await File(image.path).length(); // File size in bytes
      const maxImageSize = 5 * 1024 * 1024; // 5 MB in bytes

      if (fileSize > maxImageSize) {
        // Show dialog for large image
        _showFileSizeErrorDialog(
          context,
          'Image exceeds 5 MB. Please select a smaller file.',
        );
        return;
      }

      print('Selected an image');

      // Add a temporary uploading message to the messages list
      final tempMessageId = DateTime.now().millisecondsSinceEpoch.toString();
      setState(() {
        _messages.add({
          'id': tempMessageId,
          'type': 'image',
          'fileName': image.name,
          'fileSize': fileSize,
          'sender': 'user',
          'reaction': null,
          'isUploading': true,
          'uploadProgress': 0.0,
          'public_url': image.path,
          'timestamp': DateTime.now(),
          'status': false
        });
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
      // Upload to backend and get public URL
      await uploadFileToBackend(
          image.path, 'image', image.name, widget.userId, widget.userName);

      // Update the temporary message in the messages list

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    }
  }

  void openVideoPicker() async {
    final ImagePicker picker = ImagePicker();

    final XFile? video = await picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      final fileSize = await File(video.path).length(); // File size in bytes
      const maxVideoSize = 15 * 1024 * 1024; // 15 MB in bytes

      if (fileSize > maxVideoSize) {
        // Show dialog for large video
        _showFileSizeErrorDialog(
          context,
          'Video exceeds 15 MB. Please select a smaller file.',
        );
        return;
      }

      print('Selected a video');

      // Add a temporary uploading message to the messages list
      final tempMessageId = DateTime.now().millisecondsSinceEpoch.toString();
      setState(() {
        _messages.add({
          'id': tempMessageId,
          'type': 'video',
          'fileName': video.name,
          'fileSize': fileSize,
          'sender': 'user',
          'reaction': null,
          'isUploading': true,
          'uploadProgress': 0.0,
          'public_url': video.path,
          'timestamp': DateTime.now(),
          'status': false
        });
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
      // Upload to backend and get public URL
      await uploadFileToBackend(
          video.path, 'video', video.name, widget.userId, widget.userName);

      // Update the temporary message in the messages list

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    }
  }

  void _showFileSizeErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('File Size Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _openAudioPicker() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );

    if (result != null) {
      PlatformFile file = result.files.first;

      // Upload to backend and get public URL
      setState(() {
        _messages.add({
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'type': 'audio',
          'fileName': file.name,
          'fileSize': '${(file.size / 1024).toStringAsFixed(2)} KB',
          'sender': 'user',
          'reaction': null,
          'public_url': file.path,
          'timestamp': DateTime.now(),
          'status': false
        });
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
      await uploadFileToBackend(
          file.path!, 'audio', file.name, widget.userId, widget.userName);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    }
  }

  void _openCatalogPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => Catalog(
                phoneNumber: widget.userId,
                name: widget.userName,
              )),
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
                    'Image',
                    Icons.photo,
                    Colors.purple,
                    () {
                      Navigator.pop(context); // Close modal
                      _openGalleryPicker(); // Perform action
                    },
                  ),
                  _buildAttachmentButton(
                    'Video',
                    Icons.video_file,
                    Colors.purple,
                    () {
                      Navigator.pop(context); // Close modal
                      openVideoPicker(); // Perform action
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildAttachmentButton(
                    'Audio',
                    Icons.headphones,
                    Colors.orange,
                    () {
                      Navigator.pop(context); // Close modal
                      _openAudioPicker(); // Perform action
                    },
                  ),
                  _buildAttachmentButton(
                    'Templates',
                    Icons.document_scanner,
                    Colors.green,
                    () {
                      Navigator.pop(context); // Close modal
                      _openCatalogPage(); // Perform action
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
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(
      //       content: Text('An error occurred while saving contact!')),
      // );
    }
  }

  String _getMessageDateLabel(DateTime messageDate) {
    final today = DateTime.now();
    final yesterday = today.subtract(Duration(days: 1));

    // Check if the message is today
    if (_isSameDay(today, messageDate)) {
      return "Today";
    }
    // Check if the message is yesterday
    else if (_isSameDay(yesterday, messageDate)) {
      return "Yesterday";
    } else {
      // Format the date (you can use any format you prefer)
      return DateFormat('yyyy-MM-dd').format(messageDate);
    }
  }

// Helper to compare if two dates are the same day
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  List<Widget> _buildMessageList() {
    List<Widget> messageWidgets = [];
    DateTime? lastMessageDate;

    for (var message in _messages) {
      DateTime messageDate =
          DateTime.fromMillisecondsSinceEpoch(message['timestamp']);
      String dateLabel = _getMessageDateLabel(messageDate);

      // Add the date label if it's different from the last message's date
      if (lastMessageDate == null ||
          !_isSameDay(lastMessageDate, messageDate)) {
        messageWidgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              dateLabel,
              style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.bold),
            ),
          ),
        );
      }

      messageWidgets
          .add(_buildMessage(message)); // Add the actual message widget
      lastMessageDate = messageDate; // Update the last message date
    }

    return messageWidgets;
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
              CircleAvatar(
                backgroundColor: Colors.grey,
                child: Text(
                  widget.userName[0].toUpperCase(),
                  style: const TextStyle(color: Colors.white),
                ),
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
