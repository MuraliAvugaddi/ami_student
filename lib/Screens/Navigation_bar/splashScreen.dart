import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

// Import your endpoints & screens
import 'package:ami_student/api/api_endpoint.dart';
import 'package:ami_student/Screens/Navigation_bar/new_main_screen.dart';
import 'package:ami_student/Screens/auth/onbording_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Keep the 3-second splash screen display time
    await Future.delayed(const Duration(seconds: 3));

    final box = GetStorage();
    final token = box.read('token');

    // If no token exists locally, go straight to onboarding
    if (token == null) {
      Get.off(() => const OnboardingScreen());
      return;
    }

    try {
      // 🟢 FIX 1: Using actual production ApiEndpoints URL instead of hardcoded placeholder
      final response = await http.get(
        Uri.parse(ApiEndpoints.userProfile),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      // If backend explicitly says unauthorized (token expired / deleted user)
      if (response.statusCode == 401 || response.statusCode == 404) {
        await box.remove('token');
        await box.remove('user_data');
        Get.off(() => const OnboardingScreen());
      } else if (response.statusCode == 200) {
        // User exists and token is valid
        Get.off(() => const MainScreen());
      } else {
        // Fallback for unexpected status codes: open app using stored local data
        Get.off(() => const MainScreen());
      }
    } catch (e) {
      // 🟢 FIX 2: DO NOT call box.erase() on network error!
      // If internet fails or server times out, navigate user inside using cached token.
      debugPrint("Splash screen sync error (offline mode active): $e");
      Get.off(() => const MainScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/AMI Hostilers Jaipur Crest (1).png',
            width: 250,
          ),
          const SizedBox(height: 30),
          const CircularProgressIndicator(
            color: Colors.deepPurple,
          ),
        ],
      )),
    );
  }
}
