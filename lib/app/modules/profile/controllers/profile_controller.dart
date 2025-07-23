import 'package:get/get.dart';
import 'package:mobile/app/data/models/user.dart';
import 'package:mobile/app/data/services/auth_services.dart';
import 'package:mobile/app/routes/app_pages.dart';
import 'package:flutter/material.dart';

class ProfileController extends GetxController {
  final AuthService _authService;
  ProfileController({required AuthService authService})
      : _authService = authService;

  var user = UserModel(
    name: "Loading...",
    profileImage: "",
    level: 0,
    history: [],
    email: "",
    points: 0,
  ).obs;

  @override
  void onInit() {
    fetchUser();
    super.onInit();
  }

  void fetchUser() async {
    final userData = await _authService.fetchUserProfile();
    if (userData != null && userData.containsKey('user')) {
      try {
        user.value = UserModel.fromMap(userData['user']);
      } catch (e) {
        print("❌ Failed to parse user data: $e");
      }
    } else {
      print("⚠️ Failed to fetch user data or user key missing.");
    }
  }

  void logout() async {
    final result = await _authService.logout();
    if (result['success']) {
      Get.snackbar('Berhasil', 'Logout berhasil');
      Get.offAllNamed(Routes.LOGIN);
    } else {
      Get.snackbar('Gagal', result['message']);
    }
  }

  // Helper
  void showLoading() {
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );
  }

  void hideLoading() {
    if (Get.isDialogOpen ?? false) Get.back();
  }

  void deleteAccount() async {
    showLoading();
    final result = await _authService.deleteUser();
    hideLoading();

    if (result['success']) {
      Get.snackbar('Sukses', 'Akun berhasil dihapus');
      Get.offAllNamed(Routes.LOGIN);
    } else {
      Get.snackbar('Gagal', result['message']);
    }
  }
}
