import 'package:ami_student/Controllers/hostel_controller.dart';
import 'package:ami_student/Screens/hostel/complaint_details_screen.dart';
import 'package:ami_student/Screens/hostel/sos_screen.dart';
import 'package:ami_student/utils/hostel_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

// ============================================================
// HOSTEL NOTIFICATIONS (bell)
// ============================================================

class HostelNotificationsScreen extends StatelessWidget {
  HostelNotificationsScreen({super.key});

  final HostelController controller = Get.isRegistered<HostelController>()
      ? Get.find<HostelController>()
      : Get.put(HostelController());

  static const Color primaryDark = Color(0xFFD5A514);
  static const Color primaryLight = Color(0xFFFFF8DC);
  static const Color darkTextColor = Color(0xFF252A27);
  static const Color lightTextColor = Color(0xFF7C837F);
  static const Color backgroundColor = Color(0xFFFAFAF8);

  void _open(Map<String, dynamic> n) {
    final type = '${n['type']}';
    final id = '${n['refId'] ?? ''}';
    if (type == 'complaint' && id.isNotEmpty) {
      Get.to(() => ComplaintDetailsScreen(complaintId: id));
    } else if (type.startsWith('sos')) {
      Get.to(() => const SosScreen());
    }
  }

  IconData _icon(String type) {
    if (type.startsWith('sos')) return Icons.sos_rounded;
    if (type == 'complaint') return Icons.handyman_rounded;
    return Icons.notifications_rounded;
  }

  @override
  Widget build(BuildContext context) {
    controller.loadNotifications().then((_) => controller.markAllRead());

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        surfaceTintColor: backgroundColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: darkTextColor),
        title: Text(
          "Notifications",
          style: GoogleFonts.poppins(
            color: darkTextColor,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.notifications.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 70,
                  width: 70,
                  decoration: const BoxDecoration(color: primaryLight, shape: BoxShape.circle),
                  child: const Icon(Icons.notifications_off_rounded, color: primaryDark, size: 32),
                ),
                const SizedBox(height: 12),
                Text(
                  "No notifications yet",
                  style: GoogleFonts.poppins(
                    color: darkTextColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          );
        }
        return RefreshIndicator(
          color: primaryDark,
          onRefresh: controller.loadNotifications,
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 30),
            itemCount: controller.notifications.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final n = controller.notifications[i];
              final unread = n['isRead'] != true;
              final isSos = '${n['type']}'.startsWith('sos');
              return Material(
                color: unread ? primaryLight : Colors.white,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => _open(n),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 38,
                          width: 38,
                          decoration: BoxDecoration(
                            color: isSos ? const Color(0xFFFDECEC) : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _icon('${n['type']}'),
                            color: isSos ? const Color(0xFFE53935) : primaryDark,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${n['title']}',
                                style: GoogleFonts.poppins(
                                  color: darkTextColor,
                                  fontSize: 13.5,
                                  fontWeight: unread ? FontWeight.w700 : FontWeight.w600,
                                ),
                              ),
                              if ('${n['body'] ?? ''}'.isNotEmpty)
                                Text(
                                  '${n['body']}',
                                  style: GoogleFonts.poppins(
                                    color: darkTextColor.withOpacity(0.8),
                                    fontSize: 12,
                                    height: 1.4,
                                  ),
                                ),
                              const SizedBox(height: 4),
                              Text(
                                timeAgo(n['createdAt']),
                                style: GoogleFonts.poppins(color: lightTextColor, fontSize: 10.5),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
