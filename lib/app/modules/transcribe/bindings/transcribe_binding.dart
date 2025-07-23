import 'package:get/get.dart';

import '../controllers/transcribe_controller.dart';

class TranscribeBinding extends Bindings {
  @override
  void dependencies() {
    // Get.lazyPut<TranscribeController>(
    //   () => TranscribeController(),
    // );
    Get.put(TranscribeController());
  }
}
