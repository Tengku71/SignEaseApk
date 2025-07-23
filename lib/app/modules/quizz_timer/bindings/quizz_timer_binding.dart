import 'package:get/get.dart';

import '../controllers/quizz_timer_controller.dart';

class QuizzTimerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<QuizzTimerController>(
      () => QuizzTimerController(),
    );
  }
}
