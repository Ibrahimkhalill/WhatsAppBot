import 'dart:io';
import 'package:dio/dio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_filex/open_filex.dart';

Future<bool> _requestStoragePermission() async {
  // For Android 11+, request MANAGE_EXTERNAL_STORAGE
  if (await Permission.manageExternalStorage.request().isGranted) {
    return true;
  }

  // For Android <11, request READ and WRITE permissions
  if (await Permission.storage.request().isGranted) {
    return true;
  }

  // Permission denied
  return false;
}

Future<void> downloadAndOpenDocument(String url) async {
  final permissionGranted = await _requestStoragePermission();
  if (!permissionGranted) {
    print('Storage permission denied');
    return;
  }

  // Get the Downloads directory for Android
  final downloadsDirectory = Directory('/storage/emulated/0/Download');
  if (!downloadsDirectory.existsSync()) {
    downloadsDirectory.createSync();
  }

  // Extract the file name and file extension from the URL
  final fileName = url.split('/').last;
  final fileExtension = fileName.split('.').last.toLowerCase();

  // Check if the file is an audio or video file
  const audioExtensions = ['mp3', 'wav', 'aac', 'flac', 'ogg'];
  const videoExtensions = ['mp4', 'avi', 'mov', 'mkv', 'webm'];

  if (audioExtensions.contains(fileExtension) ||
      videoExtensions.contains(fileExtension)) {
    print('Audio or video files are not supported for opening.');
    return;
  }

  // Define the file path
  final filePath = '${downloadsDirectory.path}/$fileName';

  // Check if the file already exists
  if (!File(filePath).existsSync()) {
    try {
      // Download the file using Dio
      print('Downloading file...');
      final dio = Dio();
      await dio.download(url, filePath);
      print('File downloaded to: $filePath');
    } catch (e) {
      print('Error downloading file: $e');
      return;
    }
  }

  // Open the file using OpenFilex
  final result = await OpenFilex.open(filePath);

  if (result.type != ResultType.done) {
    print('Error opening file: ${result.message}');
  }
}
