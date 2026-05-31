import 'package:flutter/material.dart';
import 'package:seblak_say_cafe/controllers/order_controller.dart';

class OrderDetailButton extends StatelessWidget {
  final Map<String, dynamic> order;
  final OrderController controller;
  final Future<void> Function() onPressed;

  const OrderDetailButton({
    super.key,
    required this.order,
    required this.controller,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFEEEEEE),
          foregroundColor: Colors.black87,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        onPressed: () async {
          await onPressed();
        },
        child: const Text(
          "Detail",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ),
    );
  }
}

