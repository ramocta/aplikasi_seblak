import 'package:flutter/material.dart';

class MenuItemTile extends StatelessWidget {
  final BuildContext context;
  final String name;
  final String price;
  final String stock;
  final dynamic fullData;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const MenuItemTile({
    super.key,
    required this.context,
    required this.name,
    required this.price,
    required this.stock,
    required this.fullData,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // LOGIKA WARNA STOK DINAMIS
    final int stockValue = int.tryParse(stock) ?? 0;
    Color stockColor;
    String stockLabel;

    if (stockValue >= 10) {
      stockColor = Colors.green.shade700;
      stockLabel = "Stok: $stock";
    } else if (stockValue > 0 && stockValue <= 9) {
      stockColor = Colors.amber.shade800;
      stockLabel = "Stok Menipis: $stock";
    } else {
      stockColor = Colors.red.shade700;
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
                Text(
                  stockLabel,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: stockColor,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              _buildActionButton(Icons.edit, Colors.orange, onEdit),
              const SizedBox(width: 8),
              _buildActionButton(Icons.delete, Colors.red, onDelete),
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
}

