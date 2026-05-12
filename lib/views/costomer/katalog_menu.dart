import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:seblak_say_cafe/controllers/menu_controller.dart' as my_ctrl;
import 'package:seblak_say_cafe/core/constans/app_color.dart';
import 'package:seblak_say_cafe/core/constans/app_assets.dart'; // Pastikan path ini benar
import '../widgets/item_menu.dart';
import '../widgets/menu_rectangle.dart';
import '../widgets/table_number.dart';
import '../widgets/custom_button.dart'; // Import widget CustomButton Anda

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(my_ctrl.MenuController());

    return Scaffold(
      backgroundColor: AppColors.page,
      body: Stack(
        children: [
          // ==================== 1. HEADER & BANNER IKLAN ====================
          Column(
            children: [
              const SizedBox(height: 40), // Jarak aman status bar
              // Header Logo & Menu Icon
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.red),
                      onPressed: () => Get.back(),
                    ),
                    Image.asset(AppAssets.logo2, height: 80), // Ganti dengan logo Anda
                    const Icon(Icons.menu, color: Colors.red, size: 30),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              // Banner Iklan
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                width: double.infinity,
                height: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: const DecorationImage(
                    image: AssetImage(AppAssets.bannerPromo), // Ganti asset iklan Anda
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),

          // ==================== 2. KONTEN UTAMA (WHITE BOX) ====================
          Padding(
            padding: const EdgeInsets.only(top: 250), // Menyesuaikan tinggi iklan
            child: MenuRectangle(
              child: Obx(() {
                if (controller.isLoading.value && controller.listMenu.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.errorMessage.value.isNotEmpty) {
                  return _buildErrorState(controller);
                }

                return Column(
                  children: [
                    const TableNumber(),
                    _buildCategoryNav(controller),

                    // LIST MENU
                    Expanded(
                      child: Stack(
                        children: [
                          controller.listMenu.isEmpty
                              ? const Center(child: Text("Tidak ada menu"))
                              : ListView.builder(
                                  padding: const EdgeInsets.only(
                                    left: 16, 
                                    right: 16, 
                                    bottom: 100 // Padding bawah agar tidak tertutup button
                                  ),
                                  itemCount: controller.listMenu.length,
                                  itemBuilder: (context, index) {
                                    final menu = controller.listMenu[index];
                                    return ItemMenu(
                                      namaMenu: menu.nama,
                                      harga: menu.harga,
                                      gambarUrl: menu.gambarUrl,
                                    );
                                  },
                                ),
                          
                          // Loading overlay saat ganti kategori
                          if (controller.isLoading.value && controller.listMenu.isNotEmpty)
                            const Center(child: CircularProgressIndicator()),
                        ],
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),

          // ==================== 3. FLOATING VIEW CART BUTTON ====================
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: CustomButton(
                text: 'View cart',
                onPressed: () {
                  // Fungsi nanti
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget Error State
  Widget _buildErrorState(my_ctrl.MenuController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 60, color: Colors.red),
          const SizedBox(height: 16),
          Text(controller.errorMessage.value),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: controller.refreshData,
            child: const Text("Coba Lagi"),
          ),
        ],
      ),
    );
  }

  // Widget Navigasi Kategori (Pallet warna disesuaikan)
  Widget _buildCategoryNav(my_ctrl.MenuController controller) {
    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Obx(
        () => ListView.builder(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemCount: controller.listCategories.length,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemBuilder: (context, index) {
            final cat = controller.listCategories[index];
            final bool isActive = controller.selectedCategoryId.value == cat.id;

            return GestureDetector(
              onTap: () => controller.changeCategory(cat.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: isActive ? const Color(0xFFE53935) : const Color(0xFFF3F3F3),
                  borderRadius: BorderRadius.circular(15), // Lebih kotak sedikit sesuai gambar
                ),
                child: Center(
                  child: Text(
                    cat.nama,
                    style: TextStyle(
                      color: isActive ? Colors.white : Colors.grey[600],
                      fontSize: 14,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}