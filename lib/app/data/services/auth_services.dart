import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mobile/app/data/models/leaderboard.dart';
import 'package:mobile/app/data/models/login_history.dart';
import 'dart:convert';

import 'api_config.dart';

class AuthService {
  final GetStorage _storage = GetStorage();
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile', 'openid'],
    serverClientId:
        '941760787235-rpq7omdh2e0651jrpf8upiqj4r42lpm3.apps.googleusercontent.com',
  );

  Future<GoogleSignInAccount?> getLastSignedInGoogleUser() async {
    return _googleSignIn.currentUser ?? await _googleSignIn.signInSilently();
  }

  /// Save user object to local storage
  Future<void> saveUserToStorage(Map<String, dynamic> user) async {
    await _storage.write('user', user);
  }

  /// Get saved user object
  Map<String, dynamic>? getUser() => _storage.read('user');

  /// Get JWT token
  String? getToken() => _storage.read('token');

  /// Email/Password Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.loginUrl()),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final body = jsonDecode(response.body);

      if (response.statusCode == 200 && body['token'] != null) {
        await _storage.write('token', body['token']);
        if (body.containsKey('user')) {
          await saveUserToStorage(body['user']);
        }
        return {'success': true, 'data': body};
      } else if (body['message'] == 'otp' && body.containsKey('email')) {
        return {
          'success': false,
          'message': 'otp',
          'email': body['email'],
        };
      } else {
        return {'success': false, 'message': body['error']};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  /// Google Sign-In Login
  Future<Map<String, dynamic>> loginWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return {'success': false, 'message': 'User cancelled sign-in'};
      }

      final googleAuth = await googleUser.authentication;

      final response = await http.post(
        Uri.parse(ApiConfig.googleLoginUrl()),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'idToken': googleAuth.idToken}),
      );

      final body = jsonDecode(response.body);

      if (response.statusCode == 200 && body['token'] != null) {
        await _storage.write('token', body['token']);
        if (body.containsKey('user')) {
          await saveUserToStorage(body['user']);
        }
        return {'success': true, 'data': body};
      } else {
        return {
          'success': false,
          'data': body,
          'message': body['message'] ?? 'Login Google gagal'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Google login error: $e'};
    }
  }

  Future<bool> verifyToken(String token) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.verifyToken()),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['message'] == 'Token is valid';
      } else {
        print('Token check failed: ${response.body}');
      }
    } catch (e) {
      print('Token verification error: $e');
    }
    return false;
  }

  /// Register user
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String gender,
    required String birthDate,
    required String address,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.registerUrl()),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nama': name,
          'email': email,
          'jeniskelamin': gender,
          'tanggal_lahir': birthDate,
          'alamat': address,
          'password': password,
          'confirmpassword': confirmPassword,
        }),
      );

      final body = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {'success': true, 'message': 'Registrasi berhasil'};
      } else if (body.toString().contains('err1')) {
        return {
          'success': false,
          'message': 'Password dan konfirmasi tidak cocok'
        };
      } else if (body.toString().contains('err2')) {
        return {
          'success': false,
          'message': 'Password harus lebih dari 6 karakter'
        };
      } else if (body.toString().contains('err3')) {
        return {'success': false, 'message': 'Email sudah terdaftar'};
      } else {
        return {'success': false, 'message': 'Registrasi gagal'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  Future<void> editUser({
    required String name,
    required String email,
    required String profileImage,
    String? password,
    String? confirmPassword,
  }) async {
    final token = await getToken();
    final response = await http.put(
      Uri.parse(ApiConfig.editUser()),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'nama': name,
        'email': email,
        'profileImage': profileImage,
        if (password != null) 'password': password,
        if (confirmPassword != null) 'confirmpassword': confirmPassword,
      }),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode != 200) {
      throw Exception(data['error'] ?? 'Gagal update user');
    }
  }

  /// Logout
  Future<Map<String, dynamic>> logout() async {
    try {
      final token = getToken();
      await _googleSignIn.signOut();

      if (token == null) {
        return {'success': false, 'message': 'Token tidak tersedia'};
      }

      final response = await http.get(
        Uri.parse(ApiConfig.logout()),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
      );

      _storage.remove('token');
      _storage.remove('user');

      if (response.statusCode == 200) {
        return {'success': true};
      } else {
        final body = jsonDecode(response.body);
        return {'success': false, 'message': body['message'] ?? 'Logout gagal'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Logout error: $e'};
    }
  }

  Future<void> submitScore(int remainingSeconds) async {
    final token = await getToken();
    if (token == null) throw ("Token not found");

    final url = Uri.parse(ApiConfig.submitScore());
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'remaining_seconds': remainingSeconds,
      }),
    );

    if (response.statusCode != 200) {
      throw ('Failed to submit score: ${response.body}');
    }
  }

  Future<Map<String, dynamic>?> fetchUserProfile() async {
    final token = getToken(); // Ambil token JWT yang tersimpan
    if (token == null) {
      return null;
    }

    final response = await http.get(
      Uri.parse(ApiConfig.getUser()), // Endpoint get user
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // print("🛰️ USER PROFILE DARI API: $data");

      if (data is Map<String, dynamic> && data.containsKey('user')) {
        final user = data['user'];
        // print("✅ USER DETAIL: $user");

        // Simpan ulang ke local storage kalau perlu
        await saveUserToStorage(user);
      }

      return data;
    } else {
      print('❌ Failed to fetch user: ${response.statusCode}');
      print('📦 Body: ${response.body}');
      return null;
    }
  }

  Future<List<String>> getQuestionsByLevel(int level) async {
    final token = await getToken();
    if (token == null) throw ("Token tidak ditemukan");

    final url = Uri.parse("${ApiConfig.getQuizQuestion()}/$level");
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['questions'] as List).cast<String>();
    } else if (response.statusCode == 401) {
      logout();
      throw ("Unauthorized: Token expired");
    } else if (response.statusCode == 403) {
      final data = json.decode(response.body);
      print(data);
      // lempar sebagai  biasa
      throw (data['message'] ?? "Limit attempt tercapai");
    } else {
      throw ("Gagal mengambil soal (${response.statusCode})");
    }
  }

  Future<void> sendProgress(String level) async {
    final token = await getToken();
    if (token == null) throw ("Token tidak ditemukan");

    final url = Uri.parse(ApiConfig.getUserProgressAPI());

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({"level": level}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw ("Gagal mengirim progress: ${data['message'] ?? 'Unknown error'}");
    }

    /// ✅ Ambil data terbaru dan simpan ke storage
    final updatedUser = await fetchUserProfile();
    if (updatedUser != null) {
      await saveUserToStorage(updatedUser);
      print("✅ USER LEVEL UPDATED: ${updatedUser}");
    }

    // if (data['status'] == 'success' || data['status'] == 'info') {
    //   Get.snackbar("Info", data['message']);
    // }
  }

  Future<List<Map<String, dynamic>>> getProgress() async {
    final token = await getToken();
    if (token == null) throw ("Token tidak ditemukan");

    final url = Uri.parse(ApiConfig.getUserProgressAPI());

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw ("Gagal mengambil progress (${response.statusCode})");
    }

    final data = jsonDecode(response.body);
    return List<Map<String, dynamic>>.from(data['progress'] ?? []);
  }

  Future<List<Map<String, dynamic>>> getQuestionAttempts() async {
    final token = await getToken(); // ✅ Tambah await
    if (token == null) throw ("Token tidak ditemukan");

    final url = Uri.parse(ApiConfig.getQuizAttemptsAPI());
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw ("Gagal mengambil histori attempt (${response.statusCode})");
    }

    final data = jsonDecode(response.body);
    if (data['attempts'] is! List) {
      throw ("Format data 'attempts' tidak valid");
    }

    return List<Map<String, dynamic>>.from(data['attempts']);
  }

  Future<List<UserLeaderboard>> fetchLeaderboard() async {
    try {
      final token = getToken(); // Ambil token JWT

      final response = await http.get(
        Uri.parse(ApiConfig.getLeaderboard()),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<UserLeaderboard>.from(
          data.map((item) => UserLeaderboard.fromJson(item)),
        );
      } else {
        throw ('Failed to load leaderboard');
      }
    } catch (e) {
      throw ('Error: $e');
    }
  }

  Future<List<LoginHistory>> getLoginHistory() async {
    try {
      final token = getToken(); // Ambil token JWT

      final response = await http.get(
        Uri.parse(ApiConfig.getLoginHistory()),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> historyList = data['login_history'];

        return historyList.map((item) => LoginHistory.fromJson(item)).toList();
      } else {
        throw ('Failed to load login history');
      }
    } catch (e) {
      throw ('Error: $e');
    }
  }

  Future<String> requestPasswordReset(String email) async {
    final url = Uri.parse(ApiConfig.resetPassword());

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'email': email},
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['status'] == 'success') {
        return data['message'];
      } else {
        throw (data['message'] ?? 'Gagal mengirim permintaan');
      }
    } catch (e) {
      throw ('Terjadi kesalahan: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> deleteUser() async {
    try {
      final token = await getToken(); // Ambil token dari storage
      final response = await http.delete(
        Uri.parse(ApiConfig.deleteUser()), // Ganti dengan endpoint kamu
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        await _storage.remove('token'); // Hapus token dari storage
        return {'success': true};
      } else {
        final body = jsonDecode(response.body);
        return {
          'success': false,
          'message': body['error'] ?? 'Gagal menghapus akun'
        };
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}
