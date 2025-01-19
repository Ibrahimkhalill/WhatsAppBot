import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class TemplatesPage extends StatefulWidget {
  const TemplatesPage({super.key});

  @override
  _TemplatesPageState createState() => _TemplatesPageState();
}

class _TemplatesPageState extends State<TemplatesPage> {
  final List<Map<String, dynamic>> _templates = [];

  void _addTemplate(Map<String, dynamic> newTemplate) {
    setState(() {
      _templates.add(newTemplate);
    });
  }

  void _sendMessage(Map<String, dynamic> template) {
    // Logic to send the message
    print('Sending Template: ${template['name']}');
    print('Message Body: ${template['body']}');
    if (template['mediaUrl'] != null) {
      print('Media: ${template['mediaUrl']} (${template['mediaType']})');
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('Message sent using template: ${template['name']}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Message Templates'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreateTemplateScreen(
                    onTemplateCreated: _addTemplate,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: _templates.isEmpty
          ? const Center(child: Text('No templates available. Add a new one!'))
          : ListView.builder(
              itemCount: _templates.length,
              itemBuilder: (context, index) {
                final template = _templates[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    leading: template['mediaUrl'] != null
                        ? Image.file(
                            File(template['mediaUrl']),
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          )
                        : const Icon(Icons.text_fields, size: 50),
                    title: Text(template['name']),
                    subtitle: Text(template['body']),
                    trailing: IconButton(
                      icon: const Icon(Icons.send, color: Colors.green),
                      onPressed: () => _sendMessage(template),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class CreateTemplateScreen extends StatefulWidget {
  final Function(Map<String, dynamic>) onTemplateCreated;

  const CreateTemplateScreen({super.key, required this.onTemplateCreated});

  @override
  _CreateTemplateScreenState createState() => _CreateTemplateScreenState();
}

class _CreateTemplateScreenState extends State<CreateTemplateScreen> {
  final _nameController = TextEditingController();
  final _bodyController = TextEditingController();
  File? _selectedMedia;
  String? _mediaType; // image, video, or document
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickMedia() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedMedia = File(pickedFile.path);
        _mediaType = 'image';
      });
    }
  }

  void _saveTemplate() {
    if (_nameController.text.isEmpty || _bodyController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    final newTemplate = {
      'name': _nameController.text,
      'body': _bodyController.text,
      'mediaUrl': _selectedMedia?.path,
      'mediaType': _mediaType,
    };

    widget.onTemplateCreated(newTemplate);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Template'),
        backgroundColor: Colors.black26,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Template Name'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _bodyController,
              decoration: const InputDecoration(labelText: 'Message Body'),
              maxLines: 5,
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _pickMedia,
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: _selectedMedia == null
                    ? const Center(child: Text('Upload Media (Image/Video)'))
                    : Image.file(_selectedMedia!, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveTemplate,
              child: const Text('Save Template'),
            ),
          ],
        ),
      ),
    );
  }
}
