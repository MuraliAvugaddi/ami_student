import 'package:ami_student/Controllers/hostel_controller.dart';
import 'package:ami_student/Screens/hostel/complaint_details_screen.dart';
import 'package:ami_student/Screens/hostel/sos_screen.dart';
import 'package:ami_student/utils/hostel_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

// ============================================================
// HOME — small hostel strip under the greeting card
//   [ 🚨 SOS ]   [ 🔧 Room problem / complaint status ]
// ============================================================

class HostelHomeStrip extends StatelessWidget {
  final VoidCallback onOpenHostel;

  HostelHomeStrip({super.key, required this.onOpenHostel});

  final HostelController controller = Get.isRegistered<HostelController>()
      ? Get.find<HostelController>()
      : Get.put(HostelController());

  static const Color primaryDark = Color(0xFFD5A514);
  static const Color primaryLight = Color(0xFFFFF8DC);
  static const Color secondaryDark = Color(0xFF669447);
  static const Color darkTextColor = Color(0xFF252A27);
  static const Color lightTextColor = Color(0xFF7C837F);
  static const Color sosRed = Color(0xFFE53935);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 22),
      child: Row(
        children: [
          // ---------------- SOS ----------------
          Material(
            color: sosRed,
            borderRadius: BorderRadius.circular(18),
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () => Get.to(() => const SosScreen()),
              child: SizedBox(
                height: 64,
                width: 82,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.sos_rounded, color: Colors.white, size: 26),
                    Text(
                      "Emergency",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // ---------------- ROOM PROBLEM ----------------
          Expanded(
            child: Obx(() {
              final active = controller.activeComplaints;
              final confirm = controller.waitingForConfirm;
              final first = active.isNotEmpty ? active.first : null;

              String title = "Room problem?";
              String subtitle = "Fan, tap, door, cleaning — report it";
              IconData icon = Icons.handyman_rounded;
              Color color = primaryDark;

              if (confirm > 0) {
                title = "Repaired — please confirm";
                subtitle = "Tap to check and rate";
                icon = Icons.task_alt_rounded;
                color = secondaryDark;
              } else if (first != null) {
                title = '${first['title']}';
                subtitle = '${HostelUi.statusName('${first['status']}')}'
                    '${active.length > 1 ? ' · +${active.length - 1} more' : ''}';
                icon = HostelUi.categoryIcon('${first['category']}');
                color = HostelUi.categoryColor('${first['category']}');
              }

              return Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () {
                    if (confirm > 0) {
                      final c = controller.complaints.firstWhere((x) => x['status'] == 'repaired');
                      Get.to(() => ComplaintDetailsScreen(complaintId: '${c['_id']}'));
                    } else {
                      onOpenHostel();
                    }
                  },
                  child: Container(
                    height: 64,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.black.withOpacity(0.05)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          height: 38,
                          width: 38,
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(icon, color: color, size: 20),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  color: darkTextColor,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                subtitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  color: lightTextColor,
                                  fontSize: 10.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded, color: lightTextColor),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
