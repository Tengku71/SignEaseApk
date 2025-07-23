import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/app/data/models/user.dart';
import 'package:mobile/app/data/services/auth_services.dart';
import 'package:mobile/app/routes/app_pages.dart';

class HomeController extends GetxController {
  final user = UserModel(
    name: '',
    profileImage: '',
    level: 0,
    history: [],
    email: '',
    points: 0,
    authType: '',
  ).obs;

  final isLoading = false.obs;
  final AuthService _authService = AuthService();
  var selectedIndex = 0.obs;
  var searchController = TextEditingController();
  var filteredPages = <Map<String, dynamic>>[].obs;
  var searchText = ''.obs;

  final List<Map<String, dynamic>> pages = [
    {'title': 'Home', 'route': Routes.HOME},
    {'title': 'Profile', 'route': Routes.PROFILE},
    {'title': 'Quizz Level', 'route': Routes.QUIZZ_LEVEL},
    {'title': 'Quizz Timer', 'route': Routes.QUIZZ_TIMER},
    {'title': 'Leaderboard', 'route': Routes.LEADERBOARD},
    {'title': 'Edukasi', 'route': Routes.EDUKASI},
    {'title': 'Transcribe', 'route': Routes.TRANSCRIBE},
    {'title': 'Informasi', 'route': Routes.WEBVIEW},
    {'title': 'Histori Login', 'route': Routes.LOGIN_HISTORY},
    {'title': 'HIstori Quizz', 'route': Routes.HISTORY_QUIZ},
  ];

  Future<void> refreshUser() async {
    await fetchUser();
  }

  Future<void> fetchUser() async {
    isLoading.value = true;
    try {
      final result = await _authService.fetchUserProfile();
      if (result != null && result.containsKey('user')) {
        user.value = UserModel.fromMap(result['user']);
      }
    } catch (e) {
      Get.snackbar("Error", "Gagal mengambil data profil: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void searchPages(String query) {
    searchText.value = query;

    if (query.trim().isEmpty) {
      filteredPages.clear();
      return;
    }

    filteredPages.value = pages
        .where(
            (page) => page['title'].toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  void clearSearch() {
    searchController.clear();
    filteredPages.clear();
  }

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    // searchController.dispose();
    super.onClose();
  }
}
