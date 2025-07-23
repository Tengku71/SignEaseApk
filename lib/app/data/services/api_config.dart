class ApiConfig {
  static const String baseUrl = 'https://signease.tengkudimas.my.id';
  // static const String baseUrl =
  // 'https://1027-2404-8000-1013-36-d921-9483-960a-4c01.ngrok-free.app';

  // You can add more endpoints if needed
  static String loginUrl() => '$baseUrl/login_u';
  static String registerUrl() => '$baseUrl/register';
  static String logout() => '$baseUrl/logout_u';
  static String getUser() => '$baseUrl/get_user';
  static String googleLoginUrl() => '$baseUrl/api/login-google';
  static String generateOtp() => '$baseUrl/generate_otp';
  static String verifyToken() => '$baseUrl/verify-token';
  static String submitScore() => '$baseUrl/api/score';
  static String getQuizQuestion() => '$baseUrl/api/questions';
  static String getUserProgressAPI() => '$baseUrl/api/user/progress';
  static String getQuizAttemptsAPI() => '$baseUrl/api/attempts';
  static String getLeaderboard() => '$baseUrl/user/leaderboard';
  static String getLoginHistory() => '$baseUrl/login_history_user';
  static String resetPassword() => '$baseUrl/request-reset';
  static String editUser() => '$baseUrl/edit_user';
  static String deleteUser() => '$baseUrl/delete_user';
  // etc.
}
