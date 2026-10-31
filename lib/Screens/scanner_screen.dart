import 'package:ami_student/Screens/token_screen.dart';
import 'package:ami_student/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:permission_handler/permission_handler.dart';

/// Camera permission state for the scanner.
enum _CamState { checking, granted, denied, permanentlyDenied }

class ScannerScreen extends StatefulWidget {
  final String mealType;
  const ScannerScreen({Key? key, required this.mealType}) : super(key: key);

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen>
    with WidgetsBindingObserver {
  _CamState _camState = kIsWeb ? _CamState.granted : _CamState.checking;

  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool _isScanComplete = false;
  final ApiService _apiService = ApiService();

  // --- Ad-related variables ---
  BannerAd? _topBannerAd;
  bool _isTopBannerLoaded = false;
  BannerAd? _bottomBannerAd;
  bool _isBottomBannerLoaded = false;

  // ✅ Your production Ad Unit IDs for Top & Bottom Scanner Banners
  final String _topBannerAdUnitId = 'ca-app-pub-6236176751859838/9897005033';
  final String _bottomBannerAdUnitId = 'ca-app-pub-6236176751859838/5734398744';

  // --- TIME VALIDATION LOGIC ---
  bool isTimeValidForMeal() {
    final now = DateTime.now();
    final hour = now.hour;
    final minute = now.minute;
    final currentTimeInMinutes = hour * 60 + minute;

    switch (widget.mealType) {
      case "Breakfast":
        return currentTimeInMinutes >= (00 * 60 + 00) &&
            currentTimeInMinutes <= (24 * 60 + 00);
      case "Lunch":
        return currentTimeInMinutes >= (00 * 60 + 00) &&
            currentTimeInMinutes <= (24 * 60 + 00);
      case "Snacks":
        return currentTimeInMinutes >= (00 * 60 + 00) &&
            currentTimeInMinutes <= (24 * 60 + 00);
      case "Dinner":
        return currentTimeInMinutes >= (00 * 60 + 00) &&
            currentTimeInMinutes <= (24 * 60 + 00);
      default:
        return false;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadTopBannerAd();
    _loadBottomBannerAd();
    _checkCameraPermission(askIfNeeded: true);
  }

  // When the student comes back from phone Settings, check again
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        _camState != _CamState.granted &&
        _camState != _CamState.checking) {
      _checkCameraPermission(askIfNeeded: false);
    }
  }

  // --- CAMERA PERMISSION ---
  Future<void> _checkCameraPermission({required bool askIfNeeded}) async {
    if (kIsWeb) return;
    var status = await Permission.camera.status;
    if (!status.isGranted && askIfNeeded && !status.isPermanentlyDenied) {
      status = await Permission.camera.request();
    }
    if (!mounted) return;
    setState(() {
      if (status.isGranted || status.isLimited) {
        _camState = _CamState.granted;
      } else if (status.isPermanentlyDenied || status.isRestricted) {
        _camState = _CamState.permanentlyDenied;
      } else {
        _camState = _CamState.denied;
      }
    });
  }

  Widget _buildPermissionView() {
    final permanently = _camState == _CamState.permanentlyDenied;
    return Container(
      color: const Color(0xFF111111),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: const Color(0xFFFADD73).withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.photo_camera_rounded,
                color: Color(0xFFFADD73), size: 42),
          ),
          const SizedBox(height: 24),
          Text(
            'Camera permission needed',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          Text(
            permanently
                ? 'Camera access is turned off for this app. Open Settings → Permissions → Camera and choose "Allow", then come back.'
                : 'To scan the mess QR code and generate your ${widget.mealType} token, please allow camera access.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
                color: Colors.white70, fontSize: 13.5, height: 1.5),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () async {
                if (permanently) {
                  await openAppSettings();
                } else {
                  await _checkCameraPermission(askIfNeeded: true);
                }
              },
              icon: Icon(permanently ? Icons.settings_rounded : Icons.check_rounded),
              label: Text(permanently ? 'Open Settings' : 'Allow Camera',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFADD73),
                foregroundColor: const Color(0xFF252A27),
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Go back',
                style: GoogleFonts.poppins(color: Colors.white60)),
          ),
        ],
      ),
    );
  }

  // --- Ad loading functions ---
  void _loadTopBannerAd() {
    if (kIsWeb) return;

    _topBannerAd = BannerAd(
      adUnitId: _topBannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isTopBannerLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, err) {
          debugPrint('❌ Top BannerAd failed to load: $err');
          ad.dispose();
        },
      ),
    )..load();
  }

  void _loadBottomBannerAd() {
    if (kIsWeb) return;

    _bottomBannerAd = BannerAd(
      adUnitId: _bottomBannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isBottomBannerLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, err) {
          debugPrint('❌ Bottom BannerAd failed to load: $err');
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  void reassemble() {
    super.reassemble();
    if (controller != null) {
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
        controller!.pauseCamera();
      }
      controller!.resumeCamera();
    }
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      if (_isScanComplete) return;

      if (scanData.code == 'ACIKgwq4WrEncscjBbVRbA') {
        setState(() {
          _isScanComplete = true;
        });
        controller.pauseCamera();
        _generateToken();
      } else {
        controller.pauseCamera();
        Get.snackbar(
          'Invalid QR Code',
          'This is not a valid mess QR code.',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
        Future.delayed(const Duration(seconds: 2), () {
          controller.resumeCamera();
        });
      }
    });
  }

  Future<void> _generateToken() async {
    Get.dialog(
      const Center(child: CircularProgressIndicator(color: Color(0xffFFC800))),
      barrierDismissible: false,
    );
    final result = await _apiService.generateToken(widget.mealType);
    Get.back();

    if (result['success'] == true) {
      Get.off(
        () => TokenScreen(
          mealType: result['token']['mealType'],
          tokenNumber: result['token']['tokenNumber'].toString(),
          generatedAt: result['token']['generatedAt'],
        ),
      );
    } else {
      Get.snackbar(
        'Token Generation Failed',
        result['message'] ?? 'An unknown error occurred.',
        backgroundColor: const Color.fromARGB(255, 255, 0, 0),
        colorText: Colors.white,
      );
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          _isScanComplete = false;
        });
        controller?.resumeCamera();
      });
    }
  }

  // ✅ Styled Container to prevent collapse when ad is loading/failed
  Widget _buildAdContainer(BannerAd? ad, bool isLoaded) {
    return Container(
      alignment: Alignment.center,
      height: 50.0,
      width: double.infinity,
      color: Colors.black, // Matching scanner background
      child: isLoaded && ad != null
          ? SizedBox(
              width: ad.size.width.toDouble(),
              height: ad.size.height.toDouble(),
              child: AdWidget(ad: ad),
            )
          : const SizedBox.shrink(), // Keeps UI clean if ad hasn't loaded yet
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!isTimeValidForMeal()) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            '${widget.mealType} Token',
            style: GoogleFonts.roboto(
              fontWeight: FontWeight.w600,
              fontSize: 22,
              color: const Color.fromARGB(255, 0, 0, 0),
            ),
          ),
          backgroundColor: const Color(0xffFADD73),
        ),
        body: Column(
          children: [
            if (!kIsWeb) _buildAdContainer(_topBannerAd, _isTopBannerLoaded),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.all(40),
                      child: Image.asset(
                        "assets/images/timeout-3d.webp",
                      ),
                    ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Text(
                          'Sorry, the window for generating a ${widget.mealType} token is currently closed.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                              fontSize: 18,
                              color: const Color.fromARGB(255, 0, 0, 0)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (!kIsWeb)
              _buildAdContainer(_bottomBannerAd, _isBottomBannerLoaded),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: <Widget>[
          // ✅ Upside (Top) Banner Ad
          if (!kIsWeb)
            SafeArea(
              bottom: false,
              child: _buildAdContainer(_topBannerAd, _isTopBannerLoaded),
            ),

          // QR Scanner View Area
          Expanded(
            child: _camState == _CamState.checking
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFFFADD73)))
                : _camState != _CamState.granted
                    ? _buildPermissionView()
                    : Stack(
              alignment: Alignment.center,
              children: <Widget>[
                QRView(
                  key: qrKey,
                  onQRViewCreated: _onQRViewCreated,
                  // If the camera is refused here, show the permission screen
                  onPermissionSet: (ctrl, granted) {
                    if (!granted && mounted) {
                      _checkCameraPermission(askIfNeeded: false);
                    }
                  },
                  overlay: QrScannerOverlayShape(
                    borderColor: Colors.teal,
                    borderRadius: 10,
                    borderLength: 30,
                    borderWidth: 10,
                    cutOutSize: 300,
                  ),
                ),
                Positioned(
                  top: 60,
                  child: Text(
                    'Scan Mess QR for ${widget.mealType}',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 60,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Align QR code within the frame',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ✅ Downside (Bottom) Banner Ad wrapped nicely inside SafeArea
          if (!kIsWeb)
            SafeArea(
              top: false,
              child: _buildAdContainer(_bottomBannerAd, _isBottomBannerLoaded),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controller?.dispose();
    _topBannerAd?.dispose();
    _bottomBannerAd?.dispose();
    super.dispose();
  }
}
