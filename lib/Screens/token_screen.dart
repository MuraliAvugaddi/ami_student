import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:ami_student/Controllers/profile_controller.dart';
import 'package:ami_student/Screens/Navigation_bar/new_main_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';

class TokenScreen extends StatefulWidget {
  final String mealType;
  final String tokenNumber;
  final String generatedAt;

  const TokenScreen({
    super.key,
    required this.mealType,
    required this.tokenNumber,
    required this.generatedAt,
  });

  @override
  State<TokenScreen> createState() => _TokenScreenState();
}

class _TokenScreenState extends State<TokenScreen> {
  final ProfileController controller = Get.find<ProfileController>();
  final AudioPlayer _audioPlayer = AudioPlayer();

  late Timer _timer;
  int _countdown = 30; // 30 second countdown

  // --- AdMob State Variables ---
  NativeAd? _nativeAd;
  bool _isAdLoaded = false;

  // ✅ Updated Production Native Ad ID for Token Generated Screen
  final String _androidAdUnitId = 'ca-app-pub-6236176751859838/7802038746';
  final String _iosAdUnitId = 'ca-app-pub-6236176751859838/9597704324';

  String get _nativeAdUnitId {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return _androidAdUnitId;
    }
    return _iosAdUnitId;
  }
  // --- End AdMob State ---

  @override
  void initState() {
    super.initState();
    _playSound();
    _startTimer();
    _loadAd();
  }

  void _loadAd() {
    if (kIsWeb) return;

    setState(() {
      _isAdLoaded = false;
    });

    _nativeAd = NativeAd(
      adUnitId: _nativeAdUnitId,
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (Ad ad) {
          debugPrint('✅ Ad loaded.');
          if (mounted) {
            setState(() {
              _isAdLoaded = true;
            });
          }
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          debugPrint('❌ Ad failed to load: $error');
          ad.dispose();
        },
      ),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.medium,
      ),
    )..load();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        if (_countdown > 0) {
          setState(() {
            _countdown--;
          });
        } else {
          _timer.cancel();
          Get.offAll(() => const MainScreen());
        }
      } else {
        _timer.cancel();
      }
    });
  }

  Future<void> _playSound() async {
    try {
      await _audioPlayer.play(AssetSource('audio/success-221935.mp3'));
    } catch (e) {
      debugPrint("Error playing sound: $e");
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    _audioPlayer.dispose();
    _nativeAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    DateTime parsedDate;
    try {
      parsedDate = DateTime.parse(widget.generatedAt).toLocal();
    } catch (e) {
      parsedDate = DateTime.now(); // Fallback to current device time
    }

    final String formattedDate = DateFormat(
      'dd MMMM, hh:mm a',
    ).format(parsedDate);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Obx(
          () => Text(
            'Hello ${controller.user.value.name}',
            style: GoogleFonts.roboto(
              fontWeight: FontWeight.w600,
              fontSize: 22,
              color: const Color.fromARGB(255, 0, 0, 0),
            ),
          ),
        ),
        backgroundColor: const Color(0xffFADD73),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Image.asset(
                  "assets/images/AMI Hostilers Jaipur Crest (1).png",
                  height: 120,
                ),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xffFBE156),
                        Color(0xffFEEFB1),
                        Color(0xffFEEFB1),
                        Color(0xffFAE153),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    border: Border.all(
                      color: const Color(0xffF8DE56),
                      width: 4,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          widget.mealType,
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              '#${widget.tokenNumber}',
                              style: GoogleFonts.poppins(
                                fontSize: 50,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Image.asset("assets/images/donephoto.png"),
                          ],
                        ),
                        Text(
                          'Your Token Number.',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                        Text(
                          formattedDate,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Closing $_countdown seconds...',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.red.shade700,
                  ),
                ),
                if (!kIsWeb) ...[
                  if (_nativeAd != null && _isAdLoaded)
                    Container(
                      key: ValueKey(_nativeAd.hashCode),
                      width: double.infinity,
                      height: 340,
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      alignment: Alignment.center,
                      child: AdWidget(ad: _nativeAd!),
                    )
                  else
                    Container(
                      height: 340,
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      alignment: Alignment.center,
                      child: const Center(
                        child: Text("Loading ad..."),
                      ),
                    ),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }
}
