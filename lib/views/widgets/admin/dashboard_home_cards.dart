import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import '../../../controllers/order_controller.dart';

class MonthlyRevenueCard extends StatelessWidget {
  const MonthlyRevenueCard({super.key});

  @override
  Widget build(BuildContext context) {
    final OrderController controller = Get.find<OrderController>();

    return InkWell(
      onTap: () => context.push('/reports'),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFE64A19),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE64A19).withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(() => Text(
                      "Monthly Revenue (${controller.reportMonth.value})",
                      style: const TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w500),
                    )),
                const Row(
                  children: [
                    Text(
                      "View Report ",
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 14),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Obx(() => Text(
              // Menggunakan calculatedRevenue agar hitung otomatis dari recentActivities
              "Rp ${controller.calculatedRevenue.toStringAsFixed(0)}",
              style: const TextStyle(
                color: Colors.white, 
                fontSize: 32, 
                fontWeight: FontWeight.bold
              ),
            )),
            const SizedBox(height: 4),
            const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.white54, size: 14),
                SizedBox(width: 4),
                Text(
                  "Tap to view full sales reports",
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class StatCardsRow extends StatelessWidget {
  final int completedCount;
  final int totalOrdersCount;

  const StatCardsRow({super.key, required this.completedCount, required this.totalOrdersCount});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildStatCard(
          "Completed Today",
          "$completedCount",
          Icons.check_circle_outline,
          Colors.green,
        ),
        const SizedBox(width: 16),
        _buildStatCard(
          "Total Orders",
          "$totalOrdersCount",
          Icons.receipt_long_outlined,
          const Color(0xFFE64A19),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String val, IconData icon, Color iconColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor, size: 28),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            Text(val, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black87)),
          ],
        ),
      ),
    );
  }
}

