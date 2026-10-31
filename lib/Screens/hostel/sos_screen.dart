import 'dart:async';

import 'package:ami_student/Controllers/hostel_controller.dart';
import 'package:ami_student/utils/hostel_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

// ============================================================
// SOS — hold the red button for 2 seconds
// Warden, attender and director get a loud alarm + SMS with
// the room number and phone.
// ============================================================

class SosScreen extends StatefulWidget {
  const SosScreen({super.key});

  @override
  State<SosScreen> createState() => _SosScreenState();
}

class _SosScreenState extends State<SosScreen> with SingleTickerProviderStateMixin {
  // ============================================================
  // COLORS
  // ============================================================

  static const Color sosRed = Color(0xFFE53935);
  static const Color sosDark = Color(0xFFB71C1C);
  static const Color secondaryDark = Color(0xFF669447);
  static const Color secondaryLight = Color(0xFFF1F8EB);
  static const Color darkTextColor = Color(0xFF252A27);
  static const Color lightTextColor = Color(0xFF7C837F);
  static const Color backgroundColor = Color(0xFFFAFAF8);

  final HostelController controller = Get.isRegistered<HostelController>()
      ? Get.find<HostelController>()
      : Get.put(HostelController());
  final TextEditingController _noteController = TextEditingController();

  late final AnimationController _hold = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  );

  String _type = 'medical';
  Timer? _poll;

  @override
  void initState() {
    super.initState();
    _hold.addStatusListener((status) {
      if (status == AnimationStatus.completed) _send();
    });
    controller.loadSos();
    // Keep checking while an SOS is open, so "help is coming" shows quickly
    _poll = Timer.periodic(const Duration(seconds: 8), (_) {
      if (controller.activeSos != null) controller.loadSos();
    });
  }

  @override
  void dispose() {
    _poll?.cancel();
    _hold.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    HapticFeedback.heavyImpact();
    final ok = await controller.sendSos(_type, _noteController.text.trim());
    _hold.reset();
    if (ok) {
      Get.snackbar(
        "SOS sent 🚨",
        "Warden and attender are alerted. Stay where you are.",
        snackPosition: SnackPosition.TOP,
        backgroundColor: sosRed,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    }
  }

  Future<void> _call(String phone) async {
    if (phone.isEmpty) return;
    await launchUrl(Uri(scheme: 'tel', path: phone));
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        surfaceTintColor: backgroundColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: darkTextColor),
        title: Text(
          "SOS Emergency",
          style: GoogleFonts.poppins(
            color: darkTextColor,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Obx(() {
        final active = controller.activeSos;
        return ListView(
          padding: const EdgeInsets.fromLTRB(18, 6, 18, 30),
          children: [
            if (active != null) _buildStatus(active) else ..._buildForm(),
          ],
        );
      }),
    );
  }

  // ============================================================
  // FORM
  // ============================================================

  List<Widget> _buildForm() {
    return [
      Text(
        "What is happening?",
        style: GoogleFonts.poppins(
          color: darkTextColor,
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(height: 10),
      GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.05,
        children: HostelUi.sosTypes.map((t) {
          final selected = _type == t;
          return GestureDetector(
            onTap: () => setState(() => _type = t),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              decoration: BoxDecoration(
                color: selected ? const Color(0xFFFDECEC) : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: selected ? sosRed : Colors.black.withOpacity(0.06),
                  width: selected ? 2 : 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(HostelUi.sosIcon(t), color: selected ? sosRed : lightTextColor, size: 28),
                  const SizedBox(height: 6),
                  Text(
                    HostelUi.sosName(t),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: selected ? sosDark : darkTextColor,
                      fontSize: 11,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
      const SizedBox(height: 14),
      TextField(
        controller: _noteController,
        maxLength: 300,
        style: GoogleFonts.poppins(fontSize: 13.5),
        decoration: InputDecoration(
          hintText: "Short note (optional) — e.g. snake near bathroom",
          hintStyle: GoogleFonts.poppins(fontSize: 12.5, color: lightTextColor),
          counterText: '',
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.black.withOpacity(0.08)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.black.withOpacity(0.08)),
          ),
        ),
      ),
      const SizedBox(height: 26),
      Center(child: _buildHoldButton()),
      const SizedBox(height: 14),
      Text(
        "Hold the button for 2 seconds",
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(
          color: darkTextColor,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
      Text(
        "Your name, room and phone go to the warden, attender and director.",
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(color: lightTextColor, fontSize: 11.5, height: 1.5),
      ),
    ];
  }

  Widget _buildHoldButton() {
    return GestureDetector(
      onTapDown: (_) {
        HapticFeedback.mediumImpact();
        _hold.forward();
      },
      onTapUp: (_) {
        if (_hold.status != AnimationStatus.completed) _hold.reverse();
      },
      onTapCancel: () {
        if (_hold.status != AnimationStatus.completed) _hold.reverse();
      },
      child: AnimatedBuilder(
        animation: _hold,
        builder: (context, _) {
          return SizedBox(
            height: 200,
            width: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: 200,
                  width: 200,
                  child: CircularProgressIndicator(
                    value: _hold.value,
                    strokeWidth: 8,
                    color: sosDark,
                    backgroundColor: sosRed.withOpacity(0.15),
                  ),
                ),
                Container(
                  height: 170,
                  width: 170,
                  decoration: BoxDecoration(
                    color: sosRed,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: sosRed.withOpacity(0.35 + _hold.value * 0.3),
                        blurRadius: 30 + _hold.value * 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Obx(
                    () => controller.isSending.value
                        ? const Center(child: CircularProgressIndicator(color: Colors.white))
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "SOS",
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 40,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 2,
                                ),
                              ),
                              Text(
                                "HOLD",
                                style: GoogleFonts.poppins(
                                  color: Colors.white.withOpacity(0.85),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 2,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // STATUS (after sending)
  // ============================================================

  Widget _buildStatus(Map<String, dynamic> sos) {
    final going = sos['status'] == 'on_the_way';
    final color = going ? secondaryDark : sosRed;

    return Column(
      children: [
        const SizedBox(height: 20),
        Container(
          height: 110,
          width: 110,
          decoration: BoxDecoration(
            color: (going ? secondaryLight : const Color(0xFFFDECEC)),
            shape: BoxShape.circle,
          ),
          child: Icon(
            going ? Icons.directions_run_rounded : Icons.notifications_active_rounded,
            color: color,
            size: 54,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          going ? "Help is coming" : "SOS sent",
          style: GoogleFonts.poppins(
            color: darkTextColor,
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          going
              ? "${sos['goingName']} is on the way to Room ${sos['room']}."
              : "Warden, attender and director have been alerted with your room number. Stay where you are.",
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(color: lightTextColor, fontSize: 13, height: 1.5),
        ),
        const SizedBox(height: 22),
        if (going && '${sos['goingPhone'] ?? ''}'.isNotEmpty)
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              onPressed: () => _call('${sos['goingPhone']}'),
              icon: const Icon(Icons.call_rounded),
              label: Text(
                "Call ${sos['goingName']}",
                style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: secondaryDark,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton(
            onPressed: _send,
            style: OutlinedButton.styleFrom(
              foregroundColor: sosRed,
              side: const BorderSide(color: sosRed),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Text(
              "Ring the alarm again",
              style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
            ),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          "${sos['code']} · ${HostelUi.sosName('${sos['type']}')} · ${timeAgo(sos['createdAt'])}",
          style: GoogleFonts.poppins(color: lightTextColor, fontSize: 11.5),
        ),
      ],
    );
  }
}
