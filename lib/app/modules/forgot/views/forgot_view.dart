import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/app/routes/app_pages.dart';

import '../controllers/forgot_controller.dart';

class ForgotView extends GetView<ForgotController> {
  const ForgotView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
        'SignEase',
        style: GoogleFonts.lobster(
          textStyle: const TextStyle(fontSize: 20),
          color: Colors.orange,
        ),
      )),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Image.asset('assets/forgot.png', width: 200, height: 200),
          const SizedBox(height: 20),
          Text(
            'Forgot Password',
            style: GoogleFonts.lobster(
              textStyle: const TextStyle(fontSize: 30),
              color: Colors.orange,
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: controller.emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          Obx(() => ElevatedButton(
                onPressed: controller.isLoading.value
                    ? null
                    : controller.sendResetLink,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                ),
                child: controller.isLoading.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Kirim',
                        style: TextStyle(color: Colors.white),
                      ),
              )),
        ]),
      ),
    );
  }
}
