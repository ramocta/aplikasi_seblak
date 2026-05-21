import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:seblak_say_cafe/controllers/menu_controller.dart' as my_ctrl;
import 'package:seblak_say_cafe/controllers/cart_controller.dart';
import 'package:seblak_say_cafe/core/constans/app_color.dart';
import 'package:seblak_say_cafe/core/constans/app_assets.dart';
import '../widgets/item_menu.dart';
import '../widgets/menu_rectangle.dart';
import '../widgets/table_number.dart';
import '../widgets/custom_button.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(my_ctrl.MenuController());
    final cartController = Get.find<CartController>();

    return Scaffold(
      backgroundColor: AppColors.page,
      body: Stack(
        children: [
          // ==================== KONTEN UTAMA ====================
          Column(
            children: [
              // HEADER (Back, Logo, Menu)
              Container(
                padding: const EdgeInsets.only(
                  top: 20,
                  left: 16,
                  right: 16,
                  bottom: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: AppColors.primary,
                      ),
                      onPressed: () => context.pop(),
                    ),
                    Image.asset(
                      AppAssets.logo2,
                      height: 80,
                    ), // Sesuaikan ukuran logo
                    IconButton(
                      icon: const Icon(
                        Icons.menu,
                        color: AppColors.primary,
                        size: 28,
                      ),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),

              // BANNER PROMO
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                height: 160,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: DecorationImage(
                    image: AssetImage(AppAssets.bannerPromo),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // KONTEN MENU (Table Number + Kategori + List)
              Expanded(
                child: MenuRectangle(
                  child: Obx(() {
                    if (controller.isLoading.value &&
                        controller.listMenu.isEmpty) {
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
                                  ? const Center(
                                      child: Text(
                                        "There are no items for this category",
                                      ),
                                    )
                                  : ListView.builder(
                                      padding: const EdgeInsets.only(
                                        left: 16,
                                        right: 16,
                                        bottom: 80,
                                      ),
                                      itemCount: controller.listMenu.length,
                                      itemBuilder: (context, index) {
                                        final menu = controller.listMenu[index];
                                        return ItemMenu(
                                          id: menu.id,
                                          namaMenu: menu.nama,
                                          harga: menu.harga,
                                          gambarUrl: menu.gambarUrl,
                                          idKategoriMenu: menu.kategorimenu.id,
                                        );
                                      },
                                    ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ],
          ),

          // FLOATING VIEW CART BUTTON
          Positioned(
            bottom: 20,
            left: 16,
            right: 16,
            child: Obx(() {
              return Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  // 1. Tombol Utama (Selalu Ada)
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      text: 'View cart',
                      onPressed: () => context.push('/cart'),
                    ),
                  ),

                  // 2. Badge Merah (Hanya muncul jika totalItems > 0)
                  if (cartController.totalItems > 0)
                    Positioned(
                      // Mengatur posisi badge tepat di pojok kanan atas tombol
                      top: -8,
                      right: 15,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape
                              .circle, // Solusi untuk BoxType tidak terdefinisi
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 28,
                          minHeight: 28,
                        ),
                        child: Center(
                          child: Text(
                            '${cartController.totalItems}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(my_ctrl.MenuController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 60, color: Colors.red),
          const SizedBox(height: 16),
          Text(controller.errorMessage.value, textAlign: TextAlign.center),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: controller.refreshData,
            child: const Text("Coba Lagi"),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryNav(my_ctrl.MenuController controller) {
    return Container(
      height: 45,
      margin: const EdgeInsets.symmetric(vertical: 8),
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
                duration: const Duration(milliseconds: 100),
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.symmetric(horizontal: 22),
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFFE53935)
                      : const Color(0xFFF3F3F3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    cat.nama,
                    style: TextStyle(
                      color: isActive ? Colors.white : Colors.grey[700],
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
