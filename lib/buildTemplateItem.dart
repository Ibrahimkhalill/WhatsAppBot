import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class TemplatePreviewWidget extends StatefulWidget {
  final String templateName;

  const TemplatePreviewWidget({super.key, required this.templateName});

  @override
  _TemplatePreviewWidgetState createState() => _TemplatePreviewWidgetState();
}

class _TemplatePreviewWidgetState extends State<TemplatePreviewWidget> {
  Map<String, dynamic>? selectedTemplate;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTemplate(widget.templateName);
  }

  Future<void> fetchTemplate(String templateName) async {
    final url =
        "https://evidently-deciding-insect.ngrok-free.app/api/templates"; // Replace with your backend URL

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success' && data['data']['data'] != null) {
          List<Map<String, dynamic>> fetchedTemplates =
              List<Map<String, dynamic>>.from(data['data']['data']);

          Map<String, dynamic>? matchedTemplate = fetchedTemplates.firstWhere(
            (template) => template['name'] == templateName,
            orElse: () => {},
          );

          setState(() {
            selectedTemplate =
                matchedTemplate.isNotEmpty ? matchedTemplate : null;
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

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (selectedTemplate == null) {
      return const Center(child: Text("❌ Template not found"));
    }

    return buildTemplatePreview(selectedTemplate!);
  }

  Widget buildTemplatePreview(Map<String, dynamic> template) {
    double screenWidth =
        MediaQuery.of(context).size.width; // Get full screen width
    double maxWidth = screenWidth * 0.8; // ✅ Limit width to 60% of screen

    return Center(
      child: Container(
        width: maxWidth, // ✅ Apply width limit
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
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
              template['components'][1]['text'] ?? "No body text available",
              style: const TextStyle(fontSize: 14),
            ),

            const SizedBox(height: 10),

            // 🔽 Footer (Smaller & Lighter)
            if (template['components'].length > 2)
              Text(
                template['components'][2]['text'] ?? "No footer",
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),

            // 🕒 Timestamp (Simulated)
          ],
        ),
      ),
    );
  }
}
