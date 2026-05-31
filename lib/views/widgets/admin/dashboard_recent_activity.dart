import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/order_controller.dart';

class RecentActivityList extends StatelessWidget {
  const RecentActivityList({super.key});

  @override
  Widget build(BuildContext context) {
    final OrderController controller = Get.find<OrderController>();

    return Obx(() {
      if (controller.isLoading.value) {
        return const Padding(
          padding: EdgeInsets.only(top: 100.0),
          child: Center(
            child: CircularProgressIndicator(color: Color(0xFFE64A19)),
          ),
        );
      }

      if (controller.recentActivities.isEmpty) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: Center(
            child: Text(
              "Belum ada aktivitas transaksi hari ini",
              style: TextStyle(color: Colors.grey),
            ),
          ),
        );
      }

      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.recentActivities.take(10).length,
        itemBuilder: (context, index) {
          var activity = controller.recentActivities[index];
          var rawStatus = (activity['status_pesanan'] ?? 'pending').toString().toLowerCase().trim();

          Color statusColor;
          String statusText;

          if (rawStatus == 'done') {
            statusColor = Colors.green;
            statusText = "Done";
          } else if (rawStatus == 'reject') {
            statusColor = Colors.red;
            statusText = "Reject";
          } else {
            statusColor = Colors.amber;
            statusText = "Pending";
          }

          return _buildActivityItem(
            activity['nama_pemesan'] ?? activity['customer'] ?? "Pelanggan",
            "Metode: ${activity['payment_method'] ?? 'Tunai'}",
            activity['created_at'] ?? "Baru saja",
            statusText,
            statusColor,
          );
        },
      );
    });
  }

  Widget _buildActivityItem(String name, String desc, String time, String status, Color statusColor) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const CircleAvatar(
        backgroundColor: Color.fromARGB(255, 227, 227, 227),
        child: Icon(Icons.person, color: Colors.white),
      ),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Text(desc, style: const TextStyle(fontSize: 13, color: Colors.grey, height: 1.3)),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            time.length > 10 ? time.substring(0, 10) : time,
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              status,
              style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

