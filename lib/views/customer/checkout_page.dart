import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import '../../controllers/order_controller.dart';
import '../../core/constans/app_assets.dart';
import '../widgets/custom_button.dart';
import '../widgets/menu_rectangle.dart'; // ✅ Pastikan ini diimport


class CheckoutPage extends StatelessWidget {
  const CheckoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final OrderController orderController = Get.find<OrderController>();

    return Scaffold(
      // ✅ Ubah background sedikit keabuan sesuai desain gambar
      backgroundColor: const Color(0xFFFBFBFC),
      appBar: AppBar(
        // ✅ Buat AppBar transparan agar background body terlihat menyatu
        backgroundColor: Colors.transparent,
        elevation: 0,
        // ✅ Hapus splash effect pada tombol back
        leading: Theme(
          data: ThemeData(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFFDE3905)),
            onPressed: () => context.pop(),
          ),
        ),
        title: const Text(
          "Checkout",
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      // ✅ Solusi Biru-Biru: Bungkus body dengan Theme transparan
      body: Theme(
        data: ThemeData(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ ✅ SEKARANG MEMBUNGKUS SEMUA CONTENT UTAMA DENGAN MENU RECTANGLE ✅ ✅
              // Widget ini memberikan padding dalam dan background putih dengan shadow
              MenuRectangle(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Logo Say Cafe di dalam box putih
                    Center(child: Image.asset(AppAssets.logo2, height: 55)),
                    const SizedBox(height: 28),

                    // Input Nama Pemesan
                    const Text(
                      "Enter your name",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Input Field (tidak perlu dibungkus Theme lagi karena sudah di root body)
                    TextField(
                      onChanged: (value) =>
                          orderController.namaPemesan.value = value,
                      style: const TextStyle(fontSize: 14),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[100], // Sedikit lebih terang
                        hintText: "Masukkan nama Anda",
                        hintStyle: const TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Section Pilihan Mode Pembayaran
                    const Text(
                      "Payment mode:",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Choose a method of payment",
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    const SizedBox(height: 20),

                    // Opsi QRIS
                    Obx(
                      () => _buildPaymentOption(
                        imageAsset: AppAssets.iconQris,
                        value: "qris",
                        groupValue: orderController.paymentMethod.value,
                        onChanged: (val) =>
                            orderController.paymentMethod.value = val!,
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Opsi Tunai / Pay at Cashier
                    Obx(
                      () => _buildPaymentOption(
                        imageAsset: AppAssets.iconTunai,
                        value: "tunai",
                        groupValue: orderController.paymentMethod.value,
                        onChanged: (val) =>
                            orderController.paymentMethod.value = val!,
                      ),
                    ),

                    // Padding bawah di dalam MenuRectangle agar tidak mepet tombol
                    const SizedBox(height: 20),
                  ],
                ),
              ),

              const SizedBox(height: 60), // Jarak ke tombol checkout
              // Tombol Checkout (di luar MenuRectangle, nempel di bawah body)
              Obx(() {
                final bool isValid = orderController.isCheckoutValid;
                final bool isLoading = orderController.isLoading.value;
                final String method = orderController.paymentMethod.value;

                return CustomButton(
                  text: isLoading
                      ? "Processing..."
                      : method == 'qris'
                      ? "Continue to Payment"
                      : "Checkout",
                  onPressed: (!isValid || isLoading)
                      ? null
                      : () async {
                          if (method == 'qris') {
                            context.push(
                              '/pay-qris',
                              extra: {
                                'orderId':
                                    'Order#${DateTime.now().millisecondsSinceEpoch}',
                                'totalHarga': 0.0,
                              },
                            );
                          } else {
                            try {
                              final result = await orderController
                                  .processCheckout(context);
                              if (result != null && context.mounted) {
                                context.go(
                                  '/detail-transaction',
                                  extra: result,
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      e
                                          .toString()
                                          .replaceAll('Exception:', '')
                                          .trim(),
                                    ),
                                    backgroundColor: Colors.red[700],
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                );
                              }
                            }
                          }
                        },
                );
              }),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentOption({
    required String imageAsset,
    required String value,
    required String groupValue,
    required ValueChanged<String?> onChanged,
  }) {
    final bool isSelected = groupValue == value;

    return GestureDetector(
      onTap: () => onChanged(value),
      // Solusi Biru-Biru 2: Gunakan Container transparan untuk GestureDetector
      child: Container(
        color: Colors.transparent,
        child: Row(
          children: [
            // Radio button di kiri
            Radio<String>(
              value: value,
              groupValue: groupValue,
              onChanged: onChanged,
              activeColor: const Color(0xFFDE3905),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            const SizedBox(width: 8),
            // Gambar ikon metode pembayaran
            // Border berubah warna saat dipilih sesuai tampilan di gambar
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFDE3905)
                      : Colors.grey[300]!,
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: const Color(0xFFDE3905).withOpacity(0.1),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Image.asset(imageAsset, height: 38, fit: BoxFit.contain),
            ),
          ],
        ),
      ),
    );
  }
}
