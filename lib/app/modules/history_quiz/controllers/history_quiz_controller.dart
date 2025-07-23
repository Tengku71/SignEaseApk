import 'package:get/get.dart';
import 'package:mobile/app/data/services/auth_services.dart';

class HistoryQuizController extends GetxController {
  RxList<Map<String, dynamic>> progressList = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> attemptsList = <Map<String, dynamic>>[].obs;

  RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final progress = await AuthService().getProgress();
      final attempts = await AuthService().getQuestionAttempts();

      progressList.assignAll(progress);
      attemptsList.assignAll(attempts);
    } catch (e) {
      print("❌ Failed to fetch data: $e");
    }
  }
}
