import 'dart:typed_data';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import 'package:mobile/app/modules/edukasi/controllers/edukasi_controller.dart';
import 'package:mobile/app/routes/app_pages.dart';

class EdukasiView extends GetView<EdukasiController> {
  const EdukasiView({super.key});

  // Helper function to generate thumbnail from asset video path
  Future<Uint8List?> generateThumbnail(String assetVideoPath) async {
    try {
      final byteData = await rootBundle.load(assetVideoPath);
      final tempDir = await getTemporaryDirectory();
      final tempFile = File(
        '${tempDir.path}/${assetVideoPath.split('/').last}',
      );
      await tempFile.writeAsBytes(byteData.buffer.asUint8List());

      final uint8list = await VideoThumbnail.thumbnailData(
        video: tempFile.path,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 256,
        quality: 100,
      );
      return uint8list;
    } catch (e) {
      print('Error generating thumbnail: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5, // 6 tabs
      child: Scaffold(
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
              default:
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
              icon: Icon(Icons.person_outline),
              label: "Profile",
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Header with TabBar
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(217, 217, 217, 1),
                  image: const DecorationImage(
                    image: AssetImage("assets/bg3.png"),
                    fit: BoxFit.cover,
                    opacity: 0.5,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 2.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 50),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.blue, width: 2),
                        ),
                        child: TabBar(
                          indicatorColor: Colors.white,
                          labelColor: Colors.white,
                          unselectedLabelColor: Colors.white,
                          tabs: const [
                            Tab(
                              icon: Icon(Icons.abc, size: 30),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  "Abjad",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            Tab(
                              icon: Icon(Icons.apple, size: 30),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  "Buah",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            // Tab(
                            //   icon: Icon(Icons.lightbulb, size: 30),
                            //   child: FittedBox(
                            //     fit: BoxFit.scaleDown,
                            //     child: Text(
                            //       "Imbuhan",
                            //       maxLines: 1,
                            //       overflow: TextOverflow.ellipsis,
                            //     ),
                            //   ),
                            // ),
                            Tab(
                              icon: Icon(Icons.group, size: 30),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  "Kata Sifat",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            Tab(
                              icon: Icon(Icons.onetwothree_sharp, size: 30),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  "Angka",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            Tab(
                              icon: Icon(Icons.home_work_outlined, size: 30),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  "Umum",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Content for each Tab
              Expanded(
                child: TabBarView(
                  children: [
                    TabContent(
                      tabId: 'abjad',
                      controller: controller,
                      generateThumbnail: generateThumbnail,
                    ),
                    TabContent(
                      tabId: 'buah',
                      controller: controller,
                      generateThumbnail: generateThumbnail,
                    ),
                    // TabContent(
                    //     tabId: 'imbuhan',
                    //     controller: controller,
                    //     generateThumbnail: generateThumbnail),
                    TabContent(
                        tabId: 'katasifat',
                        controller: controller,
                        generateThumbnail: generateThumbnail),
                    TabContent(
                      tabId: 'angka',
                      controller: controller,
                      generateThumbnail: generateThumbnail,
                    ),
                    TabContent(
                      tabId: 'umum',
                      controller: controller,
                      generateThumbnail: generateThumbnail,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TabContent extends StatelessWidget {
  final String tabId;
  final EdukasiController controller;
  final Future<Uint8List?> Function(String) generateThumbnail;

  const TabContent({
    Key? key,
    required this.tabId,
    required this.controller,
    required this.generateThumbnail,
  }) : super(key: key);

  String getTabTitle(String tabId) {
    switch (tabId) {
      case 'abjad':
        return 'Abjad';
      case 'buah':
        return 'Buah';
      // case 'imbuhan':
      //   return 'Imbuhan';
      case 'katasifat':
        return 'Kata Sifat';
      case 'angka':
        return 'Angka';
      case 'umum':
        return 'Umum';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 18),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: TextField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: "Cari",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(14)),
              ),
            ),
            onChanged: (value) => controller.onSearch(tabId, value),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Text(
            getTabTitle(tabId),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: Obx(() {
            final dataList = controller.getDataForTab(tabId);
            if (dataList.isEmpty) {
              return const Center(child: Text("No data found"));
            }

            return GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.8,
              ),
              itemCount: dataList.length,
              itemBuilder: (context, index) {
                final item = dataList[index];
                final isVideo = item['imagePath']?.endsWith('.mp4') ?? false;

                // Inside itemBuilder of GridView.builder in TabContent:
                return GestureDetector(
                  onTap: () {
                    if (isVideo) {
                      // Navigate to video detail page with video path
                      Get.toNamed(
                        Routes.VIDEO_DETAIL,
                        arguments: {
                          'videoPath': '${item['imagePath']}',
                          'videoTitle': '${item['title']}',
                        },
                      );
                    } else {
                      // For images, you could show a detail page or nothing
                      Get.snackbar(
                        'Info',
                        'This is an image, no video detail.',
                      );
                    }
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12),
                            ),
                            child: isVideo
                                ? FutureBuilder<Uint8List?>(
                                    future: generateThumbnail(
                                      item['imagePath']!,
                                    ),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      }
                                      if (snapshot.hasError ||
                                          snapshot.data == null) {
                                        return const Center(
                                          child: Icon(Icons.error),
                                        );
                                      }
                                      return Image.memory(
                                        snapshot.data!,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                      );
                                    },
                                  )
                                : Image.asset(
                                    item['imagePath']!,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            item['title'] ?? '',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }
}
