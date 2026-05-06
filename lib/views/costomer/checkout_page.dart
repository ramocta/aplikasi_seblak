import 'package:flutter/material.dart';
import '../../models/cart_models.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  static const Color _orange = Color(0xFFE8632A);
  String? _selectedPayment; // 'qris' atau 'kasir'
  final _nameController = TextEditingController();
  bool _orderExpanded = false;
  final cart = CartManager();

  String _fmt(int n) => n
      .toString()
      .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');

  bool get _canCheckout => _selectedPayment != null && _nameController.text.trim().isNotEmpty;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Logo
                    const Center(
                      child: Text('Say',
                          style: TextStyle(
                            color: Color(0xFFE8632A),
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            fontStyle: FontStyle.italic,
                          )),
                    ),
                    const SizedBox(height: 20),

                    // Input nama
                    const Text('Enter your name',
                        style: TextStyle(fontSize: 13, color: Color(0xFF333333), fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _nameController,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFEEEEEE),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Your Order dropdown
                    GestureDetector(
                      onTap: () => setState(() => _orderExpanded = !_orderExpanded),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFDDDDDD)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Your Order',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                            Icon(_orderExpanded ? Icons.expand_less : Icons.expand_more,
                                color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                    if (_orderExpanded)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(10),
                            bottomRight: Radius.circular(10),
                          ),
                          border: Border.all(color: const Color(0xFFDDDDDD)),
                        ),
                        child: Column(
                          children: cart.items.map((item) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('${item.name} x${item.quantity}',
                                      style: const TextStyle(fontSize: 12)),
                                  Text('Rp. ${_fmt(item.subtotal)}',
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    const SizedBox(height: 20),

                    // Payment mode
                    const Text('Payment mode:',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF111111))),
                    const SizedBox(height: 4),
                    const Text('Choose a method of payment',
                        style: TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 12),

                    // QRIS
                    _buildPaymentOption(
                      value: 'qris',
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF003087),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('QRIS\nCode Transfer\nPembayaran Nasional',
                            style: TextStyle(color: Colors.white, fontSize: 9, height: 1.4)),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Bayar di Kasir
                    _buildPaymentOption(
                      value: 'kasir',
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFCC0000),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Column(
                          children: [
                            Text('BAYAR DI KASIR',
                                style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800)),
                            Text('PAY AT CASHIER',
                                style: TextStyle(color: Colors.white, fontSize: 9)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Checkout button
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _canCheckout ? _doCheckout : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _canCheckout ? _orange : const Color(0xFFDDDDDD),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: Text(
                    'Checkout',
                    style: TextStyle(
                      color: _canCheckout ? Colors.white : Colors.grey,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption({required String value, required Widget child}) {
    final selected = _selectedPayment == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedPayment = value),
      child: Row(
        children: [
          Container(
            width: 22, height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? _orange : Colors.grey,
                width: selected ? 2 : 1.5,
              ),
              color: Colors.white,
            ),
            child: selected
                ? Center(
                    child: Container(
                      width: 12, height: 12,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: _orange,
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          child,
        ],
      ),
    );
  }

  void _doCheckout() {
    cart.clear();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Pesanan Berhasil! 🎉'),
        content: Text(
          'Halo ${_nameController.text}, pesananmu sudah diterima.\n'
          'Pembayaran: ${_selectedPayment == "qris" ? "QRIS" : "Bayar di Kasir"}',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text('OK', style: TextStyle(color: Color(0xFFE8632A))),
          ),
        ],
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
            child: const Icon(Icons.arrow_back_ios, color: Color(0xFFE8632A), size: 18),
          ),
          const Expanded(
            child: Center(
              child: Text('Checkout',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF111111))),
            ),
          ),
          const SizedBox(width: 18),
        ],
      ),
    );
  }
}