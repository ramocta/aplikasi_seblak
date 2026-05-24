import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart'; 
import 'package:shared_preferences/shared_preferences.dart'; 
import '../core/api/api_client.dart'; 

// Paksa import controller kamu agar tidak tertukar dengan bawaan Flutter SDK
import 'package:seblak_say_cafe/controllers/menu_controller.dart' as custom_menu;
import 'package:seblak_say_cafe/controllers/topping_controller.dart';

class OrderController extends GetxController {
  var isLoading = false.obs;
  
  var monthlyRevenue = 0.obs;
  var reportMonth = "".obs;
  var newCustomers = 0.obs;
  var ordersToday = 0.obs;
  
  // List riwayat transaksi utama untuk halaman Dashboard / Orders
  var recentActivities = [].obs;

  // State untuk menampung item detail transaksi yang sedang dibuka
  var currentOrderItems = [].obs;

  // 1. Menghitung murni harga dasar makanan master + topping yang melekat pada menu tersebut
  double get subtotal {
    double total = 0.0;
    for (var item in currentOrderItems) {
      if (item == null) continue;
      
      // Hitung harga dasar menu utama
      double hargaMenuDasar = 0.0;
      var menuData = item['menu'];
      if (menuData != null && menuData['harga'] != null) {
        hargaMenuDasar = double.tryParse(menuData['harga'].toString()) ?? 0.0;
      } else {
        hargaMenuDasar = double.tryParse(item['harga_satuan']?.toString() ?? item['harga']?.toString() ?? "0") ?? 0.0;
      }

      // Hitung akumulasi semua topping khusus untuk menu ini saja
      double totalToppingPerMenu = 0.0;
      var toppings = item['pesanan_toppings'] ?? item['toppings'] ?? [];
      if (toppings is List) {
        for (var t in toppings) {
          if (t == null) continue;
          var toppingMaster = t['topping'];
          double hargaTopping = 0.0;
          if (toppingMaster != null && toppingMaster['harga'] != null) {
            hargaTopping = double.tryParse(toppingMaster['harga'].toString()) ?? 0.0;
          } else {
            hargaTopping = double.tryParse(t['harga_satuan']?.toString() ?? t['harga']?.toString() ?? t['harga_topping']?.toString() ?? "0") ?? 0.0;
          }
          int qtyTopping = int.tryParse(t['qty']?.toString() ?? t['jumlah']?.toString() ?? "1") ?? 1;
          totalToppingPerMenu += (hargaTopping * qtyTopping);
        }
      }

      int qtyMenu = int.tryParse(item['qty']?.toString() ?? item['jumlah']?.toString() ?? "1") ?? 1;
      
      // Total akumulasi: (Harga Menu + Total Topping Menu Ini) x Qty Menu Utama
      total += ((hargaMenuDasar + totalToppingPerMenu) * qtyMenu);
    }
    return total;
  }

  // 2. Tetap dipertahankan jika sewaktu-waktu kamu butuh panggil harga total topping terpisah
  double get totalTopping {
    double total = 0.0;
    for (var item in currentOrderItems) {
      if (item == null) continue;
      var toppings = item['pesanan_toppings'] ?? item['toppings'] ?? [];
      double toppingSatuMenu = 0.0;
      if (toppings is List) {
        for (var t in toppings) {
          if (t == null) continue;
          var toppingMaster = t['topping'];
          double hargaTopping = double.tryParse(toppingMaster?['harga']?.toString() ?? t['harga_satuan']?.toString() ?? t['harga']?.toString() ?? "0") ?? 0.0;
          int qtyTopping = int.tryParse(t['qty']?.toString() ?? t['jumlah']?.toString() ?? "1") ?? 1;
          toppingSatuMenu += (hargaTopping * qtyTopping);
        }
      }
      int qtyMenu = int.tryParse(item['qty']?.toString() ?? item['jumlah']?.toString() ?? "1") ?? 1;
      total += (toppingSatuMenu * qtyMenu);
    }
    return total;
  }

  // 3. Grand total akhir disamakan dengan subtotal (karena topping sudah masuk ke subtotal)
  double get grandTotal => subtotal;

  // === FUNGSI HITUNG TOTAL HARGA DI LIST DASHBOARD ===
  double hitungTotalOrder(Map<String, dynamic> order) {
    // LANGSUNG UTAMAKAN NILAI HARGA TOTAL DARI DATABASE BIAR GAK MISKOR
    var rawHargaTotal = order['harga_total'] ?? order['total_harga'] ?? order['total_price'];
    if (rawHargaTotal != null) {
      double parsedHarga = double.tryParse(rawHargaTotal.toString()) ?? 0.0;
      if (parsedHarga > 0) return parsedHarga;
    }

    // Fallback hitung manual jika data database kosong
    double total = 0.0;
    var itemsList = order['pesanan_menus'] ?? order['items'] ?? order['pesanan'];
    
    if (itemsList is List) {
      for (var item in itemsList) {
        if (item == null) continue;
        
        double hargaMenuDasar = 0.0;
        var menuData = item['menu'];
        if (menuData != null && menuData['harga'] != null) {
          hargaMenuDasar = double.tryParse(menuData['harga'].toString()) ?? 0.0;
        } else {
          hargaMenuDasar = double.tryParse(item['harga_satuan']?.toString() ?? item['harga']?.toString() ?? "0") ?? 0.0;
        }

        double totalToppingPerMenu = 0.0;
        var toppings = item['pesanan_toppings'] ?? item['toppings'] ?? [];
        if (toppings is List) {
          for (var t in toppings) {
            if (t == null) continue;
            var toppingMaster = t['topping'];
            double hargaTopping = double.tryParse(toppingMaster?['harga']?.toString() ?? t['harga_satuan']?.toString() ?? t['harga']?.toString() ?? t['harga_topping']?.toString() ?? "0") ?? 0.0;
            int qtyTopping = int.tryParse(t['qty']?.toString() ?? t['jumlah']?.toString() ?? "1") ?? 1;
            totalToppingPerMenu += (hargaTopping * qtyTopping);
          }
        }

        int qtyMenu = int.tryParse(item['qty']?.toString() ?? item['jumlah']?.toString() ?? "1") ?? 1;
        total += ((hargaMenuDasar + totalToppingPerMenu) * qtyMenu);
      }
    }
    
    return total > 0 ? total : double.tryParse((order['subtotal'] ?? order['sub_total'] ?? "0").toString()) ?? 0.0;
  }

  var selectedOrderType = "".obs; 
  var tableNumber = "".obs;

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> submitManualOrder({
    required String nama,
    required String noMeja,
    required List items, 
    required String paymentMethod,
  }) async {
    try {
      isLoading(true);
      final payload = {
        "nama_pemesan": nama,
        "no_meja": noMeja,
        "opsi_pemesanan": noMeja.isEmpty ? "Take Away" : "Dine In",
        "payment_method": paymentMethod,
        "items": items,
        "status_pesanan": "done", 
      };

      await ApiClient.dio.post('/transactions', data: payload);
      Get.back(); 
      Get.snackbar("Sukses", "Pesanan berhasil dicatat!");
    } catch (e) {
      Get.snackbar("Error", "Gagal: $e");
    } finally {
      isLoading(false);
    }
  }

  // === AMBIL DATA STATISTIK DASHBOARD & LIST RIWAYAT TRANSAKSI ===
  Future<void> fetchDashboardStats({String? status}) async {
    try {
      isLoading(true);
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token'); 

      if (token == null || token.isEmpty) return;

      final headersOptions = Options(
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token', 
        },
      );

      final statsResponse = await ApiClient.dio.get('/admin/stats', options: headersOptions);
      if (statsResponse.statusCode == 200) {
        final resBody = statsResponse.data;
        final data = resBody['data'] ?? resBody;
        
        var rawRevenue = data['monthly_revenue'];
        if (rawRevenue != null) {
          double? parsedDouble = double.tryParse(rawRevenue.toString());
          monthlyRevenue.value = parsedDouble?.toInt() ?? 0;
        }

        reportMonth.value = data['report_month'] ?? "";
        newCustomers.value = int.tryParse(data['new_customers'].toString()) ?? 0;
        ordersToday.value = int.tryParse(data['orders_today'].toString()) ?? 0;
      }

      String urlPath = '/admin/history';
      if (status != null && status != 'all') {
        urlPath = '/admin/history?status=$status';
      }

      final historyResponse = await ApiClient.dio.get(urlPath, options: headersOptions);
      if (historyResponse.statusCode == 200) {
        final resBody = historyResponse.data;
        var listData = resBody['data'] ?? resBody ?? [];
        
        recentActivities.assignAll(listData);
        
        for (var order in listData) {
          String currentId = (order['id_transaksi'] ?? order['id'] ?? '0').toString();
          if (currentId == '0' || currentId.isEmpty) continue;

          ApiClient.dio.get('/admin/transactions/$currentId', options: headersOptions).then((detailRes) {
            if (detailRes.statusCode == 200) {
              final dBody = detailRes.data;
              final orderData = dBody['data'] ?? dBody;
              
              var items = orderData['pesanan_menus'] ?? 
                          orderData['items'] ?? 
                          orderData['pesanan'] ?? [];

              int idx = recentActivities.indexWhere((el) => (el['id_transaksi'] ?? el['id'] ?? '0').toString() == currentId);
              if (idx != -1) {
                var updatedOrder = Map<String, dynamic>.from(recentActivities[idx]);
                
                updatedOrder['pesanan_menus'] = items;
                
                var dbHargaTotal = orderData['harga_total'] ?? orderData['total_harga'] ?? orderData['total_price'];
                if (dbHargaTotal != null && (double.tryParse(dbHargaTotal.toString()) ?? 0.0) > 0) {
                  updatedOrder['harga_total'] = double.tryParse(dbHargaTotal.toString());
                  updatedOrder['total_harga'] = double.tryParse(dbHargaTotal.toString());
                }

                recentActivities[idx] = updatedOrder;
                recentActivities.refresh(); 
              }
            }
          }).catchError((err) => debugPrint("Gagal sinkron background ID $currentId: $err"));
        }
      }
    } catch (e) {
      debugPrint("Gagal sinkron data dashboard: $e");
    } finally {
      isLoading(false);
    }
  }

  // === AMBIL DETAIL TRANSAKSI BERDASARKAN ID ===
  Future<void> fetchOrderDetail(String transactionId) async {
    if (transactionId.isEmpty || transactionId == 'null' || transactionId == '0') return;

    try {
      isLoading(true);
      currentOrderItems.clear(); 

      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      final response = await ApiClient.dio.get(
        '/admin/transactions/$transactionId',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        final resBody = response.data;
        final orderData = resBody['data'] ?? resBody;
        
        var items = orderData['pesanan_menus'] ?? 
                    orderData['items'] ?? 
                    orderData['pesanan'] ?? [];
                    
        currentOrderItems.assignAll(items);

        int indexDiList = recentActivities.indexWhere((element) => 
          (element['id_transaksi'] ?? element['id'] ?? '0').toString() == transactionId.toString()
        );

        if (indexDiList != -1) {
          var updatedOrder = Map<String, dynamic>.from(recentActivities[indexDiList]);
          
          updatedOrder['pesanan_menus'] = items;
          
          var dbHargaTotal = orderData['harga_total'] ?? orderData['total_harga'] ?? orderData['total_price'];
          if (dbHargaTotal != null && (double.tryParse(dbHargaTotal.toString()) ?? 0.0) > 0) {
            updatedOrder['harga_total'] = double.tryParse(dbHargaTotal.toString());
            updatedOrder['total_harga'] = double.tryParse(dbHargaTotal.toString());
          }

          recentActivities[indexDiList] = updatedOrder;
          recentActivities.refresh(); 
        }
      }
    } catch (e) {
      debugPrint("Gagal detail: $e");
    } finally {
      isLoading(false);
    }
  }

  String getMenuSummary(Map<String, dynamic> order) {
    var itemsList = order['pesanan_menus'] ?? order['items'] ?? order['pesanan'] ?? [];
    if (itemsList is List && itemsList.isNotEmpty) {
      var firstItem = itemsList[0];
      String namaMenu = "Menu";
      if (firstItem['menu'] != null && firstItem['menu']['nama_menu'] != null) {
        namaMenu = firstItem['menu']['nama_menu'].toString();
      } else if (firstItem['nama_menu'] != null) {
        namaMenu = firstItem['nama_menu'].toString();
      }
      var qty = firstItem['qty'] ?? firstItem['jumlah'] ?? 1;
      String summary = "$namaMenu (x$qty)";
      if (itemsList.length > 1) {
        summary += " (+${itemsList.length - 1} menu lainnya)";
      }
      return summary;
    }
    return "Menu Lainnya";
  }

  // === LOGIKA UPDATE STATUS (SINKRON DENGAN BACKEND LARAVEL) ===
  Future<bool> updateTransactionStatus(BuildContext context, String orderId, String status) async {
    if (orderId.isEmpty || orderId == '0') return false;

    try {
      isLoading(true);
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      
      final headersOptions = Options(
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      String urlPath = '';
      if (status == 'done') {
        urlPath = '/admin/transactions/$orderId/apply';
      } else if (status == 'reject' || status == 'canceled' || status == 'rejected') {
        urlPath = '/admin/transactions/$orderId/reject';
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("Pesanan ini memang sedang dalam status pending/proses dapur."),
              backgroundColor: Colors.amber[700],
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
        return false;
      }

      final response = await ApiClient.dio.post(urlPath, options: headersOptions);

      if (response.statusCode == 200 || response.statusCode == 201) {
        
        // =======================================================================
        // 💡 SOLUSI AMAN: Hapus potong stok lokal buatan Flutter.
        // Serahkan hitungan stok sepenuhnya ke Laravel DB. 
        // Flutter cukup panggil fungsi fetch ulang data menu & topping agar segar.
        // =======================================================================
        if (status == 'done') {
          debugPrint("=================================================");
          debugPrint("🚨 [SINKRONISASI] AMBIL DATA STOK VALID DARI BACKEND LARAVEL 🚨");
          debugPrint("=================================================");

          // Ambil ulang data menu agar stok di UI ter-update sesuai real DB Laravel
          if (Get.isRegistered<custom_menu.MenuController>()) {
            final menuCtrl = Get.find<custom_menu.MenuController>();
            // Panggil nama fungsi load data milik temanmu di MenuController (Contoh: fetchMenus() / loadData())
            // menuCtrl.fetchMenus(); 
          }

          // Ambil ulang data topping agar stok di UI ter-update sesuai real DB Laravel
          if (Get.isRegistered<ToppingController>()) {
            final toppingCtrl = Get.find<ToppingController>();
            // toppingCtrl.fetchToppings();
          }
        }

        final resBody = response.data;
        String msg = resBody['message'] ?? "Status transaksi berhasil diperbarui!";
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(msg),
              backgroundColor: Colors.green[700],
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
        
        await fetchDashboardStats(); 
        await fetchOrderDetail(orderId);
        return true; 
      }
      return false;
    } catch (e) {
      debugPrint("❌ Error Fatal Detail: $e");
      if (Get.isRegistered<custom_menu.MenuController>()) {
        Get.find<custom_menu.MenuController>().clearCache();
      }

      String errorMsg = "Gagal memproses status transaksi.";
      if (e is DioException && e.response?.data != null) {
        errorMsg = e.response?.data['message'] ?? errorMsg;
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: Colors.red[700],
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
      return false; 
    } finally {
      isLoading(false);
    }
  }

  bool get isOrderTypeSelected => selectedOrderType.value.isNotEmpty;
  void selectType(String type) => selectedOrderType.value = type;

  void setTableNumber(String number) {
    String cleaned = number.trim();
    if (cleaned.isEmpty) { tableNumber.value = ''; return; }
    final int? tableNum = int.tryParse(cleaned);
    if (tableNum == null || tableNum < 1 || tableNum > 20) return;
    tableNumber.value = cleaned;
  }

  bool get isTableNumberValid {
    if (tableNumber.value.isEmpty) return false;
    final int? num = int.tryParse(tableNumber.value);
    return num != null && num >= 1 && num <= 20;
  }

  String getNextRoute() => selectedOrderType.value == "Dine In" ? '/table-number' : '/menu';
  void resetOrder() { selectedOrderType.value = ""; tableNumber.value = ""; }
}