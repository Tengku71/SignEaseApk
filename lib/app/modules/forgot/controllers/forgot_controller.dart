import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/services/auth_services.dart';

class ForgotController extends GetxController {
  final emailController = TextEditingController();
  final isLoading = false.obs;

  void sendResetLink() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      Get.snackbar('Error', 'Email tidak boleh kosong',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    isLoading.value = true;

    try {
      final message = await AuthService().requestPasswordReset(email);
      Get.snackbar('Sukses', message,
          backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Gagal', e.toString(),
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }
}
