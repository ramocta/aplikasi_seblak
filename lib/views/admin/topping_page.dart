import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'add_topping_page.dart';
import 'edit_topping_page.dart';

class ToppingPage extends StatefulWidget {
  const ToppingPage({super.key});

  @override
  State<ToppingPage> createState() => _ToppingPageState();
}

class _ToppingPageState extends State<ToppingPage> {
  // Variabel untuk tab kategori aktif
  String _activeCategory = 'Kerupuk';

  // Data Toping Lengkap Sesuai Desain
  final Map<String, List<Map<String, String>>> toppingData = {
    "Kerupuk": [
      {"name": "Kerupuk Tangga", "price": "2.000", "stock": "80"},
      {"name": "Kerupuk Bintang", "price": "2.000", "stock": "80"},
      {"name": "Kerupuk Seblak", "price": "2.000", "stock": "80"},
      {"name": "Kerupuk Warna Warni", "price": "2.000", "stock": "80"},
      {"name": "Kerupuk Rafael", "price": "2.000", "stock": "80"},
    ],
    "Frozen Food": [
      {"name": "Otak-otak", "price": "2.000", "stock": "80"},
      {"name": "Udang", "price": "2.000", "stock": "80"},
      {"name": "Crab Stick", "price": "2.000", "stock": "80"},
      {"name": "Kembang Cumi", "price": "2.000", "stock": "80"},
      {"name": "Sosis", "price": "2.000", "stock": "80"},
    ],
    "Lainnya": [
      {"name": "Sawi hijau", "price": "2.000", "stock": "80"},
      {"name": "Batagor Mini", "price": "2.000", "stock": "80"},
      {"name": "Jamur enoki", "price": "3.000", "stock": "80"},
      {"name": "Cuangki Lidah", "price": "2.000", "stock": "80"},
      {"name": "Pilus", "price": "2.000", "stock": "80"},
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Filter Tabs
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCategoryTab("Kerupuk"),
                _buildCategoryTab("Frozen Food"),
                _buildCategoryTab("Lainnya"),
              ],
            ),
          ),

          // List Topping (Sesuai Kategori)
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              children: _getToppingList(),
            ),
          ),
        ],
      ),

      // Tombol Tambah Topping
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Menggunakan GoRouter
          context.push('/add_topping');
        },
        backgroundColor: const Color(0xFFE64A19),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }

  Widget _buildCategoryTab(String label) {
    bool isActive = _activeCategory == label;
    return GestureDetector(
      onTap: () => setState(() => _activeCategory = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFE64A19) : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  List<Widget> _getToppingList() {
    final items = toppingData[_activeCategory] ?? [];
    return items.map((item) {
      return _buildToppingTile(
        item['name'] ?? '',
        item['price'] ?? '',
        item['stock'] ?? '',
      );
    }).toList();
  }

  Widget _buildToppingTile(String name, String price, String stock) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 70,
              height: 70,
              color: Colors.grey.shade100,
              child: const Icon(Icons.fastfood, color: Colors.grey),
            ),
          ),
          const SizedBox(width: 12),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 4),
                Text("harga: Rp. $price", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                const SizedBox(height: 12),
                Text("Stok: $stock", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              ],
            ),
          ),

          // Tombol Aksi (Edit & Delete)
          Row(
            children: [
              _buildActionButton(Icons.edit, Colors.orange, () {
                // Menggunakan GoRouter dengan parameter extra
                context.push('/edit_topping', extra: {
                  'name': name,
                  'price': price,
                  'stock': stock,
                  'category': _activeCategory,
                });
              }),
              const SizedBox(width: 8),
              _buildActionButton(Icons.delete, Colors.red, () {
                // Tambahkan logika hapus di sini
              }),
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