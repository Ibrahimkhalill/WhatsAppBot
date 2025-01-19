import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';


class FileLinkList extends StatelessWidget {
  final List<Map<String, String>> data = [
    {"id": "1", "name": "Www.Good.Com"},
    {"id": "2", "name": "Www.Good.Com"},
    {"id": "3", "name": "Www.Good.Com"},
    {"id": "4", "name": "Www.Good.Com"},
    {"id": "5", "name": "Www.Good.Com"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("File"),

      ),
      body: Padding(
        
        padding: const EdgeInsets.all(10.0),
        
        child: Container(
          color: Color(0xff0F0F0F),
          child: ListView.builder(
            
            itemCount: data.length,
            itemBuilder: (context, index) {
              final item = data[index];
              return Container(
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
                        child: FaIcon(FontAwesomeIcons.file, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      item['name']!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
