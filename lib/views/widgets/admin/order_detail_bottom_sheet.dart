import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/order_controller.dart';


class OrderDetailBottomSheet {
  static void showUpdateStatusSheet({
    required BuildContext context,
    required String currentOrderId,
    required RxString reactiveStatusPesanan,
  }) {
    // Inisialisasi controller di dalam UI
    final OrderController orderController = Get.find<OrderController>();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "Update Order Status",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Pilih status terbaru untuk pesanan #ORD-${currentOrderId.padLeft(3, '0')}",
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),

              _buildStatusOption(
                context: context,
                orderController: orderController,
                reactiveStatusPesanan: reactiveStatusPesanan,
                currentOrderId: currentOrderId,
                title: "PENDING / PROSES",
                subtitle: "Pesanan masuk antrean atau sedang dimasak dapur",
                icon: Icons.hourglass_empty_rounded,
                color: Colors.orange,
                statusKey: "pending",
              ),
              const SizedBox(height: 12),

              _buildStatusOption(
                context: context,
                orderController: orderController,
                reactiveStatusPesanan: reactiveStatusPesanan,
                currentOrderId: currentOrderId,
                title: "COMPLETED / SELESAI",
                subtitle: "Seblak selesai disajikan dan transaksi dinyatakan lunas",
                icon: Icons.check_circle_rounded,
                color: Colors.green,
                statusKey: "done",
              ),
              const SizedBox(height: 12),

              _buildStatusOption(
                context: context,
                orderController: orderController,
                reactiveStatusPesanan: reactiveStatusPesanan,
                currentOrderId: currentOrderId,
                title: "REJECT / BATAL",
                subtitle: "Batalkan pesanan dan kembalikan stok bahan",
                icon: Icons.cancel_rounded,
                color: Colors.red,
                statusKey: "reject",
              ),
            ],
          ),
        );
      },
    );
  }

  static Widget _buildStatusOption({
    required BuildContext context,
    required OrderController orderController,
    required RxString reactiveStatusPesanan,
    required String currentOrderId,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String statusKey,
  }) {
    return Obx(() {
      // 1. Cek apakah ini status yang sedang aktif
      bool isSelected = reactiveStatusPesanan.value.toLowerCase() == statusKey.toLowerCase() ||
          (reactiveStatusPesanan.value.toLowerCase() == 'selesai' && statusKey == 'done');

      // 2. CEK LOGIKA: Jika status sudah 'done' atau 'reject', jangan izinkan klik lagi
      bool isAlreadyProcessed = reactiveStatusPesanan.value.toLowerCase() == 'done' ||
          reactiveStatusPesanan.value.toLowerCase() == 'selesai' ||
          reactiveStatusPesanan.value.toLowerCase() == 'reject';

      return InkWell(
        onTap: isAlreadyProcessed
            ? null
            : () async {
                bool isSuccess = await orderController.updateTransactionStatus(
                  context,
                  currentOrderId,
                  statusKey,
                );

                if (isSuccess) {
                  if (statusKey == 'done') {
                    reactiveStatusPesanan.value = 'selesai';
                  } else {
                    reactiveStatusPesanan.value = statusKey;
                  }

                  if (context.mounted) Navigator.pop(context);
                }
              },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isAlreadyProcessed
                ? Colors.grey.withOpacity(0.05)
                : (isSelected ? color.withOpacity(0.06) : const Color(0xFFF8F9FA)),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? color : Colors.grey.withOpacity(0.15),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: isAlreadyProcessed
                    ? Colors.grey.withOpacity(0.1)
                    : color.withOpacity(0.15),
                child: Icon(
                  icon,
                  color: isAlreadyProcessed ? Colors.grey : color,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: isAlreadyProcessed
                            ? Colors.grey
                            : (isSelected ? color : Colors.black87),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                isSelected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off_rounded,
                color: isAlreadyProcessed
                    ? Colors.grey
                    : (isSelected ? color : Colors.grey[400]),
              ),
            ],
          ),
        ),
      );
    });
  }
}

