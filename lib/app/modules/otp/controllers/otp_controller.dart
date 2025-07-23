import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/app/data/services/otp_services.dart';
import 'package:mobile/app/routes/app_pages.dart';

class OtpController extends GetxController {
  final otp1 = TextEditingController();
  final otp2 = TextEditingController();
  final otp3 = TextEditingController();
  final otp4 = TextEditingController();
  final email = ''.obs; // Bind this from previous screen

  RxInt remainingSeconds = 300.obs; // 5 minutes = 300 seconds
  RxBool canResend = false.obs;
  Timer? _timer;
  final isLoading = false.obs;

  @override
  void onInit() {
    email.value = Get.arguments['email'];
    super.onInit();
    startCountdown();
  }

  void startCountdown() {
    canResend.value = false;
    remainingSeconds.value = 300;
    _timer?.cancel(); // Cancel any existing timer

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds.value > 0) {
        remainingSeconds.value--;
      } else {
        canResend.value = true;
        timer.cancel();
      }
    });
  }

  void resendOtp() async {
    final email = Get.arguments['email'];
    try {
      final result = await OtpService.resendOtp(email);
      if (result['success']) {
        Get.snackbar('OTP Dikirim Ulang', 'Silakan periksa email Anda');
        startCountdown(); // restart countdown
      } else {
        Get.snackbar('Gagal', result['message'] ?? 'Gagal mengirim ulang OTP');
      }
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan: $e');
    }
  }

  void verifyOtp() async {
    final otp = otp1.text + otp2.text + otp3.text + otp4.text;

    if (otp.length != 4) {
      Get.snackbar("Error", "Masukkan OTP lengkap!");
      return;
    }

    isLoading.value = true;
    try {
      final response = await OtpService.verifyOtp(email.value, otp);
      if (response['status'] == 'success') {
        Get.snackbar("Berhasil", response['message']);
        Get.toNamed(Routes.HOME);
      } else {
        Get.snackbar("Gagal", response['message']);
      }
    } catch (e) {
      Get.snackbar("Error", "Terjadi kesalahan saat verifikasi.");
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    otp1.dispose();
    otp2.dispose();
    otp3.dispose();
    otp4.dispose();
    _timer?.cancel();
    super.onClose();
  }
}
