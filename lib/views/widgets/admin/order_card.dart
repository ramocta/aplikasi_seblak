import 'package:flutter/material.dart';
import 'package:seblak_say_cafe/controllers/order_controller.dart';
import 'package:seblak_say_cafe/views/widgets/admin/order_detail_button.dart';
import 'package:seblak_say_cafe/views/widgets/admin/order_status_badge.dart';

class OrderCard extends StatelessWidget {
  final Map<String, dynamic> order;
  final OrderController controller;
  final String Function(dynamic harga) formatRupiah;
  final Future<void> Function(String orderId, Map<String, dynamic> orderData)
      onPressedDetail;

  const OrderCard({
    super.key,
    required this.order,
    required this.controller,
    required this.formatRupiah,
    required this.onPressedDetail,
  });

  @override
  Widget build(BuildContext context) {
    String orderId = (order['id_transaksi'] ?? order['id'] ?? "0").toString();
    String namaPemesan = order['nama_pemesan'] ?? "Tanpa Nama";

    // 1. Ambil nilai double murni dari controller (Hasil kalkulasi: 18000.0)
    double totalHargaDouble = controller.hitungTotalOrder(order);

    // 2. Format hasilnya menggunakan fungsi formatRupiah yang sudah kita perbaiki
    String totalHargaText = formatRupiah(totalHargaDouble);

    // Deteksi status dari database Laravel ('pending', 'done', 'reject')
    String status = (order['status_pesanan'] ?? order['status'] ?? "pending")
        .toString()
        .toLowerCase()
        .trim();

    String itemsDetail = controller.getMenuSummary(order);
    bool isPending = status == 'pending';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPending ? const Color(0xFFFFE0B2) : Colors.grey.withOpacity(0.2),
          width: isPending ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "#ORD-$orderId",
                  style: TextStyle(
                    color: isPending ? const Color(0xFFD32F2F) : Colors.grey[600],
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                OrderStatusBadge(status: status),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              namaPemesan,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              "Items:",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              itemsDetail,
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    order['tanggal_transaksi'] ??
                        order['created_at'] ??
                        "Today",
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  totalHargaText,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            OrderDetailButton(
              order: order,
              controller: controller,
              onPressed: () async {
                await onPressedDetail(orderId, order);
              },
            ),
          ],
        ),
      ),
    );
  }
}

