// lib/views/costomer/cart_page.dart

import 'package:flutter/material.dart';
import '../../models/cart_models.dart';
import 'checkout_page.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  static const Color _orange = Color(0xFFE8632A);
  final cart = CartManager();

  String _fmt(int n) => n
      .toString()
      .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context),
            Expanded(
              child: cart.items.isEmpty
                  ? const Center(
                      child: Text('Keranjang kosong',
                          style: TextStyle(color: Colors.grey, fontSize: 14)),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: cart.items.length,
                      itemBuilder: (_, i) => _buildCartItem(i),
                    ),
            ),
            _buildBottomBar(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back_ios, color: _orange, size: 18),
          ),
          const Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shopping_cart_outlined, color: _orange, size: 20),
                SizedBox(width: 6),
                Text('Your Cart',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF111111))),
              ],
            ),
          ),
          // Edit & Delete icons
          Row(
            children: [
              Icon(Icons.edit_outlined, color: Colors.orange[300], size: 20),
              const SizedBox(width: 10),
              Icon(Icons.delete_outline, color: Colors.red[300], size: 20),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(int index) {
    final item = cart.items[index];
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 1))
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nomor
          Text('${index + 1}.',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF222222))),
          const SizedBox(width: 10),
          // Gambar
          Container(
            width: 60, height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFF0E0D0),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                item.category == 'Drink' ? '🥤' : item.category == 'Mie' ? '🍜' : '🥘',
                style: const TextStyle(fontSize: 28),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Detail
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${item.name} x ${item.quantity}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                    Text('Rp. ${_fmt(item.basePrice * item.quantity)}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF333333))),
                  ],
                ),
                if (item.toppings.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(item.toppings.join('\n'),
                      style: const TextStyle(fontSize: 11, color: Colors.grey)),
                ],
                const Divider(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Subtotal:',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    Text('Rp. ${_fmt(item.subtotal)}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total:',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF111111))),
              Text('Rp. ${_fmt(cart.totalPrice)}',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF111111))),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: cart.items.isEmpty
                  ? null
                  : () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CheckoutPage()),
                      ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _orange,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: const Text('Checkout',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
            ),
          ),
        ],
      ),
    );
  }
}