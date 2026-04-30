import 'package:flutter/material.dart';
import 'deskripsi_menu_page1.dart';

// ─────────────────────────────────────────
// DATA MODEL (shared, didefinisikan di sini)
// ─────────────────────────────────────────

class MenuItem {
  final String name;
  final int basePrice;
  const MenuItem(this.name, this.basePrice);
}

const List<MenuItem> seblakMenu = [
  MenuItem('Seblak Level 1', 7000),
  MenuItem('Seblak Level 2', 7000),
  MenuItem('Seblak Level 3', 7000),
  MenuItem('Seblak Level 4', 7000),
];

// ─────────────────────────────────────────
// HALAMAN 1 — MENU PAGE
// ─────────────────────────────────────────

class MenuPage1 extends StatefulWidget {
  const MenuPage1({super.key});

  @override
  State<MenuPage1> createState() => _MenuPage1State();
}

class _MenuPage1State extends State<MenuPage1> {
  int _selectedTab = 0;
  final List<String> _tabs = ['Seblak', 'Mie', 'Drink', 'Snack'];
  static const Color _orange = Color(0xFFE8632A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            _buildBanner(),
            _buildTableBar(),
            _buildTabs(),
            Expanded(child: _buildItemList()),
            _buildViewCart(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Icon(Icons.arrow_back_ios, color: _orange, size: 18),
          Text(
            'Say',
            style: TextStyle(
              color: _orange,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              fontStyle: FontStyle.italic,
            ),
          ),
          Icon(Icons.menu, color: Colors.black87, size: 22),
        ],
      ),
    );
  }

  Widget _buildBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1A1A1A), Color(0xFF333333)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: const [
          Text("Let's Celebrate",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
          SizedBox(height: 2),
          Text('THIS NIGHT OF SHIVA',
              style: TextStyle(
                  color: _orange,
                  fontSize: 16,
                  fontWeight: FontWeight.w800)),
          SizedBox(height: 2),
          Text('with us!',
              style: TextStyle(color: Colors.white, fontSize: 11)),
          SizedBox(height: 2),
          Text('DELICIOUS FOOD | WARM DRINKS | GOOD MOOD',
              style: TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                  letterSpacing: 0.5)),
        ],
      ),
    );
  }

  Widget _buildTableBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      padding: const EdgeInsets.symmetric(vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFFF5A623),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(
        child: Text('Table 1  |  Dine in',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 13)),
      ),
    );
  }

  Widget _buildTabs() {
    return SizedBox(
      height: 38,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _tabs.length,
        itemBuilder: (_, i) {
          final active = i == _selectedTab;
          return GestureDetector(
            onTap: () => setState(() => _selectedTab = i),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
              decoration: BoxDecoration(
                color: active ? _orange : const Color(0xFFEEEEEE),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                _tabs[i],
                style: TextStyle(
                  color: active ? Colors.white : Colors.grey[600],
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildItemList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      itemCount: seblakMenu.length,
      itemBuilder: (_, i) => _buildItemCard(seblakMenu[i]),
    );
  }

  Widget _buildItemCard(MenuItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 4,
            offset: const Offset(0, 1),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFF0E0D0),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
                child: Text('🥘', style: TextStyle(fontSize: 26))),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF222222))),
                const SizedBox(height: 2),
                const Text('( Add your toppings )',
                    style: TextStyle(fontSize: 11, color: Colors.grey)),
                const SizedBox(height: 4),
                Text('Rp. ${_fmt(item.basePrice)}',
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF222222))),
              ],
            ),
          ),
          // ✅ Tombol Add → navigasi ke DeskripsiMenuSeblak
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DeskripsiMenuSeblak(item: item),
              ),
            ),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: _orange,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Add',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  
  Widget _buildViewCart() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: ElevatedButton.icon(
        onPressed: () {},
        icon:
            const Icon(Icons.shopping_cart, color: Colors.white, size: 18),
        label: const Text('View cart',
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
    );
  }

  String _fmt(int n) => n.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
}