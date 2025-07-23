import 'package:get/get.dart';
import 'package:mobile/app/data/services/auth_services.dart';
import 'package:intl/intl.dart';
import 'package:mobile/app/routes/app_pages.dart'; // Ensure this is imported

class RegisterController extends GetxController {
  final AuthService _authService = AuthService();

  var name = ''.obs;
  var birthDate = Rxn<DateTime>();
  var gender = ''.obs;
  var email = ''.obs;
  var address = ''.obs;
  var password = ''.obs;
  var confirmPassword = ''.obs;
  var isLoading = false.obs; // Add this

  void updateConfirmPassword(String value) {
    confirmPassword.value = value;
  }

  void register() async {
    if (name.value.isEmpty ||
        birthDate.value == null ||
        gender.value.isEmpty ||
        email.value.isEmpty ||
        address.value.isEmpty ||
        password.value.isEmpty ||
        confirmPassword.value.isEmpty) {
      Get.snackbar('Error', 'Semua field harus diisi!');
    } else if (!GetUtils.isEmail(email.value)) {
      Get.snackbar('Error', 'Email tidak valid!');
    } else {
      isLoading.value = true; // Start loading
      final formattedDate = DateFormat('yyyy-MM-dd').format(birthDate.value!);

      try {
        final result = await _authService.register(
          name: name.value,
          email: email.value,
          gender: gender.value,
          birthDate: formattedDate,
          address: address.value,
          password: password.value,
          confirmPassword: confirmPassword.value,
        );

        if (result['success']) {
          Get.snackbar('Sukses', result['message']);
          // Navigate to OTP page
          Get.toNamed(Routes.OTP, arguments: {"email": email.value});
        } else {
          Get.snackbar('Error', result['message']);
        }
      } catch (e) {
        Get.snackbar('Error', 'Terjadi kesalahan saat registrasi.');
      } finally {
        isLoading.value = false; // Stop loading
      }
    }
  }
}
