import 'package:get/get.dart';

import '../controllers/history_quiz_controller.dart';

class HistoryQuizBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HistoryQuizController>(
      () => HistoryQuizController(),
    );
  }
}
