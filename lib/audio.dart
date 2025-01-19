import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class AudioPlayerWidget extends StatefulWidget {
  final String audioUrl;

  const AudioPlayerWidget({Key? key, required this.audioUrl}) : super(key: key);

  @override
  AudioPlayerWidgetState createState() => AudioPlayerWidgetState();
}

class AudioPlayerWidgetState extends State<AudioPlayerWidget>
    with WidgetsBindingObserver {
  late AudioPlayer _audioPlayer;
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  final List<int> waveformData = [
    5,
    20,
    35,
    40,
    15,
    10,
    5,
    10,
    20,
    25,
    20,
    10,
    5,
    15,
    25,
    15,
    10,
    12,
    13,
    20,
    30,
    13,
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // Observe app lifecycle changes
    _audioPlayer = AudioPlayer();

    _audioPlayer.onDurationChanged.listen((newDuration) {
      setState(() {
        duration = newDuration;
      });
    });

    _audioPlayer.onPositionChanged.listen((newPosition) {
      setState(() {
        position = newPosition;
      });
    });

    _audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        isPlaying = false;
        position = Duration.zero;
      });
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Remove lifecycle observer
    _audioPlayer.stop(); // Stop the audio playback
    _audioPlayer.dispose(); // Release the audio player
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      // Pause or stop the audio when the app goes to the background
      _audioPlayer.pause();
      setState(() {
        isPlaying = false;
      });
    }
  }

  Future<void> togglePlayPause() async {
    if (isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play(UrlSource(widget.audioUrl));
    }

    setState(() {
      isPlaying = !isPlaying;
    });
  }

  String formatTime(Duration time) {
    final minutes = time.inMinutes;
    final seconds = time.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final filledBars = duration.inMilliseconds > 0
        ? ((position.inMilliseconds / duration.inMilliseconds) *
                waveformData.length)
            .floor()
        : 0;

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: togglePlayPause,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Row(
                children: waveformData.asMap().entries.map((entry) {
                  final index = entry.key;
                  final height = entry.value;
                  final isFilled = index < filledBars;

                  return Container(
                    width: MediaQuery.sizeOf(context).width * 0.019,
                    height: height.toDouble(),
                    decoration: BoxDecoration(
                      color: isFilled ? Colors.green : Colors.grey,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              formatTime(duration - position),
              style: const TextStyle(color: Colors.white, fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
