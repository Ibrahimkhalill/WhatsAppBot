import 'package:cargpt/chat.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NotificationController extends GetxController {
  static NotificationController instance = Get.find();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
    _initializeNotifications();
  }

  /// Initialize Firebase Messaging
  void _initializeNotifications() async {
    // Request permission for notifications
    await _firebaseMessaging.requestPermission();

    // Get FCM Token for debugging (Remove in production)
    String? token = await _firebaseMessaging.getToken();
    if (token != null) {
      await sendTokenToBackend(token);
      print("🔥 FCM Token: $token");
    }

    // Initialize local notifications with click action
    const AndroidInitializationSettings androidInitSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initSettings =
    InitializationSettings(android: androidInitSettings);

    _flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null) {
          _fetchUserDataAndNavigate(response.payload!);
        }
      },
    );

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showNotification(message);
    });

    // Handle background & terminated messages (click action)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _fetchUserDataAndNavigate(message.data['from']);
    });
  }

  /// Show local notification with `from` field as payload
  Future<void> _showNotification(RemoteMessage message) async {
    String? fromNumber = message.data['phoneNumber']; // Extract sender's number
    print("fromNumber, $fromNumber");

    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformDetails =
    NotificationDetails(android: androidDetails);
    await _flutterLocalNotificationsPlugin.show(
      0,
      message.notification?.title ?? "",
      message.notification?.body ?? "You have a new message",
      platformDetails,
      payload: fromNumber, // Send sender's number in payload
    );
  }

  /// Fetch user details from Firestore and navigate to ChatPage
  void _fetchUserDataAndNavigate(String? fromNumber) async {
    if (fromNumber == null || fromNumber.isEmpty) return;

    print("🔍 Fetching user data for: $fromNumber");

    try {
      // Query Firestore to get user details
      QuerySnapshot querySnapshot = await _firestore
          .collection('conversation')
          .where('from', isEqualTo: fromNumber)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var userData = querySnapshot.docs.first.data() as Map<String, dynamic>;

        final name = userData['name'].toLowerCase();
        final number = userData['from'].toLowerCase();

        print("✅ User Found: $name ($number)");

        // Navigate to ChatPage
        Get.to(() => Chat(
          userId: number,
          userName: name,
        ));
      } else {
        print("❌ No matching conversation found.");
      }
    } catch (e) {
      print("⚠️ Error fetching user data: $e");
    }
  }
}

/// Send FCM Token to Backend
Future<void> sendTokenToBackend(String token) async {
  final String backendUrl =
      "https://cargpt-mfnpvbi7nq-uc.a.run.app/save-token"; // Replace with your backend URL
  try {
    final response = await http.post(
      Uri.parse(backendUrl),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'token': token}),
    );

    if (response.statusCode == 200) {
      print("✅ Token successfully sent to backend.");
    } else {
      print("❌ Failed to send token. Status: ${response.statusCode}");
    }
  } catch (e) {
    print("⚠️ Error sending token to backend: $e");
  }
}
