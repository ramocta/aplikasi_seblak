import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'print_receipt_page.dart';

class OrderDetailPage extends StatelessWidget {
  const OrderDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryOrange = Color(0xFFE64A19);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: const Text('Order Detail',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
                color: const Color(0xFFFFE0B2),
                borderRadius: BorderRadius.circular(20)),
            child: const Text('#ORD-8821',
                style: TextStyle(
                    color: primaryOrange,
                    fontWeight: FontWeight.bold,
                    fontSize: 12)),
          ),
        ],
      ),
      body: Column(
        children: [
          // --- BAGIAN YANG BISA DI-SCROLL ---
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Customer Information',
                      style: TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Budi Setiawan',
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold)),
                      const CircleAvatar(
                          backgroundColor: Color(0xFFF5F5F5),
                          child: Icon(Icons.person, color: Colors.grey)),
                    ],
                  ),
                  const Row(
                    children: [
                      Icon(Icons.home_outlined, size: 16, color: Colors.grey),
                      SizedBox(width: 4),
                      Text('Table 04 — Dine-In',
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      _buildStatusCard(
                          "Payment Status", "Paid via QRIS", Colors.blue),
                      const SizedBox(width: 12),
                      _buildStatusCard("Order Status", "Pending", Colors.orange),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Order Summary',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      Text('2 Items', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                  const Divider(height: 32),
                  
                  // Daftar Item
                  _buildOrderItem("Seblak - Level 3", "Rp7.000"),
                  _buildOrderItem("Seblak - Level 1", "Rp7.000"),

                  const Divider(height: 32),

                  // --- RINGKASAN TOTAL (Sesuai Gambar Baru) ---
                  _buildPriceRow("Subtotal", "Rp37.000"),
                  const SizedBox(height: 8),
                  _buildPriceRow("Tax (10%)", "Rp3.700"),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('Total Price',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      Text('Rp40.700',
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: primaryOrange)),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // --- TOMBOL TETAP DI BAWAH (STICKY) ---
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  const BoxShadow(
                      color: Colors.black12, blurRadius: 4, offset: Offset(0, -2))
                ]),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: () => context.push('/print_receipt'),
                    icon: const Icon(Icons.print, color: Colors.white),
                    label: const Text("print receipt",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: primaryOrange,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12))),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.sync, color: Colors.black),
                    label: const Text("Update Status",
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE0E0E0),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12))),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget Baris Harga (Subtotal/Tax)
  Widget _buildPriceRow(String label, String price) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 16)),
        Text(price,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
      ],
    );
  }

  Widget _buildStatusCard(String title, String status, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: const Color(0xFFF9F9F9),
            borderRadius: BorderRadius.circular(8)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(color: Colors.grey, fontSize: 11)),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.circle, size: 8, color: color),
                const SizedBox(width: 6),
                Text(status,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 13)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItem(String title, String price) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
              Text(price,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          ...List.generate(
              4,
              (index) => Padding(
                    padding: const EdgeInsets.only(left: 8, top: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Dumpling x${index + 1}",
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 13)),
                        const Text("Rp 6.000",
                            style:
                                TextStyle(color: Colors.grey, fontSize: 13)),
                      ],
                    ),
                  )),
          const SizedBox(height: 4),
          const Text("Qty: 1",
              style: TextStyle(
                  color: Color(0xFFE64A19),
                  fontWeight: FontWeight.bold,
                  fontSize: 13)),
        ],
      ),
    );
  }
}