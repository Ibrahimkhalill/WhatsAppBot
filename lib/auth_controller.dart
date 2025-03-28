// TODO Implement this library.
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Rx<User?> firebaseUser = Rx<User?>(null);

  @override
  void onInit() {
    super.onInit();
    firebaseUser.bindStream(_auth.authStateChanges()); // Auto-login listener
  }

  // Login Method
  Future<void> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      Get.snackbar("Login Successful", "Welcome back!");
    } catch (e) {
      Get.snackbar("Login Error", e.toString());
    }
  }

  // Logout Method
  Future<void> logout() async {
    await _auth.signOut();
  }
}
