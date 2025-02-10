import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cargpt/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase Initialization with DefaultFirebaseOptions
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyDhllH4_opu1UHBHfA4x4voDJ-FqujibGw",
      authDomain:
          "cargpt-sg.firebaseapp.com", // usually <project_id>.firebaseapp.com
      projectId: "cargpt-sg",
      storageBucket: "cargpt-sg.firebasestorage.app",
      messagingSenderId: "991914845428", // from your project number
      appId: "1:991914845428:android:87ed41f43bcfbf98722aa1",
    ),
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(child: HomeScreen()),
      ),
    );
  }
}
