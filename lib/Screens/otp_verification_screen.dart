import 'package:ami_student/Controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

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
// OTP VERIFICATION SCREEN
// ============================================================

class OtpVerificationScreen extends StatefulWidget {
  final bool isForgotPassword;

  const OtpVerificationScreen({
    super.key,
    this.isForgotPassword = false,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final SignupController _authController = Get.find<SignupController>();

  final ScrollController _scrollController = ScrollController();

  // ============================================================
  // FOCUS NODES
  // ============================================================

  final FocusNode _otpFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  // ============================================================
  // FIELD KEYS FOR AUTO SCROLL
  // ============================================================

  final GlobalKey _otpKey = GlobalKey();
  final GlobalKey _passwordKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    _setupFocusListener(
      _otpFocus,
      _otpKey,
    );

    _setupFocusListener(
      _passwordFocus,
      _passwordKey,
    );

    // Automatically focus OTP after screen opens.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _otpFocus.requestFocus();
      }
    });
  }

  // ============================================================
  // AUTO SCROLL ACTIVE FIELD ABOVE KEYBOARD
  // ============================================================

  void _setupFocusListener(
    FocusNode focusNode,
    GlobalKey fieldKey,
  ) {
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        Future.delayed(
          const Duration(milliseconds: 300),
          () {
            _scrollFieldIntoView(fieldKey);
          },
        );
      }
    });
  }

  void _scrollFieldIntoView(GlobalKey fieldKey) {
    if (!mounted) return;

    final BuildContext? fieldContext = fieldKey.currentContext;

    if (fieldContext == null) return;

    Scrollable.ensureVisible(
      fieldContext,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      alignment: 0.30,
      alignmentPolicy: ScrollPositionAlignmentPolicy.explicit,
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _scrollController.dispose();

    _otpFocus.dispose();
    _passwordFocus.dispose();

    super.dispose();
  }

  // ============================================================
  // SUBMIT
  // ============================================================

  void _submit() {
    FocusScope.of(context).unfocus();

    if (widget.isForgotPassword) {
      _authController.submitNewPassword(
        _authController.emailController.text,
        _authController.otpController.text,
        _authController.resetNewPasswordController.text,
      );
    } else {
      _authController.verifyOtpAndProceed();
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    final bool keyboardOpen = keyboardHeight > 0;

    final String email = _authController.emailController.text.trim();

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: backgroundColor,

      // ========================================================
      // TAP OUTSIDE = CLOSE KEYBOARD
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
              // TOP BAR
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
                        FocusScope.of(context).unfocus();
                        Get.back();
                      },
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: darkTextColor,
                        size: 17,
                      ),
                    ),

                    // PAGE BADGE
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 13,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: primaryLight,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.verified_user_outlined,
                            color: primaryDark,
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            widget.isForgotPassword
                                ? 'Reset Password'
                                : 'Email Verification',
                            style: GoogleFonts.poppins(
                              color: primaryDark,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // SPACER TO BALANCE BACK BUTTON
                    const SizedBox(
                      width: 40,
                      height: 40,
                    ),
                  ],
                ),
              ),

              // =================================================
              // SCROLLABLE CONTENT
              // =================================================

              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: EdgeInsets.fromLTRB(
                    22,
                    12,
                    22,
                    keyboardOpen ? 130 : 24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 6),

                      // =========================================
                      // ICON
                      // =========================================

                      Center(
                        child: Container(
                          height: 76,
                          width: 76,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                primaryColor,
                                Color(0xFFFFE99A),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withOpacity(
                                  0.28,
                                ),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Icon(
                            widget.isForgotPassword
                                ? Icons.lock_reset_rounded
                                : Icons.mark_email_read_outlined,
                            color: darkTextColor,
                            size: 35,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // =========================================
                      // TITLE
                      // =========================================

                      Text(
                        widget.isForgotPassword
                            ? 'Create new password'
                            : 'Check your email',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: darkTextColor,
                          fontSize: 25,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),

                      const SizedBox(height: 7),

                      Text(
                        widget.isForgotPassword
                            ? 'Enter the verification code and choose a new password.'
                            : 'We sent a 6-digit verification code to your email address.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: lightTextColor,
                          fontSize: 11.5,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 15),

                      // =========================================
                      // EMAIL CARD
                      // =========================================

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 11,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: const Color(0xFFEAEAE5),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              height: 34,
                              width: 34,
                              decoration: const BoxDecoration(
                                color: primaryLight,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.email_outlined,
                                color: primaryDark,
                                size: 17,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Code sent to',
                                    style: GoogleFonts.poppins(
                                      color: lightTextColor,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 1),
                                  Text(
                                    email.isEmpty
                                        ? 'Your email address'
                                        : email,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.poppins(
                                      color: darkTextColor,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.check_circle_rounded,
                              color: secondaryDark,
                              size: 18,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 22),

                      // =========================================
                      // OTP
                      // =========================================

                      Container(
                        key: _otpKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildLabel(
                              'Verification Code',
                            ),
                            const SizedBox(height: 6),
                            CustomTextField(
                              controller: _authController.otpController,
                              focusNode: _otpFocus,
                              hintText: 'Enter 6-digit OTP',
                              icon: Icons.password_rounded,
                              keyboardType: TextInputType.number,
                              labelText: '6-digit OTP',
                              textInputAction: widget.isForgotPassword
                                  ? TextInputAction.next
                                  : TextInputAction.done,
                              onSubmitted: (_) {
                                if (widget.isForgotPassword) {
                                  _passwordFocus.requestFocus();
                                } else {
                                  FocusScope.of(context).unfocus();
                                }
                              },
                            ),
                          ],
                        ),
                      ),

                      // =========================================
                      // PASSWORD
                      // =========================================

                      if (widget.isForgotPassword) ...[
                        const SizedBox(height: 15),
                        Container(
                          key: _passwordKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildLabel(
                                'New Password',
                              ),
                              const SizedBox(height: 6),
                              CustomTextField(
                                controller:
                                    _authController.resetNewPasswordController,
                                focusNode: _passwordFocus,
                                hintText: 'Create your new password',
                                icon: Icons.lock_outline_rounded,
                                isPassword: true,
                                labelText: 'New Password',
                                textInputAction: TextInputAction.done,
                                onSubmitted: (_) {
                                  _submit();
                                },
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),

                      // =========================================
                      // VERIFY BUTTON
                      // =========================================

                      Obx(
                        () => SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: _authController.isLoading.value
                                ? null
                                : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              disabledBackgroundColor: primaryColor.withOpacity(
                                0.55,
                              ),
                              foregroundColor: darkTextColor,
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
                                    height: 21,
                                    width: 21,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.4,
                                      color: darkTextColor,
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        widget.isForgotPassword
                                            ? 'Save New Password'
                                            : 'Verify & Continue',
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 7,
                                      ),
                                      Icon(
                                        widget.isForgotPassword
                                            ? Icons.check_circle_outline_rounded
                                            : Icons.arrow_forward_rounded,
                                        size: 19,
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 13),

                      // =========================================
                      // SECURITY MESSAGE
                      // =========================================

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.shield_outlined,
                            color: secondaryDark,
                            size: 14,
                          ),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              'Your verification code is secure',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                color: lightTextColor,
                                fontSize: 9.5,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),
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

  Widget _buildLabel(String label) {
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
