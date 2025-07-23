import 'package:get/get.dart';

import '../controllers/quizz_timer_detail_controller.dart';

class QuizzTimerDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<QuizzTimerDetailController>(
      () => QuizzTimerDetailController(),
    );
  }
}
