import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ToppingSelectionPage extends StatefulWidget {
  final String menuName; // <-- Tambahan parameter
  final int basePrice;   // <-- Tambahan parameter

  const ToppingSelectionPage({
    super.key,
    required this.menuName,
    required this.basePrice,
  });

  @override
  State<ToppingSelectionPage> createState() => _ToppingSelectionPageState();
}

class _ToppingSelectionPageState extends State<ToppingSelectionPage> {
  String _activeTab = 'Frozenfood';

  // Data dummy item topping
  final List<Map<String, dynamic>> _toppings = [
    {'name': 'Dumpling Ayam', 'price': 2000, 'qty': 1},
    {'name': 'Dumpling Ayam', 'price': 3000, 'qty': 0},
    {'name': 'Dumpling Ayam', 'price': 2000, 'qty': 0},
    {'name': 'Dumpling Ayam', 'price': 2000, 'qty': 0},
    {'name': 'Dumpling Ayam', 'price': 2000, 'qty': 0},
    {'name': 'Dumpling Ayam', 'price': 2000, 'qty': 0},
    {'name': 'Dumpling Ayam', 'price': 2000, 'qty': 0},
    {'name': 'Dumpling Ayam', 'price': 2000, 'qty': 0},
    {'name': 'Dumpling Ayam', 'price': 2000, 'qty': 1},
    {'name': 'Dumpling Ayam', 'price': 2000, 'qty': 0},
  ];

  int get _totalPrice {
    int toppingTotal = _toppings.fold(0, (sum, item) => sum + (item['price'] * (item['qty'] as int) as int));
    return widget.basePrice + toppingTotal; // Menggunakan basePrice dinamis
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFE64A19)),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Add Toping',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Info
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.menuName, // <-- Ditampilkan secara dinamis
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Base price: Rp. ${widget.basePrice}', // <-- Ditampilkan secara dinamis
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Choose your toppings',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),

          // Kategori Tab
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                _buildTab('Krecek'),
                const SizedBox(width: 8),
                _buildTab('Frozenfood'),
                const SizedBox(width: 8),
                _buildTab('Other'),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // List Topping
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: _toppings.length,
              itemBuilder: (context, index) {
                return _buildToppingItem(index);
              },
            ),
          ),

          // Total & Button Tambah Pesanan
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildTab(String label) {
    bool isActive = _activeTab == label;
    return GestureDetector(
      onTap: () => setState(() => _activeTab = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFE64A19) : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isActive ? Colors.white : Colors.black54,
          ),
        ),
      ),
    );
  }

  Widget _buildToppingItem(int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.fastfood, color: Colors.grey, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _toppings[index]['name'],
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
                Text(
                  'Rp. ${_toppings[index]['price']}',
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ],
            ),
          ),
          Row(
            children: [
              _counterBtn(Icons.remove, () {
                if (_toppings[index]['qty'] > 0) {
                  setState(() => _toppings[index]['qty']--);
                }
              }, isAdd: false),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Text(
                  '${_toppings[index]['qty']}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
              _counterBtn(Icons.add, () {
                setState(() => _toppings[index]['qty']++);
              }, isAdd: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _counterBtn(IconData icon, VoidCallback onTap, {required bool isAdd}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isAdd ? const Color(0xFFE64A19) : Colors.white,
          border: Border.all(color: const Color(0xFFE64A19)),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          icon,
          size: 14,
          color: isAdd ? Colors.white : const Color(0xFFE64A19),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -3),
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
                'Total:',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              Text(
                'Rp. $_totalPrice',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFFE64A19),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE64A19),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => context.pop(),
              child: const Text(
                'Tambah Pesanan',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}