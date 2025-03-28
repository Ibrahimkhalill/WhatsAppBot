import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

Widget buildImageWidget(String imageUrl) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(10), // Rounded corners
    child: Stack(
      children: [
        // Shimmer placeholder while loading
        Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            width: 230, // Max width
            color: Colors.grey.shade300, // Placeholder background
          ),
        ),

        // Actual image
        LayoutBuilder(
          builder: (context, constraints) {
            double maxWidth = 230;
            double aspectRatio = 1.0; // Default aspect ratio of 1:1

            // Get the aspect ratio of the image
            return FutureBuilder(
              future: _getImageAspectRatio(imageUrl),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done &&
                    snapshot.hasData) {
                  aspectRatio = snapshot.data as double;
                }

                double imageHeight = maxWidth /
                    aspectRatio; // Adjust height based on aspect ratio

                return SizedBox(
                  width: maxWidth,
                  height: imageHeight,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain, // Preserve aspect ratio
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) {
                        return child;
                      }
                      return Shimmer.fromColors(
                        baseColor: Colors.grey.shade300,
                        highlightColor: Colors.grey.shade100,
                        child: Container(
                          width: maxWidth,
                          height: imageHeight,
                          color: Colors.grey.shade300,
                        ),
                      ); // Show shimmer effect until loading completes
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: maxWidth,
                        height: imageHeight,
                        color: Colors.grey.shade300,
                        child: const Center(
                          child: Icon(Icons.image_not_supported,
                              color: Colors.grey, size: 50),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ],
    ),
  );
}

// Helper function to get the aspect ratio of the image
Future<double> _getImageAspectRatio(String imageUrl) async {
  final image = NetworkImage(imageUrl);
  final configuration = ImageConfiguration();
  final imageStream = image.resolve(configuration);

  final completer = Completer<double>();
  imageStream.addListener(
    ImageStreamListener(
      (ImageInfo info, bool synchronousCall) {
        final width = info.image.width;
        final height = info.image.height;
        final aspectRatio = width / height;
        completer.complete(aspectRatio);
      },
      onError: (exception, stackTrace) {
        completer.completeError(exception);
      },
    ),
  );
  return completer.future;
}
