import 'package:get/get.dart';
import 'package:mobile/app/data/services/auth_services.dart';

import '../controllers/login_controller.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    // Make sure AuthService is created once and reused
    Get.lazyPut<AuthService>(() => AuthService());

    // Inject AuthService instance into LoginController constructor
    Get.lazyPut<LoginController>(
      () => LoginController(authService: Get.find<AuthService>()),
    );
  }
}
