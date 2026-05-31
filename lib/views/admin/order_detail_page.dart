import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:get/get.dart';
import '../../../controllers/order_controller.dart'; 
import '../widgets/admin/order_detail_bottom_sheet.dart';


class OrderDetailPage extends StatefulWidget {
  final Map<String, dynamic> orderData;

  const OrderDetailPage({super.key, required this.orderData});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  late RxString reactiveStatusPesanan;
  late String rawId;
  late OrderController controller;

  @override
  void initState() {
    super.initState();
    
    String initialStatus = (widget.orderData['status_pesanan'] ?? widget.orderData['status'] ?? "pending").toString();
    reactiveStatusPesanan = initialStatus.obs;
    rawId = (widget.orderData['id_transaksi'] ?? widget.orderData['id'] ?? "0").toString();

    try {
      controller = Get.find<OrderController>();
    } catch (e) {
      debugPrint("OrderController di-inject ulang di Detail Page");
      controller = Get.put(OrderController());
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchOrderDetail(rawId);
    });
  }

  String formatRupiah(dynamic harga) {
    try {
      if (harga == null) return "Rp0";
      double parsed = double.parse(harga.toString());
      int value = parsed.toInt();
      String valueStr = value.toString();
      if (valueStr.length <= 3) return "Rp$valueStr";
      
      String result = "";
      int count = 0;
      for (int i = valueStr.length - 1; i >= 0; i--) {
        result = valueStr[i] + result;
        count++;
        if (count % 3 == 0 && i != 0) {
          result = "." + result;
        }
      }
      return "Rp$result";
    } catch (e) {
      return "Rp$harga";
    }
  }

  void _showUpdateStatusSheet(BuildContext context, String currentOrderId) {
    OrderDetailBottomSheet.showUpdateStatusSheet(
      context: context,
      currentOrderId: currentOrderId,
      reactiveStatusPesanan: reactiveStatusPesanan,
    );
  }


  @override
  Widget build(BuildContext context) {
    const primaryOrange = Color(0xFFE64A19);

    String formattedOrderId = rawId.padLeft(3, '0');
    String namaPemesan = widget.orderData['nama_pemesan']?.toString() ?? "Tanpa Nama";
    String noMeja = widget.orderData['no_meja']?.toString() ?? "-";
    
    String tipePesanan = (widget.orderData['opsi_pemesanan'] ?? widget.orderData['tipe_pesanan'] ?? widget.orderData['order_type'] ?? "dine in").toString().toLowerCase();
    bool isTakeaway = tipePesanan.contains('take away') || tipePesanan.contains('takeaway') || noMeja == '-' || noMeja == '0' || noMeja.toLowerCase() == 'takeaway';

    String dbPaymentMethod = (widget.orderData['payment_method'] ?? "tunai").toString().toLowerCase();
    String displayPayment = dbPaymentMethod == 'qris' ? "Paid via QRIS" : "Paid via Tunai";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            controller.fetchDashboardStats();
            context.go('/order');
          },
        ),
        title: const Text('Order Detail', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16, top: 12, bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
                color: const Color(0xFFFFE0B2),
                borderRadius: BorderRadius.circular(20)),
            child: Center(
              child: Text('#ORD-$formattedOrderId',
                  style: const TextStyle(color: primaryOrange, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Customer Information', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(namaPemesan, 
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const CircleAvatar(
                          backgroundColor: Color(0xFFF5F5F5),
                          child: Icon(Icons.person, color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(isTakeaway ? Icons.shopping_bag_rounded : Icons.table_restaurant, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(isTakeaway ? 'Takeaway' : 'Table $noMeja — Dine-In', style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 32),
                  
                  // ✅ FIXED: Menggunakan Row dengan pembungkus Expanded agar tidak RenderFlex Overflow bocor ke kanan
                  Obx(() {
                    String currentStatus = reactiveStatusPesanan.value;
                    Color statusColor = Colors.orange;
                    if (currentStatus.toLowerCase() == 'selesai' || currentStatus.toLowerCase() == 'done') {
                      statusColor = Colors.green;
                    } else if (currentStatus.toLowerCase() == 'reject') {
                      statusColor = Colors.red;
                    }

                    String displayStatus = currentStatus.toLowerCase() == 'done' ? 'Selesai' : currentStatus.capitalizeFirst!;

                    return Row(
                      children: [
                        _buildStatusCard("Payment Status", displayPayment, Colors.blue),
                        _buildStatusCard("Order Status", displayStatus, statusColor),
                      ],
                    );
                  }),
                  
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Order Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Obx(() => Text('${controller.currentOrderItems.length} Items', style: const TextStyle(color: Colors.grey))),
                    ],
                  ),
                  const Divider(height: 32),
                  
                  Obx(() {
                    if (controller.isLoading.value) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 32),
                        child: Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(primaryOrange))),
                      );
                    }

                    var itemsList = controller.currentOrderItems;

                    if (itemsList.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(child: Text("No items found", style: TextStyle(color: Colors.grey))),
                      );
                    }

                    List<Widget> orderItemWidgets = itemsList.map((item) {
                      if (item == null) return const SizedBox.shrink();
                      
                      String namaMenu = "Menu Tidak Diketahui";
                      if (item['menu'] != null && item['menu']['nama_menu'] != null) {
                        namaMenu = item['menu']['nama_menu'].toString();
                      } else if (item['nama_menu'] != null) {
                        namaMenu = item['nama_menu'].toString();
                      }
                      
                      double hargaMenuBase = 0.0;
                      if (item['menu'] != null && item['menu']['harga'] != null) {
                        hargaMenuBase = double.tryParse(item['menu']['harga'].toString()) ?? 0.0;
                      } else {
                        hargaMenuBase = double.tryParse(item['harga_satuan']?.toString() ?? item['harga']?.toString() ?? "0") ?? 0.0;
                      }
                      
                      int qty = int.tryParse(item['qty']?.toString() ?? item['jumlah']?.toString() ?? "1") ?? 1;

                      var toppings = item['pesanan_toppings'] ?? item['toppings'] ?? [];
                      List<Widget> toppingWidgets = [];
                      
                      if (toppings is List && toppings.isNotEmpty) {
                        for (var t in toppings) {
                          if (t != null) {
                            String namaTopping = "Topping";
                            if (t['topping'] != null) {
                              namaTopping = (t['topping']['nama_topping'] ?? t['topping']['nama'] ?? "Topping").toString();
                            } else {
                              namaTopping = (t['nama_topping'] ?? "Topping").toString();
                            }

                            int toppingQty = int.tryParse(t['qty']?.toString() ?? t['jumlah']?.toString() ?? "1") ?? 1;
                            
                            // ──> 1. AMBIL HARGA SATUAN TOPPING DARI DATA API/DATABASE
                            double hargaToppingSatuan = 0.0;
                            if (t['topping'] != null) {
                              hargaToppingSatuan = double.tryParse(t['topping']['harga']?.toString() ?? "0") ?? 0.0;
                            } else {
                              hargaToppingSatuan = double.tryParse(t['harga_satuan']?.toString() ?? t['harga']?.toString() ?? "0") ?? 0.0;
                            }

                            // ──> 2. HITUNG TOTAL HARGA BERDASARKAN QUANTITY TOPPING
                            double totalHargaToppingIni = hargaToppingSatuan * toppingQty;

                            // ✅ POTONGAN KODE INI YANG MEMUNCULKAN HARGA TOPPING
                            toppingWidgets.add(
                              Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween, // <-- Membuat nama di kiri, harga di kanan
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "• $namaTopping (x$toppingQty)", 
                                        style: const TextStyle(color: Colors.grey, fontSize: 13, height: 1.2),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    // ──> 3. TAMPILKAN NOMINAL HARGA DI SINI (Garis merah dijamin hilang!)
                                    Text(
                                      formatRupiah(totalHargaToppingIni), 
                                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                        }
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    namaMenu, 
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // ✅ PERBAIKAN 3: Sesuai Gambar, Sebelah Kanan Menu Menampilkan Harga Menu Murni
                                Text(
                                  formatRupiah(hargaMenuBase), 
                                  style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15, color: Colors.black54),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            
                            if (toppingWidgets.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(left: 8, top: 4, bottom: 4),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: toppingWidgets,
                                ),
                              ),
                            
                            const SizedBox(height: 6),
                            
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                // ✅ SEKARANG DISINI HANYA MENAMPILKAN QUANTITY SAJA (Harga total item dihapus dari baris ini)
                                Text(
                                  "Qty: $qty", 
                                  style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList();

                    return Column(
                      children: [
                        ...orderItemWidgets,
                        const Divider(height: 32),
                        // ✅ PERBAIKAN 4: Data Subtotal dan Total Price sekarang ditarik Real-Time dari Controller yang sudah presisi
                        _buildPriceRow("Subtotal", formatRupiah(controller.subtotal)),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total Price', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            Text(
                              formatRupiah(controller.grandTotal),
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primaryOrange),
                            ),
                          ],
                        ),
                      ],
                    );
                  }),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // === SECTION BOTTOM NAVIGATION BAR ===
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, -2))]),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton.icon(
                    // ✅ PERBAIKAN: Gunakan variabel rawId yang sudah diinisialisasi di initState
                    onPressed: () {
                      context.push('/print-receipt/$rawId');
                    },
                    icon: const Icon(Icons.print, color: Colors.white),
                    label: const Text("Print Receipt", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: primaryOrange,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  ),
                ),
                const SizedBox(height: 12),
                
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton.icon(
                    // UBAH BARIS INI: Tambahkan rawId ke dalam fungsi
                    onPressed: () => _showUpdateStatusSheet(context, rawId), 
                    icon: const Icon(Icons.sync_alt_rounded, color: Colors.black87),
                    label: const Text(
                      "Update Status", 
                      style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF2F2F2),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String price) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 16)),
        Text(price, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
      ],
    );
  }

  Widget _buildStatusCard(String title, String status, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(color: const Color(0xFFF9F9F9), borderRadius: BorderRadius.circular(8)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Colors.grey, fontSize: 11)),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.circle, size: 7, color: color),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    status, 
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12), 
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}