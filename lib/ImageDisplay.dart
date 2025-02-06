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
            width: 200,
            height: 200,
            color: Colors.grey.shade300, // Placeholder background
          ),
        ),

        // Actual image
        SizedBox(
          width: 200,
          height: 200,
          child: Image.network(
            imageUrl,

            fit: BoxFit.cover, // Cover the box without distortion
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) {
                // Remove shimmer and show image when loaded
                return child;
              }
              return const SizedBox
                  .shrink(); // Show shimmer until loading completes
            },
            errorBuilder: (context, error, stackTrace) {
              // Show error placeholder if image fails to load
              return Container(
                width: 200,
                height: 200,
                color: Colors.grey.shade300,
                child: const Center(
                  child: Icon(Icons.image_not_supported,
                      color: Colors.grey, size: 50),
                ),
              );
            },
          ),
        ),

        // Overlay text or spinner while loading
        // Positioned.fill(
        //   child: Container(
        //     alignment: Alignment.center,
        //     child: CircularProgressIndicator(
        //       valueColor: AlwaysStoppedAnimation<Color>(Colors.grey.shade600),
        //       strokeWidth: 2.0,
        //     ),
        //   ),
        // ),
      ],
    ),
  );
}
