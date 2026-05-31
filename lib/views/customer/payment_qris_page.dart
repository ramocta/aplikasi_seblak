import 'dart:io';
import 'package:gal/gal.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:seblak_say_cafe/core/constans/app_assets.dart';
import '../../controllers/order_controller.dart';
import '../widgets/qris_instruction_sheet.dart';
import '../widgets/custom_button.dart';

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


  Uint8List? _imageBytes;
  File? _imageFile;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedFile != null) {

        if (kIsWeb) {
          final bytes = await pickedFile.readAsBytes();
          setState(() {
            _imageBytes = bytes;
            _imageFile = null;
          });
          orderController.imageProofBytes.value = bytes;
          orderController.imageProofXFile.value = pickedFile;
        } else {
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
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Gagal mengambil gambar.")));
    }
  }

  void _removeImage() {
    setState(() {
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

  Future<void> _downloadQRCode() async {
    try {
      // ✅ Minta permission galeri dulu
      final bool hasAccess = await Gal.hasAccess();
      if (!hasAccess) {
        await Gal.requestAccess();
      }

      // Baca asset QR Code sebagai bytes
      final ByteData data = await rootBundle.load(AppAssets.qrisCode);
      final Uint8List bytes = data.buffer.asUint8List();

      if (kIsWeb) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'QR Code siap. Klik kanan gambar untuk simpan.',
            ),
            backgroundColor: Colors.blue[700],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        // ✅ Simpan ke galeri via package gal
        // Tulis ke file temp dulu baru simpan ke galeri
        final String tempPath =
            '${Directory.systemTemp.path}/qris_seblak_say.png';
        final File tempFile = File(tempPath);
        await tempFile.writeAsBytes(bytes);

        // ✅ Simpan file temp ke galeri
        await Gal.putImage(tempPath, album: 'Seblak Say Cafe');

        // Hapus file temp setelah berhasil
        await tempFile.delete();

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('QR Code berhasil disimpan ke galeri'),
            backgroundColor: Colors.green[700],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } on GalException catch (e) {
      // ✅ Tangkap error spesifik dari package gal
      if (!mounted) return;
      String message = 'Gagal menyimpan QR Code';

      switch (e.type) {
        case GalExceptionType.accessDenied:
          message = 'Izin galeri ditolak. Aktifkan di pengaturan HP.';
          break;
        case GalExceptionType.notEnoughSpace:
          message = 'Penyimpanan HP tidak mencukupi.';
          break;
        case GalExceptionType.unexpected:
          message = 'Terjadi kesalahan tidak terduga.';
          break;
        default:
          message = 'Gagal menyimpan ke galeri.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red[700],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
     debugPrint('Gal error: ${e.toString()}');

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Gagal membaca QR Code'),
          backgroundColor: Colors.red[700],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      debugPrint('Download error: $e');
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
        scrolledUnderElevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(top: 12.0),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFFDE3905)),
            onPressed: () => context.pop(),
          ),
        ),
        centerTitle: true,
        title: const Padding(
          padding: EdgeInsets.only(top: 16.0),
          child: Text(
            "QRIS Payment",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          constraints: const BoxConstraints(minHeight: 650),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // QR Code
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
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
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.qr_code_2,
                      size: 200,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Tombol Unduh
                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    text: "Unduh QR Code",
                    onPressed: _downloadQRCode,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Screenshot jika QR Code tidak bisa di download",
                  style: TextStyle(fontSize: 11, color: Colors.black54),
                ),
                const SizedBox(height: 28),

                // Upload Bukti Transfer
                Align(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    "Upload Bukti Transfer",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: _pickImage,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: double.infinity,
                    // ✅ Height lebih kecil
                    height: _hasImage ? 120 : 90,
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
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
                                borderRadius: BorderRadius.circular(10),
                                child: kIsWeb
                                    ? Image.memory(
                                        _imageBytes!,
                                        width: double.infinity,
                                        height: 120,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.file(
                                        _imageFile!,
                                        width: double.infinity,
                                        height: 120,
                                        fit: BoxFit.cover,
                                      ),
                              ),
                              Positioned(
                                top: 6,
                                right: 6,
                                child: GestureDetector(
                                  onTap: _removeImage,
                                  child: Container(
                                    padding: const EdgeInsets.all(3),
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cloud_upload_outlined,
                                size: 28,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Ketuk untuk upload bukti transfer",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                  ),
                ),

                const SizedBox(height: 24),

                // Instruksi Pembayaran
                Align(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    "Payment Instructions",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
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

                const SizedBox(height: 32),

                // Tombol Pay
                CustomButton(
                  text: _isLoading ? "Processing..." : "Pay",
                  onPressed: isButtonActive ? _handlePayment : null,
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
