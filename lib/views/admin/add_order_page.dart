import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AddOrderPage extends StatefulWidget {
  const AddOrderPage({super.key});

  @override
  State<AddOrderPage> createState() => _AddOrderPageState();
}

class _AddOrderPageState extends State<AddOrderPage> {
  String _currentOrderType = "Dine In";
  String _selectedCategory = "Seblak";

  // Data Menu
  final Map<String, List<Map<String, String>>> menuData = {
    "Seblak": [
      {"title": "Seblak Level 1", "price": "Rp. 7.000", "subtitle": "( Add your toppings )"},
      {"title": "Seblak Level 2", "price": "Rp. 7.000", "subtitle": "( Add your toppings )"},
      {"title": "Seblak Level 3", "price": "Rp. 7.000", "subtitle": "( Add your toppings )"},
      {"title": "Seblak Level 4", "price": "Rp. 15.000", "subtitle": "( Add your toppings )"},
      {"title": "Seblak Level 5", "price": "Rp. 10.000", "subtitle": "( Add your toppings )"},
    ],
    "Mie": [
      {"title": "Mie Level 1", "price": "Rp. 9.000", "subtitle": "( Sweet / Savory )"},
      {"title": "Mie Level 2", "price": "Rp. 12.000", "subtitle": "( Very Spicy + Topping )"},
      {"title": "Mie Level 3", "price": "Rp. 12.000", "subtitle": "( Spicy Sweet )"},
      {"title": "Mie Level 4", "price": "Rp. 6.000", "subtitle": "( Without Topping )"},
      {"title": "Mie Level 5", "price": "Rp. 6.000", "subtitle": "( Without Topping )"},
    ],
    "Minuman": [
      {"title": "Es Doger", "price": "Rp. 7.000", "subtitle": "Fresh and Sweet"},
      {"title": "Iced Tea", "price": "Rp. 3.000", "subtitle": "Iced / Hot"},
      {"title": "Iced Orange", "price": "Rp. 5.000", "subtitle": "Fresh Squeezed Orange"},
      {"title": "Mineral Water", "price": "Rp. 3.000", "subtitle": "600ml"},
    ],
    "Snack": [
      {"title": "French Fries", "price": "Rp. 7.000", "subtitle": "Medium Portion"},
      {"title": "Cireng", "price": "Rp. 7.000", "subtitle": "Rujak Sauce"},
      {"title": "Otak-otak", "price": "Rp. 8.000", "subtitle": "Crispy Fried"},
      {"title": "Dimsum", "price": "Rp. 10.000", "subtitle": "4 pcs"},
    ],
  };

  int _parsePrice(String priceStr) {
    String cleaned = priceStr.replaceAll(RegExp(r'[^\d]'), '');
    return int.tryParse(cleaned) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Add Order',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // Dine In / Take Away
                Row(
                  children: [
                    Expanded(child: _buildOrderTypeBtn("Dine In", Icons.restaurant)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildOrderTypeBtn("Take Away", Icons.shopping_bag)),
                  ],
                ),
                const SizedBox(height: 24),
                const Text("CUSTOMER NAME", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 8),
                _buildTextField("Input name"),
                if (_currentOrderType == "Dine In") ...[
                  const SizedBox(height: 20),
                  const Text("TABLE NUMBER", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 8),
                  _buildTextField("Input table number"),
                ],
                const SizedBox(height: 24),
                const Text("Category", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                
                // Tabs Kategori
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ["Seblak", "Mie", "Minuman", "Snack"].map((cat) {
                      return _buildCategoryTab(cat, _selectedCategory == cat);
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 24),
                const Text("Menu Selection", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                
                // List Item
                ...(menuData[_selectedCategory] ?? []).map((item) {
                  return _buildMenuItem(item['title']!, item['price']!, item['subtitle']!);
                }).toList(),
              ],
            ),
          ),
          _buildBottomButton(),
        ],
      ),
    );
  }

  Widget _buildMenuItem(String title, String price, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(width: 70, height: 70, decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.fastfood, color: Colors.grey)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                const SizedBox(height: 8),
                Text(price, style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          
          // TOMBOL ADD
          GestureDetector(
            onTap: () {
              if (_selectedCategory == "Seblak") {
                // Navigasi ke Topping Seblak
                final priceNumber = _parsePrice(price);
                context.push(
                  '/topping_selection',
                  extra: {'menuName': title, 'basePrice': priceNumber},
                );
              } 
              else if (_selectedCategory == "Mie") {
                // Navigasi ke Detail Mie (Halaman yang baru lo buat)
                context.push('/detail_mie');
              } 
              else {
                // Selain seblak dan mie, munculin SnackBar
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("$title ditambahkan")),
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE64A19)),
              ),
              child: const Text(
                "Add",
                style: TextStyle(
                  color: Color(0xFFE64A19),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget pendukung lainnya tetap sama agar tidak merusak UI lo
  Widget _buildOrderTypeBtn(String label, IconData icon) {
    bool isSelected = _currentOrderType == label;
    return GestureDetector(
      onTap: () => setState(() => _currentOrderType = label),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFD180) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? const Color(0xFFE64A19) : Colors.grey[300]!),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: isSelected ? const Color(0xFFE64A19) : Colors.black54),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? const Color(0xFFE64A19) : Colors.black54)),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String hint) {
    return TextField(
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildCategoryTab(String label, bool isActive) {
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = label),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFE64A19) : Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(label, style: TextStyle(color: isActive ? Colors.white : Colors.black87, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildBottomButton() {
    int totalItems = 3; // Nanti ini lo ganti pake variable dinamis/provider

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Total Order", style: TextStyle(color: Colors.grey)),
              Text("Rp 27.000", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFE64A19))),
            ],
          ),
          const SizedBox(height: 16),
          Stack(
            clipBehavior: Clip.none,
            children: [
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => context.push('/order_cart'), // Pindah ke halaman Cart
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE64A19),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Process Order", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              // INI ANGKA PESANANNYA (Badge)
              Positioned(
                right: 10,
                top: -10,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Color(0xFFB71C1C), // Merah tua kyak di foto
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                  child: Text(
                    '$totalItems',
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}