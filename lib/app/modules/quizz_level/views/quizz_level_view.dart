import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/app/modules/quizz_level/controllers/quizz_level_controller.dart';
import 'package:mobile/app/routes/app_pages.dart';

class QuizzLevelView extends GetView<QuizzLevelController> {
  const QuizzLevelView({super.key});

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
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "HOME"),
          BottomNavigationBarItem(
            icon: CircleAvatar(
              radius: 30,
              backgroundColor: Colors.blue,
              child: Icon(Icons.transcribe_outlined, color: Colors.white),
            ),
            label: "",
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: "Profile"),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color.fromRGBO(217, 217, 217, 1),
                image: const DecorationImage(
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
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 0, 99, 181),
                          ),
                        ),
                        CircleAvatar(
                          backgroundImage:
                              NetworkImage(controller.user.value.profileImage),
                        ),
                      ],
                    )),
              ),
            ),
            const SizedBox(height: 20),

            // Quiz Level Section
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16.0),
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "QUIZ Level",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Monospace',
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: Obx(() {
                        final currentLevel = controller.user.value.level.value;

                        return GridView.builder(
                          itemCount: controller.levelLabels.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 20,
                            childAspectRatio: 1,
                          ),
                          itemBuilder: (context, index) {
                            final label = controller.levelLabels[index];
                            final levelNumber = index + 1;

                            final isPassed = levelNumber <= currentLevel;
                            final isCurrent = levelNumber == currentLevel + 1;
                            final isClickable = isPassed || isCurrent;

                            return ElevatedButton(
                              onPressed: isClickable
                                  ? () async {
                                      final result = await Get.toNamed(
                                        Routes.QUIZ_LEVEL_DETAIL,
                                        arguments: {
                                          'index': levelNumber,
                                          'label': label,
                                        },
                                      );
                                      if (result == true) {
                                        controller.fetchUser(); // refresh
                                      }
                                    }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isPassed
                                    ? Colors.green
                                    : isCurrent
                                        ? Colors.blue
                                        : Colors.grey.shade300,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                "$levelNumber",
                                style: TextStyle(
                                  fontSize: 22,
                                  color: isClickable
                                      ? Colors.white
                                      : Colors.black26,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          },
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
