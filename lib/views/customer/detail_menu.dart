import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import '../widgets/menu_rectangle.dart';
import '../widgets/custom_button.dart';
import '../../controllers/cart_controller.dart';
import '../../models/cart_models.dart';

class DetailMenuPage extends StatefulWidget {
  final int id;

  const DetailMenuPage({super.key, required this.id});

  @override
  State<DetailMenuPage> createState() => _DetailMenuPageState();
}

class _DetailMenuPageState extends State<DetailMenuPage> {
  final CartController cartController = Get.find<CartController>();

  Map<String, dynamic> data = {};
  int quantity = 1;
  bool isEditMode = false;
  int cartIndex = -1;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final Object? extra = GoRouterState.of(context).extra;

      if (extra != null && extra is Map<String, dynamic>) {
        setState(() {
          data = {
            'namaMenu': extra['namaMenu'],
            'harga': extra['harga'] ?? 0,
            'gambarUrl': extra['gambarUrl'] ?? '',
            'idKategoriMenu': extra['idKategoriMenu'] ?? 0,
          };
          quantity = extra['quantity'] as int? ?? 1;
          // ✅ Baca isEditMode dari flag eksplisit yang dikirim CartPage
          isEditMode = extra['isEditMode'] as bool? ?? false;
          // ✅ Baca cartIndex untuk updateCartItemAt
          cartIndex = extra['cartIndex'] as int? ?? -1;
        });
      } else {
        setState(() {
          data = {'namaMenu': 'Menu Item', 'harga': 0, 'gambarUrl': ''};
          isEditMode = false;
          cartIndex = -1;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    int hargaSatuan = data['harga'] is int
        ? data['harga']
        : int.tryParse(data['harga']?.toString() ?? '0') ?? 0;
    int totalHarga = hargaSatuan * quantity;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. Gambar Background Menu
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.45,
              child:
                  data['gambarUrl'] != null &&
                      data['gambarUrl'].toString().isNotEmpty
                  ? Image.network(
                      data['gambarUrl'],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildImageError(),
                    )
                  : _buildImageError(),
            ),
          ),

          // 2. Tombol Back
          Positioned(
            top: 40,
            left: 16,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Color(0xFFDE3905),
                size: 30,
              ),
              onPressed: () => context.pop(),
            ),
          ),

          // 3. Panel Detail
          Align(
            alignment: Alignment.bottomCenter,
            child: MenuRectangle(
              child: SizedBox(
                height: 620,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25,
                    vertical: 30,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    Text(
                      data['namaMenu'] ?? 'Menu',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Roboto',
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Price: Rp $hargaSatuan",
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Divider(color: Color(0xFFD9D9D9), thickness: 1),
                    const SizedBox(height: 20),

                    // Selector Quantity
                    Row(
                      children: [
                        const Text(
                          "Quantity:",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        const Spacer(),
                        _buildQtyBtn(Icons.remove, () {
                          if (quantity > 1) setState(() => quantity--);
                        }),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Text(
                            "$quantity",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        _buildQtyBtn(Icons.add, () {
                          setState(() => quantity++);
                        }),
                      ],
                    ),

                    const Spacer(),

                    // Total Harga Display
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Total:",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Rp $totalHarga",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFDE3905),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),

                    CustomButton(
                      text: isEditMode ? "Update Cart" : "Add to Cart",
                      onPressed: () {
                        int kategoriId = data['idKategoriMenu'] is int
                            ? data['idKategoriMenu']
                            : int.tryParse(
                                    data['idKategoriMenu']?.toString() ?? '0',
                                  ) ??
                                  0;

                        final newItem = CartItem(
                          id: widget.id,
                          idKategoriMenu: kategoriId,
                          nama: data['namaMenu'] ?? 'Menu',
                          harga: hargaSatuan,
                          gambarUrl: data['gambarUrl'] ?? '',
                          quantity: quantity,
                          selectedToppings: const [],
                        );

                        if (isEditMode) {
                      
                          cartController.updateCartItem(newItem);
                        } else {
                          cartController.addToCart(newItem);
                        }

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isEditMode
                                  ? "${data['namaMenu']} edited to cart"
                                  : "$quantity x ${data['namaMenu']} added to cart",
                            ),
                            backgroundColor: const Color(0xFF10B981),
                            duration: const Duration(seconds: 1),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );

                        Future.delayed(const Duration(seconds: 1), () {
                          if (mounted) context.pop();
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageError() {
    return Container(
      color: Colors.grey[300],
      child: const Icon(Icons.fastfood, size: 50, color: Colors.grey),
    );
  }

  Widget _buildQtyBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(5),
        child: Icon(icon, size: 20, color: const Color(0xFFDE3905)),
      ),
    );
  }
}
