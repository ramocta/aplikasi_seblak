import 'package:flutter/material.dart' hide MenuController;
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
// Alias tetap dipakai supaya tidak bentrok dengan material.dart
import 'package:seblak_say_cafe/controllers/menu_controller.dart' as menu_controller;

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  // Menginstansiasi GetX Controller di luar build method agar efisien
  final menu_controller.MenuController controller = Get.put(menu_controller.MenuController());

  @override
  void initState() {
    super.initState();
    // Auto-refresh data menu saat halaman pertama kali dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.refreshData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Obx(() {
        // 1. Tampilan Loading
        if (controller.isLoading.value && controller.listCategories.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFFE64A19)));
        }

        // 2. Tampilan Error
        if (controller.errorMessage.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(controller.errorMessage.value, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => controller.refreshData(),
                  child: const Text("Coba Lagi"),
                )
              ],
            ),
          );
        }

        return Column(
          children: [
            // Filter Tabs Kategori (Dinamis dari listCategories)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: controller.listCategories.map((cat) {
                    return _buildCategoryTab(
                      label: cat.nama,
                      id: cat.id,
                      isActive: controller.selectedCategoryId.value == cat.id,
                      onTap: () => controller.changeCategory(cat.id),
                    );
                  }).toList(),
                ),
              ),
            ),

            // List Data Menu Sesuai Kategori
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => controller.refreshData(),
                child: controller.listMenu.isEmpty
                    ? const Center(child: Text("Tidak ada menu di kategori ini"))
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 80), // Jaga jarak aman dari FAB
                        itemCount: controller.listMenu.length,
                        itemBuilder: (context, index) {
                          final menu = controller.listMenu[index];
                          return _buildMenuTile(
                            context,
                            name: menu.nama,
                            desc: "",
                            price: menu.harga.toString(),
                            stock: menu.stok.toString(),
                            fullData: menu,
                          );
                        },
                      ),
              ),
            ),
          ],
        );
      }),
      
      floatingActionButton: FloatingActionButton(
        // SINKRONISASI: Pakai context.go agar navbar bawah tetap utuh
        onPressed: () => context.go('/add_menu'),
        backgroundColor: const Color(0xFFE64A19),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }

  Widget _buildCategoryTab({
    required String label,
    required int id,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0),
      child: GestureDetector(
        onTap: onTap,
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
              color: isActive ? Colors.white : Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuTile(BuildContext context, {
    required String name,
    required String desc,
    required String price,
    required String stock,
    required dynamic fullData,
  }) {
    // === LOGIKA WARNA STOK DINAMIS ===
    // Mengubah data stock dari teks (String) ke angka (int) dengan aman
    final int stockValue = int.tryParse(stock) ?? 0;
    Color stockColor;
    String stockLabel;

    if (stockValue >= 10) {
      stockColor = Colors.green.shade700; // Aman (Hijau segar redup)
      stockLabel = "Stok: $stock";
    } else if (stockValue > 0 && stockValue <= 9) {
      stockColor = Colors.amber.shade800; // Warning (Oranye tua/Kuning gelap)
      stockLabel = "Stok Menipis: $stock";
    } else {
      stockColor = Colors.red.shade700; // Bahaya/Kosong (Merah tua)
      stockLabel = "Stok Habis";
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05), 
            blurRadius: 5, 
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 70,
              height: 70,
              child: fullData.gambarUrl.isEmpty || fullData.gambarUrl == '-'
                  ? const Icon(Icons.broken_image, color: Colors.grey)
                  : Image.network(
                      fullData.gambarUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.broken_image, color: Colors.grey);
                      },
                    ),
            ),
          ), 
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name, 
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  "Harga: Rp $price", 
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                // Text Stok yang warnanya berubah sesuai kondisi jumlahnya
                Text(
                  stockLabel, 
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: stockColor),
                ),
              ],
            ),
          ),
          Row(
            children: [
              _buildActionButton(Icons.edit, Colors.orange, () {
                context.go('/edit_menu', extra: fullData);
              }),
              const SizedBox(width: 8),
              _buildActionButton(Icons.delete, Colors.red, () {
                _showDeleteMenuDialog(context, fullData);
              }),
            ],
          ),
        ],
      ),
    );
  } 

  Widget _buildActionButton(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  // ==================== FIX DIALOG PENGAMAN HAPUS MENU ====================
  void _showDeleteMenuDialog(BuildContext context, dynamic menu) {
    showDialog(
      context: context,
      barrierDismissible: false, // User wajib klik tombol pilihan di dalam dialog
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red),
              SizedBox(width: 8),
              Text("Hapus Menu", style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: Text("Apakah anda yakin ingin menghapus '${menu.nama}'? Tindakan ini tidak dapat dibatalkan."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext), // Tutup dialog dengan aman
              child: const Text("Batal", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              onPressed: () async {
                // 1. Tutup dialognya dulu agar overlay dilepas dari browser web
                Navigator.pop(dialogContext);
                
                try {
                  // Ambil ID menu secara dinamis
                  final int idMenu = menu is Map ? (menu['id'] ?? 0) : (menu.id ?? 0);
                  
                  // 2. Jalankan fungsi delete menu aslinya ke database Laravel via controller
                  await controller.deleteMenu(idMenu);
                  
                  // Jeda tipis 300 milidetik demi kelancaran update state & UI di Flutter Web
                  await Future.delayed(const Duration(milliseconds: 300));

                  // 3. Tarik data terbaru yang sudah bersih dari database server
                  await controller.refreshData();

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: Colors.green, 
                        content: Text("Menu '${menu.nama}' berhasil dihapus!")
                      ),
                    );
                  }
                } catch (e) {
                  // Catch error jika token expired, server down, atau foreign key constraint di DB
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: Colors.red, 
                        content: Text("Gagal menghapus menu dari database: $e")
                      ),
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