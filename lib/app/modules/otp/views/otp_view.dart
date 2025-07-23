import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/otp_controller.dart';

class OtpView extends GetView<OtpController> {
  const OtpView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'SignEase',
          style: GoogleFonts.lobster(
            textStyle: const TextStyle(fontSize: 20, color: Colors.orange),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 30, right: 30, top: 20),
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - kToolbarHeight,
            ),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  Container(
                    height: 300,
                    width: double.infinity,
                    child: Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        Positioned.fill(
                          child: Image.asset(
                            'assets/bg4.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                        Text(
                          'Masukkan OTP',
                          style: GoogleFonts.lobster(
                            textStyle: const TextStyle(
                              fontSize: 30,
                              color: Colors.orange,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildOtpBox(context, controller.otp1),
                        _buildOtpBox(context, controller.otp2),
                        _buildOtpBox(context, controller.otp3),
                        _buildOtpBox(context, controller.otp4),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Obx(() {
                    return ElevatedButton(
                      onPressed: controller.isLoading.value
                          ? null
                          : controller.verifyOtp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 20),
                      ),
                      child: controller.isLoading.value
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Verifikasi',
                              style: TextStyle(color: Colors.white),
                            ),
                    );
                  }),

                  const SizedBox(height: 30),

                  // Resend OTP and Countdown Timer
                  Obx(() {
                    final minutes = (controller.remainingSeconds.value ~/ 60)
                        .toString()
                        .padLeft(2, '0');
                    final seconds = (controller.remainingSeconds.value % 60)
                        .toString()
                        .padLeft(2, '0');

                    return Column(
                      children: [
                        Text(
                          'Kirim ulang OTP dalam: $minutes:$seconds',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: controller.canResend.value
                              ? controller.resendOtp
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: controller.canResend.value
                                ? Colors.orange
                                : Colors.grey.shade300,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 30, vertical: 16),
                          ),
                          child: Text(
                            'Kirim Ulang OTP',
                            style: TextStyle(
                              color: controller.canResend.value
                                  ? Colors.white
                                  : Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Widget _buildOtpBox(BuildContext context, TextEditingController controller) {
  return SizedBox(
    width: 50,
    child: TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      maxLength: 1,
      onChanged: (value) {
        if (value.length == 1) {
          FocusScope.of(context).nextFocus();
        }
      },
      decoration: InputDecoration(
        counterText: "",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    ),
  );
}
