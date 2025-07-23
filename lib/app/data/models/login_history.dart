// login_history_model.dart
class LoginHistory {
  final String email;
  final String timestamp;
  final String ipAddress;
  final String userAgent;

  LoginHistory({
    required this.email,
    required this.timestamp,
    required this.ipAddress,
    required this.userAgent,
  });

  factory LoginHistory.fromJson(Map<String, dynamic> json) {
    return LoginHistory(
      email: json['email'] ?? '',
      timestamp: json['timestamp'] ?? '',
      ipAddress: json['ip_address'] ?? '',
      userAgent: json['user_agent'] ?? '',
    );
  }
}
