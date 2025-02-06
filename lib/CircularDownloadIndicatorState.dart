import 'dart:async';
import 'package:flutter/material.dart';

class TenMinuteProgress extends StatefulWidget {
  @override
  _TenMinuteProgressState createState() => _TenMinuteProgressState();
}

class _TenMinuteProgressState extends State<TenMinuteProgress> {
  double _progress = 0.0; // Tracks progress (0.0 to 1.0)
  Timer? _timer; // Timer to update progress

  @override
  void initState() {
    super.initState();
    _startProgress(); // Start the progress when the widget is loaded
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer to prevent memory leaks
    super.dispose();
  }

  void _startProgress() {
    const totalDuration = Duration(minutes: 10); // Fixed 10-minute duration
    const updateInterval = Duration(milliseconds: 100); // Update every 100ms

    final totalSteps =
        totalDuration.inMilliseconds / updateInterval.inMilliseconds;
    final incrementValue = 1.0 / totalSteps; // Increment per step

    _timer = Timer.periodic(updateInterval, (timer) {
      if (_progress < 1.0) {
        setState(() {
          _progress += incrementValue; // Increment progress
        });
      } else {
        timer.cancel(); // Stop the timer when progress reaches 100%
        print("Progress completed!");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Circular progress bar
              CircularProgressIndicator(
                value: _progress, // Dynamically updates progress (0.0 to 1.0)
                strokeWidth: 6.0,
                valueColor: const AlwaysStoppedAnimation<Color>(
                    Colors.blue), // Progress color
                backgroundColor: Colors.grey.shade300, // Background color
              ),
              // Percentage text in the center
              Text(
                "${(_progress * 100).toStringAsFixed(0)}%", // Display percentage
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
