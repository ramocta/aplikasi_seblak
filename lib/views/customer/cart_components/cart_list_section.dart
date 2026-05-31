import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import '../../../controllers/cart_controller.dart';
import '../../../models/cart_models.dart';
import '../../widgets/menu_rectangle.dart';
import 'cart_item_widget.dart';

class CartListSection extends StatelessWidget {
  final CartController cartController;
  final RxString activeMode;
  final RxInt selectedIndex;
  final void Function({
    required String title,
    required String message,
    required String confirmText,
    required VoidCallback onConfirm,
  })
  showValidationDialog;

  const CartListSection({
    super.key,
    required this.cartController,
    required this.activeMode,
    required this.selectedIndex,
    required this.showValidationDialog,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: MenuRectangle(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: Obx(() {
            if (cartController.cartItems.isEmpty) {
              return const Center(child: Text("Cart is empty"));
            }
            return ListView.separated(
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: cartController.cartItems.length,
              separatorBuilder: (_, __) => const Divider(height: 30),
              itemBuilder: (context, index) {
                final item = cartController.cartItems[index];
                final router = GoRouter.of(context);

                return Obx(() {
                  final String mode = activeMode.value;
                  final bool isModeActive = mode.isNotEmpty;
                  final bool isSelected = selectedIndex.value == index;

                  return CartItemWidget(
                    itemNumber: index + 1,
                    item: item,
                    isSelected: isSelected,
                    isModeActive: isModeActive,
                    mode: mode,
                    onTap: () => _handleItemTap(context, index, item, router),
                  );
                });
              },
            );
          }),
        ),
      ),
    );
  }

  void _handleItemTap(
    BuildContext context,
    int index,
    CartItem item,
    GoRouter router,
  ) {
    if (activeMode.value.isEmpty) return;

    final dynamic itemId = item.id;
    if (itemId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Item tidak valid")));
      return;
    }

    selectedIndex.value = index;

    if (activeMode.value == 'edit') {
      showValidationDialog(
        title: "Edit This Menu?",
        message: "Do you want to change the details of this item?",
        confirmText: "Edit",
        onConfirm: () {
          if (context.mounted) {
            final String route = item.idKategoriMenu == 1
                ? '/edit-detail-seblak/$itemId'
                : '/edit-detail-menu/$itemId';

            router.push(
              route,
              extra: {
                'namaMenu': item.nama,
                'harga': item.harga,
                'gambarUrl': item.gambarUrl,
                'quantity': item.quantity,
                'idKategoriMenu': item.idKategoriMenu,
                'id_kategori_menu': item.idKategoriMenu,
                'id': itemId,
                'selectedToppings': item.selectedToppings,
                'isEditMode': true,
                'cartIndex': index,
              },
            );
          }
        },
      );
    } else if (activeMode.value == 'delete') {
      showValidationDialog(
        title: "Delete This Item?",
        message: "If you delete this item it cannot be restored.",
        confirmText: "Delete",
        onConfirm: () {
          final String namaMenuYangDihapus = item.nama;
          cartController.removeFromCartAt(index);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("$namaMenuYangDihapus deleted from cart"),
              backgroundColor: const Color(0xFFDE3905),
              duration: const Duration(seconds: 1),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        },
      );
    }
  }
}
