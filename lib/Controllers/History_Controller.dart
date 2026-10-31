import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class HistoryController extends GetxController {
  final ApiService _apiService = ApiService();

  ScrollController scrollController = ScrollController();

  var historyList = <dynamic>[].obs;
  var isLoading = false.obs;
  var isMoreLoading = false.obs;
  var currentPage = 1.obs;
  var hasMoreData = true.obs;

  // Track selected month filter (e.g., "2026-06")
  var selectedMonth = DateFormat('yyyy-MM').format(DateTime.now()).obs;

  @override
  void onInit() {
    super.onInit();
    fetchInitialHistory();

    scrollController.addListener(() {
      // FIX: Guard against multiple triggers when close to bottom
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 100) {
        if (!isMoreLoading.value && hasMoreData.value && !isLoading.value) {
          fetchMoreHistory();
        }
      }
    });
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  void changeMonth(String monthStr) {
    selectedMonth.value = monthStr;
    fetchInitialHistory();
  }

  Future<void> fetchInitialHistory() async {
    try {
      isLoading(true);
      currentPage.value = 1;
      hasMoreData.value = true;

      final response = await _apiService.getUserHistoryPaginated(
          currentPage.value, selectedMonth.value);

      if (response['success'] == true) {
        List data = response['history'];
        historyList.assignAll(data);
        if (data.length < 15) hasMoreData.value = false;
      }
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchMoreHistory() async {
    if (!hasMoreData.value || isMoreLoading.value || isLoading.value) return;

    try {
      isMoreLoading(true);
      int nextPage = currentPage.value + 1;
      final response = await _apiService.getUserHistoryPaginated(
          nextPage, selectedMonth.value);

      if (response['success'] == true) {
        List newItems = response['history'];
        if (newItems.isEmpty) {
          hasMoreData.value = false;
        } else {
          historyList.addAll(newItems);
          currentPage.value = nextPage;
          if (newItems.length < 15) hasMoreData.value = false;
        }
      }
    } finally {
      isMoreLoading(false);
    }
  }
}
