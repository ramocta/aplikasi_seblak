import 'package:flutter/material.dart';

class OrderStatusBadge extends StatelessWidget {
  final String status;

  const OrderStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    // Pengkondisian warna badge & text badge murni dari status database
    Color badgeBgColor = const Color(0xFFFFF8E1);
    Color badgeTextColor = Colors.orange[800]!;
    String textBadge = "PENDING";

    if (status == 'done') {
      badgeBgColor = const Color(0xFFE8F5E9);
      badgeTextColor = Colors.green[700]!;
      textBadge = "DONE";
    } else if (status == 'reject') {
      badgeBgColor = const Color(0xFFFFEBEE);
      badgeTextColor = Colors.red[700]!;
      textBadge = "REJECT";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: badgeBgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        textBadge,
        style: TextStyle(
          color: badgeTextColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

