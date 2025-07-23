import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/app/routes/app_pages.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    controller.refreshUser();
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          switch (index) {
            case 0:
              Get.toNamed(Routes.HOME);
              break;
            case 1:
              Get.toNamed(Routes.TRANSCRIBE);
              break;
            case 2:
              Get.toNamed(Routes.PROFILE);
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
        child: SingleChildScrollView(
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Obx(() => Row(
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
                              GestureDetector(
                                onTap: () => Get.toNamed(Routes.EDIT_PROFILE),
                                child: CircleAvatar(
                                  radius: 25,
                                  backgroundImage: controller
                                          .user.value.profileImage.isNotEmpty
                                      ? NetworkImage(
                                          controller.user.value.profileImage)
                                      : null,
                                  child:
                                      controller.user.value.profileImage.isEmpty
                                          ? const Icon(Icons.person, size: 25)
                                          : null,
                                ),
                              ),
                            ],
                          )),
                      const SizedBox(height: 20),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.blue, width: 2),
                        ),
                        child: TextField(
                          controller: controller.searchController,
                          onChanged: controller.searchPages,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon:
                                Obx(() => controller.searchText.value.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.clear),
                                        onPressed: controller.clearSearch,
                                      )
                                    : const SizedBox.shrink()),
                            hintText: "Search page...",
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Obx(() {
                        final results = controller.filteredPages;

                        if (results.isEmpty) return const SizedBox();

                        return Container(
                          margin: const EdgeInsets.only(top: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.blue.shade100),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 6,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Hasil Pencarian:",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              ...results.map(
                                (page) => ListTile(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  tileColor: Colors.blue.shade50,
                                  title: Text(page['title']),
                                  trailing: const Icon(Icons.arrow_forward_ios,
                                      size: 16),
                                  onTap: () {
                                    controller.clearSearch();
                                    Get.toNamed(page['route']);
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Menu Cards: Edukasi, Leaderboard, Riwayat
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _menuCard("Edukasi", Icons.book_outlined, Colors.white, 0,
                        () => Get.toNamed(Routes.EDUKASI)),
                    _menuCard("Leaderboard", Icons.leaderboard_outlined,
                        Colors.white, 1, () => Get.toNamed(Routes.LEADERBOARD)),
                    _menuCard(
                        "Informasi",
                        Icons.insert_drive_file_outlined,
                        Colors.white,
                        2,
                        () => Get.toNamed(Routes.WEBVIEW, arguments: {
                              'url': 'https://signease.streamlit.app/',
                              'title': 'Informasi',
                            })),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // CTA Card
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.groups_2_outlined,
                        color: Colors.white, size: 30),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text("Ayo Coba sekarang !",
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                          Text(
                              "Mulai belajar dengan lebih mudah dan menyenangkan",
                              style: TextStyle(
                                  fontSize: 16, color: Colors.white70)),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Get.toNamed(Routes.TRANSCRIBE),
                      child: const Text(
                        "Start",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Kuiz section
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text("Kuiz ",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    Text(">>",
                        style: TextStyle(fontSize: 20, color: Colors.blue)),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: SizedBox(
                  height: 150,
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Get.toNamed(Routes.QUIZZ_LEVEL),
                          child: Image.asset("assets/medals.png",
                              fit: BoxFit.cover),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Get.toNamed(Routes.QUIZZ_TIMER),
                          child: Image.asset("assets/quizz.png",
                              fit: BoxFit.cover),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _menuCard(
    String title,
    IconData icon,
    Color color,
    int index,
    VoidCallback onTap,
  ) {
    return Obx(() {
      bool isSelected = controller.selectedIndex.value == index;

      return GestureDetector(
        onTap: () {
          controller.selectedIndex.value = index;
          onTap();
        },
        child: Container(
          height: 110,
          width: 100,
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue : color,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: isSelected ? color : Colors.blue),
                const SizedBox(height: 30),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? color : Colors.blue,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
