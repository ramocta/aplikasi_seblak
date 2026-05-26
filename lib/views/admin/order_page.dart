import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:seblak_say_cafe/controllers/order_controller.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  final OrderController controller = Get.find<OrderController>();
  // Default filter "all" sesuai dengan backend
  String activeStatus = "all";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchDashboardStats();
    });
  }

  // === 1. FUNGSI FORMAT RUPIAH YANG SUDAH DIPERBAIKI & AMAN ===
  String formatRupiah(dynamic harga) {
    try {
      if (harga == null) return "Rp0";
      
      // Amankan parsing dari tipe data apapun (int/double/string)
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
          result = ".$result";
        }
      }
      return "Rp$result";
    } catch (e) {
      return "Rp$harga";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          // === FILTER BUTTONS TABS (SINKRON 100% SAMA DATABASE) ===
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              children: [
                _buildFilterButton("All Orders", "all"),
                const SizedBox(width: 8),
                _buildFilterButton("Pending", "pending"),
                const SizedBox(width: 8),
                _buildFilterButton("Done", "done"),
                const SizedBox(width: 8),
                _buildFilterButton("Reject", "reject"),
              ],
            ),
          ),

          // === LIST TRANSAKSI UTAMA ===
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD32F2F)),
                  ),
                );
              }

              // Filter list data dari controller berdasarkan status transaksi asli di database
              var filteredList = controller.recentActivities.where((activity) {
                if (activeStatus == "all") return true;
                
                String currentStatus = (activity['status_pesanan'] ?? activity['status'] ?? "pending")
                    .toString()
                    .toLowerCase()
                    .trim();
                    
                return currentStatus == activeStatus;
              }).toList();

              if (filteredList.isEmpty) {
                return const Center(
                  child: Text(
                    "No orders available.", 
                    style: TextStyle(color: Colors.grey, fontSize: 15),
                  ),
                );
              }

              return ListView.builder(
                itemCount: filteredList.length,
                padding: const EdgeInsets.all(16),
                itemBuilder: (context, index) {
                  final order = filteredList[index];

                  String orderId = (order['id_transaksi'] ?? order['id'] ?? "0").toString();
                  String namaPemesan = order['nama_pemesan'] ?? "Tanpa Nama";

                  // 1. Ambil nilai double murni dari controller (Hasil kalkulasi: 18000.0)
                  double totalHargaDouble = controller.hitungTotalOrder(order);

                  // 2. Format hasilnya menggunakan fungsi formatRupiah yang sudah kita perbaiki
                  String totalHargaText = formatRupiah(totalHargaDouble);

                  // Deteksi status dari database Laravel ('pending', 'done', 'reject')
                  String status = (order['status_pesanan'] ?? order['status'] ?? "pending").toString().toLowerCase().trim();

                  String itemsDetail = controller.getMenuSummary(order);
                  bool isPending = status == 'pending';

                  // Pengkondisian warna badge & text badge murni dari status database
                  Color badgeBgColor = const Color(0xFFFFF8E1);
                  Color badgeTextColor = Colors.orange[800]!;
                  String textBadge = "PENDING";

                  if (status == 'done') {
                    badgeBgColor = const Color(0xFFE8F5E9);
                    badgeTextColor = Colors.green[700]!;
                    textBadge = "DONE"; 
                  } else if (status == 'reject') {
                    badgeBgColor = const Color(0xFFFFEBEE);
                    badgeTextColor = Colors.red[700]!;
                    textBadge = "REJECT"; 
                  }

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isPending ? const Color(0xFFFFE0B2) : Colors.grey.withOpacity(0.2),
                        width: isPending ? 2 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "#ORD-$orderId",
                                style: TextStyle(
                                  color: isPending ? const Color(0xFFD32F2F) : Colors.grey[600],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: badgeBgColor,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  textBadge,
                                  style: TextStyle(
                                    color: badgeTextColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            namaPemesan,
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            "Items:",
                            style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            itemsDetail,
                            style: const TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Text(
                                  order['tanggal_transaksi'] ?? order['created_at'] ?? "Today", 
                                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                totalHargaText, // Memanggil String "Rp18.000" yang sudah matang dari atas
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFEEEEEE),
                                foregroundColor: Colors.black87,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              onPressed: () async {
                                String currentId = (order['id_transaksi'] ?? order['id'] ?? '0').toString();
                                debugPrint("🔥 Mencoba masuk ke detail untuk ID Transaksi: $currentId");

                                if (context.mounted) {
                                  context.push('/order_detail', extra: order);
                                }

                                await controller.fetchOrderDetail(currentId);
                              },
                              child: const Text("Detail", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String label, String statusKey) {
    bool isSelected = activeStatus == statusKey;
    return Expanded(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? const Color(0xFFE64A19) : const Color(0xFFF5F5F5),
          foregroundColor: isSelected ? Colors.white : Colors.black54,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        ),
        onPressed: () {
          setState(() {
            activeStatus = statusKey;
          });
        },
        child: Text(
          label, 
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11, 
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
          ),
        ),
      ),
    );
  }
}