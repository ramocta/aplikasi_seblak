import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import '../widgets/menu_rectangle.dart';
import '../widgets/custom_button.dart';
import '../../controllers/cart_controller.dart';
import '../../models/cart_models.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> with TickerProviderStateMixin {
  final CartController cartController = Get.find<CartController>();
  final RxString activeMode = ''.obs;
  final RxInt selectedIndex = (-1).obs;

  late AnimationController _blinkController;
  late Animation<double> _blinkAnimation;

  @override
  void initState() {
    super.initState();
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _blinkAnimation = Tween<double>(begin: 1.0, end: 0.2).animate(
      CurvedAnimation(parent: _blinkController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _blinkController.dispose();
    super.dispose();
  }

  void _showValidationDialog({
    required String title,
    required String message,
    required String confirmText,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              selectedIndex.value = -1;
            },
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.black54),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              WidgetsBinding.instance.addPostFrameCallback((_) {
                onConfirm();
                selectedIndex.value = -1;
              });
            },
            child: Text(
              confirmText,
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // Ditambahkan margin atas pada back button agar sejajar dengan title yang turun
        leading: Padding(
          padding: const EdgeInsets.only(top: 12.0),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFFDE3905)),
            onPressed: () => context.pop(),
          ),
        ),
        centerTitle: true, // ✅ MERUBAH HEADER MENJADI DI TENGAH
        title: Padding(
          padding: const EdgeInsets.only(
            top: 16.0,
          ), // ✅ MENURUNKAN POSISI HEADER
          child: Row(
            mainAxisSize: MainAxisSize
                .min, // Memaksa Row menciut ke tengah mengikuti centerTitle
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.shopping_cart_outlined,
                color: Color(0xFFDE3905),
                size: 26,
              ),
              const SizedBox(width: 8),
              const Text(
                "Your Cart",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20), // ✅ MEMBERIKAN JARAK KEBAWAH DARI APPBAR
          // Row button edit/delete dan teks hint dalam satu baris
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Obx(() {
              final bool modeActive = activeMode.value.isNotEmpty;
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) => FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(-0.2, 0),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      ),
                      child: modeActive
                          ? AnimatedBuilder(
                              key: ValueKey(activeMode.value),
                              animation: _blinkAnimation,
                              builder: (context, child) => Opacity(
                                opacity: _blinkAnimation.value,
                                child: child,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    activeMode.value == 'edit'
                                        ? Icons.edit
                                        : Icons.delete,
                                    size: 13,
                                    color: const Color(0xFFDE3905),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    activeMode.value == 'edit'
                                        ? "Click on the menu you want to edit.."
                                        : "Click on the menu you want to delete..",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFFDE3905),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : const SizedBox(key: ValueKey('empty')),
                    ),
                  ),

                  // Button edit dan delete di kanan
                  Row(
                    children: [
                      _buildActionIcon(Icons.edit, Colors.red, () {
                        activeMode.value = activeMode.value == 'edit'
                            ? ''
                            : 'edit';
                        selectedIndex.value = -1;
                      }),
                      const SizedBox(width: 10),
                      _buildActionIcon(Icons.delete, Colors.red, () {
                        activeMode.value = activeMode.value == 'delete'
                            ? ''
                            : 'delete';
                        selectedIndex.value = -1;
                      }),
                    ],
                  ),
                ],
              );
            }),
          ),

          const SizedBox(
            height: 10,
          ), // ✅ MEMBERIKAN JARAK ANTAR ROW HINT DENGAN LIST CART 
          Expanded(
            child: MenuRectangle(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(
                  25,
                ), // Menyesuaikan lengkungan MenuRectangle Anda
                child: Obx(() {
                  if (cartController.cartItems.isEmpty) {
                    return const Center(child: Text("Cart is empty"));
                  }
                  return ListView.separated(
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

                        return GestureDetector(
                          onTap: () {
                            if (activeMode.value.isEmpty) return;

                            final dynamic itemId = item.id;
                            if (itemId == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Item tidak valid"),
                                ),
                              );
                              return;
                            }

                            selectedIndex.value = index;

                            if (activeMode.value == 'edit') {
                              _showValidationDialog(
                                title: "Edit This Menu?",
                                message:
                                    "Do you want to change the details of this item?",
                                confirmText: "Edit",
                                onConfirm: () {
                                  if (!mounted) return;
                                  final String route = item.idKategoriMenu == 1
                                      ? '/detail-seblak/$itemId'
                                      : '/detail/$itemId';

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
                                },
                              );
                            } else if (activeMode.value == 'delete') {
                              _showValidationDialog(
                                title: "Delete This Item?",
                                message:
                                    "If you delete this item it cannot be restored.",
                                confirmText: "Delete",
                                onConfirm: () {
                                  
                                  final String namaMenuYangDihapus = item.nama;

                                  // 2. Jalankan logika hapus dari CartController
                                  cartController.removeFromCartAt(index);

                                  
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        "$namaMenuYangDihapus deleted from cart",
                                      ), // ✅ Pesan dinamis sesuai nama menu
                                      backgroundColor: const Color(
                                        0xFFDE3905,
                                      ), // ✅ Warna merah branding Anda
                                      duration: const Duration(seconds: 1),
                                      behavior: SnackBarBehavior
                                          .floating, // Agar melayang estetik
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          10,
                                        ), // Sudut melengkung halus
                                      ),
                                    ),
                                  );
                                },
                              );
                            }
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 350),
                            curve: Curves.easeInOut,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: isSelected
                                  ? Border.all(
                                      color: activeMode.value == 'edit'
                                          ? Colors.blue
                                          : Colors.red,
                                      width: 1.5,
                                    )
                                  : null,
                              color: isSelected
                                  ? (activeMode.value == 'edit'
                                        ? Colors.blue.withOpacity(0.04)
                                        : Colors.red.withOpacity(0.04))
                                  : Colors.transparent,
                            ),
                            padding: isSelected
                                ? const EdgeInsets.all(8)
                                : EdgeInsets.zero,
                            child: _buildCartItem(
                              index + 1,
                              item,
                              mode,
                              isModeActive,
                            ),
                          ),
                        );
                      });
                    },
                  );
                }),
              ),
            ),
          ),
          _buildCheckoutSection(),
        ],
      ),
    );
  }

  Widget _buildActionIcon(IconData icon, Color color, VoidCallback onTap) {
    return Obx(() {
      final String mode = icon == Icons.edit ? 'edit' : 'delete';
      final bool isActive = activeMode.value == mode;

      return GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isActive ? color.withOpacity(0.1) : Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: isActive ? color : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Icon(icon, color: isActive ? color : Colors.grey, size: 20),
        ),
      );
    });
  }

  Widget _buildCartItem(
    int number,
    CartItem item,
    String mode,
    bool isModeActive,
  ) {
    final int kategoriId = item.idKategoriMenu;

    int totalHargaTopping = 0;
    if (kategoriId == 1 && item.selectedToppings.isNotEmpty) {
      totalHargaTopping = item.selectedToppings.fold(
        0,
        (sum, topping) => sum + (topping.harga * topping.quantity),
      );
    }

    int subtotalAkhir = (item.harga + totalHargaTopping) * item.quantity;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedSize(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeInOut,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 250),
                opacity: isModeActive ? 0.0 : 1.0,
                child: isModeActive
                    ? const SizedBox(width: 0)
                    : Text("$number. ", style: const TextStyle(fontSize: 14)),
              ),
            ),

            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: item.gambarUrl.isNotEmpty
                  ? Image.network(
                      item.gambarUrl,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[300],
                        child: const Icon(Icons.fastfood, color: Colors.grey),
                      ),
                    )
                  : Container(width: 80, height: 80, color: Colors.grey[300]),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.nama,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  if (kategoriId == 1 && item.selectedToppings.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    const Text(
                      "Topping:",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    ...item.selectedToppings.map(
                      (topping) => Padding(
                        padding: const EdgeInsets.only(bottom: 3),
                        child: Text(
                          "${topping.nama} x ${topping.quantity}",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ] else ...[
                    const SizedBox(height: 4),
                    Text(
                      "Quantity x ${item.quantity}",
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(width: 16),

            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "Rp. ${item.harga}",
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
                if (kategoriId == 1 && item.selectedToppings.isNotEmpty) ...[
                  const SizedBox(height: 22),
                  ...item.selectedToppings.map(
                    (topping) => Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Text(
                        "Rp. ${topping.harga * topping.quantity}",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),

        const SizedBox(height: 12),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Subtotal:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            Text(
              "Rp. $subtotalAkhir",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Color(0xFFDE3905),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCheckoutSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Total:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Obx(
                () => Text(
                  "Rp. ${cartController.totalPrice}",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFDE3905),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          CustomButton(
            text: "Checkout",
            onPressed: () {
              if (cartController.cartItems.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Opps.. Your cart is empty!"),
                    backgroundColor: Color(0xFFDE3905),
                  ),
                );
                return;
              }
              context.push('/checkout');
            },
          ),
        ],
      ),
    );
  }
}
