import 'package:flutter/material.dart';
import 'package:seblak_say_cafe/controllers/topping_controller.dart' as topping_controller;

class ToppingTile extends StatelessWidget {
  final topping_controller.ToppingController controller;
  final dynamic topping;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ToppingTile({
    super.key,
    required this.controller,
    required this.topping,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final int stockValue = int.tryParse(topping.stok.toString()) ?? 0;
    Color stockColor;
    String stockLabel;

    if (stockValue >= 10) {
      stockColor = Colors.green.shade700;
      stockLabel = "Stok: $stockValue";
    } else if (stockValue > 0 && stockValue <= 9) {
      stockColor = Colors.amber.shade800;
      stockLabel = "Stok Menipis: $stockValue";
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
            child: Container(
              width: 70,
              height: 70,
              color: const Color(0xFFE64A19).withOpacity(0.1),
              child: const Icon(Icons.fastfood, color: Color(0xFFE64A19)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  topping.nama,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  "Harga: Rp ${topping.harga}",
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
              _buildActionButton(
                icon: Icons.edit,
                color: Colors.orange,
                onTap: onEdit,
              ),
              const SizedBox(width: 8),
              _buildActionButton(
                icon: Icons.delete,
                color: Colors.red,
                onTap: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: Tooltip(
        message: '',
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
        ),
      ),
    );
  }
}

