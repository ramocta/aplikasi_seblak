import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:seblak_say_cafe/controllers/order_controller.dart';

class TableNumber extends StatelessWidget {
  const TableNumber({super.key});

  @override
  Widget build(BuildContext context) {
    final OrderController orderController = Get.find<OrderController>();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      width: double.infinity,
      height: 45,
      decoration: ShapeDecoration(
        color: const Color(0xFFF6C453),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(13),
        ),
      ),
      // Membungkus Obx dengan Center agar teks berada di tengah Container
      child: Center(
        child: Obx(() {
          String displayText = "";

          if (orderController.selectedOrderType.value == "Dine In") {
            String table = orderController.tableNumber.value.isNotEmpty
                ? "Table ${orderController.tableNumber.value}"
                : "Table -";
            displayText = "$table | Dine In";
          } else if (orderController.selectedOrderType.value == "Take Away") {
            displayText = "Take Away";
          } else {
            displayText = "Pilih Tipe Pesanan";
          }

          return Text(
            displayText,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontFamily: 'Rubik',
              fontWeight: FontWeight.w400,
              color: Color(0xFF333333),
            ),
          );
        }),
      ),
    );
  }
}