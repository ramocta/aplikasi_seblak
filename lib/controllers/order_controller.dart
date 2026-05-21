import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:seblak_say_cafe/controllers/cart_controller.dart';
import 'package:seblak_say_cafe/services/transactions_services.dart';
import 'package:seblak_say_cafe/models/transaction_models.dart';

class OrderController extends GetxController {
  final TransactionService _transactionService = TransactionService();
  final ImagePicker _picker = ImagePicker();

  var selectedOrderType = "".obs;
  var tableNumber = "".obs;
  var namaPemesan = "".obs;
  var paymentMethod = "tunai".obs;
  var isLoading = false.obs;

  var imageProof = Rxn<File>();
  var imageProofBytes = Rxn<Uint8List>();
  var imageProofXFile = Rxn<XFile>();

  bool get isOrderTypeSelected => selectedOrderType.value.isNotEmpty;

  bool get isCheckoutValid =>
      namaPemesan.value.trim().isNotEmpty &&
      paymentMethod.value.isNotEmpty;

  bool get isTableNumberValid {
    if (tableNumber.value.isEmpty) return false;
    final int? num = int.tryParse(tableNumber.value);
    return num != null && num >= 1 && num <= 20;
  }

  void selectType(String type) {
    selectedOrderType.value = type;
  }

  void setTableNumber(String number) {
    String cleaned = number.trim();

    if (cleaned.isEmpty) {
      tableNumber.value = '';
      return;
    }

    final int? tableNum = int.tryParse(cleaned);

    if (tableNum == null) {
      tableNumber.value = '';
      return;
    } else if (tableNum < 1 || tableNum > 20) {
      tableNumber.value = '';
      return;
    }

    tableNumber.value = cleaned;
  }

  String getNextRoute() {
    if (selectedOrderType.value == "Dine In") {
      return '/table-number';
    } else {
      return '/menu';
    }
  }

  Future<void> pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        imageProofXFile.value = pickedFile;

        if (!kIsWeb) {
          imageProof.value = File(pickedFile.path);
        } else {
          final bytes = await pickedFile.readAsBytes();
          imageProofBytes.value = bytes;
        }
      }
    } catch (e) {
      // Error ditangkap di page
      rethrow;
    }
  }

  void removeImage() {
    imageProof.value = null;
    imageProofBytes.value = null;
    imageProofXFile.value = null;
  }

  // ✅ Return TransactionModel? — navigasi ditangani di page
  // Semua validasi throw Exception agar bisa ditangkap di page
  Future<TransactionModel?> processCheckout(BuildContext context) async {
    // ✅ Validasi — throw Exception bukan Get.snackbar
    if (namaPemesan.value.trim().isEmpty) {
      throw Exception('Nama pemesan wajib diisi.');
    }

    String opsiFormatLaravel =
        selectedOrderType.value.toLowerCase() == 'dine in'
            ? 'dine in'
            : 'take away';

    if (opsiFormatLaravel == 'dine in' && tableNumber.value.isEmpty) {
      throw Exception(
          'Nomor meja belum diisi. Silakan kembali ke halaman meja.');
    }

    if (paymentMethod.value == 'qris' && imageProofXFile.value == null) {
      throw Exception('Bukti pembayaran QRIS wajib diupload.');
    }

    final CartController cartController = Get.find<CartController>();
    if (cartController.cartItems.isEmpty) {
      throw Exception('Keranjang belanja masih kosong.');
    }

    try {
      isLoading(true);

      List<Map<String, dynamic>> formattedItems =
          cartController.cartItems.map((cartItem) {
        return {
          "id_menu": cartItem.id,
          "qty": cartItem.quantity,
          "toppings": cartItem.selectedToppings.map((topItem) {
            return {
              "id_topping": topItem.id,
              "qty": topItem.quantity,
            };
          }).toList(),
        };
      }).toList();

      final result = await _transactionService.checkout(
        namaPemesan: namaPemesan.value,
        noMeja: opsiFormatLaravel == 'take away' ? null : tableNumber.value,
        opsiPemesanan: opsiFormatLaravel,
        paymentMethod: paymentMethod.value,
        items: formattedItems,
        imageProof: imageProof.value,
        imageProofXFile: imageProofXFile.value,
      );

      cartController.clearCart();
      resetOrder();

      return result;
    } catch (e) {
      // Re-throw agar ditangkap di page
      rethrow;
    } finally {
      isLoading(false);
    }
  }

  void resetOrder() {
    selectedOrderType.value = "";
    tableNumber.value = "";
    namaPemesan.value = "";
    paymentMethod.value = "tunai";
    imageProof.value = null;
    imageProofBytes.value = null;
    imageProofXFile.value = null;
  }
}