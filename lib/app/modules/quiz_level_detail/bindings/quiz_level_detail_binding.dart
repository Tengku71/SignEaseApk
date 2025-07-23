import 'package:get/get.dart';

import '../controllers/quiz_level_detail_controller.dart';

class QuizLevelDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<QuizLevelDetailController>(
      () => QuizLevelDetailController(),
    );
  }
}
