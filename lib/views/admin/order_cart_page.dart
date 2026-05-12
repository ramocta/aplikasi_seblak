import 'package:flutter/material.dart';

class OrderCartPage extends StatefulWidget {
  const OrderCartPage({super.key});

  @override
  State<OrderCartPage> createState() => _OrderCartPageState();
}

class _OrderCartPageState extends State<OrderCartPage> {
  String? _paymentMode; // Menampung pilihan metode pembayaran

  // Data tiruan (dummy) untuk item di dalam keranjang
  final List<Map<String, dynamic>> _cartItems = [
    {
      'id': 1,
      'name': 'Seblak Level 1',
      'price': 7000,
      'toppings': [
        {'name': 'Dumpling Ayam', 'qty': 4, 'price': 2000},
      ],
      'subtotal': 15000,
    },
    {
      'id': 2,
      'name': 'Mie Level 1',
      'price': 9000,
      'notes': 'Flavor: Sweet',
      'subtotal': 9000,
    },
    {
      'id': 3,
      'name': 'Es Teh',
      'price': 3000,
      'subtotal': 3000,
    },
  ];

  @override
  Widget build(BuildContext context) {
    int total = _cartItems.fold(0, (sum, item) => sum + (item['subtotal'] as int));

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFE64A19)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Order Cart',
          style: TextStyle(
            color: Color(0xFFE64A19),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Color(0xFFE64A19)),
            onPressed: () {
              // Aksi Edit
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Color(0xFFE64A19)),
            onPressed: () {
              // Aksi Hapus
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // List Item pada Cart
            ..._cartItems.map((item) => _buildCartItem(item)),
            
            const SizedBox(height: 16),
            
            // Pilihan Pembayaran
            _buildPaymentSection(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(total),
    );
  }

  // Widget untuk menampilkan Item Keranjang
  Widget _buildCartItem(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.restaurant, color: Color(0xFFE64A19)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item['name'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          'Rp. ${item['price']}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                    if (item.containsKey('toppings')) ...[
                      const SizedBox(height: 6),
                      const Text(
                        'Topping:',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                      ...?((item['toppings'] as List).map((topping) {
                        return Text(
                          '${topping['name']} x ${topping['qty']}       Rp. ${topping['price'] * topping['qty']}',
                          style: const TextStyle(fontSize: 11, color: Colors.black87),
                        );
                      })),
                    ],
                    if (item.containsKey('notes')) ...[
                      const SizedBox(height: 6),
                      Text(
                        item['notes'],
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Subtotal:',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              Text(
                'Rp. ${item['subtotal']}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE64A19),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget Bagian Pilihan Pembayaran
  Widget _buildPaymentSection() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payment mode:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Choose a method of payment',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          
          // Opsi QRIS
          Row(
            children: [
              Radio<String>(
                value: 'qris',
                groupValue: _paymentMode,
                activeColor: const Color(0xFFE64A19),
                onChanged: (value) {
                  setState(() {
                    _paymentMode = value;
                  });
                },
              ),
              const Icon(Icons.qr_code_2, size: 30, color: Colors.black54),
              const SizedBox(width: 8),
              const Text(
                'QRIS',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Opsi Bayar di Kasir
          Row(
            children: [
              Radio<String>(
                value: 'cashier',
                groupValue: _paymentMode,
                activeColor: const Color(0xFFE64A19),
                onChanged: (value) {
                  setState(() {
                    _paymentMode = value;
                  });
                },
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'BAYAR DI KASIR',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget Bagian Bawah: Total dan Proses Pesanan
  Widget _buildBottomBar(int total) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total:',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  'Rp. $total',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE64A19),
                  ),
                ),
              ],
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE64A19),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                // Aksi untuk memproses pesanan
              },
              child: const Text(
                'Proses Pesanan',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}