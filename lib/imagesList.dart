import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ImagesList extends StatelessWidget {
  final List<Map<String, String>> data = [
    {
      "id": "1",
      "image":
          "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTW-ZDo6dn0xY3dzUY7oInTwNNjk6ugbnlp-w&s",
    },
    {
      "id": "2",
      "image":
          "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSt-aVSwyC837TC1jX1MU851UgmO1l5clhqFA&s",
    },
    {
      "id": "3",
      "image":
          "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQqAcQK0E1dBdD4VZd5GccLrtlE3jyBKsfnRw&s",
    },
    {
      "id": "4",
      "image":
          "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSt-aVSwyC837TC1jX1MU851UgmO1l5clhqFA&s",
    },
    {
      "id": "5",
      "image":
          "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSYVE48Lu5SA84tJJyjLX1gPfuGg2tJR_JXCw&s",
    },
    {
      "id": "6",
      "image":
          "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSt-aVSwyC837TC1jX1MU851UgmO1l5clhqFA&s",
    },
    {
      "id": "7",
      "image":
          "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSC3kkPLgaCGbBGiUXJR2xgUZDkwlMmtqdZYQ&s",
    },
    {
      "id": "8",
      "image":
          "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSt-aVSwyC837TC1jX1MU851UgmO1l5clhqFA&s",
    },
    {
      "id": "9",
      "image":
          "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQaR2D9K2yAvAJpoqn0SMt1CHSRrziLietBPQ&s",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Images"),
        backgroundColor: Color(0xff0F0F0F),
      ),
      body: Padding(
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
            return FutureBuilder(
              future:
                  Future.delayed(const Duration(seconds: 2)), // 1-minute delay
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // Show shimmer effect while waiting
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
                } else {
                  // Show the image once delay is over
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      item['image']!,
                      fit: BoxFit
                          .cover, // Ensures the image covers the container
                    ),
                  );
                }
              },
            );
          },
        ),
      ),
    );
  }
}
