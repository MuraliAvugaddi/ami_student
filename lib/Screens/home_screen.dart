import 'package:ami_student/Controllers/notwork_controller.dart';
import 'package:ami_student/Controllers/profile_controller.dart';
import 'package:ami_student/Screens/AlaCarteScreen.dart';
import 'package:ami_student/Screens/UserMenuScreen.dart';
import 'package:ami_student/Screens/Navigation_bar/new_main_screen.dart';
import 'package:ami_student/Screens/hostel/hostel_home_strip.dart';
import 'package:ami_student/Screens/subscription_screen.dart';
import 'package:ami_student/Screens/scanner_screen.dart';
import 'package:ami_student/widgets/my_Choice_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

// ============================================================
// CHEF BRAND COLORS
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
const Color cardColor = Colors.white;

// ============================================================
// HOME SCREEN
// ============================================================

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final ProfileController controller = Get.find<ProfileController>();
  final NetworkController networkController = Get.put(NetworkController());

  // ============================================================
  // MEAL TIME CHECK
  // ============================================================

  bool _isWithinTimeSlot(String mealType) {
    final now = DateTime.now();
    final currentTime = now.hour * 60 + now.minute;

    switch (mealType) {
      case "Breakfast":
        //return currentTime >= (7 * 60 + 50) && currentTime <= (10 * 60 + 20);
return currentTime >= (0 * 60) && currentTime <= (23 * 60 + 59);
      case "Lunch":
        return currentTime >= (11 * 60 + 50) && currentTime <= (14 * 60 + 20);

      case "Snacks":
            return currentTime >= (16 * 60 + 50) && currentTime <= (18 * 60 + 15);
       // return currentTime >= (0 * 60 + 0) && currentTime <= (23 * 60 + 59);

      case "Dinner":
        return currentTime >= (19 * 60 + 50) && currentTime <= (21 * 60 + 40);

      default:
        return false;
    }
  }

  // ============================================================
  // TIME RESTRICTION DIALOG
  // ============================================================

  void _showTimeRestrictionDialog(
    String mealType,
    String allowedTime,
  ) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 28),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.10),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 78,
                width: 78,
                decoration: const BoxDecoration(
                  color: primaryLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.schedule_rounded,
                  color: primaryDark,
                  size: 38,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "$mealType isn't available yet",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: darkTextColor,
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "You can generate your $mealType token during the service time below.",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: lightTextColor,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: primaryLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: primaryColor.withOpacity(0.7),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.access_time_rounded,
                      color: primaryDark,
                      size: 19,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      allowedTime,
                      style: GoogleFonts.poppins(
                        color: darkTextColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: darkTextColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    "Got it",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
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
  // NAVIGATION LOGIC
  // ============================================================

  void _handleNavigation(String mealType) {
    if (networkController.isOffline.value) {
      Get.snackbar(
        "No Internet Connection",
        "Please check your internet connection and try again.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade500,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 16,
        icon: const Icon(
          Icons.wifi_off_rounded,
          color: Colors.white,
        ),
      );
      return;
    }

    String allowedTime = "";
    if (mealType == "Breakfast") allowedTime = "8:00 AM - 9:00 AM";
    if (mealType == "Lunch") allowedTime = "12:00 PM - 2:00 PM";
    if (mealType == "Snacks") allowedTime = "5:00 PM - 6:00 PM";
    if (mealType == "Dinner") allowedTime = "8:00 PM - 9:00 PM";

    if (!_isWithinTimeSlot(mealType)) {
      _showTimeRestrictionDialog(
        mealType,
        allowedTime,
      );
      return;
    }

    if (controller.isSubscriptionActive) {
      Get.to(
        () => ScannerScreen(
          mealType: mealType,
        ),
      );
    } else {
      _showSubscriptionExpiredDialog();
    }
  }

  // ============================================================
  // À LA CARTE NAVIGATION
  // ============================================================

  void _openAlaCarte() {
    if (networkController.isOffline.value) {
      Get.snackbar(
        "No Internet Connection",
        "Internet connection is required to open À La Carte ordering.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade500,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 16,
        icon: const Icon(
          Icons.wifi_off_rounded,
          color: Colors.white,
        ),
      );
      return;
    }

    Get.to(
      () => const AlaCarteScreen(),
    );
  }

  // ============================================================
  // OPEN MONTHLY MESS MENU SCREEN
  // ============================================================

  void _openMessMenu() {
    Get.to(
      () => const UserMenuScreen(),
    );
  }

  // ============================================================
  // SUBSCRIPTION EXPIRED
  // ============================================================

  void _showSubscriptionExpiredDialog() {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 28),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 78,
                width: 78,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.credit_card_off_rounded,
                  color: Colors.red.shade400,
                  size: 36,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Subscription Expired",
                style: GoogleFonts.poppins(
                  color: darkTextColor,
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Please pay your mess fees to access meal tokens for this month.",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: lightTextColor,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back();
                    Get.to(() => SubscriptionScreen());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: darkTextColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    "Pay Now",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Get.back(),
                child: Text(
                  "Maybe Later",
                  style: GoogleFonts.poppins(
                    color: lightTextColor,
                    fontWeight: FontWeight.w500,
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
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // OFFLINE BANNER
            Obx(() {
              if (!networkController.isOffline.value) {
                return const SizedBox.shrink();
              }

              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                color: Colors.red.shade500,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.wifi_off_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "No internet connection",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }),

            // PAGE
            Expanded(
              child: RefreshIndicator(
                color: primaryDark,
                backgroundColor: Colors.white,
                onRefresh: () => controller.fetchUserProfile(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      HostelHomeStrip(
                        onOpenHostel: () => MainScreen.switchTab?.call(2),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ==================================
                            // TODAY'S MEALS TITLE & MENU BUTTON
                            // ==================================

                            Row(
                              children: [
                                Container(
                                  height: 38,
                                  width: 38,
                                  decoration: BoxDecoration(
                                    color: primaryLight,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.restaurant_menu_rounded,
                                    color: primaryDark,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 11),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Today's Meals",
                                        style: GoogleFonts.poppins(
                                          color: darkTextColor,
                                          fontSize: 17,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      Text(
                                        "Select a meal to generate your token",
                                        style: GoogleFonts.poppins(
                                          color: lightTextColor,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // 🌟 NEW: "VIEW MESS MENU" BUTTON
                                InkWell(
                                  onTap: _openMessMenu,
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: primaryLight,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: primaryDark.withOpacity(0.3),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.menu_book_rounded,
                                          color: primaryDark,
                                          size: 15,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          "Menu",
                                          style: GoogleFonts.poppins(
                                            color: primaryDark,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // BREAKFAST
                            MealCard(
                              mealType: "Breakfast",
                              time: "8:00 AM - 9:00 AM",
                              imagePath: "assets/images/breakfast.png",
                              accentColor: primaryColor,
                              accentLight: primaryLight,
                              isAvailable: _isWithinTimeSlot("Breakfast"),
                              onTap: () => _handleNavigation("Breakfast"),
                            ),

                            const SizedBox(height: 8),

                            // LUNCH
                            MealCard(
                              mealType: "Lunch",
                              time: "12:00 PM - 2:00 PM",
                              imagePath: "assets/images/lunch.png",
                              accentColor: secondaryColor,
                              accentLight: secondaryLight,
                              isAvailable: _isWithinTimeSlot("Lunch"),
                              onTap: () => _handleNavigation("Lunch"),
                            ),

                            const SizedBox(height: 8),

                            // SNACKS
                            MealCard(
                              mealType: "Snacks",
                              time: "5:00 PM - 6:00 PM",
                              imagePath: "assets/images/snakes.png",
                              accentColor: primaryColor,
                              accentLight: primaryLight,
                              isAvailable: _isWithinTimeSlot("Snacks"),
                              onTap: () => _handleNavigation("Snacks"),
                            ),

                            const SizedBox(height: 8),

                            // DINNER
                            MealCard(
                              mealType: "Dinner",
                              time: "8:00 PM - 9:00 PM",
                              imagePath: "assets/images/dinner.png",
                              accentColor: secondaryColor,
                              accentLight: secondaryLight,
                              isAvailable: _isWithinTimeSlot("Dinner"),
                              onTap: () => _handleNavigation("Dinner"),
                            ),

                            const SizedBox(height: 28),

                            MyChoiceWidget(),

                            const SizedBox(height: 20),

                            // À LA CARTE SECTION TITLE
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Want something special?",
                                        style: GoogleFonts.poppins(
                                          color: darkTextColor,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        "Explore our special À La Carte menu",
                                        style: GoogleFonts.poppins(
                                          color: lightTextColor,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 9,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: primaryLight,
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.star_rounded,
                                        color: primaryDark,
                                        size: 13,
                                      ),
                                      const SizedBox(width: 3),
                                      Text(
                                        "SPECIAL",
                                        style: GoogleFonts.poppins(
                                          color: primaryDark,
                                          fontSize: 7.5,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            _buildAlaCarteCard(),

                            const SizedBox(height: 20),
                          ],
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
    );
  }

  // ============================================================
  // À LA CARTE CARD
  // ============================================================

  Widget _buildAlaCarteCard() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _openAlaCarte,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFADD73),
                Color(0xFFFFE99A),
                Color(0xFFFFF1BE),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.22),
                blurRadius: 20,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    height: 56,
                    width: 56,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.70),
                      borderRadius: BorderRadius.circular(17),
                    ),
                    child: const Icon(
                      Icons.restaurant_menu_rounded,
                      color: darkTextColor,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                "À La Carte",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  color: darkTextColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const SizedBox(width: 7),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.70),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                "SPECIAL",
                                style: GoogleFonts.poppins(
                                  color: primaryDark,
                                  fontSize: 7,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          "Order your favourite special food",
                          style: GoogleFonts.poppins(
                            color: darkTextColor.withOpacity(0.65),
                            fontSize: 9.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 38,
                    width: 38,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.72),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.arrow_forward_rounded,
                      color: darkTextColor,
                      size: 19,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.76),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.85),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      height: 36,
                      width: 36,
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.60),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: const Icon(
                        Icons.alarm_rounded,
                        color: darkTextColor,
                        size: 19,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "PRE-ORDER 2 HOURS BEFORE",
                            style: GoogleFonts.poppins(
                              color: darkTextColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            "Place your order at least 2 hours before your meal",
                            style: GoogleFonts.poppins(
                              color: lightTextColor,
                              fontSize: 8,
                              height: 1.3,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: darkTextColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "2 HR",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 7,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildAlaCarteBenefit(
                      icon: Icons.menu_book_rounded,
                      text: "View Menu",
                    ),
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: _buildAlaCarteBenefit(
                      icon: Icons.qr_code_rounded,
                      text: "Scan QR",
                    ),
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: _buildAlaCarteBenefit(
                      icon: Icons.shopping_bag_outlined,
                      text: "Pre-Order",
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                height: 46,
                decoration: BoxDecoration(
                  color: darkTextColor,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: darkTextColor.withOpacity(0.14),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.restaurant_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "View Menu & Pre-Order",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 7),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 17,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // À LA CARTE BENEFIT
  // ============================================================

  Widget _buildAlaCarteBenefit({
    required IconData icon,
    required String text,
  }) {
    return Container(
      height: 35,
      padding: const EdgeInsets.symmetric(
        horizontal: 5,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.55),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: darkTextColor,
            size: 13,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                color: darkTextColor,
                fontSize: 7.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MODERN HEADER
  // ============================================================

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        16,
        12,
        16,
        20,
      ),
      padding: const EdgeInsets.fromLTRB(
        20,
        20,
        20,
        22,
      ),
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
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.28),
            blurRadius: 24,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Obx(
        () => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.65),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    color: darkTextColor,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getGreeting(),
                        style: GoogleFonts.poppins(
                          color: darkTextColor.withOpacity(0.60),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        controller.user.value.name.isEmpty
                            ? "Student"
                            : controller.user.value.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          color: darkTextColor,
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 44,
                  width: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.65),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    controller.isSubscriptionActive
                        ? Icons.verified_rounded
                        : Icons.error_outline_rounded,
                    color: controller.isSubscriptionActive
                        ? secondaryDark
                        : Colors.red.shade400,
                    size: 23,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: controller.isSubscriptionActive
                    ? secondaryLight
                    : Colors.red.withOpacity(0.08),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    controller.isSubscriptionActive
                        ? Icons.check_circle_rounded
                        : Icons.error_outline_rounded,
                    color: controller.isSubscriptionActive
                        ? secondaryDark
                        : Colors.red.shade500,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    controller.isSubscriptionActive
                        ? "Mess subscription active"
                        : "Subscription expired",
                    style: GoogleFonts.poppins(
                      color: controller.isSubscriptionActive
                          ? secondaryDark
                          : Colors.red.shade500,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
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

  // ============================================================
  // GREETING
  // ============================================================

  String _getGreeting() {
    final int hour = DateTime.now().hour;
    if (hour < 12) return "Good morning";
    if (hour < 17) return "Good afternoon";
    return "Good evening";
  }
}

// ============================================================
// MODERN MEAL CARD
// ============================================================

class MealCard extends StatelessWidget {
  final String mealType;
  final String time;
  final String imagePath;
  final Color accentColor;
  final Color accentLight;
  final bool isAvailable;
  final VoidCallback onTap;

  const MealCard({
    super.key,
    required this.mealType,
    required this.time,
    required this.imagePath,
    required this.accentColor,
    required this.accentLight,
    required this.isAvailable,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: const BorderRadius.horizontal(
          left: Radius.circular(10),
          right: Radius.circular(22),
        ),
        child: Ink(
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(10),
              right: Radius.circular(22),
            ),
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
                width: 8,
                height: 100,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(22),
                    bottomLeft: Radius.circular(22),
                  ),
                ),
              ),
              const SizedBox(width: 13),
              Container(
                height: 78,
                width: 78,
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: accentLight,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.restaurant_menu_rounded,
                        color: darkTextColor.withOpacity(0.45),
                        size: 30,
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mealType,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        color: darkTextColor,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 14,
                          color: lightTextColor.withOpacity(0.8),
                        ),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            time,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              color: lightTextColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isAvailable
                            ? secondaryLight
                            : const Color(0xFFF5F5F3),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            height: 6,
                            width: 6,
                            decoration: BoxDecoration(
                              color:
                                  isAvailable ? secondaryDark : lightTextColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            isAvailable ? "Available now" : "Closed",
                            style: GoogleFonts.poppins(
                              color:
                                  isAvailable ? secondaryDark : lightTextColor,
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                height: 38,
                width: 38,
                decoration: BoxDecoration(
                  color: accentLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: darkTextColor,
                  size: 14,
                ),
              ),
              const SizedBox(width: 14),
            ],
          ),
        ),
      ),
    );
  }
}
