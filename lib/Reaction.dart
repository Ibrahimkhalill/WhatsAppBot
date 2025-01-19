import 'package:flutter/material.dart';

class ReactionDialog {
  static void showReactionDialog({
    required BuildContext context,
    required Function(String) onReactionSelect,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey.shade800,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () {
                  onReactionSelect('👍');
                  Navigator.of(context).pop(); // Close dialog
                },
                child: const Text('👍', style: TextStyle(fontSize: 20)),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  onReactionSelect('❤️');
                  Navigator.of(context).pop();
                },
                child: const Text('❤️', style: TextStyle(fontSize: 20)),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  onReactionSelect('😂');
                  Navigator.of(context).pop();
                },
                child: const Text('😂', style: TextStyle(fontSize: 20)),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  onReactionSelect('😮');
                  Navigator.of(context).pop();
                },
                child: const Text('😮', style: TextStyle(fontSize: 20)),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  onReactionSelect('😢');
                  Navigator.of(context).pop();
                },
                child: const Text('😢', style: TextStyle(fontSize: 20)),
              ),
            ],
          ),
        );
      },
    );
  }
}
