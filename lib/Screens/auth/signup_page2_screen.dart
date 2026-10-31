import 'package:ami_student/Controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../widgets/custom_textfield.dart';

// ============================================================
// COLORS
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
// SIGNUP STEP 2
// ============================================================

class SignupPage2 extends StatefulWidget {
  const SignupPage2({super.key});

  @override
  State<SignupPage2> createState() => _SignupPage2State();
}

class _SignupPage2State extends State<SignupPage2> {
  final SignupController _authController = Get.find<SignupController>();

  final ScrollController _scrollController = ScrollController();

  // Focus nodes
  final FocusNode _enrollmentFocus = FocusNode();
  final FocusNode _courseFocus = FocusNode();
  final FocusNode _yearFocus = FocusNode();
  final FocusNode _hostelFocus = FocusNode();
  final FocusNode _roomFocus = FocusNode();

  // Keys used to scroll fields into view
  final GlobalKey _enrollmentKey = GlobalKey();
  final GlobalKey _courseKey = GlobalKey();
  final GlobalKey _yearKey = GlobalKey();
  final GlobalKey _hostelKey = GlobalKey();
  final GlobalKey _roomKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    _setupFocusListener(
      _enrollmentFocus,
      _enrollmentKey,
    );

    _setupFocusListener(
      _courseFocus,
      _courseKey,
    );

    _setupFocusListener(
      _yearFocus,
      _yearKey,
    );

    _setupFocusListener(
      _hostelFocus,
      _hostelKey,
    );

    _setupFocusListener(
      _roomFocus,
      _roomKey,
    );
  }

  // ============================================================
  // AUTO SCROLL WHEN FIELD GETS FOCUS
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
            _scrollFieldIntoView(fieldKey);
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
      duration: const Duration(
        milliseconds: 300,
      ),
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

    _enrollmentFocus.dispose();
    _courseFocus.dispose();
    _yearFocus.dispose();
    _hostelFocus.dispose();
    _roomFocus.dispose();

    super.dispose();
  }

  // ============================================================
  // WHATSAPP
  // ============================================================

  Future<void> _openWhatsApp() async {
    const String message =
        'Hi Ami Hostlers Support, I need help completing my account registration.';

    final String encodedMessage = Uri.encodeComponent(message);

    final Uri whatsappApp = Uri.parse(
      'whatsapp://send?phone=$supportWhatsAppNumber&text=$encodedMessage',
    );

    final Uri whatsappWeb = Uri.parse(
      'https://wa.me/$supportWhatsAppNumber?text=$encodedMessage',
    );

    try {
      if (await canLaunchUrl(whatsappApp)) {
        final bool opened = await launchUrl(
          whatsappApp,
          mode: LaunchMode.externalApplication,
        );

        if (opened) return;
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
  // CALL
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
  // ERRORS
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
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(
                    0xFFE5E5E0,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              const SizedBox(height: 18),

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
                'Need help with registration?',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: darkTextColor,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                'Contact Ami Hostlers Support',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: lightTextColor,
                ),
              ),

              const SizedBox(height: 18),

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
                      color: Color(0xFFEAEAE5),
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
    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final bool keyboardOpen = keyboardHeight > 0;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: backgroundColor,
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
                        FocusScope.of(context).unfocus();
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
                            'Step 2 of 2',
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
              // SCROLLABLE FORM
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
                              Icons.school_rounded,
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
                                  'Almost there!',
                                  style: GoogleFonts.poppins(
                                    color: darkTextColor,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.4,
                                  ),
                                ),
                                Text(
                                  'Complete your student details.',
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
                                color: primaryColor,
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
                      // ENROLLMENT
                      // =========================================

                      Container(
                        key: _enrollmentKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildLabel(
                              'Enrollment Number',
                            ),
                            const SizedBox(
                              height: 6,
                            ),
                            CustomTextField(
                              controller:
                                  _authController.enrollmentNoController,
                              focusNode: _enrollmentFocus,
                              hintText: 'Enter enrollment number',
                              icon: Icons.badge_outlined,
                              labelText: 'Enrollment No.',
                              textCapitalization: TextCapitalization.words,
                              textInputAction: TextInputAction.next,
                              onSubmitted: (_) {
                                _courseFocus.requestFocus();
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(
                        height: 14,
                      ),

                      // =========================================
                      // COURSE
                      // =========================================

                      Container(
                        key: _courseKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildLabel(
                              'Course',
                            ),
                            const SizedBox(
                              height: 6,
                            ),
                            CustomTextField(
                              controller: _authController.courseController,
                              focusNode: _courseFocus,
                              hintText: 'e.g. B.Tech',
                              icon: Icons.menu_book_rounded,
                              labelText: 'Course',
                              textCapitalization: TextCapitalization.words,
                              textInputAction: TextInputAction.next,
                              onSubmitted: (_) {
                                _yearFocus.requestFocus();
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(
                        height: 14,
                      ),

                      // =========================================
                      // ACADEMIC YEAR (UPDATED FOR CLARITY)
                      // =========================================

                      Container(
                        key: _yearKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildLabel(
                              'Academic Year (1, 2, 3, 4)',
                            ),
                            const SizedBox(
                              height: 6,
                            ),
                            CustomTextField(
                              controller: _authController.yearController,
                              focusNode: _yearFocus,
                              hintText: 'e.g. 1st Year or 2',
                              icon: Icons.calendar_today_outlined,
                              keyboardType: TextInputType.text,
                              labelText: 'Year of Study',
                              textInputAction: TextInputAction.next,
                              onSubmitted: (_) {
                                _hostelFocus.requestFocus();
                              },
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Enter your current year of study (e.g., 1, 2, 3, 4)',
                              style: GoogleFonts.poppins(
                                color: lightTextColor,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(
                        height: 14,
                      ),

                      // =========================================
                      // HOSTEL
                      // =========================================

                      Container(
                        key: _hostelKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildLabel(
                              'Hostel Block',
                            ),
                            const SizedBox(
                              height: 6,
                            ),
                            CustomTextField(
                              controller: _authController.hostelBlockController,
                              focusNode: _hostelFocus,
                              hintText: 'e.g. A',
                              icon: Icons.home_work_outlined,
                              labelText: 'Hostel Block',
                              textCapitalization: TextCapitalization.words,
                              textInputAction: TextInputAction.next,
                              onSubmitted: (_) {
                                _roomFocus.requestFocus();
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(
                        height: 14,
                      ),

                      // =========================================
                      // ROOM
                      // =========================================

                      Container(
                        key: _roomKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildLabel(
                              'Room Number',
                            ),
                            const SizedBox(
                              height: 6,
                            ),
                            CustomTextField(
                              controller: _authController.roomController,
                              focusNode: _roomFocus,
                              hintText: 'Enter room number',
                              icon: Icons.meeting_room_outlined,
                              keyboardType: TextInputType.number,
                              labelText: 'Room No.',
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
                      // GENDER
                      // =========================================

                      _buildLabel(
                        'Gender',
                      ),

                      const SizedBox(
                        height: 9,
                      ),

                      Obx(
                        () => Row(
                          children: [
                            _buildGenderOption(
                              'Male',
                              Icons.male_rounded,
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            _buildGenderOption(
                              'Female',
                              Icons.female_rounded,
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            _buildGenderOption(
                              'Other',
                              Icons.person_outline_rounded,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(
                        height: 20,
                      ),

                      // =========================================
                      // CREATE ACCOUNT
                      // =========================================

                      Obx(
                        () => SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _authController.isLoading.value
                                ? null
                                : () {
                                    FocusScope.of(
                                      context,
                                    ).unfocus();

                                    _authController.registerStep2();
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: darkTextColor,
                              disabledBackgroundColor: primaryColor.withOpacity(
                                0.55,
                              ),
                              elevation: 0,
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
                                        'Create Account',
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 7,
                                      ),
                                      const Icon(
                                        Icons.check_circle_outline_rounded,
                                        size: 19,
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
  // GENDER OPTION
  // ============================================================

  Widget _buildGenderOption(
    String gender,
    IconData icon,
  ) {
    final bool isSelected = _authController.selectedGender.value == gender;

    return Expanded(
      child: InkWell(
        onTap: () {
          FocusScope.of(context).unfocus();
          _authController.selectedGender.value = gender;
        },
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 52,
          decoration: BoxDecoration(
            color: isSelected ? primaryLight : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? primaryDark
                  : const Color(
                      0xFFE5E5E0,
                    ),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? primaryDark : lightTextColor,
              ),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  gender,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: isSelected ? darkTextColor : lightTextColor,
                    fontSize: 10.5,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
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
