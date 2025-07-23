import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/app/modules/login_history/controllers/login_history_controller.dart';

class LoginHistoryView extends GetView<LoginHistoryController> {
  const LoginHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login History")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (value) =>
                  controller.searchQuery.value = value.toLowerCase(),
              decoration: InputDecoration(
                hintText: "Cari by email, IP, atau tanggal (30, Juni, 2025)",
                prefixIcon: const Icon(Icons.search),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              final filtered = controller.historyList.where((entry) {
                final query = controller.searchQuery.value.toLowerCase();

                final email = entry.email.toLowerCase();
                final ip = entry.ipAddress.toLowerCase();
                final timestamp =
                    entry.timestamp.toLowerCase(); // "2025-06-30 00:00:00"

                // Try parsing timestamp to DateTime
                DateTime? date;
                try {
                  date = DateTime.parse(
                      entry.timestamp); // Format: yyyy-MM-dd HH:mm:ss
                } catch (_) {}

                final day =
                    date != null ? date.day.toString().padLeft(2, '0') : '';
                final month =
                    date != null ? _monthName(date.month).toLowerCase() : '';
                final year = date != null ? date.year.toString() : '';

                return email.contains(query) ||
                    ip.contains(query) ||
                    timestamp.contains(query) ||
                    day.contains(query) ||
                    month.contains(query) ||
                    year.contains(query);
              }).toList();

              if (filtered.isEmpty) {
                return const Center(child: Text("Tidak ada data ditemukan"));
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: filtered.length,
                itemBuilder: (_, index) {
                  final item = filtered[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("📧 ${item.email}",
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text("🕒 ${item.timestamp}"),
                        Text("🌐 IP: ${item.ipAddress}"),
                        Text("📱 UA: ${item.userAgent}",
                            maxLines: 2, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  // Fungsi untuk mengubah nomor bulan menjadi nama bulan (dalam Bahasa Indonesia)
  String _monthName(int month) {
    const months = [
      '',
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];
    return months[month];
  }
}
