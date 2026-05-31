import 'package:flutter/material.dart' hide MenuController;
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
// Alias tetap dipakai supaya tidak bentrok dengan material.dart
import 'package:seblak_say_cafe/controllers/menu_controller.dart' as menu_controller;
import 'package:seblak_say_cafe/views/widgets/admin/menu_category_tabs.dart';
import 'package:seblak_say_cafe/views/widgets/admin/menu_item_tile.dart';
import 'package:seblak_say_cafe/views/widgets/admin/menu_delete_dialog.dart';


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
            MenuCategoryTabs(
              categories: controller.listCategories,
              selectedCategoryId: controller.selectedCategoryId.value,
              onTap: (id) => controller.changeCategory(id),
            ),

            Expanded(
              child: RefreshIndicator(
                onRefresh: () => controller.refreshData(),
                child: controller.listMenu.isEmpty
                    ? const Center(child: Text("Tidak ada menu di kategori ini"))
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                        itemCount: controller.listMenu.length,
                        itemBuilder: (context, index) {
                          final menu = controller.listMenu[index];
                          return MenuItemTile(
                            context: context,
                            name: menu.nama,
                            price: menu.harga.toString(),
                            stock: menu.stok.toString(),
                            fullData: menu,
                            onEdit: () {
                              context.go('/edit_menu', extra: menu);
                            },
                            onDelete: () {
                              MenuDeleteDialog.show(
                                context: context,
                                menu: menu,
                                onConfirmDelete: (idMenu) async {
                                  await controller.deleteMenu(idMenu);
                                  await Future.delayed(const Duration(milliseconds: 300));
                                  await controller.refreshData();
                                },
                              );
                            },
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
}
