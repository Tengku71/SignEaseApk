import 'package:get/get.dart';
import 'package:mobile/app/data/models/user.dart';
import 'package:mobile/app/data/services/auth_services.dart';

class QuizzTimerController extends GetxController {
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

  void fetchUser() {
    final userJson = AuthService().getUser();
    if (userJson != null) {
      try {
        user.value = UserModel.fromMap(userJson);
      } catch (e) {
        print("❌ Failed to parse user: $e");
      }
    } else {
      print("⚠️ No user data found in storage.");
    }
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }
}
