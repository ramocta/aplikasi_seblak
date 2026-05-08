class CartItem {
  final String name;
  final String category; // 'Seblak', 'Mie', 'Drink'
  final int basePrice;
  final List<String> toppings; // deskripsi topping
  final int toppingPrice;
  int quantity;

  CartItem({
    required this.name,
    required this.category,
    required this.basePrice,
    required this.toppings,
    required this.toppingPrice,
    this.quantity = 1,
  });

  int get subtotal => (basePrice + toppingPrice) * quantity;
}

// Cart global sederhana (tanpa state management)
class CartManager {
  static final CartManager _instance = CartManager._internal();
  factory CartManager() => _instance;
  CartManager._internal();

  final List<CartItem> items = [];

  void addItem(CartItem item) {
    items.add(item);
  }

  void removeItem(int index) {
    items.removeAt(index);
  }

  void clear() {
    items.clear();
  }

  int get totalPrice => items.fold(0, (sum, item) => sum + item.subtotal);
}