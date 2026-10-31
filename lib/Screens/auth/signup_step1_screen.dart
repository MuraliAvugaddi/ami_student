import 'package:ami_student/Controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../widgets/custom_textfield.dart';

// ============================================================
// BRAND COLORS
// ============================================================

const Color primaryColor = Color(0xFFFADD73);
const Color primaryDark = Color(0xFFD5A514);
const Color primaryLight = Color(0xFFFFF8DC);

const Color secondaryDark = Color(0xFF669447);
const Color secondaryLight = Color(0xFFF1F8EB);

const Color darkTextColor = Color(0xFF252A27);
const Color lightTextColor = Color(0xFF7C837F);

const Color backgroundColor = Color(0xFFFAFAF8);

// ============================================================
// SUPPORT
// ============================================================

const String supportPhoneNumber = '9398315945';
const String supportWhatsAppNumber = '919398315945';

// ============================================================
// SIGNUP STEP 1
// ============================================================

class SignupStep1Screen extends StatefulWidget {
  const SignupStep1Screen({super.key});

  @override
  State<SignupStep1Screen> createState() => _SignupStep1ScreenState();
}

class _SignupStep1ScreenState extends State<SignupStep1Screen> {
  final SignupController _authController = Get.find<SignupController>();

  final ScrollController _scrollController = ScrollController();

  // ============================================================
  // FOCUS NODES
  // ============================================================

  final FocusNode _nameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();

  // ============================================================
  // FIELD KEYS
  // ============================================================

  final GlobalKey _nameKey = GlobalKey();
  final GlobalKey _emailKey = GlobalKey();
  final GlobalKey _passwordKey = GlobalKey();
  final GlobalKey _phoneKey = GlobalKey();

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    _setupFocusListener(
      _nameFocus,
      _nameKey,
    );

    _setupFocusListener(
      _emailFocus,
      _emailKey,
    );

    _setupFocusListener(
      _passwordFocus,
      _passwordKey,
    );

    _setupFocusListener(
      _phoneFocus,
      _phoneKey,
    );
  }

  // ============================================================
  // AUTO SCROLL ACTIVE FIELD
  // ============================================================

  void _setupFocusListener(
    FocusNode focusNode,
    GlobalKey fieldKey,
  ) {
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        Future.delayed(
          const Duration(milliseconds: 350),
          () {
            _scrollFieldIntoView(
              fieldKey,
            );
          },
        );
      }
    });
  }

  void _scrollFieldIntoView(
    GlobalKey fieldKey,
  ) {
    if (!mounted) return;

    final BuildContext? fieldContext = fieldKey.currentContext;

    if (fieldContext == null) return;

    Scrollable.ensureVisible(
      fieldContext,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      alignment: 0.28,
      alignmentPolicy: ScrollPositionAlignmentPolicy.explicit,
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _scrollController.dispose();

    _nameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _phoneFocus.dispose();

    super.dispose();
  }

  // ============================================================
  // WHATSAPP
  // ============================================================

  Future<void> _openWhatsApp() async {
    const String message =
        'Hi Ami Hostlers Support, I need help creating my account.';

    final String encodedMessage = Uri.encodeComponent(message);

    final Uri whatsappApp = Uri.parse(
      'whatsapp://send?phone=$supportWhatsAppNumber&text=$encodedMessage',
    );

    final Uri whatsappWeb = Uri.parse(
      'https://wa.me/$supportWhatsAppNumber?text=$encodedMessage',
    );

    try {
      if (await canLaunchUrl(
        whatsappApp,
      )) {
        final bool opened = await launchUrl(
          whatsappApp,
          mode: LaunchMode.externalApplication,
        );

        if (opened) {
          return;
        }
      }

      final bool opened = await launchUrl(
        whatsappWeb,
        mode: LaunchMode.externalApplication,
      );

      if (!opened) {
        _showWhatsAppError();
      }
    } catch (e) {
      debugPrint(
        'WhatsApp error: $e',
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
        'Call error: $e',
      );

      _showCallError();
    }
  }

  // ============================================================
  // ERROR MESSAGES
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
  // SUPPORT SHEET
  // ============================================================

  void _showSupportSheet() {
    FocusScope.of(context).unfocus();

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
                  color: const Color(
                    0xFFE5E5E0,
                  ),
                  borderRadius: BorderRadius.circular(
                    10,
                  ),
                ),
              ),

              const SizedBox(
                height: 18,
              ),

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

              const SizedBox(
                height: 12,
              ),

              Text(
                'Need help creating your account?',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: darkTextColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(
                height: 5,
              ),

              Text(
                'Contact Ami Hostlers Support',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: lightTextColor,
                  fontSize: 11,
                ),
              ),

              const SizedBox(
                height: 18,
              ),

              // WHATSAPP
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back();

                    _openWhatsApp();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(
                      0xFF25D366,
                    ),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        15,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.chat_rounded,
                        size: 19,
                      ),
                      const SizedBox(
                        width: 8,
                      ),
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

              const SizedBox(
                height: 9,
              ),

              // CALL
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
                      color: Color(
                        0xFFEAEAE5,
                      ),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        15,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.phone_outlined,
                        size: 18,
                      ),
                      const SizedBox(
                        width: 8,
                      ),
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

              const SizedBox(
                height: 10,
              ),

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
  Widget build(
    BuildContext context,
  ) {
    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    final bool keyboardOpen = keyboardHeight > 0;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: backgroundColor,

      // ========================================================
      // TAP OUTSIDE TO CLOSE KEYBOARD
      // ========================================================

      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SafeArea(
          child: Column(
            children: [
              // =================================================
              // FIXED TOP BAR
              // =================================================

              Padding(
                padding: const EdgeInsets.fromLTRB(
                  22,
                  12,
                  22,
                  8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // BACK
                    _topButton(
                      onTap: () {
                        FocusScope.of(
                          context,
                        ).unfocus();

                        Get.back();
                      },
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: darkTextColor,
                        size: 17,
                      ),
                    ),

                    // STEP
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 13,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: primaryLight,
                        borderRadius: BorderRadius.circular(
                          30,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            height: 7,
                            width: 7,
                            decoration: const BoxDecoration(
                              color: primaryDark,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(
                            width: 6,
                          ),
                          Text(
                            'Step 1 of 2',
                            style: GoogleFonts.poppins(
                              color: primaryDark,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // HELP
                    _topButton(
                      onTap: _showSupportSheet,
                      child: const Icon(
                        Icons.support_agent_rounded,
                        color: secondaryDark,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),

              // =================================================
              // FORM
              // =================================================

              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: EdgeInsets.fromLTRB(
                    22,
                    8,
                    22,

                    // Extra room while keyboard is open.
                    keyboardOpen ? 140 : 24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // =========================================
                      // HEADER
                      // =========================================

                      Row(
                        children: [
                          Container(
                            height: 52,
                            width: 52,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  primaryColor,
                                  Color(
                                    0xFFFFE99A,
                                  ),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(
                                16,
                              ),
                            ),
                            child: const Icon(
                              Icons.person_add_alt_1_rounded,
                              color: darkTextColor,
                              size: 25,
                            ),
                          ),
                          const SizedBox(
                            width: 13,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Create your account',
                                  style: GoogleFonts.poppins(
                                    color: darkTextColor,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.4,
                                  ),
                                ),
                                const SizedBox(
                                  height: 2,
                                ),
                                Text(
                                  'Enter your basic details to get started.',
                                  style: GoogleFonts.poppins(
                                    color: lightTextColor,
                                    fontSize: 10.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 16,
                      ),

                      // =========================================
                      // PROGRESS BAR
                      // =========================================

                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 5,
                              decoration: BoxDecoration(
                                color: primaryColor,
                                borderRadius: BorderRadius.circular(
                                  20,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 7,
                          ),
                          Expanded(
                            child: Container(
                              height: 5,
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFFEAEAE5,
                                ),
                                borderRadius: BorderRadius.circular(
                                  20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 20,
                      ),

                      // =========================================
                      // FULL NAME
                      // =========================================

                      Container(
                        key: _nameKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildLabel(
                              'Full Name',
                            ),
                            const SizedBox(
                              height: 6,
                            ),
                            CustomTextField(
                              controller: _authController.nameController,
                              focusNode: _nameFocus,
                              hintText: 'Enter your full name',
                              icon: Icons.person_outline_rounded,
                              labelText: 'Full Name',
                              textCapitalization: TextCapitalization.words,
                              textInputAction: TextInputAction.next,
                              onSubmitted: (_) {
                                _emailFocus.requestFocus();
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(
                        height: 14,
                      ),

                      // =========================================
                      // EMAIL
                      // =========================================

                      Container(
                        key: _emailKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildLabel(
                              'Email Address',
                            ),
                            const SizedBox(
                              height: 6,
                            ),
                            CustomTextField(
                              controller: _authController.emailController,
                              focusNode: _emailFocus,
                              hintText: 'name@example.com',
                              icon: Icons.alternate_email_rounded,
                              keyboardType: TextInputType.emailAddress,
                              labelText: 'Email Address',
                              textInputAction: TextInputAction.next,
                              onSubmitted: (_) {
                                _passwordFocus.requestFocus();
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(
                        height: 14,
                      ),

                      // =========================================
                      // PASSWORD
                      // =========================================

                      Container(
                        key: _passwordKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildLabel(
                              'Create Password',
                            ),
                            const SizedBox(
                              height: 6,
                            ),
                            CustomTextField(
                              controller: _authController.passwordController,
                              focusNode: _passwordFocus,
                              hintText: 'Create a secure password',
                              icon: Icons.lock_outline_rounded,
                              isPassword: true,
                              labelText: 'Create Password',
                              textInputAction: TextInputAction.next,
                              onSubmitted: (_) {
                                _phoneFocus.requestFocus();
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(
                        height: 14,
                      ),

                      // =========================================
                      // PHONE
                      // =========================================

                      Container(
                        key: _phoneKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildLabel(
                              'Phone Number',
                            ),
                            const SizedBox(
                              height: 6,
                            ),
                            CustomTextField(
                              controller: _authController.phoneController,
                              focusNode: _phoneFocus,
                              hintText: 'Enter your phone number',
                              icon: Icons.phone_outlined,
                              keyboardType: TextInputType.phone,
                              labelText: 'Phone Number',
                              textInputAction: TextInputAction.done,
                              onSubmitted: (_) {
                                FocusScope.of(
                                  context,
                                ).unfocus();
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(
                        height: 20,
                      ),

                      // =========================================
                      // CONTINUE
                      // =========================================

                      Obx(
                        () => SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _authController.isLoading.value
                                ? null
                                : () {
                                    FocusScope.of(
                                      context,
                                    ).unfocus();

                                    // YOUR ORIGINAL LOGIC
                                    _authController.registerStep1();
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: darkTextColor,
                              disabledBackgroundColor: primaryColor.withOpacity(
                                0.55,
                              ),
                              elevation: 0,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  15,
                                ),
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
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Continue',
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 7,
                                      ),
                                      const Icon(
                                        Icons.arrow_forward_rounded,
                                        size: 18,
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 12,
                      ),

                      // =========================================
                      // SUPPORT
                      // =========================================

                      Center(
                        child: InkWell(
                          onTap: _showSupportSheet,
                          borderRadius: BorderRadius.circular(
                            20,
                          ),
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
                                const SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  'Need help? ',
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

                      const SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
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
        color: darkTextColor,
        fontSize: 10.5,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
