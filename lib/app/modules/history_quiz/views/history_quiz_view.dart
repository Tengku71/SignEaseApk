import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/app/modules/history_quiz/controllers/history_quiz_controller.dart';
import 'package:mobile/app/routes/app_pages.dart';
import 'package:fl_chart/fl_chart.dart';

class HistoryQuizView extends GetView<HistoryQuizController> {
  const HistoryQuizView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Tab count: List & Chart
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Histori Quiz"),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.list), text: "List"),
              Tab(icon: Icon(Icons.bar_chart), text: "Chart"),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 1,
          onTap: (index) {
            switch (index) {
              case 0:
                Get.offAllNamed(Routes.HOME);
                break;
              case 1:
                Get.offAllNamed(Routes.TRANSCRIBE);
                break;
              case 2:
                Get.offAllNamed(Routes.PROFILE);
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
        body: TabBarView(
          children: [
            buildListTab(context),
            buildChartTab(),
          ],
        ),
      ),
    );
  }

  Widget buildListTab(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  blurRadius: 6,
                  color: Colors.grey.withOpacity(0.2),
                  offset: const Offset(0, 4),
                ),
              ],
              borderRadius: BorderRadius.circular(16),
            ),
            child: TextField(
              onChanged: (value) =>
                  controller.searchQuery.value = value.toLowerCase(),
              decoration: const InputDecoration(
                hintText: "Search by level or date",
                border: InputBorder.none,
                icon: Icon(Icons.search),
              ),
            ),
          ),
        ),
        // List
        Expanded(
          child: Obx(() {
            final query = controller.searchQuery.value;
            final progress = controller.progressList.where((item) {
              final level = item['level'].toString().toLowerCase();
              final time = item['timestamp'].toString().toLowerCase();
              return level.contains(query) || time.contains(query);
            }).toList();

            final attempts = controller.attemptsList.where((item) {
              final level = item['level'].toString();
              final levelNumber = int.tryParse(level) ?? 0;
              final label = {
                    3: 'easy',
                    5: 'medium',
                    8: 'hard',
                  }[levelNumber] ??
                  'level $levelNumber';

              final time = item['timestamp'].toString().toLowerCase();
              final count = item['count'].toString();
              return label.toLowerCase().contains(query) ||
                  time.contains(query) ||
                  count.contains(query);
            }).toList();

            if (progress.isEmpty && attempts.isEmpty) {
              return const Center(
                  child: Text("Tidak ditemukan hasil pencarian"));
            }

            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                if (progress.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text("✔ Quizz Level",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  ...progress.map((item) {
                    final level = item['level'] ?? '-';
                    final time = item['timestamp'] ?? '-';
                    return quizCard("Level $level", time);
                  }),
                ],
                if (attempts.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text("⏰ Quizz Timer",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  ...attempts.map((item) {
                    final levelNumber =
                        int.tryParse(item['level'].toString()) ?? 0;
                    final levelLabel = {
                          3: 'Easy',
                          5: 'Medium',
                          8: 'Hard',
                        }[levelNumber] ??
                        'Level $levelNumber';
                    final time = item['timestamp'] ?? '-';
                    final count = item['count'] ?? 0;
                    final points = item['points'];
                    return quizCard("Level $levelLabel (Attempt $count)", time,
                        points: points);
                  }),
                ],
              ],
            );
          }),
        ),
      ],
    );
  }

  Widget quizCard(String title, String timestamp, {int? points}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.quiz_outlined, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 4),
                Text("Waktu: $timestamp", style: const TextStyle(fontSize: 12)),
                if (points != null)
                  Text("Points: $points", style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildChartTab() {
    return Obx(() {
      final data = controller.attemptsList;
      if (data.isEmpty) {
        return const Center(child: Text("No chart data available"));
      }

      List<BarChartGroupData> barGroups = [];
      List<FlSpot> lineSpots = [];
      int x = 0;

      for (var item in data) {
        final levelNumber = int.tryParse(item['level'].toString()) ?? 0;
        final points = (item['points'] ?? 0).toDouble();

        // Map level number to label
        final levelLabel = {
              3: 'Easy',
              5: 'Medium',
              8: 'Hard',
            }[levelNumber] ??
            'L$levelNumber';

        // Bar chart group
        barGroups.add(
          BarChartGroupData(x: x, barRods: [
            BarChartRodData(
              toY: points,
              color: Colors.blue,
              width: 20,
              borderRadius: BorderRadius.circular(4),
            )
          ]),
        );

        // Line chart data
        lineSpots.add(FlSpot(x.toDouble(), points));
        x++;
      }

      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              "📊 Quiz Score by Level",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: BarChart(
                BarChartData(
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= data.length)
                            return const SizedBox.shrink();
                          final levelNumber =
                              int.tryParse(data[index]['level'].toString()) ??
                                  0;
                          final label = {
                                3: 'Easy',
                                5: 'Medium',
                                8: 'Hard',
                              }[levelNumber] ??
                              'L$levelNumber';
                          return Text(label,
                              style: const TextStyle(fontSize: 10));
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: barGroups,
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              "📈 Score Progress Over Time",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= data.length)
                            return const SizedBox.shrink();
                          return const Text(
                              ""); // Minimal label for cleaner look
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: lineSpots,
                      isCurved: true,
                      color: Colors.green,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(
                          show: true, color: Colors.green.withOpacity(0.3)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
