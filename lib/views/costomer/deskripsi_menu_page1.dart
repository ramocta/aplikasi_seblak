import 'package:flutter/material.dart';
import 'menu_page1.dart';

// ─────────────────────────────────────────
// DATA TOPPING
// ─────────────────────────────────────────

class Topping {
  final String name;
  final int price;
  const Topping(this.name, this.price);
}

const Map<String, List<Topping>> toppingData = {
  'Krecek': [
    Topping('Krecek Krispy', 1500),
    Topping('Krecek Basah', 1000),
    Topping('Ceker Ayam', 2000),
  ],
  'Frozenfood': [
    Topping('Dumpling Ayam', 2000),
    Topping('Siomay', 2000),
    Topping('Baso Ikan', 2000),
    Topping('Sosis', 1500),
    Topping('Nugget', 2000),
    Topping('Tahu Crispy', 1500),
  ],
  'Others': [
    Topping('Telur Ceplok', 2500),
    Topping('Keju', 3000),
    Topping('Mie Extra', 1500),
  ],
};

// ─────────────────────────────────────────
// HALAMAN 2 — DESKRIPSI MENU SEBLAK
// ─────────────────────────────────────────

class DeskripsiMenuSeblak extends StatefulWidget {
  final MenuItem item;
  const DeskripsiMenuSeblak({super.key, required this.item});

  @override
  State<DeskripsiMenuSeblak> createState() => _DeskripsiMenuSeblakState();
}

class _DeskripsiMenuSeblakState extends State<DeskripsiMenuSeblak> {
  static const Color _orange = Color(0xFFE8632A);
  String _activeTab = 'Frozenfood';
  final Map<String, int> _counts = {};

  // Hitung total harga (base + semua topping)
  int get _total {
    int sum = widget.item.basePrice;
    toppingData.forEach((cat, list) {
      for (int i = 0; i < list.length; i++) {
        sum += (_counts['${cat}_$i'] ?? 0) * list[i].price;
      }
    });
    return sum;
  }

  void _adjust(String key, int delta) {
    setState(() {
      _counts[key] = ((_counts[key] ?? 0) + delta).clamp(0, 99);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nama menu
                      Text(widget.item.name,
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF111111))),
                      const SizedBox(height: 4),
                      // Harga dasar
                      Text('Base price: Rp. ${_fmt(widget.item.basePrice)}',
                          style: const TextStyle(
                              fontSize: 13, color: Colors.grey)),
                      const Divider(height: 20),
                      const Text('Choose your toppings',
                          style: TextStyle(
                              fontSize: 12, color: Color(0xFF555555))),
                      const SizedBox(height: 10),
                      // Tab kategori topping
                      _buildToppingTabs(),
                      const SizedBox(height: 8),
                      // List topping
                      _buildToppingList(),
                    ],
                  ),
                ),
              ),
            ),
            // Bottom bar: total + add to cart
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  // Header dengan gambar dan tombol back
  Widget _buildHeader(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 180,
          width: double.infinity,
          color: const Color(0xFFD4A080),
          child: const Center(
              child: Text('🥘', style: TextStyle(fontSize: 60))),
        ),
        Positioned(
          top: 12,
          left: 12,
          child: GestureDetector(
            // ✅ Tombol back → kembali ke MenuPage1
            onTap: () => Navigator.pop(context),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.85),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                children: [
                  Icon(Icons.arrow_back_ios,
                      size: 13, color: Colors.black87),
                  SizedBox(width: 2),
                  Text('Back',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Tab: Krecek / Frozenfood / Others
  Widget _buildToppingTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: toppingData.keys.map((tab) {
          final active = tab == _activeTab;
          return GestureDetector(
            onTap: () => setState(() => _activeTab = tab),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: active ? _orange : const Color(0xFFEEEEEE),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(tab,
                  style: TextStyle(
                    color: active ? Colors.white : Colors.grey[600],
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  )),
            ),
          );
        }).toList(),
      ),
    );
  }

  // List topping sesuai tab aktif
  Widget _buildToppingList() {
    final list = toppingData[_activeTab]!;
    return Column(
      children: List.generate(list.length, (i) {
        final key = '${_activeTab}_$i';
        final count = _counts[key] ?? 0;
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: const BoxDecoration(
            border: Border(
                bottom: BorderSide(color: Color(0xFFF0F0F0))),
          ),
          child: Row(
            children: [
              // Gambar topping
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0E0D0),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                    child:
                        Text('🥟', style: TextStyle(fontSize: 20))),
              ),
              const SizedBox(width: 10),
              // Nama & harga topping
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(list[i].name,
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF222222))),
                    Text('Rp. ${_fmt(list[i].price)}',
                        style: const TextStyle(
                            fontSize: 11, color: Colors.grey)),
                  ],
                ),
              ),
              // Tombol - qty +
              Row(
                children: [
                  _counterBtn(
                      Icons.remove, () => _adjust(key, -1)),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 18,
                    child: Text('$count',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF222222))),
                  ),
                  const SizedBox(width: 8),
                  _counterBtn(Icons.add, () => _adjust(key, 1)),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }

  // Tombol bulat + / -
  Widget _counterBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          border: Border.all(color: _orange, width: 1.5),
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Icon(icon, size: 14, color: _orange),
      ),
    );
  }

  // Bottom bar: total harga + tombol Add to cart
  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
        color: Colors.white,
      ),
      child: Column(
        children: [
          // Total otomatis berubah sesuai topping dipilih
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total:',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111111))),
              Text('Rp. ${_fmt(_total)}',
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111111))),
            ],
          ),
          const SizedBox(height: 10),
          // Tombol Add to cart
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        '${widget.item.name} ditambahkan ke cart! Total: Rp. ${_fmt(_total)}'),
                    backgroundColor: _orange,
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              icon: const Icon(Icons.shopping_cart,
                  color: Colors.white, size: 18),
              label: const Text('Add to cart',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14)),
              style: ElevatedButton.styleFrom(
                backgroundColor: _orange,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(int n) => n.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
}