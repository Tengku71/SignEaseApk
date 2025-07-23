import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebviewController extends GetxController {
  late String url;
  late String title;

  late final WebViewController webViewController;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, String>;
    url = args['url'] ?? 'https://signease.streamlit.app/';
    title = args['title'] ?? 'Streamlit';

    webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(url));
  }
}
