import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ami_student/api/api_endpoint.dart';

class AppUpdateService {
  static Future<void> checkForUpdate({bool showNoUpdateToast = false}) async {
    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      final int currentBuildNumber = int.tryParse(packageInfo.buildNumber) ?? 1;

      final response = await http.get(
        Uri.parse(ApiEndpoints.appVersion),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final int latestBuildNumber = data['latestBuildNumber'] ?? 1;
        final bool forceUpdate = data['forceUpdate'] ?? false;
        final String downloadUrl = data['downloadUrl'] ?? '';
        final String releaseNotes = data['releaseNotes'] ?? 'A new update is available!';
        final String latestVersion = data['latestVersion'] ?? '';

        // If server version is greater than current app version
        if (latestBuildNumber > currentBuildNumber) {
          _showUpdateDialog(
            latestVersion: latestVersion,
            releaseNotes: releaseNotes,
            downloadUrl: downloadUrl,
            forceUpdate: forceUpdate,
          );
        } else if (showNoUpdateToast) {
          Get.snackbar(
            "Up to Date",
            "You are already using the latest version.",
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      }
    } catch (e) {
      debugPrint("Check update error: $e");
    }
  }

  static void _showUpdateDialog({
    required String latestVersion,
    required String releaseNotes,
    required String downloadUrl,
    required bool forceUpdate,
  }) {
    Get.dialog(
      PopScope(
        canPop: !forceUpdate, // Prevents closing if update is mandatory
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
          title: const Row(
            children: [
              Icon(Icons.system_update_rounded, color: Color(0xFFD5A514)),
              SizedBox(width: 10),
              Text(
                "Update Available!",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color(0xFF252A27),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Version $latestVersion is now available.",
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                releaseNotes,
                style: const TextStyle(color: Color(0xFF7C837F), fontSize: 13),
              ),
            ],
          ),
          actions: [
            if (!forceUpdate)
              TextButton(
                onPressed: () => Get.back(),
                child: const Text(
                  "Later",
                  style: TextStyle(color: Color(0xFF7C837F)),
                ),
              ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFADD73),
                foregroundColor: const Color(0xFF252A27),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () async {
                final Uri uri = Uri.parse(downloadUrl);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
              child: const Text(
                "Update Now",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
      barrierDismissible: !forceUpdate,
    );
  }
}