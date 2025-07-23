import 'package:get/get.dart';

import '../controllers/quizz_level_controller.dart';

class QuizzLevelBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<QuizzLevelController>(
      () => QuizzLevelController(),
    );
  }
}
