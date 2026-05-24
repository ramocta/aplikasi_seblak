import 'package:flutter/material.dart' hide MenuController;
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:seblak_say_cafe/controllers/topping_controller.dart' as topping_controller;

class ToppingPage extends StatefulWidget {
  const ToppingPage({super.key});

  @override
  State<ToppingPage> createState() => _ToppingPageState();
}

class _ToppingPageState extends State<ToppingPage> {
  final topping_controller.ToppingController controller = Get.put(topping_controller.ToppingController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.refreshData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Obx(() {
        if (controller.isLoading.value && controller.listCategories.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFFE64A19)));
        }

        if (controller.errorMessage.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 50),
                const SizedBox(height: 10),
                Text(controller.errorMessage.value, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => controller.refreshData(),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE64A19)),
                  child: const Text("Coba Lagi", style: TextStyle(color: Colors.white)),
                )
              ],
            ),
          );
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: controller.listCategories.map((cat) {
                    return _buildCategoryTab(
                      label: cat.nama,
                      isActive: controller.selectedCategoryId.value == cat.id,
                      onTap: () => controller.changeCategory(cat.id),
                    );
                  }).toList(),
                ),
              ),
            ),

            Expanded(
              child: RefreshIndicator(
                onRefresh: () => controller.refreshData(),
                color: const Color(0xFFE64A19),
                child: controller.listTopping.isEmpty
                    ? const Center(child: Text("Tidak ada topping di kategori ini"))
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 80), 
                        itemCount: controller.listTopping.length,
                        itemBuilder: (context, index) {
                          final topping = controller.listTopping[index];
                          return _buildToppingTile(
                            context,
                            controller: controller,
                            topping: topping,
                          );
                        },
                      ),
              ),
            ),
          ],
        );
      }),
      
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/add_topping'),
        backgroundColor: const Color(0xFFE64A19),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }

  Widget _buildCategoryTab({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFFE64A19) : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isActive ? Colors.transparent : Colors.grey.shade300,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.grey.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToppingTile(BuildContext context, {
    required topping_controller.ToppingController controller,
    required dynamic topping,
  }) {
    // === LOGIKA WARNA & LABEL STOK TOPPING DINAMIS ===
    final int stockValue = int.tryParse(topping.stok.toString()) ?? 0;
    Color stockColor;
    String stockLabel;

    if (stockValue >= 10) {
      stockColor = Colors.green.shade700; // Aman (Hijau)
      stockLabel = "Stok: $stockValue";
    } else if (stockValue > 0 && stockValue <= 9) {
      stockColor = Colors.amber.shade800; // Warning (Oranye Tua)
      stockLabel = "Stok Menipis: $stockValue";
    } else {
      stockColor = Colors.red.shade700; // Kosong (Merah)
      stockLabel = "Stok Habis";
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 70, height: 70,
              color: const Color(0xFFE64A19).withOpacity(0.1),
              child: const Icon(Icons.fastfood, color: Color(0xFFE64A19)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(topping.nama, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 4),
                Text("Harga: Rp ${topping.harga}", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                // Text Stok dinamis mengikuti kondisi jumlah topping
                Text(
                  stockLabel, 
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: stockColor),
                ),
              ],
            ),
          ),
          Row(
            children: [
              _buildActionButton(
                icon: Icons.edit, 
                color: Colors.orange, 
                onTap: () => context.go('/edit_topping', extra: topping),
                tooltip: "Edit",
              ),
              const SizedBox(width: 8),
              _buildActionButton(
                icon: Icons.delete, 
                color: Colors.red, 
                onTap: () => _showDeleteDialog(context, controller, topping),
                tooltip: "Hapus",
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon, 
    required Color color, 
    required VoidCallback onTap,
    String? tooltip,
  }) {
    return Material(
      color: Colors.transparent,
      child: Tooltip(
        message: tooltip ?? "",
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
        ),
      ),
    );
  }

  // FIX POP-UP DIALOG HAPUS TOPPING ANTI-MACET GO_ROUTER WEB
  void _showDeleteDialog(BuildContext context, topping_controller.ToppingController controller, dynamic topping) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red),
              SizedBox(width: 8),
              Text("Hapus Topping", style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: Text("Yakin ingin menghapus topping '${topping.nama}'?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext), // Tutup dialog secara aman
              child: const Text("Batal", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              onPressed: () async {
                // 1. Singkirkan modal overlay dialog dari screen browser
                Navigator.pop(dialogContext);
                
                try {
                  // 2. Tembak fungsi controller aslinya ke database Laravel
                  await controller.deleteTopping(topping.id);
                  
                  // Jeda milidetik demi kestabilan render di web browser
                  await Future.delayed(const Duration(milliseconds: 300));

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(backgroundColor: Colors.green, content: Text("Topping '${topping.nama}' sukses dihapus!")),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(backgroundColor: Colors.red, content: Text("Gagal menghapus: $e")),
                    );
                  }
                }
              },
              child: const Text("Hapus", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}