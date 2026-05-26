import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/api/api_client.dart';

import 'package:seblak_say_cafe/controllers/cart_controller.dart';
import 'package:seblak_say_cafe/controllers/menu_controller.dart'
    as custom_menu;
import 'package:seblak_say_cafe/controllers/topping_controller.dart';

import 'package:seblak_say_cafe/models/transaction_models.dart';

import 'package:seblak_say_cafe/services/transactions_services.dart';

class OrderController extends GetxController {
  // ===========================================================================
  // SERVICES
  // ===========================================================================

  final TransactionService _transactionService = TransactionService();
  final ImagePicker _picker = ImagePicker();

  // ===========================================================================
  // COMMON STATE
  // ===========================================================================

  var isLoading = false.obs;

  // ===========================================================================
  // CUSTOMER STATE
  // ===========================================================================

  var selectedOrderType = "".obs;
  var tableNumber = "".obs;
  var namaPemesan = "".obs;
  var paymentMethod = "tunai".obs;

  var imageProof = Rxn<File>();
  var imageProofBytes = Rxn<Uint8List>();
  var imageProofXFile = Rxn<XFile>();

  // ===========================================================================
  // ADMIN STATE
  // ===========================================================================

  var monthlyRevenue = 0.obs;
  var reportMonth = "".obs;
  var newCustomers = 0.obs;
  var ordersToday = 0.obs;

  var recentActivities = [].obs;
  var currentOrderItems = [].obs;

  // ===========================================================================
  // CUSTOMER GETTERS
  // ===========================================================================

  bool get isOrderTypeSelected => selectedOrderType.value.isNotEmpty;

  bool get isCheckoutValid =>
      namaPemesan.value.trim().isNotEmpty &&
      paymentMethod.value.isNotEmpty;

  bool get isTableNumberValid {
    if (tableNumber.value.isEmpty) return false;

    final int? num = int.tryParse(tableNumber.value);

    return num != null && num >= 1 && num <= 20;
  }

  // ===========================================================================
  // ADMIN GETTERS
  // ===========================================================================

  double get subtotal {
    double total = 0.0;

    for (var item in currentOrderItems) {
      if (item == null) continue;

      double hargaMenuDasar = 0.0;

      var menuData = item['menu'];

      if (menuData != null && menuData['harga'] != null) {
        hargaMenuDasar =
            double.tryParse(menuData['harga'].toString()) ?? 0.0;
      } else {
        hargaMenuDasar = double.tryParse(
              item['harga_satuan']?.toString() ??
                  item['harga']?.toString() ??
                  "0",
            ) ??
            0.0;
      }

      double totalToppingPerMenu = 0.0;

      var toppings =
          item['pesanan_toppings'] ?? item['toppings'] ?? [];

      if (toppings is List) {
        for (var t in toppings) {
          if (t == null) continue;

          var toppingMaster = t['topping'];

          double hargaTopping = 0.0;

          if (toppingMaster != null &&
              toppingMaster['harga'] != null) {
            hargaTopping =
                double.tryParse(toppingMaster['harga'].toString()) ??
                    0.0;
          } else {
            hargaTopping = double.tryParse(
                  t['harga_satuan']?.toString() ??
                      t['harga']?.toString() ??
                      t['harga_topping']?.toString() ??
                      "0",
                ) ??
                0.0;
          }

          int qtyTopping =
              int.tryParse(
                t['qty']?.toString() ??
                    t['jumlah']?.toString() ??
                    "1",
              ) ??
              1;

          totalToppingPerMenu +=
              (hargaTopping * qtyTopping);
        }
      }

      int qtyMenu =
          int.tryParse(
            item['qty']?.toString() ??
                item['jumlah']?.toString() ??
                "1",
          ) ??
          1;

      total +=
          ((hargaMenuDasar + totalToppingPerMenu) *
              qtyMenu);
    }

    return total;
  }

  double get totalTopping {
    double total = 0.0;

    for (var item in currentOrderItems) {
      if (item == null) continue;

      var toppings =
          item['pesanan_toppings'] ?? item['toppings'] ?? [];

      double toppingSatuMenu = 0.0;

      if (toppings is List) {
        for (var t in toppings) {
          if (t == null) continue;

          var toppingMaster = t['topping'];

          double hargaTopping = double.tryParse(
                toppingMaster?['harga']?.toString() ??
                    t['harga_satuan']?.toString() ??
                    t['harga']?.toString() ??
                    "0",
              ) ??
              0.0;

          int qtyTopping =
              int.tryParse(
                t['qty']?.toString() ??
                    t['jumlah']?.toString() ??
                    "1",
              ) ??
              1;

          toppingSatuMenu +=
              (hargaTopping * qtyTopping);
        }
      }

      int qtyMenu =
          int.tryParse(
            item['qty']?.toString() ??
                item['jumlah']?.toString() ??
                "1",
          ) ??
          1;

      total += (toppingSatuMenu * qtyMenu);
    }

    return total;
  }

  double get grandTotal => subtotal;

  // ===========================================================================
  // CUSTOMER METHODS
  // ===========================================================================

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
    }

    if (tableNum < 1 || tableNum > 20) {
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
      rethrow;
    }
  }

  void removeImage() {
    imageProof.value = null;
    imageProofBytes.value = null;
    imageProofXFile.value = null;
  }

  Future<TransactionModel?> processCheckout(
    BuildContext context,
  ) async {
    if (namaPemesan.value.trim().isEmpty) {
      throw Exception('Nama pemesan wajib diisi.');
    }

    String opsiFormatLaravel =
        selectedOrderType.value.toLowerCase() ==
                'dine in'
            ? 'dine in'
            : 'take away';

    if (opsiFormatLaravel == 'dine in' &&
        tableNumber.value.isEmpty) {
      throw Exception(
        'Nomor meja belum diisi.',
      );
    }

    if (paymentMethod.value == 'qris' &&
        imageProofXFile.value == null) {
      throw Exception(
        'Bukti pembayaran QRIS wajib diupload.',
      );
    }

    final CartController cartController =
        Get.find<CartController>();

    if (cartController.cartItems.isEmpty) {
      throw Exception(
        'Keranjang belanja masih kosong.',
      );
    }

    try {
      isLoading(true);

      List<Map<String, dynamic>> formattedItems =
          cartController.cartItems.map((cartItem) {
        return {
          "id_menu": cartItem.id,
          "qty": cartItem.quantity,
          "toppings":
              cartItem.selectedToppings.map((topItem) {
            return {
              "id_topping": topItem.id,
              "qty": topItem.quantity,
            };
          }).toList(),
        };
      }).toList();

      final result =
          await _transactionService.checkout(
        namaPemesan: namaPemesan.value,
        noMeja: opsiFormatLaravel == 'take away'
            ? null
            : tableNumber.value,
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

  // ===========================================================================
  // ADMIN METHODS
  // ===========================================================================

  double hitungTotalOrder(
    Map<String, dynamic> order,
  ) {
    var rawHargaTotal =
        order['harga_total'] ??
            order['total_harga'] ??
            order['total_price'];

    if (rawHargaTotal != null) {
      double parsedHarga =
          double.tryParse(rawHargaTotal.toString()) ??
              0.0;

      if (parsedHarga > 0) {
        return parsedHarga;
      }
    }

    double total = 0.0;

    var itemsList =
        order['pesanan_menus'] ??
            order['items'] ??
            order['pesanan'];

    if (itemsList is List) {
      for (var item in itemsList) {
        if (item == null) continue;

        double hargaMenuDasar = 0.0;

        var menuData = item['menu'];

        if (menuData != null &&
            menuData['harga'] != null) {
          hargaMenuDasar =
              double.tryParse(
                menuData['harga'].toString(),
              ) ??
              0.0;
        } else {
          hargaMenuDasar = double.tryParse(
                item['harga_satuan']?.toString() ??
                    item['harga']?.toString() ??
                    "0",
              ) ??
              0.0;
        }

        double totalToppingPerMenu = 0.0;

        var toppings =
            item['pesanan_toppings'] ??
                item['toppings'] ??
                [];

        if (toppings is List) {
          for (var t in toppings) {
            if (t == null) continue;

            var toppingMaster = t['topping'];

            double hargaTopping = double.tryParse(
                  toppingMaster?['harga']
                          ?.toString() ??
                      t['harga_satuan']
                          ?.toString() ??
                      t['harga']?.toString() ??
                      t['harga_topping']
                          ?.toString() ??
                      "0",
                ) ??
                0.0;

            int qtyTopping =
                int.tryParse(
                  t['qty']?.toString() ??
                      t['jumlah']
                          ?.toString() ??
                      "1",
                ) ??
                1;

            totalToppingPerMenu +=
                (hargaTopping * qtyTopping);
          }
        }

        int qtyMenu =
            int.tryParse(
              item['qty']?.toString() ??
                  item['jumlah']
                      ?.toString() ??
                  "1",
            ) ??
            1;

        total +=
            ((hargaMenuDasar +
                        totalToppingPerMenu) *
                    qtyMenu);
      }
    }

    return total;
  }

  Future<void> fetchDashboardStats({
    String? status,
  }) async {
    try {
      isLoading(true);

      final prefs =
          await SharedPreferences.getInstance();

      String? token = prefs.getString('token');

      if (token == null || token.isEmpty) return;

      final headersOptions = Options(
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final statsResponse = await ApiClient.dio.get(
        '/admin/stats',
        options: headersOptions,
      );

      if (statsResponse.statusCode == 200) {
        final resBody = statsResponse.data;
        final data = resBody['data'] ?? resBody;

        var rawRevenue = data['monthly_revenue'];

        if (rawRevenue != null) {
          double? parsedDouble =
              double.tryParse(
            rawRevenue.toString(),
          );

          monthlyRevenue.value =
              parsedDouble?.toInt() ?? 0;
        }

        reportMonth.value =
            data['report_month'] ?? "";

        newCustomers.value =
            int.tryParse(
              data['new_customers'].toString(),
            ) ??
            0;

        ordersToday.value =
            int.tryParse(
              data['orders_today'].toString(),
            ) ??
            0;
      }
    } catch (e) {
      debugPrint(
        "Gagal sinkron data dashboard: $e",
      );
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchOrderDetail(
    String transactionId,
  ) async {
    if (transactionId.isEmpty ||
        transactionId == '0') {
      return;
    }

    try {
      isLoading(true);

      currentOrderItems.clear();

      final prefs =
          await SharedPreferences.getInstance();

      String? token = prefs.getString('token');

      final response = await ApiClient.dio.get(
        '/admin/transactions/$transactionId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        final resBody = response.data;

        final orderData =
            resBody['data'] ?? resBody;

        var items =
            orderData['pesanan_menus'] ??
                orderData['items'] ??
                [];

        currentOrderItems.assignAll(items);
      }
    } catch (e) {
      debugPrint("Gagal detail: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<bool> updateTransactionStatus(
    BuildContext context,
    String orderId,
    String status,
  ) async {
    if (orderId.isEmpty || orderId == '0') {
      return false;
    }

    try {
      isLoading(true);

      final prefs =
          await SharedPreferences.getInstance();

      String? token = prefs.getString('token');

      final headersOptions = Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      String urlPath = '';

      if (status == 'done') {
        urlPath =
            '/admin/transactions/$orderId/apply';
      } else {
        urlPath =
            '/admin/transactions/$orderId/reject';
      }

      final response = await ApiClient.dio.post(
        urlPath,
        options: headersOptions,
      );

      if (response.statusCode == 200 ||
          response.statusCode == 201) {
        if (Get.isRegistered<
            custom_menu.MenuController>()) {
          Get.find<custom_menu.MenuController>()
              .clearCache();
        }

        if (Get.isRegistered<
            ToppingController>()) {
          Get.find<ToppingController>()
              .clearCache();
        }

        await fetchDashboardStats();
        await fetchOrderDetail(orderId);

        return true;
      }

      return false;
    } catch (e) {
      debugPrint(
        "❌ Error update status: $e",
      );

      return false;
    } finally {
      isLoading(false);
    }
  }
}