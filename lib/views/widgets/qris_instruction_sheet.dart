import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:seblak_say_cafe/controllers/cart_controller.dart'; // 💡 Sesuaikan dengan path proyek Anda
import 'package:seblak_say_cafe/utils/currency_format.dart';      // 💡 Menggunakan utilitas format rupiah Cafe Anda

class QrisInstructionSheet extends StatelessWidget {
  final String orderId;

  const QrisInstructionSheet({
    super.key,
    required this.orderId,
  });

  // ✅ Static method diperbarui (tidak perlu lagi melempar double totalHarga dari luar)
  static void show(
    BuildContext context, {
    required String orderId,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => QrisInstructionSheet(
        orderId: orderId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 💡 Hubungkan langsung ke CartController Anda
    final CartController cartController = Get.find<CartController>();

    // 💡 Ambil langsung nilai getter 'totalPrice' dari controller Anda
    final int grandTotal = cartController.totalPrice;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar penarik bottom sheet
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "QRIS Payment Instructions",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildStep("1", 
              "Pindai (Scan) kode QR yang tampil di layar menggunakan aplikasi e-wallet atau m-banking Anda."),
          const SizedBox(height: 12),
          _buildStep("2", 
              // 💡 Sekarang nominal otomatis terformat rapi sesuai kalkulasi subtotal + topping di cart
              "Pastikan nominal transfer sesuai dengan total tagihan, yaitu ${CurrencyFormat.convertToIdr(grandTotal)}."),
          const SizedBox(height: 12),
          _buildStep("3", 
              "Selesaikan proses pembayaran di aplikasi Anda, lalu ambil tangkapan layar (screenshot) sebagai Bukti Transfer."),
          const SizedBox(height: 12),
          _buildStep("4", 
              "Kembali ke aplikasi ini, unggah (upload) foto bukti transfer tersebut, lalu ketuk tombol pay."),
          const SizedBox(height: 12),
          _buildStep("5", 
              "Kasir akan memverifikasi dan memproses pesanan Anda setelah pembayaran diterima."),
          const SizedBox(height: 12),
          _buildStep("6", 
              "Tunggu pesanan Anda selesai. Selamat menikmati!"),
          
          const SizedBox(height: 24),
          
          // Tombol Aksi Tutup Sheet
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFFDE3905),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                "Understand",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(String number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: const BoxDecoration(
            color: Color(0xFFDE3905),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}