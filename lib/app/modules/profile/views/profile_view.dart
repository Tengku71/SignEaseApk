import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/app/modules/profile/controllers/profile_controller.dart';
import 'package:mobile/app/routes/app_pages.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          switch (index) {
            case 0:
              Get.offNamed(Routes.HOME);
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
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "HOME",
          ),
          BottomNavigationBarItem(
            icon: CircleAvatar(
              radius: 30,
              backgroundColor: Colors.blue,
              child: Icon(Icons.transcribe_outlined, color: Colors.white),
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
              height: 200,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color.fromRGBO(217, 217, 217, 1),
              ),
              padding: const EdgeInsets.all(16),
              child: Obx(
                () => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Get.toNamed(Routes.EDIT_PROFILE);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundImage: NetworkImage(
                                  controller.user.value.profileImage),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(controller.user.value.name),
                                ],
                              ),
                            ),
                            Text("Point ${controller.user.value.points}"),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Container(
                    //   decoration: BoxDecoration(
                    //     borderRadius: BorderRadius.circular(10),
                    //     color: Colors.grey.shade200,
                    //   ),
                    //   child: ListTile(
                    //     leading: const Icon(Icons.person),
                    //     title: const Text("Hubungi kami"),
                    //     onTap: () {},
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.blue,
              ),
              margin: const EdgeInsets.symmetric(horizontal: 12),
              width: double.infinity,
              child: ListTile(
                onTap: () {
                  Get.toNamed(Routes.HISTORY_QUIZ);
                },
                leading:
                    const Icon(Icons.ssid_chart_rounded, color: Colors.white),
                title: const Text("History Quiz",
                    style: TextStyle(color: Colors.white)),
              ),
            ),

            const SizedBox(height: 16),

            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.green,
              ),
              margin: const EdgeInsets.symmetric(horizontal: 12),
              width: double.infinity,
              child: ListTile(
                onTap: () {
                  Get.toNamed(Routes.LOGIN_HISTORY);
                },
                leading:
                    const Icon(Icons.ssid_chart_rounded, color: Colors.white),
                title: const Text("Login History",
                    style: TextStyle(color: Colors.white)),
              ),
            ),

            const SizedBox(height: 16),

            // 🔴 Delete Account Button with Confirmation
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.red,
              ),
              margin: const EdgeInsets.symmetric(horizontal: 12),
              width: double.infinity,
              child: ListTile(
                onTap: () {
                  Get.defaultDialog(
                    title: "Konfirmasi",
                    middleText: "Apakah kamu yakin ingin menghapus akun ini?",
                    textConfirm: "Ya",
                    textCancel: "Batal",
                    confirmTextColor: Colors.white,
                    onConfirm: () {
                      Get.back(); // Tutup dialog
                      controller.deleteAccount();
                    },
                  );
                },
                leading: const Icon(Icons.delete, color: Colors.white),
                title: const Text("Hapus Akun",
                    style: TextStyle(color: Colors.white)),
              ),
            ),

            const Spacer(),

            // Logout
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey.shade200,
              ),
              child: ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title:
                    const Text("Keluar", style: TextStyle(color: Colors.red)),
                onTap: () {
                  controller.logout();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
