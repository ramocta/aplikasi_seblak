import 'package:flutter/material.dart';
import 'package:seblak_say_cafe/views/costomer/cart_page.dart';
import '../../../models/cart_models.dart';

// ─── DATA MODEL ───────────────────────────────────────────

class FoodItem {
  final String name;
  final int basePrice;
  final String category;
  final String imagePath; // ← tambahan path foto
  const FoodItem(this.name, this.basePrice, this.category, this.imagePath);
}

class Topping {
  final String name;
  final int price;
  const Topping(this.name, this.price);
}

const List<FoodItem> seblakMenu = [
  FoodItem('Seblak Level 1', 7000, 'Seblak', 'assets/images/seblak1.jpg'),
  FoodItem('Seblak Level 2', 7000, 'Seblak', 'assets/images/seblak2.jpg'),
  FoodItem('Seblak Level 3', 7000, 'Seblak', 'assets/images/seblak3.jpg'),
  FoodItem('Seblak Level 4', 7000, 'Seblak', 'assets/images/seblak4.jpg'),
];

const List<FoodItem> drinkMenu = [
  FoodItem('Es Doger', 7000, 'Drink', 'assets/images/es_doger.jpg'),
  FoodItem('Es Teh', 3000, 'Drink', 'assets/images/es_teh.jpg'),
  FoodItem('Es Jeruk', 5000, 'Drink', 'assets/images/es_jeruk.jpg'),
  FoodItem('Air Putih', 3000, 'Drink', 'assets/images/air_putih.jpg'),
];

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

// ─── HELPER: Widget gambar dengan fallback emoji ──────────

Widget _foodImage(String imagePath, {double size = 56, String fallback = '🥘'}) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(8),
    child: Image.asset(
      imagePath,
      width: size,
      height: size,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        width: size,
        height: size,
        color: const Color(0xFFF0E0D0),
        child: Center(child: Text(fallback, style: TextStyle(fontSize: size * 0.45))),
      ),
    ),
  );
}

// ─── HALAMAN 1 — MENU ────────────────────────────────────

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  int _selectedTab = 0;
  final List<String> _tabs = ['Seblak', 'Mie', 'Drink', 'Snack'];
  static const Color _orange = Color(0xFFE8632A);

  List<FoodItem> get _currentMenu {
    switch (_selectedTab) {
      case 0: return seblakMenu;
      case 2: return drinkMenu;
      default: return [];
    }
  }

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
          Text('Say',
              style: TextStyle(
                  color: _orange, fontSize: 20, fontWeight: FontWeight.w800, fontStyle: FontStyle.italic)),
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
      child: const Column(
        children: [
          Text("Let's Celebrate",
              style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
          SizedBox(height: 2),
          Text('THIS NIGHT OF SHIVA',
              style: TextStyle(color: _orange, fontSize: 16, fontWeight: FontWeight.w800)),
          SizedBox(height: 2),
          Text('with us!', style: TextStyle(color: Colors.white, fontSize: 11)),
          SizedBox(height: 2),
          Text('DELICIOUS FOOD | WARM DRINKS | GOOD MOOD',
              style: TextStyle(color: Colors.white70, fontSize: 10, letterSpacing: 0.5)),
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
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
              decoration: BoxDecoration(
                color: active ? _orange : const Color(0xFFEEEEEE),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(_tabs[i],
                  style: TextStyle(
                      color: active ? Colors.white : Colors.grey[600],
                      fontWeight: FontWeight.w700,
                      fontSize: 12)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildItemList() {
    final menu = _currentMenu;
    if (menu.isEmpty) {
      return const Center(
        child: Text('Menu belum tersedia', style: TextStyle(color: Colors.grey, fontSize: 14)),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      itemCount: menu.length,
      itemBuilder: (_, i) => _buildItemCard(menu[i]),
    );
  }

  Widget _buildItemCard(FoodItem item) {
    final fallback = item.category == 'Drink' ? '🥤' : item.category == 'Mie' ? '🍜' : '🥘';
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 4, offset: const Offset(0, 1))
        ],
      ),
      child: Row(
        children: [
          // ← FOTO MENU (otomatis fallback ke emoji kalau foto belum ada)
          _foodImage(item.imagePath, size: 56, fallback: fallback),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF222222))),
                const SizedBox(height: 2),
                Text(item.category == 'Drink' ? '( Minuman segar )' : '( Add your toppings )',
                    style: const TextStyle(fontSize: 11, color: Colors.grey)),
                const SizedBox(height: 4),
                Text('Rp. ${_fmt(item.basePrice)}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF222222))),
              ],
            ),
          ),
          GestureDetector(
            onTap: () async {
              if (item.category == 'Drink') {
                CartManager().addItem(CartItem(
                  name: item.name,
                  category: item.category,
                  basePrice: item.basePrice,
                  toppings: [],
                  toppingPrice: 0,
                ));
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('${item.name} ditambahkan ke cart!'),
                  duration: const Duration(seconds: 1),
                  backgroundColor: _orange,
                ));
              } else {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => DetailPage(item: item)),
                );
                if (result == true) setState(() {});
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(color: _orange, borderRadius: BorderRadius.circular(8)),
              child: const Text('Add',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewCart() {
    final cartCount = CartManager().items.length;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ElevatedButton.icon(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CartPage()),
              );
              setState(() {});
            },
            icon: const Icon(Icons.shopping_cart, color: Colors.white, size: 18),
            label: const Text('View cart',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
            style: ElevatedButton.styleFrom(
              backgroundColor: _orange,
              minimumSize: const Size(double.infinity, 48),
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
          ),
          if (cartCount > 0)
            Positioned(
              top: -8,
              right: -6,
              child: Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                child: Center(
                  child: Text(
                    cartCount > 99 ? '99+' : '$cartCount',
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _fmt(int n) => n
      .toString()
      .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
}

// ─── HALAMAN 2 — DETAIL MENU ─────────────────────────────

class DetailPage extends StatefulWidget {
  final FoodItem item;
  const DetailPage({super.key, required this.item});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  static const Color _orange = Color(0xFFE8632A);
  String _activeTab = 'Frozenfood';
  final Map<String, int> _counts = {};

  int get _toppingTotal {
    int sum = 0;
    toppingData.forEach((cat, list) {
      for (int i = 0; i < list.length; i++) {
        sum += (_counts['${cat}_$i'] ?? 0) * list[i].price;
      }
    });
    return sum;
  }

  int get _total => widget.item.basePrice + _toppingTotal;

  void _adjust(String key, int delta) {
    setState(() => _counts[key] = ((_counts[key] ?? 0) + delta).clamp(0, 99));
  }

  void _addToCart() {
    final List<String> selectedToppings = [];
    toppingData.forEach((cat, list) {
      for (int i = 0; i < list.length; i++) {
        final count = _counts['${cat}_$i'] ?? 0;
        if (count > 0) selectedToppings.add('${list[i].name} x $count');
      }
    });
    CartManager().addItem(CartItem(
      name: widget.item.name,
      category: widget.item.category,
      basePrice: widget.item.basePrice,
      toppings: selectedToppings,
      toppingPrice: _toppingTotal,
    ));
    if (context.mounted) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${widget.item.name} ditambahkan ke cart!'),
        duration: const Duration(seconds: 1),
        backgroundColor: _orange,
      ));
    }
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
                      Text(widget.item.name,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF111111))),
                      const SizedBox(height: 4),
                      Text('Base price: Rp. ${_fmt(widget.item.basePrice)}',
                          style: const TextStyle(fontSize: 13, color: Colors.grey)),
                      const Divider(height: 20),
                      const Text('Choose your toppings',
                          style: TextStyle(fontSize: 12, color: Color(0xFF555555))),
                      const SizedBox(height: 10),
                      _buildToppingTabs(),
                      const SizedBox(height: 8),
                      _buildToppingList(),
                    ],
                  ),
                ),
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final fallback = widget.item.category == 'Mie' ? '🍜' : '🥘';
    return Stack(
      children: [
        // ← FOTO DI HEADER DETAIL PAGE
        SizedBox(
          height: 180,
          width: double.infinity,
          child: Image.asset(
            widget.item.imagePath,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              height: 180,
              color: const Color(0xFFD4A080),
              child: Center(child: Text(fallback, style: const TextStyle(fontSize: 60))),
            ),
          ),
        ),
        Positioned(
          top: 12, left: 12,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.85),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                children: [
                  Icon(Icons.arrow_back_ios, size: 13, color: Colors.black87),
                  SizedBox(width: 2),
                  Text('Back', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildToppingTabs() {
    return Row(
      children: toppingData.keys.map((tab) {
        final active = tab == _activeTab;
        return GestureDetector(
          onTap: () => setState(() => _activeTab = tab),
          child: Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: active ? _orange : const Color(0xFFEEEEEE),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(tab,
                style: TextStyle(
                    color: active ? Colors.white : Colors.grey[600],
                    fontWeight: FontWeight.w700,
                    fontSize: 11)),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildToppingList() {
    final list = toppingData[_activeTab]!;
    return Column(
      children: List.generate(list.length, (i) {
        final key = '${_activeTab}_$i';
        final count = _counts[key] ?? 0;
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFF0F0F0)))),
          child: Row(
            children: [
              Container(
                width: 38, height: 38,
                decoration: BoxDecoration(
                    color: const Color(0xFFF0E0D0), borderRadius: BorderRadius.circular(8)),
                child: const Center(child: Text('🥟', style: TextStyle(fontSize: 20))),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(list[i].name,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF222222))),
                    Text('Rp. ${_fmt(list[i].price)}',
                        style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
              ),
              Row(
                children: [
                  _counterBtn(Icons.remove, () => _adjust(key, -1)),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 18,
                    child: Text('$count',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF222222))),
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

  Widget _counterBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 24, height: 24,
        decoration: BoxDecoration(
          border: Border.all(color: _orange, width: 1.5),
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Icon(icon, size: 14, color: _orange),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFFEEEEEE))), color: Colors.white),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total:',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF111111))),
              Text('Rp. ${_fmt(_total)}',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF111111))),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _addToCart,
              icon: const Icon(Icons.shopping_cart, color: Colors.white, size: 18),
              label: const Text('Add to cart',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
              style: ElevatedButton.styleFrom(
                backgroundColor: _orange,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(int n) => n
      .toString()
      .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
}