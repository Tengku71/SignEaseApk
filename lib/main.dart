import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mobile/app/data/services/auth_services.dart';

import 'app/routes/app_pages.dart'; // assuming you have defined routes here

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await GetStorage.init(); // Initialize local storage
  final box = GetStorage();

  final token = box.read<String>('token');
  String initialRoute =
      Routes.ONBOARDING; // Default route if no token or invalid

  if (token != null && token.isNotEmpty) {
    final isValid = await AuthService().verifyToken(token);
    if (isValid) {
      initialRoute = Routes.HOME;
    } else {
      box.remove('token'); // Clear invalid token
    }
  }

  runApp(MyApp(initialRoute: initialRoute));
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Application",
      initialRoute: initialRoute,
      getPages: AppPages.routes,
    );
  }
}

/// Token verification function
