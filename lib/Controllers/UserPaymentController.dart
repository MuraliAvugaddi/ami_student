import 'package:flutter/foundation.dart'; // Required for debugPrint
import 'package:get/get.dart';
import '../services/api_service.dart';

class UserPaymentController extends GetxController {
  final ApiService _apiService = ApiService();

  var paymentHistory = <dynamic>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPaymentHistory();
  }

  Future<void> fetchPaymentHistory() async {
    try {
      isLoading.value = true; // Use .value for clarity
      
      final response = await _apiService.getUserPaymentHistory();

      // If response is guaranteed non-nullable, the linter will stop complaining
      // if you remove "response != null"
      if (response['success'] == true && response['history'] != null) {
        paymentHistory.assignAll(response['history']);
      }
    } catch (e) {
      // debugPrint is the "correct" way to log in Flutter
      debugPrint("Controller Error fetching payment history: $e");
    } finally {
      isLoading.value = false;
    }
  }
}