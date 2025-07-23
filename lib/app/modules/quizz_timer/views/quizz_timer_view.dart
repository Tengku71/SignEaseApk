import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/app/modules/quizz_timer/controllers/quizz_timer_controller.dart';
import 'package:mobile/app/routes/app_pages.dart';

class QuizzTimerView extends GetView<QuizzTimerController> {
  const QuizzTimerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: BottomNavigationBar(
          onTap: (index) {
            switch (index) {
              case 0:
                Get.toNamed(Routes.HOME);
                break;
              case 1:
                Get.toNamed(Routes.HOME);
                break;
              case 2:
                Get.toNamed(Routes.PROFILE);
                break;
              default:
                break;
            }
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "HOME",
            ),
            BottomNavigationBarItem(
              icon: CircleAvatar(
                radius: 30,
                backgroundColor: Colors.blue,
                child: Icon(
                  Icons.transcribe_outlined,
                  color: Colors.white,
                ),
              ),
              label: "",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: "Profile",
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Color.fromRGBO(217, 217, 217, 1),
                  image: DecorationImage(
                    image: AssetImage("assets/bg1.png"),
                    fit: BoxFit.fitWidth,
                    opacity: 0.5,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 24.0),
                  child: Obx(() => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "HI ${controller.user.value.name}",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: const Color.fromARGB(255, 0, 99, 181),
                            ),
                          ),
                          CircleAvatar(
                            backgroundImage: NetworkImage(
                                controller.user.value.profileImage),
                          ),
                        ],
                      )),
                ),
              ),
              SizedBox(height: 20),

              // Quiz Level Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "QUIZ Timer",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Monospace',
                      ),
                    ),
                    SizedBox(height: 16),
                    GestureDetector(
                      onTap: () =>
                          Get.toNamed(Routes.QUIZZ_TIMER_DETAIL, arguments: 3),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                        height: 60,
                        decoration: BoxDecoration(
                            color: Colors.greenAccent,
                            borderRadius: BorderRadius.circular(12)),
                        child: Text(
                          textAlign: TextAlign.center,
                          "Easy",
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            fontSize: 28,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    GestureDetector(
                      onTap: () =>
                          Get.toNamed(Routes.QUIZZ_TIMER_DETAIL, arguments: 5),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                        height: 60,
                        decoration: BoxDecoration(
                            color: Colors.blueAccent,
                            borderRadius: BorderRadius.circular(12)),
                        child: Text(
                          textAlign: TextAlign.center,
                          "Medium",
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            fontSize: 28,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    GestureDetector(
                      onTap: () =>
                          Get.toNamed(Routes.QUIZZ_TIMER_DETAIL, arguments: 8),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                        height: 60,
                        decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.circular(12)),
                        child: Text(
                          textAlign: TextAlign.center,
                          "Hard",
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            fontSize: 28,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 12,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}
