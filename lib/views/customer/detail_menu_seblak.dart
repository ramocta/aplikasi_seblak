import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:seblak_say_cafe/controllers/cart_controller.dart';
import 'package:seblak_say_cafe/controllers/topping_controller.dart';
import 'package:seblak_say_cafe/models/cart_models.dart';
import '../widgets/menu_rectangle.dart';
import '../widgets/custom_button.dart';
import "../../utils/currency_format.dart";

class DetailMenuSeblakPage extends StatefulWidget {
  final int id;
  const DetailMenuSeblakPage({super.key, required this.id});

  @override
  State<DetailMenuSeblakPage> createState() => _DetailMenuSeblakPageState();
}

class _DetailMenuSeblakPageState extends State<DetailMenuSeblakPage> {
  final CartController cartController = Get.find<CartController>();
  late ToppingController toppingController;

  Map<String, dynamic> data = {};
  final int menuQuantity = 1;
  bool isEditMode = false;
  int cartIndex = -1;

  @override
  void initState() {
    super.initState();

    if (Get.isRegistered<ToppingController>()) {
      Get.delete<ToppingController>(force: true);
    }
    toppingController = Get.put(ToppingController());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final Object? extra = GoRouterState.of(context).extra;

      if (extra != null && extra is Map<String, dynamic>) {
        final bool editMode = extra['isEditMode'] as bool? ?? false;

        setState(() {
          data = extra;
          isEditMode = editMode;
          cartIndex = extra['cartIndex'] as int? ?? -1;
        });

        if (editMode) {
          // ✅ Skip sync dari server saat edit mode
          toppingController.skipServerSync = true;

          final List? savedToppings = extra['selectedToppings'] as List?;
          if (savedToppings != null && savedToppings.isNotEmpty) {
            ever(toppingController.listTopping, (_) {
              if (toppingController.listTopping.isNotEmpty) {
                for (final t in savedToppings) {
                  if (t is ToppingItem) {
                    toppingController.restoreFromSaved(t.nama, t.quantity);
                  }
                }
              }
            });

            // ✅ Restore quantities dari saved toppings untuk quick update
            toppingController.restoreQuantitiesFromSaved(
              savedToppings
                  .map(
                    (t) => t is ToppingItem
                        ? {'id': t.id, 'quantity': t.quantity}
                        : t,
                  )
                  .toList(),
            );
          }
        }
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
  void dispose() {
    Get.delete<ToppingController>(force: true);
    super.dispose();
  }

  int get currentTotal {
    int hargaMenu = _parseHarga(data['harga']);
    return hargaMenu + toppingController.totalToppingPrice;
  }

  int _parseHarga(dynamic h) =>
      h is int ? h : int.tryParse(h?.toString() ?? '0') ?? 0;

  @override
  Widget build(BuildContext context) {
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
                  padding: const EdgeInsets.fromLTRB(25, 30, 25, 20),
                  child: Obx(() {
                    if (toppingController.isLoading.value &&
                        toppingController.listCategories.isEmpty) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFDE3905),
                        ),
                      );
                    }

                    if (toppingController.tabController == null ||
                        toppingController.listCategories.isEmpty) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFDE3905),
                        ),
                      );
                    }

                    final tabController = toppingController.tabController!;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data['namaMenu'] ?? 'Opps.. Something went wrong',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Base price: ${CurrencyFormat.convertToIdr(_parseHarga(data['harga']))}",
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 15),
                        const Divider(color: Color(0xFFD9D9D9), thickness: 1),
                        const SizedBox(height: 10),
                        const Text(
                          "Choose your toppings",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        // 💡 1. NAVIGASI KATEGORI DI TENGAH
                        _buildCenteredToppingNav(tabController),

                        // 💡 2. LIST TOPPING YANG BISA DIGESER KESAMPING (SWIPEABLE)
                        Expanded(
                          child: TabBarView(
                            controller: tabController,
                            physics: const BouncingScrollPhysics(),
                            children: toppingController.listCategories.map((
                              category,
                            ) {
                              // ✅ OPTIMASI: Ambil dari cache langsung tanpa filtering
                              final filteredToppings = toppingController
                                  .getToppingsByCategory(category.id);

                              if (filteredToppings.isEmpty) {
                                return const Center(
                                  child: Text("No toppings found"),
                                );
                              }

                              return ListView.builder(
                                physics: const ClampingScrollPhysics(),
                                padding: const EdgeInsets.only(top: 10),
                                itemCount: filteredToppings.length,
                                itemBuilder: (context, index) {
                                  final topping = filteredToppings[index];
                                  return _buildToppingRow(topping);
                                },
                              );
                            }).toList(),
                          ),
                        ),

                        const Divider(height: 30),
                        _buildFooterSection(),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // WIDGET NAVIGASI TOPPING DI TENGAH & MENGIKUTI SWIPE
  Widget _buildCenteredToppingNav(TabController tabController) {
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
          final catId = toppingController.listCategories[index].id;
          toppingController.changeCategory(catId);
        },
        tabs: toppingController.listCategories.map((cat) {
          return Obx(() {
            final bool isActive =
                toppingController.selectedCategoryId.value == cat.id;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFFDE3905)
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

  Widget _buildToppingRow(dynamic topping) {
    String toppingGambarUrl = topping.gambarUrl ?? '';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[100],
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1A000000),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: toppingGambarUrl.isNotEmpty
                  ? Image.network(
                      toppingGambarUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildRowPlaceholderIcon(),
                    )
                  : _buildRowPlaceholderIcon(),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  topping.nama,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF121212),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  CurrencyFormat.convertToIdr(topping.harga),
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          _buildCircleQtyBtn(
            Icons.remove,
            () => toppingController.updateQuantity(topping.id, -1),
          ),
          Obx(
            () => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Text(
                "${toppingController.getQuantity(topping.id)}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          _buildCircleQtyBtn(
            Icons.add,
            () => toppingController.updateQuantity(topping.id, 1),
          ),
        ],
      ),
    );
  }

  Widget _buildRowPlaceholderIcon() {
    return Container(
      color: Colors.grey[300],
      child: const Icon(Icons.fastfood, size: 20, color: Colors.white),
    );
  }

  Widget _buildFooterSection() {
    return Column(
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
                CurrencyFormat.convertToIdr(currentTotal),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFDE3905),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        CustomButton(
          text: isEditMode ? "Update Cart" : "Add to Cart",
          onPressed: _handleAddToCart,
        ),
      ],
    );
  }

  void _handleAddToCart() {
    // 1. Ambil daftar mentah topping terpilih
    final rawSelectedToppings = toppingController.getSelectedToppingsList();

    // 💡 PERBAIKAN UTAMA: Filter dan buat daftar objek ToppingItem HANYA jika kuantitasnya > 0
    final List<ToppingItem> validToppings = [];

    for (final t in rawSelectedToppings) {
      final int qty = toppingController.getQuantity(t.id);
      if (qty > 0) {
        validToppings.add(
          ToppingItem(id: t.id, nama: t.nama, harga: t.harga, quantity: qty),
        );
      }
    }

    // 2. Validasi: Jika setelah difilter ternyata kosong, tampilkan snackbar peringatan
    if (validToppings.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            "Must choose at least 1 topping.",
          ),
          backgroundColor: const Color(0xFFDE3905),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    int kategoriId = data['id_kategori_menu'] is int
        ? data['id_kategori_menu']
        : int.tryParse(data['id_kategori_menu']?.toString() ?? '1') ?? 1;

    final dynamic menuId = data['id'] ?? widget.id;

    // 3. Masukkan 'validToppings' yang sudah bersih dari item bernilai 0 ke dalam CartItem
    final newItem = CartItem(
      id: menuId,
      idKategoriMenu: kategoriId,
      nama: data['namaMenu'] ?? 'Seblak',
      harga: _parseHarga(data['harga']),
      gambarUrl: data['gambarUrl'] ?? '',
      quantity: menuQuantity,
      selectedToppings:
          validToppings, // 💡 Gunakan list yang sudah difilter di sini
    );

    // 4. Eksekusi penyimpanan ke CartController
    if (isEditMode && cartIndex != -1) {
      cartController.updateCartItemAt(cartIndex, newItem);
    } else {
      cartController.addToCart(newItem);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isEditMode
              ? "${data['namaMenu']} edited to cart"
              : "1 x ${data['namaMenu']} added to cart",
        ),
        backgroundColor: const Color(0xFF10B981),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        toppingController.resetSelections();
        context.pop();
      }
    });
  }

  Widget _buildImageError() {
    return Container(
      color: Colors.grey[300],
      child: const Icon(Icons.fastfood, size: 50, color: Colors.grey),
    );
  }

  Widget _buildCircleQtyBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFFFDECE8),
          border: Border.all(color: const Color(0xFFF5CCC1)),
        ),
        child: Icon(icon, size: 18, color: const Color(0xFFDE3905)),
      ),
    );
  }
}
