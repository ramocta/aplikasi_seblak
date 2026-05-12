import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'add_menu_page.dart';
import 'edit_menu_page.dart';


class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  String _activeCategory = 'Seblak';

  final Map<String, List<Map<String, String>>> menuData = {
    "Seblak": [
      {"name": "Seblak Level 1", "desc": "Level Pedas | Kuah", "price": "7.000", "stock": "80"},
      {"name": "Seblak Level 2", "desc": "Level Pedas | Kuah", "price": "7.000", "stock": "80"},
      {"name": "Seblak Level 3", "desc": "Level Pedas | Kuah", "price": "7.000", "stock": "80"},
      {"name": "Seblak Level 4", "desc": "Level Pedas | Kuah", "price": "7.000", "stock": "80"},
    ],
    "Mie": [
      {"name": "Mie Level 1", "desc": "Varian : Mie Bakso | Gurih", "price": "9.000", "stock": "50"},
      {"name": "Mie Level 2", "desc": "Varian : Mie Bakso | Gurih", "price": "9.000", "stock": "50"},
      {"name": "Mie Level 3", "desc": "Varian : Mie Bakso | Gurih", "price": "9.000", "stock": "50"},
      {"name": "Mie Level 4", "desc": "Varian : Mie Bakso | Gurih", "price": "9.000", "stock": "50"},
    ],
    "Minuman": [
      {"name": "Es Jeruk", "desc": "Segar dan Manis", "price": "5.000", "stock": "80"},
      {"name": "Es Teh", "desc": "Segar dan Manis", "price": "3.000", "stock": "80"},
      {"name": "Es Doger", "desc": "Segar dan Manis", "price": "6.000", "stock": "80"},
      {"name": "Air Mineral", "desc": "Segar dan Dingin", "price": "4.000", "stock": "80"},
    ],
    "Snack": [
      {"name": "Kentang Goreng", "desc": "Renyah dan Gurih", "price": "7.000", "stock": "50"},
      {"name": "Cireng", "desc": "Renyah dan Gurih", "price": "7.000", "stock": "50"},
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          // Filter Tabs Kategori
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: menuData.keys.map((category) => _buildCategoryTab(category)).toList(),
              ),
            ),
          ),

          // List Data Menu Sesuai Kategori yang Dipilih
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              children: _getMenuList(),
            ),
          ),
        ],
      ),
      
      // Tombol Tambah Menu
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/add_menu');
        },
        backgroundColor: const Color(0xFFE64A19),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
      // Tidak perlu mendeklarasikan bottomNavigationBar di sini agar tidak bertumpuk
    );
  }

  Widget _buildCategoryTab(String label) {
    bool isActive = _activeCategory == label;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0),
      child: GestureDetector(
        onTap: () => setState(() => _activeCategory = label),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFFE64A19) : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isActive ? Colors.transparent : Colors.grey.shade300,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _getMenuList() {
    final items = menuData[_activeCategory] ?? [];
    return items.map((item) {
      return _buildMenuTile(
        item['name'] ?? '',
        item['desc'] ?? '',
        item['price'] ?? '',
        item['stock'] ?? '',
      );
    }).toList();
  }

  Widget _buildMenuTile(String name, String desc, String price, String stock) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
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

          // Detail Teks
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 4),
                Text(desc, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 8),
                Text("harga: Rp. $price", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text("Stok: $stock", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              ],
            ),
          ),

          // Tombol Aksi (Edit & Delete)
          Row(
            children: [
              _buildActionButton(Icons.edit, Colors.orange, () {
                context.push(
                  '/edit_menu',
                  extra: {
                    'name': 'Seblak Level 1', // atau ambil dari model/data yang diklik
                    'category': 'Seblak',
                    'stock': 80,
                    'price': 7000,
                    'description': 'Level Pedas | Kuah',
                });
              }),
              const SizedBox(width: 8),
              _buildActionButton(Icons.delete, Colors.red, () {
                // Logika Hapus
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