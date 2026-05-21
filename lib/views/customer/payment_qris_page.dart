import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart'; // ✅ untuk kIsWeb
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:seblak_say_cafe/core/constans/app_assets.dart';
import '../../controllers/order_controller.dart';
import '../widgets/qris_instruction_sheet.dart';

class PaymentQrisPage extends StatefulWidget {
  final String orderId;
  final double totalHarga;

  const PaymentQrisPage({
    super.key,
    required this.orderId,
    required this.totalHarga,
  });

  @override
  State<PaymentQrisPage> createState() => _PaymentQrisPageState();
}

class _PaymentQrisPageState extends State<PaymentQrisPage> {
  final OrderController orderController = Get.find<OrderController>();
  final ImagePicker _picker = ImagePicker();

  XFile? _pickedFile; // ✅ Simpan XFile untuk semua platform
  Uint8List? _imageBytes; // ✅ Bytes untuk preview di web
  File? _imageFile; // ✅ File untuk preview di mobile
  bool _isLoading = false;

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        _pickedFile = pickedFile;

        if (kIsWeb) {
          // ✅ Di web: baca sebagai bytes untuk preview
          final bytes = await pickedFile.readAsBytes();
          setState(() {
            _imageBytes = bytes;
            _imageFile = null;
          });
          // ✅ Pass bytes ke controller untuk upload
          orderController.imageProofBytes.value = bytes;
          orderController.imageProofXFile.value = pickedFile;
        } else {
          // ✅ Di mobile: gunakan File biasa
          setState(() {
            _imageFile = File(pickedFile.path);
            _imageBytes = null;
          });
          orderController.imageProof.value = _imageFile;
          orderController.imageProofXFile.value = pickedFile;
        }
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Gagal mengambil gambar.")));
    }
  }

  void _removeImage() {
    setState(() {
      _pickedFile = null;
      _imageBytes = null;
      _imageFile = null;
    });
    orderController.imageProof.value = null;
    orderController.imageProofBytes.value = null;
    orderController.imageProofXFile.value = null;
  }

  bool get _hasImage => kIsWeb ? _imageBytes != null : _imageFile != null;

  Future<void> _handlePayment() async {
    setState(() => _isLoading = true);

    try {
      final result = await orderController.processCheckout(context);

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (result != null) {
        context.go('/detail-transaction', extra: result);
      }
    } catch (e) {
      // ✅ Tangkap exception dari controller
      if (!mounted) return;
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception:', '').trim()),
          backgroundColor: Colors.red[700],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isButtonActive = _hasImage && !_isLoading;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFDE3905)),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Image.asset(
                AppAssets.logo2,
                height: 45,
                errorBuilder: (context, error, stackTrace) => const Text(
                  "Say CAFE",
                  style: TextStyle(
                    color: Color(0xFFDE3905),
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Image.asset(
                AppAssets.qrisCode,
                width: 240,
                height: 240,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.qr_code_2,
                  size: 240,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('QR Code berhasil diunduh')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDE3905),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 2,
                ),
                child: const Text(
                  "Unduh QR Code",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Screenshot jika QR Code tidak bisa di download",
              style: TextStyle(fontSize: 11, color: Colors.black54),
            ),
            const SizedBox(height: 32),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Upload Bukti Transfer",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: _pickImage,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: double.infinity,
                    height: _hasImage ? 180 : 140,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _hasImage
                            ? const Color(0xFFDE3905)
                            : Colors.grey[300]!,
                        width: 1.5,
                      ),
                    ),
                    child: _hasImage
                        ? Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                // ✅ Pilih widget preview sesuai platform
                                child: kIsWeb
                                    ? Image.memory(
                                        _imageBytes!,
                                        width: double.infinity,
                                        height: 180,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.file(
                                        _imageFile!,
                                        width: double.infinity,
                                        height: 180,
                                        fit: BoxFit.cover,
                                      ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: GestureDetector(
                                  onTap: _removeImage,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cloud_upload_outlined,
                                size: 38,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Ketuk untuk upload foto bukti transfer",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Payment Instructions",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () => QrisInstructionSheet.show(
                    context,
                    orderId: widget.orderId,
                    totalHarga: widget.totalHarga,
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDE3905),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "How to Make Payment",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.white,
                          size: 22,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isButtonActive ? _handlePayment : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDE3905),
                  disabledBackgroundColor: Colors.grey[300],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Text(
                        "Pay",
                        style: TextStyle(
                          color: isButtonActive
                              ? Colors.white
                              : Colors.grey[500],
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
