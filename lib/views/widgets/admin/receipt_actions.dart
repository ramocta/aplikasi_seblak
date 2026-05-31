import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

class ReceiptActions extends StatelessWidget {
  final Future<void> Function() onPrint;
  final VoidCallback onBackToDashboard;

  const ReceiptActions({
    super.key,
    required this.onPrint,
    required this.onBackToDashboard,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD84315),
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
            onPressed: () async {
              await onPrint();
            },
            icon: const Icon(Icons.print, color: Colors.white),
            label: const Text(
              "CETAK PDF",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              side: BorderSide.none,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              backgroundColor: const Color(0xFFE0E0E0),
            ),
            onPressed: onBackToDashboard,
            child: const Text(
              "Back to Dashboard",
              style: TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

