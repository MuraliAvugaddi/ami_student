import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:ami_student/Controllers/auth_controller.dart';
import 'package:ami_student/Controllers/profile_controller.dart';
import 'package:ami_student/Screens/history_screen.dart';
import 'package:ami_student/Screens/meal_skippingscreen.dart';
import 'package:ami_student/services/app_update_service.dart';

// ============================================================
// CHEF APP BRAND COLORS
// ============================================================

const Color primaryColor = Color(0xFFFADD73);
const Color primaryDark = Color(0xFFD5A514);
const Color primaryLight = Color(0xFFFFF8DC);

const Color secondaryColor = Color(0xFFC6E4AD);
const Color secondaryLight = Color(0xFFF1F8EB);
const Color secondaryDark = Color(0xFF669447);

const Color darkTextColor = Color(0xFF252A27);
const Color lightTextColor = Color(0xFF7C837F);

const Color backgroundColor = Color(0xFFFAFAF8);
const Color cardColor = Colors.white;

// ============================================================
// SUPPORT DETAILS
// ============================================================

const String supportPhoneNumber = '9398315945';
const String supportWhatsAppNumber = '919398315945';

const String policyWebLink =
    'https://sites.google.com/view/chef-hospitality-policies/home';

// ============================================================
// PROFILE SCREEN
// ============================================================

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final ProfileController controller;
  late final SignupController authController;

  @override
  void initState() {
    super.initState();

    controller = Get.find<ProfileController>();
    authController = Get.find<SignupController>();

    // Check for app update in background
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppUpdateService.checkForUpdate();
    });
  }

  // ==========================================================
  // WHATSAPP
  // ==========================================================

  Future<void> _openWhatsApp() async {
    const String message =
        'Hi Ami Hostlers Support, I need help with my account.';

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

        if (opened) {
          return;
        }
      }

      final bool webOpened = await launchUrl(
        whatsappWeb,
        mode: LaunchMode.externalApplication,
      );

      if (!webOpened && mounted) {
        _showWhatsAppError();
      }
    } catch (e) {
      debugPrint('WhatsApp error: $e');

      if (mounted) {
        _showWhatsAppError();
      }
    }
  }

  void _showWhatsAppError() {
    Get.snackbar(
      'Unable to open WhatsApp',
      'Please contact support at +91 $supportPhoneNumber',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 15,
      backgroundColor: Colors.red.shade400,
      colorText: Colors.white,
      icon: const Icon(
        Icons.error_outline_rounded,
        color: Colors.white,
      ),
    );
  }

  // ==========================================================
  // CALL SUPPORT
  // ==========================================================

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

  void _showCallError() {
    Get.snackbar(
      'Unable to make call',
      'Please call +91 $supportPhoneNumber',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 15,
      backgroundColor: Colors.red.shade400,
      colorText: Colors.white,
    );
  }

  // ==========================================================
  // POLICY
  // ==========================================================

  Future<void> _openPolicyLink() async {
    final Uri url = Uri.parse(policyWebLink);

    try {
      final bool opened = await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );

      if (!opened) {
        Get.snackbar(
          'Unable to open link',
          'Please try again later.',
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          borderRadius: 15,
          backgroundColor: Colors.red.shade400,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint('Policy link error: $e');
    }
  }

  // ==========================================================
  // FEEDBACK
  // ==========================================================

  void _openFeedback() {
    Get.dialog(
      const FeedbackDialog(),
      barrierDismissible: true,
      barrierColor: Colors.black54,
    );
  }

  // ==========================================================
  // DELETE ACCOUNT
  // ==========================================================

  void _showDeleteAccountDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: const Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.red,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Delete Account?',
                style: TextStyle(
                  color: darkTextColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        content: const Text(
          'This action is permanent and cannot be undone. '
          'Your account data and meal history will be deleted.',
          style: TextStyle(
            color: lightTextColor,
            fontSize: 14,
            height: 1.4,
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: lightTextColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();

              Future.microtask(() {
                if (Get.isRegistered<ProfileController>()) {
                  controller.deleteAccount();
                }
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(13),
              ),
            ),
            child: const Text(
              'Delete Account',
              style: TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // LOGOUT
  // ==========================================================

  void _showLogoutDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: const Row(
          children: [
            Icon(
              Icons.logout_rounded,
              color: Colors.red,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Logout?',
                style: TextStyle(
                  color: darkTextColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to logout from your account?',
          style: TextStyle(
            color: lightTextColor,
            fontSize: 14,
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: lightTextColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();

              Future.microtask(() {
                authController.logout();
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade500,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(13),
              ),
            ),
            child: const Text(
              'Logout',
              style: TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Obx(
          () {
            if (controller.isLoading.value &&
                controller.user.value.name == 'Guest') {
              return const Center(
                child: CircularProgressIndicator(
                  color: primaryDark,
                ),
              );
            }

            if (controller.errorMessage.value.isNotEmpty) {
              return _buildErrorState();
            }

            return RefreshIndicator(
              color: primaryDark,
              backgroundColor: Colors.white,
              onRefresh: () {
                return controller.fetchUserProfile();
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                slivers: [
                  SliverToBoxAdapter(
                    child: _buildHeader(),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 35),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate(
                        [
                          // ==================================================
                          // PERSONAL INFORMATION
                          // ==================================================

                          _buildSectionTitle(
                            title: 'Personal Information',
                            icon: Icons.person_outline_rounded,
                            color: primaryDark,
                            background: primaryLight,
                          ),

                          const SizedBox(height: 12),

                          _buildInformationCard(
                            children: [
                              _buildInfoItem(
                                icon: Icons.badge_outlined,
                                title: 'Enrollment',
                                value: controller.user.value.enrollmentNo,
                                iconColor: primaryDark,
                                iconBackground: primaryLight,
                              ),
                              _divider(),
                              _buildInfoItem(
                                icon: Icons.phone_outlined,
                                title: 'Phone Number',
                                value: controller.user.value.phonenumber,
                                iconColor: primaryDark,
                                iconBackground: primaryLight,
                              ),
                            ],
                          ),

                          const SizedBox(height: 28),

                          // ==================================================
                          // ACADEMIC DETAILS
                          // ==================================================

                          _buildSectionTitle(
                            title: 'Academic Details',
                            icon: Icons.school_outlined,
                            color: secondaryDark,
                            background: secondaryLight,
                          ),

                          const SizedBox(height: 12),

                          _buildInformationCard(
                            children: [
                              _buildInfoItem(
                                icon: Icons.menu_book_rounded,
                                title: 'Course',
                                value: controller.user.value.course,
                                iconColor: secondaryDark,
                                iconBackground: secondaryLight,
                              ),
                              _divider(),
                              _buildInfoItem(
                                icon: Icons.calendar_month_outlined,
                                title: 'Year',
                                value: controller.user.value.year.toString(),
                                iconColor: secondaryDark,
                                iconBackground: secondaryLight,
                              ),
                              _divider(),
                              _buildInfoItem(
                                icon: Icons.meeting_room_outlined,
                                title: 'Room Number',
                                value: controller.user.value.room.toString(),
                                iconColor: secondaryDark,
                                iconBackground: secondaryLight,
                              ),
                            ],
                          ),

                          const SizedBox(height: 28),

                          // ==================================================
                          // MEAL MANAGEMENT
                          // ==================================================

                          _buildSectionTitle(
                            title: 'Meal Management',
                            icon: Icons.restaurant_menu_rounded,
                            color: primaryDark,
                            background: primaryLight,
                          ),

                          const SizedBox(height: 12),

                          _buildHistoryCard(),

                          const SizedBox(height: 28),

                          // ==================================================
                          // FEEDBACK
                          // ==================================================

                          _buildSectionTitle(
                            title: 'Your Feedback',
                            icon: Icons.rate_review_rounded,
                            color: primaryDark,
                            background: primaryLight,
                          ),

                          const SizedBox(height: 12),

                          _buildFeedbackCard(),

                          const SizedBox(height: 28),

                          // ==================================================
                          // HELP
                          // ==================================================

                          _buildSectionTitle(
                            title: 'Help & Support',
                            icon: Icons.support_agent_rounded,
                            color: secondaryDark,
                            background: secondaryLight,
                          ),

                          const SizedBox(height: 12),

                          _buildSupportCard(),

                          const SizedBox(height: 28),

                          // ==================================================
                          // POLICIES
                          // ==================================================

                          _buildSectionTitle(
                            title: 'Policies & Terms',
                            icon: Icons.privacy_tip_outlined,
                            color: primaryDark,
                            background: primaryLight,
                          ),

                          const SizedBox(height: 12),

                          _buildPolicyCard(),

                          const SizedBox(height: 30),

                          // ==================================================
                          // ACCOUNT ACTIONS
                          // ==================================================

                          const Text(
                            'Account',
                            style: TextStyle(
                              color: darkTextColor,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),

                          const SizedBox(height: 12),

                          _buildDeleteAccountButton(),

                          const SizedBox(height: 12),

                          _buildLogoutButton(),

                          const SizedBox(height: 25),

                          const Center(
                            child: Text(
                              'from',
                              style: TextStyle(
                                fontSize: 14,
                                color: lightTextColor,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),

                          const SizedBox(height: 4),

                          const Center(
                            child: Text(
                              'Avugaddi Software Systems',
                              style: TextStyle(
                                fontSize: 12,
                                color: lightTextColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),

                          const SizedBox(height: 18),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ==========================================================
  // HEADER
  // ==========================================================

  Widget _buildHeader() {
    final String name = controller.user.value.name.trim().isEmpty
        ? 'Student'
        : controller.user.value.name;

    final String email = controller.user.value.email.trim().isEmpty
        ? 'No email available'
        : controller.user.value.email;

    return Container(
      margin: const EdgeInsets.fromLTRB(18, 14, 18, 28),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 25),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFADD73),
            Color(0xFFFFE99A),
            Color(0xFFFFF3C4),
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.28),
            blurRadius: 24,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _headerIcon(Icons.person_outline_rounded),
              const Text(
                'My Profile',
                style: TextStyle(
                  color: darkTextColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              _headerIcon(Icons.verified_user_outlined),
            ],
          ),
          const SizedBox(height: 25),
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.65),
            ),
            child: Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.07),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(
                Icons.person_rounded,
                size: 58,
                color: primaryDark,
              ),
            ),
          ),
          const SizedBox(height: 17),
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: darkTextColor,
              fontSize: 23,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 7),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.mail_outline_rounded,
                color: darkTextColor.withOpacity(0.65),
                size: 16,
              ),
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: darkTextColor.withOpacity(0.68),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: secondaryLight,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: secondaryColor,
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  color: secondaryDark,
                  size: 17,
                ),
                SizedBox(width: 7),
                Text(
                  'Active Student',
                  style: TextStyle(
                    color: secondaryDark,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerIcon(IconData icon) {
    return Container(
      height: 42,
      width: 42,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.58),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withOpacity(0.75),
        ),
      ),
      child: Icon(
        icon,
        color: darkTextColor,
        size: 22,
      ),
    );
  }

  // ==========================================================
  // SECTION TITLE
  // ==========================================================

  Widget _buildSectionTitle({
    required String title,
    required IconData icon,
    required Color color,
    required Color background,
  }) {
    return Row(
      children: [
        Container(
          height: 38,
          width: 38,
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(width: 11),
        Text(
          title,
          style: const TextStyle(
            color: darkTextColor,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // INFORMATION CARD
  // ==========================================================

  Widget _buildInformationCard({
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFF0F0EA),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String value,
    required Color iconColor,
    required Color iconBackground,
  }) {
    final String displayValue = value.trim().isEmpty ? 'Not available' : value;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: lightTextColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  displayValue,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: darkTextColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return const Divider(
      height: 1,
      thickness: 1,
      color: Color(0xFFF0F1ED),
    );
  }

  // ==========================================================
  // ACTION CARDS
  // ==========================================================

  Widget _buildMealSkippingCard() {
    return _buildActionCard(
      icon: Icons.no_meals_rounded,
      iconColor: secondaryDark,
      iconBackground: secondaryLight,
      title: 'Meal Skipping',
      subtitle: 'Skip a meal when you are not going to eat at the mess.',
      onTap: () {
        Get.to(() => MealSkippingscreen());
      },
    );
  }

  Widget _buildHistoryCard() {
    return _buildActionCard(
      icon: Icons.history_rounded,
      iconColor: primaryDark,
      iconBackground: primaryLight,
      title: 'Meal History',
      subtitle: 'View your previous meal activity.',
      onTap: () {
        Get.to(() => HistoryScreen());
      },
    );
  }

  Widget _buildFeedbackCard() {
    return _buildActionCard(
      icon: Icons.rate_review_rounded,
      iconColor: primaryDark,
      iconBackground: primaryLight,
      title: 'Share Your Feedback',
      subtitle: 'Rate food, service and app experience.',
      onTap: _openFeedback,
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBackground,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          width: double.infinity,
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: const Color(0xFFF0F0EA),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.035),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                height: 56,
                width: 56,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(17),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 27,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: darkTextColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: lightTextColor,
                        fontSize: 11.5,
                        height: 1.4,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: iconColor,
                  size: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // SUPPORT CARD
  // ==========================================================

  Widget _buildSupportCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFF0F0EA),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                height: 54,
                width: 54,
                decoration: BoxDecoration(
                  color: secondaryLight,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.headset_mic_rounded,
                  color: secondaryDark,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Need some help?',
                      style: TextStyle(
                        color: darkTextColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "We're here to help with any issue.",
                      style: TextStyle(
                        color: lightTextColor,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 17),
          SizedBox(
            width: double.infinity,
            height: 51,
            child: ElevatedButton(
              onPressed: _openWhatsApp,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF25D366),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_rounded,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Chat on WhatsApp',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(width: 7),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 17,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: _callSupport,
              style: OutlinedButton.styleFrom(
                foregroundColor: darkTextColor,
                side: const BorderSide(
                  color: Color(0xFFEAEAE5),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.phone_outlined,
                    size: 18,
                    color: darkTextColor,
                  ),
                  SizedBox(width: 8),
                  Text(
                    '+91 93983 15945',
                    style: TextStyle(
                      color: darkTextColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.verified_outlined,
                size: 13,
                color: lightTextColor,
              ),
              SizedBox(width: 5),
              Text(
                'Ami Hostlers Support',
                style: TextStyle(
                  color: lightTextColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // POLICY CARD
  // ==========================================================

  Widget _buildPolicyCard() {
    return _buildActionCard(
      icon: Icons.policy_rounded,
      iconColor: primaryDark,
      iconBackground: primaryLight,
      title: 'Privacy Policy & Terms',
      subtitle: 'View our policies, terms and conditions.',
      onTap: _openPolicyLink,
    );
  }

  // ==========================================================
  // DELETE ACCOUNT & LOGOUT BUTTONS
  // ==========================================================

  Widget _buildDeleteAccountButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: _showDeleteAccountDialog,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red.shade700,
          side: BorderSide(
            color: Colors.red.shade200,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.delete_forever_rounded,
              color: Colors.red.shade700,
              size: 21,
            ),
            const SizedBox(width: 9),
            Text(
              'Delete Account',
              style: TextStyle(
                color: Colors.red.shade700,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _showLogoutDialog,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFEEEE),
          foregroundColor: Colors.red.shade500,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.logout_rounded,
              color: Colors.red.shade500,
              size: 21,
            ),
            const SizedBox(width: 9),
            Text(
              'Logout',
              style: TextStyle(
                color: Colors.red.shade500,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // ERROR STATE
  // ==========================================================

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 80,
              width: 80,
              decoration: const BoxDecoration(
                color: primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: primaryDark,
                size: 38,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Something went wrong',
              style: TextStyle(
                color: darkTextColor,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              controller.errorMessage.value,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: lightTextColor,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 22),
            ElevatedButton.icon(
              onPressed: () {
                controller.fetchUserProfile();
              },
              icon: const Icon(
                Icons.refresh_rounded,
              ),
              label: const Text(
                'Try Again',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: darkTextColor,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// FEEDBACK DIALOG (FIXED)
// ============================================================

class FeedbackDialog extends StatefulWidget {
  const FeedbackDialog({super.key});

  @override
  State<FeedbackDialog> createState() => _FeedbackDialogState();
}

class _FeedbackDialogState extends State<FeedbackDialog> {
  int _selectedRating = 5;
  bool _isSubmitting = false;
  String _message = '';

  final Set<String> _selectedTags = <String>{};

  final List<Map<String, dynamic>> _feedbackTags = [
    {'title': 'Food quality', 'icon': Icons.restaurant_rounded},
    {'title': 'Taste', 'icon': Icons.restaurant_menu_rounded},
    {'title': 'Cleanliness', 'icon': Icons.cleaning_services_rounded},
    {'title': 'Food quantity', 'icon': Icons.scale_rounded},
    {'title': 'Service', 'icon': Icons.support_agent_rounded},
    {'title': 'Menu', 'icon': Icons.menu_book_rounded},
    {'title': 'App experience', 'icon': Icons.phone_android_rounded},
    {'title': 'App issue', 'icon': Icons.bug_report_outlined},
  ];

  String get _ratingText {
    switch (_selectedRating) {
      case 1:
        return 'Very poor';
      case 2:
        return 'Poor';
      case 3:
        return 'Average';
      case 4:
        return 'Good';
      case 5:
      default:
        return 'Excellent';
    }
  }

  Future<void> _submitFeedback() async {
    if (_isSubmitting) return;

    final String cleanMessage = _message.trim();

    if (cleanMessage.isEmpty && _selectedTags.isEmpty) {
      _showRequiredMessage();
      return;
    }

    final List<String> parts = [];
    if (_selectedTags.isNotEmpty) {
      parts.add('Feedback areas: ${_selectedTags.join(', ')}');
    }
    if (cleanMessage.isNotEmpty) {
      parts.add(cleanMessage);
    }

    final String finalMessage = parts.join('\n\n');
    final ProfileController profileController = Get.find<ProfileController>();

    FocusScope.of(context).unfocus();

    setState(() {
      _isSubmitting = true;
    });

    try {
      final bool success = await profileController.sendFeedback(
        _selectedRating,
        finalMessage,
      );

      if (!mounted) return;

      if (success) {
        // Pop dialog directly via Flutter's Navigator so it never gets blocked by GetX snackbar
        Navigator.of(context, rootNavigator: true).pop();
      } else {
        setState(() {
          _isSubmitting = false;
        });
      }
    } catch (e) {
      debugPrint('Error sending feedback: $e');
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showRequiredMessage() {
    Get.snackbar(
      'Feedback required',
      'Please select an option or write a comment.',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 15,
      backgroundColor: darkTextColor,
      colorText: Colors.white,
    );
  }

  void _toggleTag(String title) {
    if (_isSubmitting) return;

    setState(() {
      if (_selectedTags.contains(title)) {
        _selectedTags.remove(title);
      } else {
        _selectedTags.add(title);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 18,
      ),
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: EdgeInsets.only(
          bottom: keyboardHeight > 0 ? 5 : 0,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.90,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              children: [
                _buildDialogHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.fromLTRB(20, 5, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildRatingSection(),
                        const SizedBox(height: 24),
                        _buildTagSection(),
                        const SizedBox(height: 24),
                        _buildCommentSection(),
                        const SizedBox(height: 15),
                      ],
                    ),
                  ),
                ),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDialogHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 14, 12),
      child: Row(
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: primaryLight,
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.rate_review_rounded,
              color: primaryDark,
              size: 25,
            ),
          ),
          const SizedBox(width: 13),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Share Your Feedback',
                  style: TextStyle(
                    color: darkTextColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Your feedback helps us improve.',
                  style: TextStyle(
                    color: lightTextColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Material(
            color: const Color(0xFFF8F8F5),
            borderRadius: BorderRadius.circular(13),
            child: InkWell(
              borderRadius: BorderRadius.circular(13),
              onTap: _isSubmitting
                  ? null
                  : () {
                      FocusScope.of(context).unfocus();
                      Navigator.of(context, rootNavigator: true).pop();
                    },
              child: const SizedBox(
                height: 42,
                width: 42,
                child: Icon(
                  Icons.close_rounded,
                  color: darkTextColor,
                  size: 21,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'How was your experience?',
          style: TextStyle(
            color: darkTextColor,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'Give us a rating for your overall mess experience.',
          style: TextStyle(
            color: lightTextColor,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 7),
          decoration: BoxDecoration(
            color: const Color(0xFFFCFCF9),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFFF0F0E8),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(5, (index) {
              final int rating = index + 1;
              final bool selected = rating <= _selectedRating;

              return GestureDetector(
                onTap: _isSubmitting
                    ? null
                    : () {
                        setState(() {
                          _selectedRating = rating;
                        });
                      },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: selected ? primaryLight : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: selected ? primaryColor : const Color(0xFFE5E5DF),
                    ),
                  ),
                  child: Icon(
                    selected ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: selected ? primaryDark : lightTextColor,
                    size: 27,
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 9),
        Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 150),
            child: Text(
              _ratingText,
              key: ValueKey(_ratingText),
              style: const TextStyle(
                color: primaryDark,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTagSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'What would you like to tell us?',
          style: TextStyle(
            color: darkTextColor,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'Select anything that matches your experience.',
          style: TextStyle(
            color: lightTextColor,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 9,
          children: _feedbackTags.map((tag) {
            final String title = tag['title'] as String;
            final IconData icon = tag['icon'] as IconData;
            final bool selected = _selectedTags.contains(title);

            return GestureDetector(
              onTap: () => _toggleTag(title),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: selected ? primaryLight : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: selected ? primaryColor : const Color(0xFFE2E2DD),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      selected ? Icons.check_circle_rounded : icon,
                      size: 15,
                      color: selected ? primaryDark : lightTextColor,
                    ),
                    const SizedBox(width: 7),
                    Text(
                      title,
                      style: TextStyle(
                        color: selected ? darkTextColor : lightTextColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCommentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Additional comments',
              style: TextStyle(
                color: darkTextColor,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              '${_message.length}/500',
              style: const TextStyle(
                color: lightTextColor,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFAFAF7),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFFF0F0EA),
            ),
          ),
          child: TextField(
            onChanged: (value) {
              if (!mounted) return;
              setState(() {
                _message = value;
              });
            },
            enabled: !_isSubmitting,
            maxLength: 500,
            maxLines: 5,
            minLines: 4,
            textInputAction: TextInputAction.newline,
            keyboardType: TextInputType.multiline,
            style: const TextStyle(
              color: darkTextColor,
              fontSize: 13,
              height: 1.4,
            ),
            decoration: const InputDecoration(
              counterText: '',
              hintText: 'Tell us what went well or what we can improve...',
              hintStyle: TextStyle(
                color: Color(0xFFAAAFA9),
                fontSize: 12,
                height: 1.4,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 18),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(28),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: _isSubmitting ? null : _submitFeedback,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            disabledBackgroundColor: const Color(0xFFE9E5D1),
            foregroundColor: darkTextColor,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: _isSubmitting
              ? const SizedBox(
                  height: 21,
                  width: 21,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: darkTextColor,
                  ),
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.send_rounded,
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Submit Feedback',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
