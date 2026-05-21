import 'package:get/get.dart';
import '../models/cart_models.dart';

class CartController extends GetxController {
  var cartItems = <CartItem>[].obs;

  void addToCart(CartItem item) {
    if (item.id == null) return;

    if (item.selectedToppings.isNotEmpty) {
      cartItems.add(item);
      return;
    }

    int index = cartItems.indexWhere(
      (i) =>
          i.id.toString() == item.id.toString() && i.selectedToppings.isEmpty,
    );

    if (index != -1) {
      cartItems[index] = cartItems[index].copyWith(
        quantity: cartItems[index].quantity + item.quantity,
      );
    } else {
      cartItems.add(item);
    }
  }

  void updateCartItem(CartItem updatedItem) {
    if (updatedItem.id == null) return;
    final index = cartItems.indexWhere(
      (i) => i.id.toString() == updatedItem.id.toString(),
    );
    if (index != -1) {
      cartItems[index] = updatedItem;
    } else {
      cartItems.add(updatedItem);
    }
  }

  void updateCartItemAt(int cartIndex, CartItem updatedItem) {
    if (cartIndex < 0 || cartIndex >= cartItems.length) return;
    cartItems[cartIndex] = updatedItem;
  }

  // ✅ Bug 3 fix: hapus berdasarkan index, bukan ID
  // agar 2 seblak dengan ID sama tidak keduanya terhapus
  void removeFromCartAt(int cartIndex) {
    if (cartIndex < 0 || cartIndex >= cartItems.length) return;
    cartItems.removeAt(cartIndex);
  }

  // Tetap ada untuk menu biasa (ID unik, tidak ada duplikat)
  void removeFromCart(dynamic id) {
    if (id == null) return;
    cartItems.removeWhere((item) => item.id.toString() == id.toString());
  }

  int get totalPrice => cartItems.fold(0, (sum, item) {
    int toppingPricePerMenu = item.selectedToppings.fold(
      0,
      (tSum, topping) => tSum + (topping.harga * topping.quantity),
    );
    return sum + ((item.harga + toppingPricePerMenu) * item.quantity);
  });

  int get totalItems => cartItems.fold(0, (sum, item) => sum + item.quantity);

  void updateQuantity(dynamic id, int newQuantity) {
    final index = cartItems.indexWhere(
      (item) => item.id.toString() == id.toString(),
    );
    if (index == -1) return;
    if (newQuantity > 0) {
      cartItems[index] = cartItems[index].copyWith(quantity: newQuantity);
    } else {
      removeFromCart(id);
    }
  }

  void clearCart() {
    cartItems.clear();
  }
}
