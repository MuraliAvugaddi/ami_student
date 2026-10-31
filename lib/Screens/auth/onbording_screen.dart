import 'package:ami_student/Controllers/auth_controller.dart';
import 'package:ami_student/Screens/auth/signin_screen.dart';
import 'package:ami_student/Screens/auth/signup_step1_screen.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

// ============================================================
// BRAND COLORS
// ============================================================

const Color primaryColor = Color(0xFFFADD73);
const Color primaryDark = Color(0xFFD5A514);
const Color primaryLight = Color(0xFFFFF8DC);

const Color secondaryColor = Color(0xFFC6E4AD);
const Color secondaryDark = Color(0xFF669447);
const Color secondaryLight = Color(0xFFF1F8EB);

const Color darkTextColor = Color(0xFF252A27);
const Color lightTextColor = Color(0xFF7C837F);

const Color backgroundColor = Color(0xFFFAFAF8);

// ============================================================
// SUPPORT DETAILS
// ============================================================

// Visible phone number
const String supportPhoneNumber = '9398315945';

// WhatsApp requires:
// Country code + phone number
// India = 91
const String supportWhatsAppNumber = '919398315945';

// ============================================================
// ONBOARDING SCREEN
// ============================================================

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  // ============================================================
  // OPEN WHATSAPP
  // ============================================================

  Future<void> _openWhatsApp() async {
    const String message =
        'Hi Ami Hostlers Support, I need help with the app.';

    final String encodedMessage = Uri.encodeComponent(message);

    // Try installed WhatsApp first
    final Uri whatsappApp = Uri.parse(
      'whatsapp://send?phone=$supportWhatsAppNumber&text=$encodedMessage',
    );

    // Browser fallback
    final Uri whatsappWeb = Uri.parse(
      'https://wa.me/$supportWhatsAppNumber?text=$encodedMessage',
    );

    try {
      if (await canLaunchUrl(whatsappApp)) {
        final bool opened = await launchUrl(
          whatsappApp,
          mode: LaunchMode.externalApplication,
        );

        if (opened) {
          return;
        }
      }

      final bool webOpened = await launchUrl(
        whatsappWeb,
        mode: LaunchMode.externalApplication,
      );

      if (!webOpened) {
        _showWhatsAppError();
      }
    } catch (e) {
      debugPrint(
        'WhatsApp opening error: $e',
      );

      _showWhatsAppError();
    }
  }

  // ============================================================
  // CALL SUPPORT
  // ============================================================

  Future<void> _callSupport() async {
    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: supportPhoneNumber,
    );

    try {
      final bool opened = await launchUrl(
        phoneUri,
        mode: LaunchMode.externalApplication,
      );

      if (!opened) {
        _showCallError();
      }
    } catch (e) {
      debugPrint(
        'Call opening error: $e',
      );

      _showCallError();
    }
  }

  // ============================================================
  // WHATSAPP ERROR
  // ============================================================

  void _showWhatsAppError() {
    Get.snackbar(
      'Unable to open WhatsApp',
      'Please contact support at +91 $supportPhoneNumber',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 16,
      backgroundColor: Colors.red.shade400,
      colorText: Colors.white,
      icon: const Icon(
        Icons.error_outline_rounded,
        color: Colors.white,
      ),
    );
  }

  // ============================================================
  // CALL ERROR
  // ============================================================

  void _showCallError() {
    Get.snackbar(
      'Unable to make call',
      'Please call us at +91 $supportPhoneNumber',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 16,
      backgroundColor: Colors.red.shade400,
      colorText: Colors.white,
      icon: const Icon(
        Icons.phone_disabled_outlined,
        color: Colors.white,
      ),
    );
  }

  // ============================================================
  // SUPPORT BOTTOM SHEET
  // ============================================================

  void _showSupportSheet() {
    Get.bottomSheet(
      SafeArea(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(
            22,
            12,
            22,
            26,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ==================================================
              // HANDLE
              // ==================================================

              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE4E5E2),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              const SizedBox(height: 22),

              // ==================================================
              // SUPPORT ICON
              // ==================================================

              Container(
                height: 64,
                width: 64,
                decoration: const BoxDecoration(
                  color: secondaryLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.support_agent_rounded,
                  color: secondaryDark,
                  size: 31,
                ),
              ),

              const SizedBox(height: 15),

              Text(
                'How can we help?',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: darkTextColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                'Having trouble logging in or creating your account?\nContact Ami Hostlers Support.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: lightTextColor,
                  fontSize: 12,
                  height: 1.5,
                  fontWeight: FontWeight.w400,
                ),
              ),

              const SizedBox(height: 22),

              // ==================================================
              // WHATSAPP
              // ==================================================

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back();
                    _openWhatsApp();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF25D366),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.chat_rounded,
                        size: 20,
                      ),
                      const SizedBox(width: 9),
                      Text(
                        'Chat on WhatsApp',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // ==================================================
              // CALL
              // ==================================================

              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () {
                    Get.back();
                    _callSupport();
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: darkTextColor,
                    side: const BorderSide(
                      color: Color(0xFFEAEAE5),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.phone_outlined,
                        size: 19,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '+91 93983 15945',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),

              Text(
                'Ami Hostlers Support',
                style: GoogleFonts.poppins(
                  color: lightTextColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    // Keep your existing controller fix.
    Get.put(
      SignupController(),
      permanent: true,
    );

    return Scaffold(
      backgroundColor: primaryColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ==================================================
            // TOP IMAGE / BRAND SECTION
            // ==================================================

            Expanded(
              flex: 5,
              child: Stack(
                children: [
                  // SUPPORT BUTTON
                  Positioned(
                    top: 12,
                    right: 18,
                    child: Material(
                      color: Colors.white.withOpacity(0.70),
                      borderRadius: BorderRadius.circular(30),
                      child: InkWell(
                        onTap: _showSupportSheet,
                        borderRadius: BorderRadius.circular(30),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 13,
                            vertical: 9,
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.support_agent_rounded,
                                color: darkTextColor,
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Help',
                                style: GoogleFonts.poppins(
                                  color: darkTextColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // CHEF IMAGE
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        20,
                        48,
                        20,
                        5,
                      ),
                      child: Image.asset(
                        'assets/images/cheifimage3d.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ==================================================
            // BOTTOM WHITE CARD
            // ==================================================

            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(
                24,
                28,
                24,
                26,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(34),
                  topRight: Radius.circular(34),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 25,
                    offset: Offset(0, -8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ==================================================
                  // SMALL BRAND LABEL
                  // ==================================================

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: primaryLight,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      'AMI HOSTLERS',
                      style: GoogleFonts.poppins(
                        color: primaryDark,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),

                  const SizedBox(height: 13),

                  // ==================================================
                  // WELCOME
                  // ==================================================

                  Text(
                    'Welcome to\nAmi Hostlers',
                    style: GoogleFonts.poppins(
                      fontSize: 27,
                      fontWeight: FontWeight.w800,
                      color: darkTextColor,
                      height: 1.15,
                      letterSpacing: -0.6,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    'Manage your daily meals and payments easily, all in one place.',
                    style: GoogleFonts.poppins(
                      fontSize: 12.5,
                      color: lightTextColor,
                      height: 1.55,
                      fontWeight: FontWeight.w400,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ==================================================
                  // LOGIN
                  // ==================================================

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {
                        Get.to(
                          () => SigninScreen(),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: darkTextColor,
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Login Now',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            size: 19,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ==================================================
                  // CREATE ACCOUNT
                  // ==================================================

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: OutlinedButton(
                      onPressed: () {
                        Get.to(
                          () => SignupStep1Screen(),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: darkTextColor,
                        backgroundColor: Colors.white,
                        side: const BorderSide(
                          color: primaryColor,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        'Create New Account',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: darkTextColor,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 17),

                  // ==================================================
                  // SUPPORT LINK
                  // ==================================================

                  Center(
                    child: InkWell(
                      onTap: _showSupportSheet,
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        child: RichText(
                          text: TextSpan(
                            style: GoogleFonts.poppins(
                              fontSize: 10.5,
                            ),
                            children: const [
                              TextSpan(
                                text: 'Having trouble? ',
                                style: TextStyle(
                                  color: lightTextColor,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              TextSpan(
                                text: 'Contact Support',
                                style: TextStyle(
                                  color: secondaryDark,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
