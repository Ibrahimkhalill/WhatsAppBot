import 'package:cargpt/global_variable.dart';
import 'package:dio/dio.dart';

Future<String?> uploadFileToBackend(String filePath, String fileType,
    String fileName, String userPhoneNumber, name) async {
  final Dio dio = Dio();

  try {
    print(
        'Uploading file: $filePath, FileName: $fileName, FileType: $fileType, User: $userPhoneNumber');
    final response = await dio.post(
      '$BASE_URL/send-media', // Replace with your API endpoint
      data: FormData.fromMap({
        'file': await MultipartFile.fromFile(
          filePath,
          filename: filePath.split('/').last,
        ),
        'type': fileType, // e.g., 'image', 'video', 'audio', 'document'
        'phone_number': userPhoneNumber, // Include the user's phone number
        'name': name
      }),
    );

    print('Response: ${response.data}');
    if (response.statusCode == 200) {
      print('Response: ${response.data}');
    } else {
      print('File upload failed with status: ${response.statusCode}');
    }
  } catch (e) {
    print('Error uploading file: $e');
  }
  return null; // Return null if the upload fails
}

Future<void> sendTextMessage(
    String messageBody, String userPhoneNumber, String name) async {
  final Dio dio = Dio();

  try {
    print('$BASE_URL');
    print('Text message asche : $messageBody');
    print('Text message 1 : $userPhoneNumber');
    final response = await dio.post(
      '$BASE_URL/send-message', // Replace with your API endpoint
      data: {
        'type': 'text', // Message type
        'body': messageBody, // The actual text message
        'phone_number': userPhoneNumber, // Sender's phone number
        'name': name
      },
    );

    if (response.statusCode == 200) {
      print('Text message sent successfully: ${response.data}');
    } else {
      print('Failed to send text message: ${response.statusCode}');
    }
  } catch (e) {
    print('Error sending text message: $e');
  }
}

Future<void> sendReactionMessges(String reaction, String userPhoneNumber,
    String name, String messageId) async {
  final Dio dio = Dio();
  print('Text message sent successfully: $messageId');
  try {
    final response = await dio.post(
      '$BASE_URL/send-reaction', // Replace with your API endpoint
      data: {
        'reaction': reaction, // Message type
        'message_id': messageId, // The actual text message
        'phone_number': userPhoneNumber, // Sender's phone number
        'name': name
      },
    );

    if (response.statusCode == 200) {
      print('Text message sent successfully: ${response.data}');
    } else {
      print('Failed to send text message: ${response.statusCode}');
    }
  } catch (e) {
    print('Error sending text message: $e');
  }
}

Future<void> sendReplyMessges(
  String replyMessage,
  String userPhoneNumber,
  String name,
  String originalMessageId,
) async {
  final Dio dio = Dio();

  try {
    final response = await dio.post(
      '$BASE_URL/send-reply', // Replace with your API endpoint
      data: {
        'reply_message': replyMessage, // Message type
        'original_message_id': originalMessageId, // The actual text message
        'phone_number': userPhoneNumber, // Sender's phone number
        'name': name,
      },
    );

    if (response.statusCode == 200) {
      print('Text message sent successfully: ${response.data}');
    } else {
      print('Failed to send text message: ${response.statusCode}');
    }
  } catch (e) {
    print('Error sending text message: $e');
  }
}

Future<void> uploadTemplates(
  String replyMessage,
  String userPhoneNumber,
  String name,
  String originalMessageId,
) async {
  final Dio dio = Dio();

  try {
    final response = await dio.post(
      '$BASE_URL/send-reply', // Replace with your API endpoint
      data: {
        'reply_message': replyMessage, // Message type
        'original_message_id': originalMessageId, // The actual text message
        'phone_number': userPhoneNumber, // Sender's phone number
        'name': name,
      },
    );

    if (response.statusCode == 200) {
      print('Text message sent successfully: ${response.data}');
    } else {
      print('Failed to send text message: ${response.statusCode}');
    }
  } catch (e) {
    print('Error sending text message: $e');
  }
}
