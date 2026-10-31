import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';

class MealSkipController extends GetxController {
  final ApiService _apiService = ApiService();
  final ScrollController scrollController = ScrollController();

  var historyList = <dynamic>[].obs;
  var isLoading = false.obs;
  var isMoreLoading = false.obs; 

  var selectedDate = DateTime.now().add(const Duration(days: 1)).obs;
  var selectedMeal = "Full Day".obs;

  // ✅ Added reactive month filter variable (Defaults to current month/year format matching backend)
  var selectedHistoryMonth = DateFormat('MMMM yyyy').format(DateTime.now()).obs;

  var currentPage = 1.obs;
  var hasMoreData = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchInitialSkips();

    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 200) {
        fetchMoreSkips();
      }
    });
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  int getHistoryCount(String type) {
    return historyList.where((item) => item['mealType'] == type).length;
  }

  int get totalHistorySkips => historyList.length;

  void changeHistoryMonth(String newMonth) {
    selectedHistoryMonth.value = newMonth;
    fetchInitialSkips();
  }

  // --- 1. INITIAL FETCH ---
  Future<void> fetchInitialSkips() async {
    try {
      isLoading(true);
      currentPage.value = 1;
      hasMoreData.value = true;

      final Map<String, dynamic> res = await _apiService.getMySkips(
        page: 1, 
        month: selectedHistoryMonth.value,
      );

      if (res['success'] == true && res['skips'] != null) {
        List data = res['skips'];
        historyList.assignAll(data);
        if (data.length < 15) hasMoreData.value = false;
      }
    } catch (e) {
      debugPrint("Error fetching skips: $e");
    } finally {
      isLoading(false);
    }
  }

  // --- 2. LOAD MORE FETCH ---
  Future<void> fetchMoreSkips() async {
    if (isMoreLoading.value || !hasMoreData.value || isLoading.value) return;

    try {
      isMoreLoading(true);
      int nextPage = currentPage.value + 1;
      final Map<String, dynamic> res = await _apiService.getMySkips(
        page: nextPage, 
        month: selectedHistoryMonth.value,
      );

      if (res['success'] == true && res['skips'] != null) {
        List newItems = res['skips'];
        if (newItems.isEmpty) {
          hasMoreData.value = false;
        } else {
          historyList.addAll(newItems);
          currentPage.value = nextPage;
          if (newItems.length < 15) hasMoreData.value = false;
        }
      }
    } catch (e) {
      debugPrint("Error loading more skips: $e");
    } finally {
      isMoreLoading(false);
    }
  }

  // --- 3. SUBMIT SKIP ---
  Future<void> submitSkip() async {
    try {
      isLoading(true);
      final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate.value);
      final Map<String, dynamic> res = await _apiService.submitMealSkip(dateStr, selectedMeal.value);

      if (res['success'] == true) {
        Get.snackbar("Success", res['message'] ?? "Meal skipped",
            backgroundColor: Colors.green, colorText: Colors.white);
        fetchInitialSkips(); 
      } else {
        Get.snackbar("Denied", res['message'] ?? "Failed",
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar("Error", "Server Error", backgroundColor: Colors.orange);
    } finally {
      isLoading(false);
    }
  }
}