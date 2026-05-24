import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:seblak_say_cafe/controllers/order_controller.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final OrderController controller = Get.find<OrderController>();
    const primaryOrange = Color(0xFFE64A19);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          "Today's Report",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: primaryOrange));
        }

        // 1. FILTER: Ambil riwayat aktivitas hari ini yang statusnya murni 'done'
        var todayOrders = controller.recentActivities.where((order) {
          var rawStatus = order['status_pesanan'] ?? order['status'] ?? '';
          String status = rawStatus.toString().toLowerCase().trim();
          return status == 'done';
        }).toList();

        // 2. KALKULASI: Gunakan hitungTotalOrder dari controller agar aman dari 'total_price' null
        double totalRevenue = todayOrders.fold(0.0, (sum, item) {
          return sum + controller.hitungTotalOrder(item);
        });

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // --- REVENUE CARD SUMMARY ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Total Revenue Today",
                        style: TextStyle(color: Colors.green.shade800, fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Rp ${totalRevenue.toInt()}",
                        style: TextStyle(color: Colors.green.shade900, fontWeight: FontWeight.bold, fontSize: 24),
                      ),
                    ],
                  ),
                  CircleAvatar(
                    backgroundColor: Colors.green.shade100,
                    child: Icon(Icons.trending_up, color: Colors.green.shade700),
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // --- TRANSACTION DETAILS SECTION ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Transaction Details", 
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: primaryOrange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "${todayOrders.length} Orders",
                    style: const TextStyle(color: primaryOrange, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(),
            
            if (todayOrders.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 60),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.receipt_long, size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      const Text(
                        "No completed transactions today.",
                        style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...todayOrders.map((order) {
                // Ambil harga riil per transaksi lewat fungsi controller bawaanmu
                double orderTotal = controller.hitungTotalOrder(order);
                String customerName = order['nama_pemesan'] ?? order['customer'] ?? "Customer";
                String paymentMethod = order['payment_method'] ?? "Cash";
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9F9F9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFF0F0F0)),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xffe0e0e0),
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    title: Text(
                      customerName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    subtitle: Text(
                      "Method: $paymentMethod",
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    trailing: Text(
                      "Rp ${orderTotal.toInt()}",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87),
                    ),
                  ),
                );
              }),
          ],
        );
      }),
    );
  }
}