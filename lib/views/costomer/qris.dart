import 'package:flutter/material.dart';

class QrisPage extends StatelessWidget {
  const QrisPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Say", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Align(alignment: Alignment.centerLeft, child: Text("Status Transaksi", style: TextStyle(fontSize: 16))),
            const SizedBox(height: 10),
            
            // Status Pending Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(color: Colors.amber[300], borderRadius: BorderRadius.circular(10)),
              child: const Text("pending", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 20),
            
            const Text("Your order is being processed. Please wait", textAlign: TextAlign.center),
            const SizedBox(height: 30),
            
            // QR Code Placeholder
            Container(
              height: 250,
              width: 250,
              decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 2)),
              child: const Center(child: Icon(Icons.qr_code_2, size: 200)),
            ),
            const SizedBox(height: 30),
            
            // Button Unduh
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange, foregroundColor: Colors.white),
                onPressed: () {}, // Tambahkan logika download di sini
                child: const Text("Unduh QR Code"),
              ),
            ),
            const SizedBox(height: 10),
            const Text("Screenshot jika QR Code tidak bisa di download", style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 30),
            
            // Instruksi Pembayaran (Navigasi ke Payment Success)
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PaymentSuccessPage()),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                decoration: BoxDecoration(color: Colors.deepOrange, borderRadius: BorderRadius.circular(10)),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Cara melakukan Pembayaran", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    Icon(Icons.keyboard_arrow_down, color: Colors.white),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Halaman kedua yang muncul setelah diklik
class PaymentSuccessPage extends StatelessWidget {
  const PaymentSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle_outline, color: Colors.deepOrange, size: 60),
              SizedBox(height: 20),
              Text("Payment successful", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}