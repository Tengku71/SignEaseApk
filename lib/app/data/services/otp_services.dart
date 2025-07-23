import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/app/data/services/api_config.dart';

class OtpService {
  static final GetStorage _storage = GetStorage();

  static Future<Map<String, dynamic>> verifyOtp(
      String email, String otp) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/verify_otp');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'otp': otp}),
    );

    final body = jsonDecode(response.body);

    // If token is returned, store it
    if (response.statusCode == 200 && body['token'] != null) {
      await _storage.write('token', body['token']);
    }

    if ([200, 400, 404].contains(response.statusCode)) {
      return body;
    } else {
      throw Exception('Failed to verify OTP');
    }
  }

  static Future<Map<String, dynamic>> resendOtp(String email) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/resend_otp');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    final body = jsonDecode(response.body);

    if ([200, 400, 404].contains(response.statusCode)) {
      return body;
    } else {
      throw Exception('Failed to resend OTP');
    }
  }
}
