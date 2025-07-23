import 'package:get/get.dart';

class EdukasiController extends GetxController {
  final isLoading = false.obs;
  final Map<String, RxList<Map<String, String>>> tabData = {
    'abjad': <Map<String, String>>[].obs,
    'buah': <Map<String, String>>[].obs,
    // 'imbuhan': <Map<String, String>>[].obs,
    'katasifat': <Map<String, String>>[].obs,
    'angka': <Map<String, String>>[].obs,
    'umum': <Map<String, String>>[].obs,
  };

  final Map<String, List<Map<String, String>>> fullData = {};

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  void loadData() {
    isLoading.value = true;
    try {
      final abjadData = List.generate(26, (i) {
        final char = String.fromCharCode(65 + i); // A-Z
        return {'title': char, 'imagePath': 'assets/edukasi/abjad/$char.mp4'};
      });

      tabData['abjad']!.assignAll(abjadData);
      fullData['abjad'] = List.from(abjadData); // backup copy for search

      tabData['buah']!.assignAll([
        {'title': 'Apel', 'imagePath': 'assets/edukasi/buah/Apel.mp4'},
        {'title': 'Pisang', 'imagePath': 'assets/edukasi/buah/Pisang.mp4'},
        {'title': 'Nanas', 'imagePath': 'assets/edukasi/buah/Nanas.mp4'},
        {'title': 'Anggur', 'imagePath': 'assets/edukasi/buah/Anggur.mp4'},
      ]);
      fullData['buah'] = List.from(tabData['buah']!);

      // tabData['imbuhan']!.assignAll([
      //   {
      //     'title': 'Akhiran-An',
      //     'imagePath': 'assets/edukasi/imbuhan/Akhiran-An.mp4'
      //   },
      //   {
      //     'title': 'Akhiran-I',
      //     'imagePath': 'assets/edukasi/imbuhan/Akhiran-I.mp4'
      //   },
      //   {
      //     'title': 'Akhiran-Kan',
      //     'imagePath': 'assets/edukasi/imbuhan/Akhiran-Kan.mp4'
      //   },
      //   {
      //     'title': 'Akhiran-Man',
      //     'imagePath': 'assets/edukasi/imbuhan/Akhiran-Man.mp4'
      //   },
      //   {
      //     'title': 'Akhiran-Nya',
      //     'imagePath': 'assets/edukasi/imbuhan/Akhiran-Nya.mp4'
      //   },
      //   {
      //     'title': 'Akhiran-Ti',
      //     'imagePath': 'assets/edukasi/imbuhan/Akhiran-Ti.mp4'
      //   },
      //   {
      //     'title': 'Akhiran-Wan',
      //     'imagePath': 'assets/edukasi/imbuhan/Akhiran-Wan.mp4'
      //   },
      //   {
      //     'title': 'Akhiran-Wati',
      //     'imagePath': 'assets/edukasi/imbuhan/Akhiran-Wati.mp4'
      //   },
      //   {
      //     'title': 'Awalan-Ber',
      //     'imagePath': 'assets/edukasi/imbuhan/Awalan-Ber.mp4'
      //   },
      //   {
      //     'title': 'Awalan-Di',
      //     'imagePath': 'assets/edukasi/imbuhan/Awalan-Di.mp4'
      //   },
      //   {
      //     'title': 'Awalan-Ke',
      //     'imagePath': 'assets/edukasi/imbuhan/Awalan-Ke.mp4'
      //   },
      //   {
      //     'title': 'Awalan-Pe',
      //     'imagePath': 'assets/edukasi/imbuhan/Awalan-Pe.mp4'
      //   },
      //   {
      //     'title': 'Awalan-Se',
      //     'imagePath': 'assets/edukasi/imbuhan/Awalan-Se.mp4'
      //   },
      //   {
      //     'title': 'Awalan-Ter',
      //     'imagePath': 'assets/edukasi/imbuhan/Awalan-Ter.mp4'
      //   },
      //   {
      //     'title': 'Partikel-Kah',
      //     'imagePath': 'assets/edukasi/imbuhan/Partikel-Kah.mp4'
      //   },
      //   {
      //     'title': 'Partikel-Lah',
      //     'imagePath': 'assets/edukasi/imbuhan/Partikel-Lah.mp4'
      //   },
      // ]);
      // fullData['imbuhan'] = List.from(tabData['imbuhan']!);

      tabData['katasifat']!.assignAll([
        {'title': 'Marah', 'imagePath': 'assets/edukasi/katasifat/Marah.mp4'},
        {'title': 'Sedih', 'imagePath': 'assets/edukasi/katasifat/Sedih.mp4'},
        {'title': 'Senang', 'imagePath': 'assets/edukasi/katasifat/Senang.mp4'},
        {'title': 'Senyum', 'imagePath': 'assets/edukasi/katasifat/Senyum.mp4'},
      ]);
      fullData['katasifat'] = List.from(tabData['katasifat']!);

      tabData['angka']!.assignAll([
        {'title': '1', 'imagePath': 'assets/edukasi/angka/01.mp4'},
        {'title': '2', 'imagePath': 'assets/edukasi/angka/02.mp4'},
        {'title': '3', 'imagePath': 'assets/edukasi/angka/03.mp4'},
        {'title': '4', 'imagePath': 'assets/edukasi/angka/04.mp4'},
        {'title': '5', 'imagePath': 'assets/edukasi/angka/05.mp4'},
        {'title': '6', 'imagePath': 'assets/edukasi/angka/06.mp4'},
        {'title': '7', 'imagePath': 'assets/edukasi/angka/07.mp4'},
        {'title': '8', 'imagePath': 'assets/edukasi/angka/08.mp4'},
        {'title': '9', 'imagePath': 'assets/edukasi/angka/09.mp4'},
        {'title': '10', 'imagePath': 'assets/edukasi/angka/10.mp4'},
      ]);
      fullData['angka'] = List.from(tabData['angka']!);

      tabData['umum']!.assignAll([
        {'title': 'Rumah', 'imagePath': 'assets/edukasi/umum/Rumah.mp4'},
        {'title': 'Makan', 'imagePath': 'assets/edukasi/umum/Makan.mp4'},
        {'title': 'Buku', 'imagePath': 'assets/edukasi/umum/Buku.mp4'},
        // {'title': 'Sekolah', 'imagePath': 'assets/edukasi/umum/Sekolah.mp4'},
        // {'title': 'Pakai', 'imagePath': 'assets/edukasi/umum/Pakai.mp4'},
        // {'title': 'Olahraga', 'imagePath': 'assets/edukasi/umum/Olahraga.mp4'},
        // {'title': 'Binatang', 'imagePath': 'assets/edukasi/umum/Binatang.mp4'},
        // {'title': 'Musik', 'imagePath': 'assets/edukasi/umum/Musik.mp4'},
        // {'title': 'Buah', 'imagePath': 'assets/edukasi/umum/Buah.mp4'},
        {'title': 'Bunga', 'imagePath': 'assets/edukasi/umum/Bunga.mp4'},
        // {'title': 'Kerja', 'imagePath': 'assets/edukasi/umum/Kerja.mp4'},
        // {'title': 'Minum', 'imagePath': 'assets/edukasi/umum/Minum.mp4'},
        // {'title': 'Seni', 'imagePath': 'assets/edukasi/umum/Seni.mp4'},
        // {'title': 'Tempat', 'imagePath': 'assets/edukasi/umum/Tempat.mp4'},
        // {'title': 'Tumbuh', 'imagePath': 'assets/edukasi/umum/Tumbuh.mp4'},
        {'title': 'Sehat', 'imagePath': 'assets/edukasi/umum/Sehat.mp4'},
      ]);

      fullData['umum'] = List.from(tabData['umum']!);
    } catch (e, st) {
      print('EdukasiController: Error loading data: $e\n$st');
    } finally {
      isLoading.value = false;
    }
  }

  RxList<Map<String, String>> getDataForTab(String tabId) {
    return tabData[tabId] ?? <Map<String, String>>[].obs;
  }

  void onSearch(String tabId, String query) {
    final fullList = fullData[tabId] ?? [];

    if (query.isEmpty) {
      tabData[tabId]!.assignAll(fullList);
    } else {
      tabData[tabId]!.assignAll(
        fullList
            .where((item) =>
                item['title']!.toLowerCase().contains(query.toLowerCase()))
            .toList(),
      );
    }
  }
}
