import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:seblak_say_cafe/controllers/order_controller.dart';
import 'package:seblak_say_cafe/views/widgets/admin/order_card.dart';
import 'package:seblak_say_cafe/views/widgets/admin/order_filter_bar.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  final OrderController controller = Get.find<OrderController>();

  // Default filter "all" sesuai dengan backend
  String activeStatus = "all";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchDashboardStats();
    });
  }

  // === 1. FUNGSI FORMAT RUPIAH YANG SUDAH DIPERBAIKI & AMAN ===
  String formatRupiah(dynamic harga) {
    try {
      if (harga == null) return "Rp0";

      // Amankan parsing dari tipe data apapun (int/double/string)
      double parsed = double.parse(harga.toString());
      int value = parsed.toInt();
      String valueStr = value.toString();

      if (valueStr.length <= 3) return "Rp$valueStr";

      String result = "";
      int count = 0;
      for (int i = valueStr.length - 1; i >= 0; i--) {
        result = valueStr[i] + result;
        count++;
        if (count % 3 == 0 && i != 0) {
          result = ".$result";
        }
      }
      return "Rp$result";
    } catch (e) {
      return "Rp$harga";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          // === FILTER BUTTONS TABS (SINKRON 100% SAMA DATABASE) ===
          OrderFilterBar(
            activeStatus: activeStatus,
            onChanged: (value) {
              setState(() {
                activeStatus = value;
              });
            },
          ),

          // === LIST TRANSAKSI UTAMA ===
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD32F2F)),
                  ),
                );
              }

              // Filter list data dari controller berdasarkan status transaksi asli di database
              var filteredList = controller.recentActivities.where((activity) {
                if (activeStatus == "all") return true;

                String currentStatus =
                    (activity['status_pesanan'] ?? activity['status'] ?? "pending")
                        .toString()
                        .toLowerCase()
                        .trim();

                return currentStatus == activeStatus;
              }).toList();

              if (filteredList.isEmpty) {
                return const Center(
                  child: Text(
                    "No orders available.",
                    style: TextStyle(color: Colors.grey, fontSize: 15),
                  ),
                );
              }

              return ListView.builder(
                itemCount: filteredList.length,
                padding: const EdgeInsets.all(16),
                itemBuilder: (context, index) {
                  final order = filteredList[index];

                  return OrderCard(
                    order: order,
                    controller: controller,
                    formatRupiah: formatRupiah,
                    onPressedDetail: (orderId, orderData) async {
                      if (context.mounted) {
                        context.push('/order_detail', extra: orderData);
                      }
                      await controller.fetchOrderDetail(orderId);
                    },
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}




