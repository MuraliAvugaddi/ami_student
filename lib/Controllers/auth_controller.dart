import 'package:ami_student/Screens/Navigation_bar/new_main_screen.dart';
import 'package:ami_student/Controllers/hostel_controller.dart';
import 'package:ami_student/Screens/auth/onbording_screen.dart';
import 'package:ami_student/Screens/auth/signup_page2_screen.dart';
import 'package:ami_student/Screens/auth/signin_screen.dart'; // ✅ Imported SigninScreen
import 'package:ami_student/Screens/otp_verification_screen.dart';
import 'package:ami_student/services/auth_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:ami_student/services/socket_service.dart';

class SignupController extends GetxController {
  final AuthService _authService = AuthService();
  final box = GetStorage();
  var isLoading = false.obs;

  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late TextEditingController otpController;
  late TextEditingController enrollmentNoController;
  late TextEditingController courseController;
  late TextEditingController yearController;
  late TextEditingController phoneController;
  late TextEditingController hostelBlockController;
  late TextEditingController roomController;

  // ✅ Reset Password Field Controller
  late TextEditingController resetNewPasswordController;

  var selectedGender = Rxn<String>();

  @override
  void onInit() {
    super.onInit();
    nameController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    otpController = TextEditingController();
    enrollmentNoController = TextEditingController();
    courseController = TextEditingController();
    yearController = TextEditingController();
    phoneController = TextEditingController();
    hostelBlockController = TextEditingController();
    roomController = TextEditingController();

    // ✅ Initialize Reset Field Controller
    resetNewPasswordController = TextEditingController();
  }

  void registerStep1() async {
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        phoneController.text.isEmpty) {
      Get.snackbar('Error', 'Please fill in all basic details',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    try {
      isLoading(true);
      await _authService.checkEmailAvailability(emailController.text.trim());
      Get.to(() => OtpVerificationScreen());
    } catch (e) {
      Get.snackbar('Error', e.toString().replaceAll('Exception: ', ''),
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading(false);
    }
  }

  void verifyOtpAndProceed() async {
    if (otpController.text.trim().isEmpty ||
        otpController.text.trim().length < 6) {
      Get.snackbar('Error', 'Please enter the 6-digit verification code.',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    try {
      isLoading(true);
      final success = await _authService.verifyOtp(
          emailController.text.trim(), otpController.text.trim());

      if (success) {
        Get.to(() => SignupPage2());
      }
    } catch (e) {
      Get.snackbar(
          'Verification Error', e.toString().replaceAll('Exception: ', ''),
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading(false);
    }
  }

  void registerStep2() async {
    // Check that all mandatory fields are filled out
    if (enrollmentNoController.text.trim().isEmpty ||
        courseController.text.trim().isEmpty ||
        yearController.text.trim().isEmpty ||
        phoneController.text.trim().isEmpty ||
        hostelBlockController.text.trim().isEmpty ||
        roomController.text.trim().isEmpty ||
        selectedGender.value == null ||
        selectedGender.value!.isEmpty) {
      Get.snackbar(
          'Error', 'Please fill in all text fields and select your gender.',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    // ✅ Updated validation: Ensuring enrollment number has at least 7 characters (change to your precise rule if needed)
    if (enrollmentNoController.text.trim().length < 7) {
      Get.snackbar(
          'Error', 'Enrollment number must be at least 7 characters long.',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    try {
      isLoading(true);
      final response = await _authService.registerUser(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        enrollmentNo: enrollmentNoController.text.trim(),
        course: courseController.text.trim(),
        year: yearController.text.trim(),
        phonenumber: phoneController.text.trim(),
        hostelblock: hostelBlockController.text.trim(),
        room: roomController.text.trim(),
        gender: selectedGender.value!,
      );

      await box.write('token', response['token']);
      await box.write('user_data', response['user']);

      SocketService.instance.connectAndListen();
      Get.offAll(() => const MainScreen());
    } catch (e) {
      Get.snackbar(
          'Registration Error', e.toString().replaceAll('Exception: ', ''),
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading(false);
    }
  }

  void signInScreen() async {
    try {
      isLoading.value = true;
      final responseData = await AuthService.signin(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      await box.write('token', responseData['token']);
      await box.write('user_data', responseData['user']);

      SocketService.instance.connectAndListen();
      clearController();
      Get.offAll(() => const MainScreen());
    } catch (e) {
      Get.snackbar(
        'Login Failed',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void sendResetCode(String email) async {
    if (email.isEmpty) {
      Get.snackbar('Error', 'Please enter your email address.',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    try {
      isLoading(true);
      await _authService.requestPasswordReset(email.trim());
      Get.snackbar('Success', 'Verification code sent to your email.',
          backgroundColor: Colors.green, colorText: Colors.white);

      emailController.text = email;

      Get.to(() => OtpVerificationScreen(isForgotPassword: true));
    } catch (e) {
      Get.snackbar('Error', e.toString().replaceAll('Exception: ', ''),
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading(false);
    }
  }

  void submitNewPassword(String email, String otp, String newPassword) async {
    final cleanEmail = email.trim();
    final cleanOtp = otp.trim();
    final cleanPassword = newPassword.trim();

    if (cleanEmail.isEmpty || cleanOtp.isEmpty || cleanPassword.isEmpty) {
      Get.snackbar('Error', 'All fields are required.',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    try {
      isLoading(true);
      await _authService.finalizePasswordReset(
          cleanEmail, cleanOtp, cleanPassword);

      Get.snackbar(
        'Success',
        'Password updated successfully! Please sign in with your new credentials.',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );

      clearController();
      resetNewPasswordController.clear();

      // ✅ FIXED ROUTE SYNTAX: Clears recovery stacks and moves directly to the SigninScreen widget layout cleanly
      Get.offAll(SigninScreen());
    } catch (e) {
      Get.snackbar('Error', e.toString().replaceAll('Exception: ', ''),
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading(false);
    }
  }

  void logout() {
    SocketService.instance.disconnect();
    // ✅ Hostel data belongs to this student only
    if (Get.isRegistered<HostelController>()) Get.delete<HostelController>(force: true);
    box.remove('token');
    box.remove('user_data');
    Get.offAll(() => OnboardingScreen());
  }

  void clearController() {
    emailController.clear();
    passwordController.clear();
    otpController.clear();
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    otpController.dispose();
    enrollmentNoController.dispose();
    courseController.dispose();
    yearController.dispose();
    phoneController.dispose();
    hostelBlockController.dispose();
    roomController.dispose();

    resetNewPasswordController.dispose();
    super.onClose();
  }
}
