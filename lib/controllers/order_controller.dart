import 'package:get/get.dart';
import 'package:flutter/material.dart';

class OrderController extends GetxController {
  // Observables
  var selectedOrderType = "".obs; // "Dine In" atau "Take Away"
  var tableNumber = "".obs;

  // Cek apakah button Continue boleh aktif
  bool get isOrderTypeSelected => selectedOrderType.value.isNotEmpty;

  void selectType(String type) {
    selectedOrderType.value = type;
  }

  /// ====================== LOGIKA NOMOR MEJA ======================
  
  /// Set nomor meja dengan validasi maksimal 20
  void setTableNumber(String number) {
    // Hapus spasi atau karakter tidak diinginkan
    String cleaned = number.trim();

    if (cleaned.isEmpty) {
      tableNumber.value = '';
      return;
    }

    // Coba parse ke integer
    final int? tableNum = int.tryParse(cleaned);

    if (tableNum == null) {
      Get.snackbar(
        "Input Tidak Valid",
        "Nomor meja harus berupa angka",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red[700],
        colorText: Colors.white,
      );
      return;
    }

    if (tableNum < 1) {
      Get.snackbar(
        "Nomor Meja Tidak Valid",
        "Nomor meja minimal adalah 1",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red[700],
        colorText: Colors.white,
      );
      return;
    }

    if (tableNum > 20) {
      Get.snackbar(
        "Meja Tidak Tersedia",
        "Maksimal nomor meja adalah 20",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange[700],
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      // Jangan set nilai jika melebihi 20
      return;
    }

    // Jika valid, simpan
    tableNumber.value = cleaned;
  }

  /// Optional: Cek apakah nomor meja sudah valid
  bool get isTableNumberValid {
    if (tableNumber.value.isEmpty) return false;
    final int? num = int.tryParse(tableNumber.value);
    return num != null && num >= 1 && num <= 20;
  }

  // Logika Navigasi
  String getNextRoute() {
    if (selectedOrderType.value == "Dine In") {
      return '/table-number';
    } else {
      return '/menu'; // Langsung ke katalog
    }
  }

  // Optional: Reset semua data
  void resetOrder() {
    selectedOrderType.value = "";
    tableNumber.value = "";
  }
}