import 'package:cargpt/auth_controller.dart';
import 'package:cargpt/login_screen.dart';
import 'package:cargpt/notification_controller.dart';
import 'package:cargpt/home.dart';
import 'package:cargpt/firebase_options.dart'; // ✅ Import the generated file
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Safe Firebase initialization using generated options
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }


  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const AuthCheck(), // Auto Login Check
    );
  }
}

class AuthCheck extends StatelessWidget {
  const AuthCheck({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.put(AuthController()); // Move outside Obx
    Get.put(NotificationController()); // Initialize Notifications
    return Obx(() {
      return authController.firebaseUser.value != null
          ?  HomeScreen()
          :  LoginScreen();
    });
  }
}
