import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PrintReceiptPage extends StatelessWidget {
  const PrintReceiptPage({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryOrange = Color(0xFFE64A19);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primaryOrange),
          onPressed: () => context.pop(),
        ),
        title: const Text('print receipt', style: TextStyle(color: primaryOrange, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 40),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
                child: Column(
                  children: [
                    const Text("SEBLAK PRASMANAN", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const Text("Outlet #01 - Plaza Surabaya Central", style: TextStyle(fontSize: 10)),
                    const Text("Jl. Sudirman No. 12, Jakarta", style: TextStyle(fontSize: 10)),
                    const Text("Telp: (021) 555-0193", style: TextStyle(fontSize: 10)),
                    const SizedBox(height: 20),
                    _rowInfo("Order: ORD-8821", "12/10/2023"),
                    _rowInfo("Cashier: Ahmad R.", "14:42:01"),
                    const Text("-------------------------------------------"),
                    _rowItem("1x Seblak Kuah - Level 5", "16.000"),
                    _rowItem("3x Bakso Sapi Jumbo", "12.000"),
                    _rowItem("1x Dumpling Keju", "4.000"),
                    const Text("-------------------------------------------"),
                    _rowTotal("Subtotal", "39.500"),
                    _rowTotal("Tax (10%)", "3.950"),
                    const SizedBox(height: 10),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("TOTAL", style: TextStyle(fontWeight: FontWeight.bold)),
                        Text("Rp45.450", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text("-------------------------------------------"),
                    const SizedBox(height: 10),
                    Image.network('https://upload.wikimedia.org/wikipedia/commons/thumb/d/d0/QR_code_for_spec_1.svg/1200px-QR_code_for_spec_1.svg.png', height: 80),
                    const SizedBox(height: 10),
                    const Text("Thank You for Dining with Us!", style: TextStyle(fontSize: 10)),
                  ],
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(backgroundColor: primaryOrange, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                    child: const Text("Copy Receipt", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => context.go('/'), // Arahkan ke root/dashboard
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE0E0E0), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                    child: const Text("Back to Dashboard", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _rowInfo(String l, String r) => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(l, style: const TextStyle(fontSize: 10)), Text(r, style: const TextStyle(fontSize: 10))]);
  Widget _rowItem(String n, String p) => Padding(padding: const EdgeInsets.symmetric(vertical: 2), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(n, style: const TextStyle(fontSize: 11)), Text(p, style: const TextStyle(fontSize: 11))]));
  Widget _rowTotal(String l, String p) => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(l, style: const TextStyle(fontSize: 11, color: Colors.grey)), Text(p, style: const TextStyle(fontSize: 11))]);
}