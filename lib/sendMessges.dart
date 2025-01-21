import 'package:dio/dio.dart';

Future<String?> uploadFileToBackend(String filePath, String fileType,
    String fileName, String userPhoneNumber) async {
  final Dio dio = Dio();

  try {
    print(
        'Uploading file: $filePath, FileName: $fileName, FileType: $fileType, User: $userPhoneNumber');
    final response = await dio.post(
      'https://b514-115-127-156-9.ngrok-free.app/send-media', // Replace with your API endpoint
      data: FormData.fromMap({
        'file': await MultipartFile.fromFile(
          filePath,
          filename: filePath.split('/').last,
        ),
        'type': fileType, // e.g., 'image', 'video', 'audio', 'document'
        'phone_number': userPhoneNumber, // Include the user's phone number
      }),
    );

    print('Response: ${response.data}');
    if (response.statusCode == 200) {
      final responseData = response.data;
      if (responseData is Map && responseData.containsKey('filePath')) {
        return responseData['filePath'] as String; // Extract the public URL
      }
    } else {
      print('File upload failed with status: ${response.statusCode}');
    }
  } catch (e) {
    print('Error uploading file: $e');
  }
  return null; // Return null if the upload fails
}

Future<void> sendTextMessage(
  String messageBody,
  String userPhoneNumber,
) async {
  final Dio dio = Dio();

  try {
    print('Text message asche : $messageBody');
    print('Text message 1 : $userPhoneNumber');
    final response = await dio.post(
      'https://b514-115-127-156-9.ngrok-free.app/send-message', // Replace with your API endpoint
      data: {
        'type': 'text', // Message type
        'body': messageBody, // The actual text message
        'phone_number': userPhoneNumber, // Sender's phone number
      },
    );
    print('Text message sent successfully: ${response.data}');
    if (response.statusCode == 200) {
      print('Text message sent successfully: ${response.data}');
    } else {
      print('Failed to send text message: ${response.statusCode}');
    }
  } catch (e) {
    print('Error sending text message: $e');
  }
}
