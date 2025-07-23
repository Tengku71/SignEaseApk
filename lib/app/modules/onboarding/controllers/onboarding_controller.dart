import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mobile/app/data/services/auth_services.dart';
import 'package:mobile/app/routes/app_pages.dart';

class OnboardingController extends GetxController {
  PageController pageController = PageController();
  RxInt currentPage = 0.obs;

  List<Map<String, String>> onboardingPages = [
    {
      // "title": "Welcome",
      // "subtitle": "This is the first onboarding screen.",
      "image": "assets/logo.png"
    },
    {
      "title": "Bahasa Isyarat Sulit Diakses",
      "subtitle": "Kamus SIBI tebal, mahal, dan sulit dipakai sehari-hari..",
      "image": "assets/bg5.png"
    },
    {
      "title": "SignEase",
      "subtitle":
          "SignEase memungkinkan pengenalan bahasa isyarat SIBI secara instan,",
      "image": "assets/bg6.png"
    },
  ];

  void nextPage() async {
    if (currentPage.value < onboardingPages.length - 1) {
      pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    } else {
      final box = GetStorage();
      final token = box.read<String>('token');

      if (token != null &&
          token.isNotEmpty &&
          await AuthService().verifyToken(token)) {
        Get.offAllNamed(Routes.HOME);
      } else {
        Get.offAllNamed(Routes.LOGIN);
      }
    }
  }

  void onPageChanged(int index) {
    currentPage.value = index;
  }
}
