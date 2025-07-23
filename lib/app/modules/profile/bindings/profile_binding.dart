import 'package:get/get.dart';
import 'package:mobile/app/data/services/auth_services.dart';

import '../controllers/profile_controller.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthService>(() => AuthService());

    // Inject AuthService instance into LoginController constructor
    Get.lazyPut<ProfileController>(
      () => ProfileController(authService: AuthService()),
      fenix: false, // Don't keep it alive
    );
  }
}
