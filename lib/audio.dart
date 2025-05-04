import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter/material.dart';

class AudioPlayerWidget extends StatefulWidget {
  final String? audioUrl;
  const AudioPlayerWidget({super.key, this.audioUrl});

  @override
  AudioPlayerWidgetState createState() => AudioPlayerWidgetState();
}

class AudioPlayerWidgetState extends State<AudioPlayerWidget>
    with WidgetsBindingObserver {
  late FlutterSoundPlayer _audioPlayer;
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
    WidgetsBinding.instance.addObserver(this);
    _audioPlayer = FlutterSoundPlayer();

    // Initialize the player
    _audioPlayer.openPlayer().then((_) {
      // Set subscription duration for progress updates
      _audioPlayer.setSubscriptionDuration(Duration(milliseconds: 100));
      // Listen for progress updates (position and duration)
      _audioPlayer.onProgress!.listen((event) {
        setState(() {
          position = event.position;
          duration = event.duration;
          // Update isPlaying based on progress
          isPlaying = event.position < event.duration;
        });
      });
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _audioPlayer.stopPlayer();
    _audioPlayer.closePlayer(); // Release resources
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _audioPlayer.stopPlayer();
      setState(() {
        isPlaying = false;
      });
    }
  }

  Future<void> togglePlayPause() async {
    if (widget.audioUrl == null || widget.audioUrl!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No valid audio URL provided')),
      );
      return;
    }

    try {
      String fileExtension = widget.audioUrl!.split('.').last.toLowerCase();
      Codec codec = fileExtension == 'mpeg' ? Codec.mp3 : Codec.defaultCodec;

      print('Playing: ${widget.audioUrl} with codec: $codec');
      if (isPlaying) {
        print('Stopping audio');
        await _audioPlayer.stopPlayer();
        setState(() {
          isPlaying = false;
          position = Duration.zero;
        });
      } else {
        print('Starting audio');
        await _audioPlayer.startPlayer(
          fromURI: widget.audioUrl!,
          codec: codec,
          whenFinished: () {
            print('Playback finished');
            setState(() {
              isPlaying = false;
              position = Duration.zero;
            });
          },
        );
        setState(() {
          isPlaying = true;
        });
      }
    } catch (e, stackTrace) {
      print('Audio error: $e\nStack trace: $stackTrace');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error playing audio: $e')),
      );
    }
  }

  String formatTime(Duration time) {
    final minutes = time.inMinutes;
    final seconds = time.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (widget.audioUrl == null || widget.audioUrl!.isEmpty) {
      return const Center(
        child: Text(
          'No audio available',
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
      );
    }

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
                decoration: const BoxDecoration(
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

                  return Expanded(
                    child: Container(
                      height: height.toDouble(),
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                      decoration: BoxDecoration(
                        color: isFilled ? Colors.green : Colors.grey,
                        borderRadius: BorderRadius.circular(2),
                      ),
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
