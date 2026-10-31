import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class AlaCarteScreen extends StatelessWidget {
  const AlaCarteScreen({super.key});

  // ============================================================
  // LINKS
  // ============================================================

  static const String alaCarteUrl =
      'https://chefhospitalityservices.com/pre-order';

  static const String supportWhatsAppNumber = '919398315945';

  // ============================================================
  // COLORS
  // ============================================================

  static const Color primaryColor = Color(0xFFFADD73);
  static const Color primaryDark = Color(0xFFD5A514);
  static const Color primaryLight = Color(0xFFFFF8DC);

  static const Color darkText = Color(0xFF202522);
  static const Color bodyText = Color(0xFF737A76);
  static const Color background = Color(0xFFFAFAF8);

  static const Color warningBackground = Color(0xFFFFF5D9);
  static const Color warningBorder = Color(0xFFF0B429);
  static const Color warningDark = Color(0xFF8A5A00);

  static const Color green = Color(0xFF669447);
  static const Color greenLight = Color(0xFFF1F8EB);

  // ============================================================
  // OPEN WEBSITE
  // ============================================================

  Future<void> _openWebsite(BuildContext context) async {
    final Uri uri = Uri.parse(alaCarteUrl);

    try {
      final bool opened = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!opened && context.mounted) {
        _showError(
          context,
          'Unable to open the ordering website.',
        );
      }
    } catch (e) {
      debugPrint('Website error: $e');

      if (context.mounted) {
        _showError(
          context,
          'Unable to open the ordering website.',
        );
      }
    }
  }

  // ============================================================
  // WHATSAPP SUPPORT
  // ============================================================

  Future<void> _openWhatsApp(BuildContext context) async {
    const String message =
        'Hi Ami Hostlers Support, I need help with À La Carte ordering.';

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

      final bool opened = await launchUrl(
        whatsappWeb,
        mode: LaunchMode.externalApplication,
      );

      if (!opened && context.mounted) {
        _showError(
          context,
          'Unable to open WhatsApp.',
        );
      }
    } catch (e) {
      debugPrint('WhatsApp error: $e');

      if (context.mounted) {
        _showError(
          context,
          'Unable to open WhatsApp.',
        );
      }
    }
  }

  // ============================================================
  // ERROR MESSAGE
  // ============================================================

  void _showError(
    BuildContext context,
    String message,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.poppins(
            fontSize: 12,
          ),
        ),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
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
      backgroundColor: background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            18,
            12,
            18,
            25,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // =================================================
              // HEADER
              // =================================================

              Row(
                children: [
                  Container(
                    height: 44,
                    width: 44,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.restaurant_menu_rounded,
                      color: darkText,
                      size: 22,
                    ),
                  ),

                  const SizedBox(width: 11),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'À La Carte',
                          style: GoogleFonts.poppins(
                            color: darkText,
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.4,
                          ),
                        ),
                        Text(
                          'Pre-order your special meal',
                          style: GoogleFonts.poppins(
                            color: bodyText,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // SUPPORT BUTTON
                  Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(13),
                    child: InkWell(
                      onTap: () => _openWhatsApp(context),
                      borderRadius: BorderRadius.circular(13),
                      child: const SizedBox(
                        height: 40,
                        width: 40,
                        child: Icon(
                          Icons.support_agent_rounded,
                          color: green,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // =================================================
              // COMPACT HERO
              // =================================================

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 17,
                  vertical: 15,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      primaryColor,
                      Color(0xFFFFEAA0),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(
                                0.65,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'SPECIAL MENU',
                              style: GoogleFonts.poppins(
                                color: darkText,
                                fontSize: 7,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.7,
                              ),
                            ),
                          ),
                          const SizedBox(height: 7),
                          Text(
                            'Craving something special?',
                            style: GoogleFonts.poppins(
                              color: darkText,
                              fontSize: 16.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Browse the menu and pre-order online.',
                            style: GoogleFonts.poppins(
                              color: darkText.withOpacity(0.68),
                              fontSize: 9,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      height: 58,
                      width: 58,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.55),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.lunch_dining_rounded,
                        color: darkText,
                        size: 31,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // =================================================
              // CLICKABLE 2 HOURS CARD
              // =================================================

              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _openWebsite(context),
                  borderRadius: BorderRadius.circular(17),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 13,
                      vertical: 11,
                    ),
                    decoration: BoxDecoration(
                      color: warningBackground,
                      borderRadius: BorderRadius.circular(17),
                      border: Border.all(
                        color: warningBorder,
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      children: [
                        // CLOCK ICON
                        Container(
                          height: 43,
                          width: 43,
                          decoration: BoxDecoration(
                            color: warningBorder.withOpacity(
                              0.18,
                            ),
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: const Icon(
                            Icons.alarm_rounded,
                            color: warningDark,
                            size: 23,
                          ),
                        ),

                        const SizedBox(width: 11),

                        // TEXT
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'ORDER ',
                                    style: GoogleFonts.poppins(
                                      color: warningDark,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    '2 HOURS BEFORE',
                                    style: GoogleFonts.poppins(
                                      color: darkText,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Pre-order at least 2 hours before your meal time.',
                                style: GoogleFonts.poppins(
                                  color: bodyText,
                                  fontSize: 8.5,
                                  height: 1.35,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'Tap to pre-order now',
                                style: GoogleFonts.poppins(
                                  color: warningDark,
                                  fontSize: 8,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 6),

                        Container(
                          height: 30,
                          width: 30,
                          decoration: const BoxDecoration(
                            color: warningBorder,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // =================================================
              // READY TO ORDER
              // =================================================

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ready to order?',
                          style: GoogleFonts.poppins(
                            color: darkText,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Open the menu and place your pre-order.',
                          style: GoogleFonts.poppins(
                            color: bodyText,
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: greenLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.circle,
                          color: green,
                          size: 6,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'ONLINE',
                          style: GoogleFonts.poppins(
                            color: green,
                            fontSize: 7,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // =================================================
              // ORDER ONLINE BUTTON
              // =================================================

              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: () => _openWebsite(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: darkText,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        height: 35,
                        width: 35,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.65),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.restaurant_rounded,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Order Online',
                              style: GoogleFonts.poppins(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'View menu & place your order',
                              style: GoogleFonts.poppins(
                                color: darkText.withOpacity(
                                  0.62,
                                ),
                                fontSize: 8,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        size: 19,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // =================================================
              // QR DIVIDER
              // =================================================

              Row(
                children: [
                  const Expanded(
                    child: Divider(
                      color: Color(0xFFE4E5E1),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                    ),
                    child: Text(
                      'OR SCAN TO ORDER',
                      style: GoogleFonts.poppins(
                        color: bodyText,
                        fontSize: 7.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Divider(
                      color: Color(0xFFE4E5E1),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // =================================================
              // LARGE QR CODE CARD
              // =================================================

              Container(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  20,
                  20,
                  18,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: const Color(0xFFE8E9E5),
                  ),
                ),
                child: Column(
                  children: [
                    // QR ICON
                    Container(
                      height: 42,
                      width: 42,
                      decoration: const BoxDecoration(
                        color: primaryLight,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.qr_code_scanner_rounded,
                        color: primaryDark,
                        size: 21,
                      ),
                    ),

                    const SizedBox(height: 9),

                    // TITLE
                    Text(
                      'Scan to Order',
                      style: GoogleFonts.poppins(
                        color: darkText,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      'Scan this QR code with your phone camera',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: bodyText,
                        fontSize: 9,
                      ),
                    ),

                    const SizedBox(height: 17),

                    // ===========================================
                    // LARGE QR CODE
                    // ===========================================

                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: primaryColor,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withOpacity(
                              0.12,
                            ),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: QrImageView(
                        data: alaCarteUrl,
                        version: QrVersions.auto,

                        // BIG QR
                        size: 160,

                        backgroundColor: Colors.white,

                        eyeStyle: const QrEyeStyle(
                          eyeShape: QrEyeShape.square,
                          color: darkText,
                        ),

                        dataModuleStyle: const QrDataModuleStyle(
                          dataModuleShape: QrDataModuleShape.square,
                          color: darkText,
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    Text(
                      'À La Carte Online Ordering',
                      style: GoogleFonts.poppins(
                        color: darkText,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 2),

                    Text(
                      'Ami Hostlers Jaipur',
                      style: GoogleFonts.poppins(
                        color: bodyText,
                        fontSize: 8.5,
                      ),
                    ),

                    const SizedBox(height: 8),

                    TextButton.icon(
                      onPressed: () => _openWebsite(context),
                      icon: const Icon(
                        Icons.open_in_new_rounded,
                        color: primaryDark,
                        size: 15,
                      ),
                      label: Text(
                        'Open ordering website',
                        style: GoogleFonts.poppins(
                          color: primaryDark,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // =================================================
              // HOW IT WORKS
              // =================================================

              Text(
                'How it works',
                style: GoogleFonts.poppins(
                  color: darkText,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 10),

              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: const Color(0xFFE8E9E5),
                  ),
                ),
                child: Column(
                  children: [
                    _buildStep(
                      number: '1',
                      title: 'Browse menu',
                      subtitle: 'Choose your favourite special food.',
                    ),
                    _buildDivider(),
                    _buildStep(
                      number: '2',
                      title: 'Order 2 hours before',
                      subtitle:
                          'Place your order at least 2 hours before your meal time.',
                      highlight: true,
                    ),
                    _buildDivider(),
                    _buildStep(
                      number: '3',
                      title: 'Complete your order',
                      subtitle:
                          'Submit your order through the online ordering system.',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // =================================================
              // SUPPORT
              // =================================================

              Material(
                color: greenLight,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  onTap: () => _openWhatsApp(context),
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 11,
                    ),
                    child: Row(
                      children: [
                        Container(
                          height: 35,
                          width: 35,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.support_agent_rounded,
                            color: green,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Need help?',
                                style: GoogleFonts.poppins(
                                  color: darkText,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                'Chat with Ami Hostlers Support',
                                style: GoogleFonts.poppins(
                                  color: bodyText,
                                  fontSize: 8,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: green,
                          size: 13,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // =================================================
              // FOOTER
              // =================================================

              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.lock_outline_rounded,
                      size: 11,
                      color: bodyText,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Ami Hostlers Jaipur • À La Carte',
                      style: GoogleFonts.poppins(
                        color: bodyText,
                        fontSize: 7.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 5),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // HOW IT WORKS STEP
  // ============================================================

  Widget _buildStep({
    required String number,
    required String title,
    required String subtitle,
    bool highlight = false,
  }) {
    return Container(
      padding: highlight
          ? const EdgeInsets.all(9)
          : const EdgeInsets.symmetric(
              vertical: 3,
            ),
      decoration: highlight
          ? BoxDecoration(
              color: warningBackground,
              borderRadius: BorderRadius.circular(12),
            )
          : null,
      child: Row(
        children: [
          Container(
            height: 30,
            width: 30,
            decoration: BoxDecoration(
              color: highlight ? warningBorder : primaryLight,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: GoogleFonts.poppins(
                  color: highlight ? Colors.white : primaryDark,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: highlight ? warningDark : darkText,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    color: bodyText,
                    fontSize: 8,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DIVIDER
  // ============================================================

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(
        vertical: 6,
      ),
      child: Divider(
        height: 1,
        color: Color(0xFFE8E9E5),
      ),
    );
  }
}
