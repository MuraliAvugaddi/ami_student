import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

class NetworkController extends GetxController {
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  // RxBool to hold the connection status. Everyone can listen to this.
  final RxBool isOffline = false.obs;

  @override
  void onInit() {
    super.onInit();
    _checkInitialConnectivity();
    // Listen to connectivity changes
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  Future<void> _checkInitialConnectivity() async {
    final List<ConnectivityResult> result =
        await _connectivity.checkConnectivity();
    _updateConnectionStatus(result);
  }

  // Updates the isOffline variable based on the connectivity result
  void _updateConnectionStatus(List<ConnectivityResult> result) {
    if (result.contains(ConnectivityResult.none)) {
      isOffline.value = true;
    } else {
      isOffline.value = false;
    }
  }

  @override
  void onClose() {
    // Cancel the subscription when the controller is closed
    _connectivitySubscription.cancel();
    super.onClose();
  }
}
 