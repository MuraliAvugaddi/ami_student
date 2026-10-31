import 'package:ami_student/Screens/Navigation_bar/splashScreen.dart';
import 'package:ami_student/Screens/Navigation_bar/new_main_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

// ==========================================
// 📌 ADMOB CONFIGURATION & AD UNIT IDs
// ==========================================
class AdMobService {
  // App ID
  static const String appId = 'ca-app-pub-6236176751859838~4507547875';

  // Banner Ads (3 Placements)
  static const String qrCodeTopBannerId =
      'ca-app-pub-6236176751859838/9897005033';
  static const String qrCodeDownBannerId =
      'ca-app-pub-6236176751859838/5734398744';
  static const String subscriptionBannerId =
      'ca-app-pub-6236176751859838/9488589732';

  // Native / Navigation Ads (2 Placements)
  static const String tokenGeneratedNativeId =
      'ca-app-pub-6236176751859838/7802038746';
  static const String profileScreenNativeId =
      'ca-app-pub-6236176751859838/9875602540';
}

void main() async {
  // 1. Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Initialize GetStorage for local data persistence
  await GetStorage.init();

  // 🔴 3. FORCE WIPE OLD TOKENS FOR VERSION 4.00 MIGRATION
  final box = GetStorage();
  bool isVersion4Cleared = box.read('is_v4_cleared') ?? false;
  if (!isVersion4Cleared) {
    await box
        .erase(); // Wipes all old local storage/tokens from previous versions
    box.write('is_v4_cleared', true); // Ensures this only runs once per device
  }

  // 4. Mobile Ads Configuration (Test Device ID kept for safe local testing)
  RequestConfiguration configuration = RequestConfiguration(
    testDeviceIds: ["11D47A979A88E7802ABEC44384052E3F"],
  );
  MobileAds.instance.updateRequestConfiguration(configuration);

  // 5. Initialize the Mobile Ads SDK
  MobileAds.instance.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Access the storage box
    final box = GetStorage();

    // Read the stored token
    final String? token = box.read('token');

    return GetMaterialApp(
      title: 'Ami Hostlers',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: token != null ? const MainScreen() : const SplashScreen(),
    );
  }
}
