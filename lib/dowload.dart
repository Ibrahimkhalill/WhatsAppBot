import 'dart:io';
import 'package:dio/dio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
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

  // Determine the correct downloads directory based on the platform
  late Directory downloadsDirectory;

  if (Platform.isAndroid) {
    // Android: Use path_provider to get a valid directory
    downloadsDirectory = await getExternalStorageDirectory() ?? Directory('/storage/emulated/0/Download');
  } else if (Platform.isIOS) {
    // iOS: Use the app's Documents directory
    downloadsDirectory = await getApplicationDocumentsDirectory();
  } else {
    print('Unsupported platform');
    return;
  }

  // Ensure the directory exists
  if (!downloadsDirectory.existsSync()) {
    downloadsDirectory.createSync();
  }

  // Extract and sanitize the file name from the URL
  String fileName = url.split('/').last.split('?').first; // Take only the part before query parameters
  fileName = Uri.decodeComponent(fileName); // Decode URL-encoded characters (e.g., %20 to space)
  final fileExtension = fileName.split('.').last.toLowerCase();

  // Check if the file is an audio or video file
  const audioExtensions = ['mp3', 'wav', 'aac', 'flac', 'ogg'];
  const videoExtensions = ['mp4', 'avi', 'mov', 'mkv', 'webm'];

  if (audioExtensions.contains(fileExtension) || videoExtensions.contains(fileExtension)) {
    print('Audio or video files are not supported for opening.');
    return;
  }

  // Shorten the file name if it exceeds 255 characters
  const maxFileNameLength = 255 - 10; // Leave room for directory path and extension
  if (fileName.length > maxFileNameLength) {
    final baseName = fileName.substring(0, fileName.lastIndexOf('.'));
    final extension = fileName.substring(fileName.lastIndexOf('.'));
    fileName = '${baseName.substring(0, maxFileNameLength - extension.length)}$extension';
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
  } else {
    print('File already exists at: $filePath');
  }

  // Open the file using OpenFilex
  final result = await OpenFilex.open(filePath);

  if (result.type != ResultType.done) {
    print('Error opening file: ${result.message}');
  } else {
    print('File opened successfully');
  }
}
