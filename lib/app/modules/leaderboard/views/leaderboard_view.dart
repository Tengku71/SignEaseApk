import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/app/modules/leaderboard/controllers/leaderboard_controller.dart';
import 'package:mobile/app/routes/app_pages.dart';

class LeaderboardView extends GetView<LeaderboardController> {
  const LeaderboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          controller.fetchUser();
          controller.loadLeaderboard();
          Get.snackbar(
            'Refreshed',
            'Data leaderboard dan user diperbarui.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.refresh),
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          switch (index) {
            case 0:
              Get.offNamed(Routes.HOME); // use offNamed to avoid stacking
              break;
            case 1:
              Get.offNamed(Routes.TRANSCRIBE);
              break;
            case 2:
              Get.offNamed(Routes.PROFILE);
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
        child: Obx(() {
          final leaderboard = controller.leaderboardList;
          final currentUser = controller.user.value;

          // Sort leaderboard descending by points
          final sortedLeaderboard = leaderboard.toList()
            ..sort((a, b) => b.points.compareTo(a.points));

          return Column(
            children: [
              // Banner
              Container(
                height: 160,
                width: double.infinity,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/bg2.png"),
                    fit: BoxFit.cover,
                    opacity: 0.5,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Current User Card
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green, width: 2),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                        radius: 24, child: Icon(Icons.verified_user)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentUser.name.isNotEmpty
                                ? currentUser.name
                                : 'User',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const Text("Poin Kamu"),
                        ],
                      ),
                    ),
                    Text(
                      "${currentUser.points}",
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Leaderboard",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Leaderboard List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: sortedLeaderboard.length,
                  itemBuilder: (context, index) {
                    final user = sortedLeaderboard[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Text(
                            "${index + 1}.",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(width: 10),
                          const CircleAvatar(
                              radius: 20, child: Icon(Icons.person)),
                          const SizedBox(width: 10),
                          Expanded(child: Text(user.nama)),
                          Text("Point ${user.points}"),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
