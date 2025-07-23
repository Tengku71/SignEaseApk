import 'package:get/get.dart';
import 'package:mobile/app/data/services/auth_services.dart';
import 'package:mobile/app/routes/app_pages.dart';

class LoginController extends GetxController {
  var email = ''.obs;
  var password = ''.obs;
  var isLoading = false.obs;

  final AuthService _authService;

  LoginController({required AuthService authService})
      : _authService = authService;

  void updateEmail(String value) => email.value = value;
  void updatePassword(String value) => password.value = value;

  void login() async {
    if (email.value.isEmpty) {
      Get.snackbar('Error', 'Email tidak boleh kosong!');
      return;
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email.value)) {
      Get.snackbar('Error', 'Format email tidak valid!');
      return;
    }
    if (password.value.isEmpty) {
      Get.snackbar('Error', 'Password tidak boleh kosong!');
      return;
    }

    isLoading.value = true;
    final result = await _authService.login(email.value, password.value);
    isLoading.value = false;

    final message = result['message'] ?? '';

    if (message == 'otp') {
      final email = result['email'] ?? '';
      Get.snackbar('Verifikasi Diperlukan',
          'Silakan masukkan OTP yang dikirim ke email');
      Get.toNamed(Routes.OTP, arguments: {'email': email});
    } else if (result['success'] == true) {
      Get.snackbar('Berhasil', 'Login berhasil');
      Get.offAllNamed(Routes.HOME);
    } else {
      // Get.snackbar('Gagal', message.isNotEmpty ? message : 'Login gagal');
      Get.snackbar('Gagal', message);
    }
  }

  void loginWithGoogle() async {
    isLoading.value = true;
    final result = await _authService.loginWithGoogle();
    isLoading.value = false;

    final message = result['message'];
    final data = result['data'];

    if (message == 'otp') {
      final email = data?['email'] ?? '';
      Get.snackbar('Verifikasi Diperlukan',
          'Silakan masukkan OTP yang dikirim ke email');
      Get.toNamed(Routes.OTP, arguments: {'email': email});
    } else if (result['success']) {
      Get.snackbar('Berhasil', 'Login Google berhasil');
      Get.offAllNamed(Routes.HOME);
    } else {
      Get.snackbar('Gagal', message ?? 'Login gagal');
    }
  }
}
