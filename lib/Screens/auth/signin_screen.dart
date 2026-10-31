import 'package:ami_student/Controllers/auth_controller.dart';
import 'package:ami_student/Screens/auth/signup_step1_screen.dart';
import 'package:ami_student/widgets/custom_textfield.dart';

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

const String supportPhoneNumber = '9398315945';
const String supportWhatsAppNumber = '919398315945';

// ============================================================
// SIGN IN SCREEN
// ============================================================

class SigninScreen extends StatelessWidget {
  SigninScreen({super.key});

  final SignupController _authController = Get.find<SignupController>();

  // ============================================================
  // OPEN WHATSAPP
  // ============================================================

  Future<void> _openWhatsApp() async {
    const String message =
        'Hi Ami Hostlers Support, I am having trouble signing in to my account.';

    final String encodedMessage = Uri.encodeComponent(message);

    final Uri whatsappApp = Uri.parse(
      'whatsapp://send?phone=$supportWhatsAppNumber&text=$encodedMessage',
    );

    final Uri whatsappWeb = Uri.parse(
      'https://wa.me/$supportWhatsAppNumber?text=$encodedMessage',
    );

    try {
      // First try installed WhatsApp
      if (await canLaunchUrl(whatsappApp)) {
        final bool opened = await launchUrl(
          whatsappApp,
          mode: LaunchMode.externalApplication,
        );

        if (opened) {
          return;
        }
      }

      // Fallback to wa.me
      final bool opened = await launchUrl(
        whatsappWeb,
        mode: LaunchMode.externalApplication,
      );

      if (!opened) {
        _showWhatsAppError();
      }
    } catch (e) {
      debugPrint('WhatsApp error: $e');
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
      debugPrint('Call error: $e');
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
            24,
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
              // HANDLE
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E5E0),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              const SizedBox(height: 18),

              // SUPPORT ICON
              Container(
                height: 58,
                width: 58,
                decoration: const BoxDecoration(
                  color: secondaryLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.support_agent_rounded,
                  color: secondaryDark,
                  size: 29,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                'Need help signing in?',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: darkTextColor,
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                'Contact Ami Hostlers Support',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: lightTextColor,
                  fontSize: 11,
                ),
              ),

              const SizedBox(height: 18),

              // WHATSAPP BUTTON
              SizedBox(
                width: double.infinity,
                height: 50,
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
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.chat_rounded,
                        size: 19,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Chat on WhatsApp',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 9),

              // CALL BUTTON
              SizedBox(
                width: double.infinity,
                height: 48,
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
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.phone_outlined,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '+91 93983 15945',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),

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
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Detect whether keyboard is open
            final bool keyboardOpen =
                MediaQuery.of(context).viewInsets.bottom > 0;

            return SingleChildScrollView(
              // ==================================================
              // IMPORTANT KEYBOARD FIX
              // ==================================================
              //
              // Keyboard CLOSED:
              // No scrolling.
              //
              // Keyboard OPEN:
              // Allow scrolling so Flutter doesn't overflow.
              //
              physics: keyboardOpen
                  ? const BouncingScrollPhysics()
                  : const NeverScrollableScrollPhysics(),

              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,

              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      22,
                      12,
                      22,
                      14,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ==========================================
                        // TOP BAR
                        // ==========================================

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // BACK BUTTON
                            _topButton(
                              onTap: () {
                                Get.back();
                              },
                              child: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: darkTextColor,
                                size: 17,
                              ),
                            ),

                            // HELP BUTTON
                            Material(
                              color: secondaryLight,
                              borderRadius: BorderRadius.circular(25),
                              child: InkWell(
                                onTap: _showSupportSheet,
                                borderRadius: BorderRadius.circular(25),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 13,
                                    vertical: 9,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.support_agent_rounded,
                                        color: secondaryDark,
                                        size: 17,
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        'Help',
                                        style: GoogleFonts.poppins(
                                          color: darkTextColor,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // ==========================================
                        // BRAND ICON
                        // ==========================================

                        Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            height: 58,
                            width: 58,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  primaryColor,
                                  Color(0xFFFFE99A),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: primaryColor.withOpacity(0.30),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.restaurant_menu_rounded,
                              size: 29,
                              color: darkTextColor,
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        // ==========================================
                        // WELCOME TITLE
                        // ==========================================

                        Text(
                          'Welcome Back',
                          style: GoogleFonts.poppins(
                            fontSize: 27,
                            fontWeight: FontWeight.w800,
                            color: darkTextColor,
                            letterSpacing: -0.6,
                          ),
                        ),

                        const SizedBox(height: 2),

                        Text(
                          'Sign in to continue to Ami Hostlers',
                          style: GoogleFonts.poppins(
                            fontSize: 11.5,
                            color: lightTextColor,
                          ),
                        ),

                        const SizedBox(height: 17),

                        // ==========================================
                        // EMAIL LABEL
                        // ==========================================

                        _buildLabel(
                          'Email Address',
                        ),

                        const SizedBox(height: 6),

                        // ==========================================
                        // EMAIL FIELD
                        // ==========================================

                        CustomTextField(
                          controller: _authController.emailController,
                          hintText: 'name@example.com',
                          icon: Icons.alternate_email_rounded,
                          keyboardType: TextInputType.emailAddress,
                          labelText: 'Email Address',
                        ),

                        const SizedBox(height: 13),

                        // ==========================================
                        // PASSWORD LABEL
                        // ==========================================

                        _buildLabel(
                          'Password',
                        ),

                        const SizedBox(height: 6),

                        // ==========================================
                        // PASSWORD FIELD
                        // ==========================================

                        CustomTextField(
                          controller: _authController.passwordController,
                          hintText: 'Enter your password',
                          icon: Icons.lock_outline_rounded,
                          isPassword: true,
                          labelText: 'Password',
                        ),

                        const SizedBox(height: 4),

                        // ==========================================
                        // FORGOT PASSWORD
                        // ==========================================

                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              FocusScope.of(context).unfocus();

                              _showEmailBottomSheet(
                                context,
                              );
                            },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 3,
                                vertical: 5,
                              ),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'Forgot Password?',
                              style: GoogleFonts.poppins(
                                color: primaryDark,
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // ==========================================
                        // SIGN IN BUTTON
                        // ==========================================

                        Obx(
                          () => SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: _authController.isLoading.value
                                  ? null
                                  : () {
                                      // Close keyboard
                                      FocusScope.of(context).unfocus();

                                      _authController.signInScreen();
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: darkTextColor,
                                disabledBackgroundColor:
                                    primaryColor.withOpacity(0.55),
                                elevation: 0,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child: _authController.isLoading.value
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.4,
                                        color: darkTextColor,
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Sign In',
                                          style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(width: 7),
                                        const Icon(
                                          Icons.arrow_forward_rounded,
                                          size: 18,
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 13),

                        // ==========================================
                        // SUPPORT LINK
                        // ==========================================

                        Center(
                          child: InkWell(
                            onTap: () {
                              FocusScope.of(context).unfocus();

                              _showSupportSheet();
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 5,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.support_agent_outlined,
                                    color: secondaryDark,
                                    size: 15,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    'Trouble signing in? ',
                                    style: GoogleFonts.poppins(
                                      color: lightTextColor,
                                      fontSize: 9.5,
                                    ),
                                  ),
                                  Text(
                                    'Contact Support',
                                    style: GoogleFonts.poppins(
                                      color: secondaryDark,
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // ==========================================
                        // FLEXIBLE SPACE
                        // ==========================================
                        //
                        // Don't use Spacer() here because this
                        // layout can become scrollable when the
                        // keyboard opens.
                        //

                        const SizedBox(height: 22),

                        // ==========================================
                        // CREATE ACCOUNT
                        // ==========================================

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account? ",
                              style: GoogleFonts.poppins(
                                color: lightTextColor,
                                fontSize: 11,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                FocusScope.of(context).unfocus();

                                Get.to(
                                  () => SignupStep1Screen(),
                                );
                              },
                              child: Text(
                                'Create Account',
                                style: GoogleFonts.poppins(
                                  color: primaryDark,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 5),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // TOP BUTTON
  // ============================================================

  Widget _topButton({
    required VoidCallback onTap,
    required Widget child,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        child: SizedBox(
          height: 40,
          width: 40,
          child: Center(
            child: child,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // LABEL
  // ============================================================

  Widget _buildLabel(
    String label,
  ) {
    return Text(
      label,
      style: GoogleFonts.poppins(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: darkTextColor,
      ),
    );
  }

  // ============================================================
  // FORGOT PASSWORD BOTTOM SHEET
  // ============================================================

  void _showEmailBottomSheet(
    BuildContext context,
  ) {
    final TextEditingController forgotEmailController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
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
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // HANDLE
                  Center(
                    child: Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5E5E0),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // RESET ICON
                  Container(
                    height: 52,
                    width: 52,
                    decoration: const BoxDecoration(
                      color: primaryLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock_reset_rounded,
                      color: primaryDark,
                      size: 26,
                    ),
                  ),

                  const SizedBox(height: 14),

                  // TITLE
                  Text(
                    'Reset Password',
                    style: GoogleFonts.poppins(
                      color: darkTextColor,
                      fontSize: 21,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 5),

                  // DESCRIPTION
                  Text(
                    'Enter your registered email to receive a password recovery code.',
                    style: GoogleFonts.poppins(
                      color: lightTextColor,
                      fontSize: 11,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 18),

                  _buildLabel(
                    'Registered Email',
                  ),

                  const SizedBox(height: 7),

                  // EMAIL
                  CustomTextField(
                    controller: forgotEmailController,
                    hintText: 'name@example.com',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    labelText: 'Account Email',
                  ),

                  const SizedBox(height: 18),

                  // SEND CODE
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        final String email = forgotEmailController.text.trim();

                        if (email.isEmpty) {
                          Get.snackbar(
                            'Email Required',
                            'Please enter your registered email address.',
                            snackPosition: SnackPosition.BOTTOM,
                            margin: const EdgeInsets.all(16),
                          );

                          return;
                        }

                        Navigator.pop(context);

                        _authController.sendResetCode(
                          email,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: darkTextColor,
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Text(
                        'Send Reset Code',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 9),

                  // SUPPORT
                  Center(
                    child: TextButton.icon(
                      onPressed: () {
                        Navigator.pop(context);

                        Future.delayed(
                          const Duration(
                            milliseconds: 250,
                          ),
                          () {
                            _showSupportSheet();
                          },
                        );
                      },
                      icon: const Icon(
                        Icons.support_agent_outlined,
                        color: secondaryDark,
                        size: 16,
                      ),
                      label: Text(
                        'Still need help? Contact Support',
                        style: GoogleFonts.poppins(
                          color: secondaryDark,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
