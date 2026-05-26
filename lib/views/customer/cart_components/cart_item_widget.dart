import 'package:flutter/material.dart';
import '../../../models/cart_models.dart';

class CartItemWidget extends StatelessWidget {
  final int itemNumber;
  final CartItem item;
  final bool isSelected;
  final bool isModeActive;
  final String mode;
  final VoidCallback onTap;

  const CartItemWidget({
    super.key,
    required this.itemNumber,
    required this.item,
    required this.isSelected,
    required this.isModeActive,
    required this.mode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(
                  color: mode == 'edit' ? Colors.blue : Colors.red,
                  width: 1.5,
                )
              : null,
          color: isSelected
              ? (mode == 'edit'
                    ? Colors.blue.withOpacity(0.04)
                    : Colors.red.withOpacity(0.04))
              : Colors.transparent,
        ),
        padding: isSelected ? const EdgeInsets.all(8) : EdgeInsets.zero,
        child: _buildCartItemContent(),
      ),
    );
  }

  Widget _buildCartItemContent() {
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
            // Item number
            AnimatedSize(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeInOut,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 250),
                opacity: isModeActive ? 0.0 : 1.0,
                child: isModeActive
                    ? const SizedBox(width: 0)
                    : Text(
                        "$itemNumber. ",
                        style: const TextStyle(fontSize: 14),
                      ),
              ),
            ),

            // Item image
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

            // Item details
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

            // Price column
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
}
