import 'package:get/get.dart';
import 'package:mobile/app/data/models/login_history.dart';
import 'package:mobile/app/data/services/auth_services.dart';

class LoginHistoryController extends GetxController {
  var historyList = <LoginHistory>[].obs;
  var isLoading = true.obs;
  var searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchLoginHistory();
  }

  void fetchLoginHistory() async {
    try {
      isLoading.value = true;
      final list = await AuthService().getLoginHistory();
      historyList.assignAll(list);
    } catch (e) {
      print(e);
      Get.snackbar("Error", "Gagal mengambil data login history");
    } finally {
      isLoading.value = false;
    }
  }
}
