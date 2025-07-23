import 'package:flutter/services.dart' show rootBundle;
import 'package:get/get.dart';
import 'package:mobile/app/data/models/user.dart';
import 'package:mobile/app/data/services/auth_services.dart';
import 'package:mobile/app/routes/app_pages.dart';

class QuizzLevelController extends GetxController {
  var user = UserModel(
    name: "Loading...",
    profileImage: "",
    level: 0,
    history: [],
    email: "",
    points: 0,
  ).obs;

  var levelLabels = <String>[].obs;

  @override
  void onInit() {
    fetchUser();
    loadLabels();
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
    fetchUser(); // Ini akan dipanggil setiap kali halaman siap tampil
  }

  void fetchUser() async {
    print("🔁 [fetchUser] Called");
    final userData = await AuthService().fetchUserProfile();

    if (userData != null && userData.containsKey('user')) {
      try {
        user.value = UserModel.fromMap(userData['user']);
        // print("✅ USER LEVEL: ${user.value.level}");
        // print("✅ USER DATA: ${userData['user']}");
      } catch (e) {
        print("❌ Failed to parse user data: $e");
      }
    } else {
      print("⚠️ Failed to fetch user data or user key missing.");
    }
  }

  Future<void> loadLabels() async {
    final labelsString = await rootBundle.loadString('assets/labels.txt');
    final lines = labelsString
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    // Custom sort logic
    lines.sort((a, b) {
      final isNumA = int.tryParse(a) != null;
      final isNumB = int.tryParse(b) != null;

      final isSingleLetterA = a.length == 1 && !isNumA;
      final isSingleLetterB = b.length == 1 && !isNumB;

      if (isNumA && !isNumB) return -1;
      if (!isNumA && isNumB) return 1;

      if (isNumA && isNumB) return int.parse(a).compareTo(int.parse(b));

      if (isSingleLetterA && !isSingleLetterB) return -1;
      if (!isSingleLetterA && isSingleLetterB) return 1;

      return a.compareTo(b);
    });

    levelLabels.value = lines;
  }
}
