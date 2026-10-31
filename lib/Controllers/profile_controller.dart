import 'package:ami_student/Controllers/auth_controller.dart';
import 'package:ami_student/Models/user_model.dart';
import 'package:ami_student/services/profile_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:ami_student/services/socket_service.dart';

class ProfileController extends GetxController with WidgetsBindingObserver {
  final GetStorage box = GetStorage();
  final UserService _userService = UserService();

  // ============================================================
  // PROFILE LOADING
  // ============================================================

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // ============================================================
  // FEEDBACK LOADING
  // ============================================================

  final RxBool isFeedbackLoading = false.obs;

  // ============================================================
  // GUEST USER
  // ============================================================

  final User _guestUser = User(
    gender: " ",
    id: '',
    name: 'Guest',
    email: '',
    enrollmentNo: '',
    course: '',
    year: '',
    phonenumber: '',
    hostelblock: '',
    room: '',
    isApproved: false,
    accessExpiresAt: null,
  );

  late final Rx<User> user;

  // ============================================================
  // SUBSCRIPTION
  // ============================================================

  bool get isSubscriptionActive {
    if (user.value.name == 'Guest') {
      return false;
    }

    if (user.value.isApproved && user.value.accessExpiresAt != null) {
      return user.value.accessExpiresAt!
          .add(const Duration(minutes: 1))
          .isAfter(DateTime.now());
    }

    return false;
  }

  // ============================================================
  // INIT
  // ============================================================

  @override
  void onInit() {
    super.onInit();

    WidgetsBinding.instance.addObserver(this);

    user = _guestUser.obs;

    loadUserProfileFromStorage();

    box.listenKey('user_data', (storedValue) {
      if (isClosed) return;

      if (storedValue != null) {
        loadUserProfileFromStorage();
      } else {
        user.value = _guestUser;
      }
    });

    SocketService.instance.connectAndListen();
  }

  // ============================================================
  // READY
  // ============================================================

  @override
  void onReady() {
    super.onReady();
    fetchUserProfile(showLoading: false);
  }

  // ============================================================
  // APP LIFECYCLE
  // ============================================================

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (isClosed) return;

      debugPrint(
        'App Resumed: Forcing silent data sync with server...',
      );

      fetchUserProfile(showLoading: false);
      SocketService.instance.connectAndListen();
    }
  }

  // ============================================================
  // CLOSE
  // ============================================================

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  // ============================================================
  // LOAD USER FROM STORAGE
  // ============================================================

  void loadUserProfileFromStorage() {
    if (isClosed) return;

    try {
      final dynamic storedData = box.read('user_data');

      if (storedData is Map && storedData.isNotEmpty) {
        final Map<String, dynamic> userData =
            Map<String, dynamic>.from(storedData);

        final dynamic actualUser = userData.containsKey('user')
            ? userData['user']
            : userData;

        if (actualUser is Map) {
          user.value = User.fromJson(
            Map<String, dynamic>.from(actualUser),
          );
        } else {
          user.value = _guestUser;
        }
      } else {
        user.value = _guestUser;
      }
    } catch (e) {
      debugPrint('❌ Failed to load profile from storage: $e');

      if (!isClosed) {
        user.value = _guestUser;
      }
    }
  }

  // ============================================================
  // SOCKET APPROVAL UPDATE
  // ============================================================

  void updateApprovalStatusFromSocket(dynamic data) {
    if (isClosed || data == null) return;

    try {
      final bool newStatus = data['isApproved'] ?? false;
      final String? newExpiryStr = data['accessExpiresAt'];

      DateTime? newExpiry;
      if (newExpiryStr != null && newExpiryStr.isNotEmpty) {
        newExpiry = DateTime.tryParse(newExpiryStr);
      }

      user.update((val) {
        if (val == null) return;
        val.isApproved = newStatus;
        val.accessExpiresAt = newExpiry;
      });

      final dynamic storedValue = box.read('user_data');

      if (storedValue is Map) {
        final Map<String, dynamic> storedUserData =
            Map<String, dynamic>.from(storedValue);

        if (storedUserData['user'] is Map) {
          final Map<String, dynamic> nestedUser =
              Map<String, dynamic>.from(storedUserData['user']);

          nestedUser['isApproved'] = newStatus;
          nestedUser['accessExpiresAt'] = newExpiryStr;

          storedUserData['user'] = nestedUser;
        } else {
          storedUserData['isApproved'] = newStatus;
          storedUserData['accessExpiresAt'] = newExpiryStr;
        }

        box.write('user_data', storedUserData);
      }

      Get.snackbar(
        'Access Updated',
        newStatus ? 'Mess access granted!' : 'Access revoked.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: newStatus ? Colors.green : Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    } catch (e) {
      debugPrint('❌ Socket approval update error: $e');
    }
  }

  // ============================================================
  // FETCH PROFILE
  // ============================================================

  Future<void> fetchUserProfile({bool showLoading = true}) async {
    if (isClosed) return;

    try {
      if (showLoading) {
        isLoading.value = true;
      }

      errorMessage.value = '';

      final User fetchedUser = await _userService.fetchUserProfile();

      if (isClosed) return;

      user.value = fetchedUser;

      final dynamic existingData = box.read('user_data');
      final Map<String, dynamic> storedUserData = existingData is Map
          ? Map<String, dynamic>.from(existingData)
          : <String, dynamic>{};

      storedUserData['user'] = fetchedUser.toJson();

      await box.write('user_data', storedUserData);

      debugPrint('✅ Profile auto-synced with Server.');
    } catch (e) {
      if (isClosed) return;

      final String errorMsg =
          e.toString().replaceFirst('Exception: ', '');

      if (showLoading) {
        errorMessage.value = errorMsg;

        Get.snackbar(
          'Sync Error',
          errorMsg,
          snackPosition: SnackPosition.BOTTOM,
        );
      }

      debugPrint('❌ Background sync failed: $e');
    } finally {
      if (!isClosed && showLoading) {
        isLoading.value = false;
      }
    }
  }

  // ============================================================
  // SEND FEEDBACK
  // ============================================================

  Future<bool> sendFeedback(int rating, String message) async {
    if (isFeedbackLoading.value) {
      return false;
    }

    try {
      isFeedbackLoading.value = true;

      final String cleanMessage = message.trim();

      final bool success = await _userService.submitFeedback(
        rating,
        cleanMessage,
      );

      if (success) {
        // Trigger snackbar after current frame to prevent dialog dismissal conflicts
        Future.delayed(const Duration(milliseconds: 150), () {
          Get.snackbar(
            'Thank You!',
            'Your feedback has been submitted successfully.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFF669447),
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
            margin: const EdgeInsets.all(12),
            borderRadius: 12,
          );
        });

        return true;
      }

      return false;
    } catch (e) {
      final String errorMsg =
          e.toString().replaceFirst('Exception: ', '');

      Get.snackbar(
        'Feedback Error',
        errorMsg,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(12),
        borderRadius: 12,
      );

      return false;
    } finally {
      if (!isClosed) {
        isFeedbackLoading.value = false;
      }
    }
  }

  // ============================================================
  // DELETE ACCOUNT
  // ============================================================

  Future<void> deleteAccount() async {
    if (isLoading.value) return;

    try {
      isLoading.value = true;

      final bool isDeleted = await _userService.deleteAccount();

      if (isClosed) return;

      if (isDeleted) {
        await box.remove('user_data');
        await box.remove('token');

        if (Get.isRegistered<SignupController>()) {
          Get.find<SignupController>().logout();
        }

        Get.snackbar(
          'Account Deleted',
          'Your account and personal data have been permanently deleted.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.black87,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(12),
          borderRadius: 12,
        );
      }
    } catch (e) {
      if (isClosed) return;

      final String errorMsg =
          e.toString().replaceFirst('Exception: ', '');

      Get.snackbar(
        'Deletion Error',
        errorMsg,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(12),
        borderRadius: 12,
      );
    } finally {
      if (!isClosed) {
        isLoading.value = false;
      }
    }
  }
}