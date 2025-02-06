import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Catalog extends StatefulWidget {
  final String phoneNumber; // ✅ Accept phone number as a parameter
  final String name; // ✅ Accept phone number as a parameter

  const Catalog({super.key, required this.phoneNumber, required this.name});

  @override
  _CatalogState createState() => _CatalogState();
}

class _CatalogState extends State<Catalog> {
  List<Map<String, dynamic>> templates = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTemplates();
  }

  Future<void> fetchTemplates() async {
    final url =
        "https://evidently-deciding-insect.ngrok-free.app/api/templates";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success' && data['data']['data'] != null) {
          setState(() {
            templates = List<Map<String, dynamic>>.from(data['data']['data']);
            isLoading = false;
          });
        } else {
          throw Exception("Invalid response format");
        }
      } else {
        throw Exception("Failed to fetch templates");
      }
    } catch (e) {
      print("❌ Error: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _sendTemplateMessage(
      String templateName, String languageCode) async {
    final url =
        "https://evidently-deciding-insect.ngrok-free.app/api/send-template";
    print(widget.phoneNumber);
    final body = jsonEncode({
      "to": widget.phoneNumber, // ✅ Use the phone number from Home Page
      "template_name": templateName,
      "language_code": languageCode,
      "name": widget.name
    });

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Template sent successfully!")),
        );
      } else {
        throw Exception("Failed to send template");
      }
    } catch (e) {
      print("❌ Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Failed to send template")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black45,
        title: const Text('WhatsApp Templates'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchTemplates,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : templates.isEmpty
              ? const Center(child: Text("No templates found"))
              : ListView.builder(
                  itemCount: templates.length,
                  itemBuilder: (context, index) {
                    final template = templates[index];
                    return buildTemplateItem(template);
                  },
                ),
    );
  }

  Widget buildTemplateItem(Map<String, dynamic> template) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ WhatsApp-style Message Preview
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(01),
                    blurRadius: 3,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🏷️ Header (Bold)
                  if (template['components'] != null &&
                      template['components'].isNotEmpty)
                    Text(
                      template['components'][0]['text'] ?? "No Header",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  const SizedBox(height: 5),

                  // 📜 Body (Regular)
                  Text(
                    template['components'][1]['text'] ??
                        "No body text available",
                    style: const TextStyle(fontSize: 14),
                  ),

                  const SizedBox(height: 10),

                  // 🔽 Footer (Smaller & Lighter)
                  if (template['components'].length > 2)
                    Text(
                      template['components'][2]['text'] ?? "No footer",
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),

                  // 🕒 Timestamp (Simulated)
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Send Template Button
            ElevatedButton(
              onPressed: () {
                _sendTemplateMessage(template['name'], template['language']);
              },
              child: const Text("Send Template"),
            ),
          ],
        ),
      ),
    );
  }
}
