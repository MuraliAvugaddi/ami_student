class ApiEndpoints {
  // ============================================================
  // SERVER CONFIGURATION
  // ============================================================

  // 🔹 Local Development (Mac IP on Wi-Fi) — uncomment for local testing
  // static const String serverUrl = 'http://192.168.1.33:5002';

  // 🔹 Production Render URL — ACTIVE
  static const String serverUrl = 'https://ami-backend-v1.onrender.com';

  // ============================================================
  // API BASE URL
  // ============================================================

  static const String baseUrl = '$serverUrl/api';

  // ============================================================
  // SOCKET.IO URL
  // ============================================================

  static const String socketUrl = serverUrl;

  // ============================================================
  // AUTH ENDPOINTS
  // ============================================================

  static const String authBaseUrl = '$baseUrl/auth';

  static const String signupStep1 = '$authBaseUrl/signup/1';

  static const String verifyOtp = '$authBaseUrl/signup/verify-otp';

  static const String signupStep2 = '$authBaseUrl/signup/2';

  static const String signinpage = '$authBaseUrl/signin';

  // ============================================================
  // PROFILE ENDPOINTS
  // ============================================================

  static const String userProfile = '$baseUrl/profile';

  // ============================================================
  // FEEDBACK ENDPOINT
  // ============================================================

  // POST /api/feedback
  static const String feedbackSubmit = '$baseUrl/feedback';

  static const String feedback = '$baseUrl/feedback';

  // ============================================================
  // MENU ENDPOINTS
  // ============================================================

  static const String menuActive = '$baseUrl/menu/active';

  static const String adminUploadMenu = '$baseUrl/admin/menu/upload';

  // ============================================================
  // TOKEN ENDPOINTS
  // ============================================================

  static const String tokenBaseUrl = '$baseUrl/tokens';

  static const String generateToken = '$tokenBaseUrl/generate';

  static const String todayStats = '$tokenBaseUrl/stats/today';

  // ============================================================
  // SKIP ENDPOINTS
  // ============================================================

  static const String skipToggle = '$baseUrl/skip/toggle';

  static const String skipCheck = '$baseUrl/skip/check';

  // ============================================================
  // PASSWORD RESET ENDPOINTS
  // ============================================================

  static const String forgotPassword = '$authBaseUrl/forgot-password';

  static const String resetPassword = '$authBaseUrl/reset-password';

  // ============================================================
  // MESS FEE — UPI QR + SCREENSHOT UPLOAD
  // ============================================================

  static const String paymentConfig = '$baseUrl/payments/config';

  static const String paymentSubmit = '$baseUrl/payments/submit';

  static const String paymentSubmissions = '$baseUrl/payments/my-submissions';

  static const String paymentReceipts = '$baseUrl/payments/my-receipts';

  // ============================================================
  // APP UPDATE CHECK
  // ============================================================

  static const String appVersion = '$baseUrl/app-version';

  // ============================================================
  // HOSTEL — ROOM COMPLAINTS, SOS, NOTIFICATIONS
  // ============================================================

  static const String complaints = '$baseUrl/complaints';

  static const String myComplaints = '$baseUrl/complaints/mine';

  static String complaintById(String id) => '$baseUrl/complaints/$id';

  static String confirmComplaint(String id) =>
      '$baseUrl/complaints/$id/confirm';

  static const String sos = '$baseUrl/sos';

  static const String mySos = '$baseUrl/sos/mine';

  static const String hostelNotifications = '$baseUrl/hostel-notifications';

  static const String hostelNotificationsReadAll =
      '$baseUrl/hostel-notifications/read-all';
}