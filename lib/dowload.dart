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
  try {
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

    // Extract the file name from the URL
    final fileName = url.split('/').last;
    final filePath = '${downloadsDirectory.path}/$fileName';

    // Download the file using Dio
    Dio dio = Dio();
    await dio.download(url, filePath);

    print('File saved to $filePath');

    // Open the file using OpenFilex
    final result = await OpenFilex.open(filePath);

    if (result.type != ResultType.done) {
      print('Error opening file: ${result.message}');
    }
  } catch (e) {
    print('Error downloading or opening file: $e');
  }
}
