import 'package:get/get.dart';
import 'package:mobile/app/data/models/leaderboard.dart';
import 'package:mobile/app/data/models/user.dart';
import 'package:mobile/app/data/services/auth_services.dart';

class LeaderboardController extends GetxController {
  final leaderboardList = <UserLeaderboard>[].obs;

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
    super.onInit();
    fetchUser();
    loadLeaderboard();
  }

  void fetchUser() async {
    final userData = await AuthService().fetchUserProfile();

    if (userData != null && userData.containsKey('user')) {
      try {
        user.value = UserModel.fromMap(userData['user']);
      } catch (e) {
        print("❌ Failed to parse user data: $e");
      }
    } else {
      print("⚠️ Failed to fetch user data.");
    }
  }

  void loadLeaderboard() async {
    try {
      final data = await AuthService().fetchLeaderboard();

      final sorted = List<UserLeaderboard>.from(data)
        ..sort((a, b) => b.points.compareTo(a.points));

      leaderboardList.value = sorted;
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }
}
