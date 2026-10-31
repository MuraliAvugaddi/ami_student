import 'package:ami_student/Controllers/hostel_controller.dart';
import 'package:ami_student/Controllers/profile_controller.dart';
import 'package:ami_student/Screens/hostel/complaint_details_screen.dart';
import 'package:ami_student/Screens/hostel/hostel_notifications_screen.dart';
import 'package:ami_student/Screens/hostel/raise_complaint_screen.dart';
import 'package:ami_student/Screens/hostel/sos_screen.dart';
import 'package:ami_student/utils/hostel_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

// ============================================================
// HOSTEL TAB
// SOS · report a room problem · my complaints
// ============================================================

class HostelScreen extends StatelessWidget {
  HostelScreen({super.key});

  final HostelController controller = Get.isRegistered<HostelController>()
      ? Get.find<HostelController>()
      : Get.put(HostelController());
  final ProfileController profile = Get.find<ProfileController>();

  // ============================================================
  // COLORS
  // ============================================================

  static const Color primaryColor = Color(0xFFFADD73);
  static const Color primaryDark = Color(0xFFD5A514);
  static const Color primaryLight = Color(0xFFFFF8DC);
  static const Color secondaryDark = Color(0xFF669447);
  static const Color secondaryLight = Color(0xFFF1F8EB);
  static const Color darkTextColor = Color(0xFF252A27);
  static const Color lightTextColor = Color(0xFF7C837F);
  static const Color backgroundColor = Color(0xFFFAFAF8);
  static const Color sosRed = Color(0xFFE53935);

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          color: primaryDark,
          backgroundColor: Colors.white,
          onRefresh: controller.loadAll,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 30),
            children: [
              _buildHeader(),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildActiveSosCard(),
                    _buildSosCard(),
                    const SizedBox(height: 24),
                    _buildSectionTitle(
                      icon: Icons.handyman_rounded,
                      title: "Report a room problem",
                      subtitle: "Our repair team gets it instantly",
                    ),
                    const SizedBox(height: 12),
                    _buildCategoryGrid(),
                    const SizedBox(height: 24),
                    _buildConfirmBanner(),
                    _buildSectionTitle(
                      icon: Icons.receipt_long_rounded,
                      title: "My complaints",
                      subtitle: "Track what is being fixed",
                    ),
                    const SizedBox(height: 12),
                    _buildComplaintList(),
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
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      padding: const EdgeInsets.fromLTRB(20, 20, 16, 20),
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
      child: Obx(() {
        final user = profile.user.value;
        return Row(
          children: [
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.65),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.apartment_rounded,
                color: darkTextColor,
                size: 25,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "My Hostel",
                    style: GoogleFonts.poppins(
                      color: darkTextColor.withOpacity(0.60),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    user.room.isEmpty ? "Room not added" : "Room ${user.room}",
                    style: GoogleFonts.poppins(
                      color: darkTextColor,
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (user.hostelblock.isNotEmpty)
                    Text(
                      user.hostelblock,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        color: darkTextColor.withOpacity(0.70),
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
            _buildBell(),
          ],
        );
      }),
    );
  }

  Widget _buildBell() {
    return Obx(
      () => Stack(
        clipBehavior: Clip.none,
        children: [
          Material(
            color: Colors.white.withOpacity(0.65),
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => Get.to(() => HostelNotificationsScreen()),
              child: const SizedBox(
                height: 44,
                width: 44,
                child: Icon(
                  Icons.notifications_none_rounded,
                  color: darkTextColor,
                ),
              ),
            ),
          ),
          if (controller.unread.value > 0)
            Positioned(
              right: -3,
              top: -3,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: sosRed,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: Text(
                  controller.unread.value > 9 ? '9+' : '${controller.unread.value}',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // SOS
  // ============================================================

  Widget _buildActiveSosCard() {
    return Obx(() {
      final sos = controller.activeSos;
      if (sos == null) return const SizedBox.shrink();
      final going = sos['status'] == 'on_the_way';

      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: going ? secondaryLight : const Color(0xFFFDECEC),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: (going ? secondaryDark : sosRed).withOpacity(0.35),
          ),
        ),
        child: Row(
          children: [
            Icon(
              going ? Icons.directions_run_rounded : Icons.notifications_active_rounded,
              color: going ? secondaryDark : sosRed,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                going
                    ? "${sos['goingName']} is coming to help you"
                    : "SOS sent · warden and attender are alerted",
                style: GoogleFonts.poppins(
                  color: going ? secondaryDark : sosRed,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Get.to(() => SosScreen()),
              child: Text(
                "View",
                style: GoogleFonts.poppins(
                  color: darkTextColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSosCard() {
    return Material(
      color: sosRed,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () => Get.to(() => SosScreen()),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                height: 52,
                width: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.sos_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Emergency? Press SOS",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Snake, medical, fire or someone in danger — warden and attender get an alarm with your room number.",
                      style: GoogleFonts.poppins(
                        color: Colors.white.withOpacity(0.90),
                        fontSize: 11,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SECTION TITLE (same look as "Today's Meals")
  // ============================================================

  Widget _buildSectionTitle({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          height: 38,
          width: 38,
          decoration: BoxDecoration(
            color: primaryLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: primaryDark,
            size: 20,
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  color: darkTextColor,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.poppins(
                  color: lightTextColor,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // CATEGORY GRID
  // ============================================================

  Widget _buildCategoryGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - 10) / 2;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: HostelUi.categories.map((c) {
            final isLast = c == 'other';
            return SizedBox(
              width: isLast ? constraints.maxWidth : itemWidth,
              child: _buildCategoryTile(c),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildCategoryTile(String category) {
    final color = HostelUi.categoryColor(category);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () async {
          final added = await Get.to(() => RaiseComplaintScreen(category: category));
          if (added == true) controller.loadComplaints();
        },
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.black.withOpacity(0.05)),
          ),
          child: Row(
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  HostelUi.categoryIcon(category),
                  color: color,
                  size: 21,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      HostelUi.categoryName(category),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        color: darkTextColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      HostelUi.categoryHint(category),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        color: lightTextColor,
                        fontSize: 10,
                      ),
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
  // "PLEASE CONFIRM" BANNER
  // ============================================================

  Widget _buildConfirmBanner() {
    return Obx(() {
      final count = controller.waitingForConfirm;
      if (count == 0) return const SizedBox.shrink();
      return Container(
        margin: const EdgeInsets.only(bottom: 18),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: secondaryLight,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: secondaryDark.withOpacity(0.25)),
        ),
        child: Row(
          children: [
            const Icon(Icons.task_alt_rounded, color: secondaryDark),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                count == 1
                    ? "1 problem is marked repaired. Please check and confirm."
                    : "$count problems are marked repaired. Please check and confirm.",
                style: GoogleFonts.poppins(
                  color: secondaryDark,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  // ============================================================
  // COMPLAINT LIST
  // ============================================================

  Widget _buildComplaintList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Padding(
          padding: EdgeInsets.all(30),
          child: Center(
            child: CircularProgressIndicator(color: primaryDark),
          ),
        );
      }
      if (controller.complaints.isEmpty) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.black.withOpacity(0.05)),
          ),
          child: Column(
            children: [
              Container(
                height: 64,
                width: 64,
                decoration: const BoxDecoration(
                  color: primaryLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.sentiment_satisfied_alt_rounded,
                  color: primaryDark,
                  size: 32,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "All good in your room!",
                style: GoogleFonts.poppins(
                  color: darkTextColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                "Something broken? Pick a type above.",
                style: GoogleFonts.poppins(
                  color: lightTextColor,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
      }
      return Column(
        children: controller.complaints
            .map((c) => ComplaintTile(complaint: c))
            .toList(),
      );
    });
  }
}

// ============================================================
// COMPLAINT TILE (used on Hostel tab and Home)
// ============================================================

class ComplaintTile extends StatelessWidget {
  final Map<String, dynamic> complaint;

  const ComplaintTile({super.key, required this.complaint});

  static const Color darkTextColor = Color(0xFF252A27);
  static const Color lightTextColor = Color(0xFF7C837F);

  @override
  Widget build(BuildContext context) {
    final category = '${complaint['category']}';
    final status = '${complaint['status']}';
    final color = HostelUi.categoryColor(category);
    final (statusText, statusBg) = HostelUi.statusColors(status);
    final level = HostelUi.levelName('${complaint['level']}');

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => Get.to(() => ComplaintDetailsScreen(complaintId: '${complaint['_id']}')),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.black.withOpacity(0.05)),
            ),
            child: Row(
              children: [
                Container(
                  height: 46,
                  width: 46,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    HostelUi.categoryIcon(category),
                    color: color,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${complaint['title']}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          color: darkTextColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '${complaint['code']} · ${timeAgo(complaint['createdAt'])}',
                        style: GoogleFonts.poppins(
                          color: lightTextColor,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          _chip(HostelUi.statusName(status), statusText, statusBg),
                          if (level.isNotEmpty)
                            _chip(level, const Color(0xFF7656A6), const Color(0xFFF2EDF9)),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: lightTextColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _chip(String text, Color fg, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          color: fg,
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
