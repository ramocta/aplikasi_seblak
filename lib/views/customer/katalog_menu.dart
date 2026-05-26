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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.primary),
            onPressed: () => context.pop(),
          ),
        ),
        centerTitle: true,
        title: Padding(
          padding: const EdgeInsets.only(top: 12.0),
          child: Image.asset(AppAssets.logo2, height: 90, fit: BoxFit.contain),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(top: 8.0, right: 8.0),
            child: IconButton(
              icon: const Icon(Icons.menu, color: AppColors.primary, size: 28),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // ==================== KONTEN UTAMA ====================
          Column(
            children: [
              const SizedBox(height: 15),

              // BANNER PROMO
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                height: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(13),
                  image: DecorationImage(
                    image: AssetImage(AppAssets.bannerPromo),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // KONTEN MENU
              Expanded(
                child: MenuRectangle(
                  child: Obx(() {
                    if (controller.isLoading.value &&
                        controller.listCategories.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (controller.errorMessage.value.isNotEmpty) {
                      return _buildErrorState(controller);
                    }

                    if (controller.tabController == null ||
                        controller.listCategories.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final tabController = controller.tabController!;
                    return Column(
                      children: [
                        const TableNumber(),

                        // 1. NAVIGASI DI TENGAH & BISA DI-SCROLL
                        _buildCenteredCategoryNav(controller, tabController),

                        // 2. HALAMAN MENU YANG BISA DI-GESER (SWIPEABLE)
                        Expanded(
                          child: TabBarView(
                            controller: tabController,
                            physics: const BouncingScrollPhysics(),
                            children: controller.listCategories.map((category) {
                              // ✅ OPTIMASI: Ambil dari cache langsung tanpa filtering
                              final filteredMenu = controller
                                  .getMenusByCategory(category.id);

                              if (filteredMenu.isEmpty) {
                                return const Center(
                                  child: Text(
                                    "There are no items for this category",
                                  ),
                                );
                              }

                              return ListView.builder(
                                physics: const ClampingScrollPhysics(),
                                padding: const EdgeInsets.only(
                                  left: 16,
                                  right: 16,
                                  bottom: 90,
                                ),
                                itemCount: filteredMenu.length,
                                itemBuilder: (context, index) {
                                  final menu = filteredMenu[index];
                                  return ItemMenu(
                                    id: menu.id,
                                    namaMenu: menu.nama,
                                    harga: menu.harga,
                                    gambarUrl: menu.gambarUrl,
                                    idKategoriMenu: menu.kategorimenu.id,
                                  );
                                },
                              );
                            }).toList(),
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
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      text: 'View cart',
                      onPressed: () => context.push('/cart'),
                    ),
                  ),
                  if (cartController.totalItems > 0)
                    Positioned(
                      top: -8,
                      right: 15,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
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

  // WIDGET NAVIGASI DITENGAH & OTOMATIS IKUT BERGESER
  Widget _buildCenteredCategoryNav(
    my_ctrl.MenuController controller,
    TabController tabController,
  ) {
    return Container(
      height: 45,
      margin: const EdgeInsets.symmetric(vertical: 8),
      alignment: Alignment.center,
      child: TabBar(
        isScrollable: true,
        controller: tabController,
        indicator: const BoxDecoration(),
        labelPadding: const EdgeInsets.symmetric(horizontal: 6),
        dividerColor: Colors.transparent,
        tabAlignment: TabAlignment.center,
        onTap: (index) {
          final catId = controller.listCategories[index].id;
          controller.changeCategory(catId);
        },
        tabs: controller.listCategories.map((cat) {
          return Obx(() {
            final bool isActive = controller.selectedCategoryId.value == cat.id;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFFE53935)
                    : const Color(0xFFF3F3F3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                cat.nama,
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.grey[700],
                  fontSize: 14,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            );
          });
        }).toList(),
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
}
