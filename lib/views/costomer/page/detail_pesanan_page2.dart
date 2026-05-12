import 'package:flutter/material.dart';

class DetailPesananPage2 extends StatefulWidget {
  final String nama;
  final String desc;
  final String harga;
  final String gambar;

  const DetailPesananPage2({
    super.key,
    required this.nama,
    required this.desc,
    required this.harga,
    required this.gambar,
  });

  @override
  State<DetailPesananPage2> createState() => _DetailPesananPage2State();
}

class _DetailPesananPage2State extends State<DetailPesananPage2> {
  String rasaDipilih = 'Sweet';
  int jumlah = 1;

  // Ambil angka dari harga, contoh: "Rp. 9.000" → 9000
  int get hargaAngka {
    return int.tryParse(widget.harga.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
  }

  // Format angka jadi rupiah, contoh: 9000 → "9.000"
  String formatRupiah(int angka) {
    return angka.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [

          // ── Gambar + Tombol Back ──
          Stack(
            children: [
              SizedBox(
                height: 260, width: double.infinity,
                child: Image.asset(widget.gambar, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: const Color(0xFFFFECCC),
                    child: const Icon(Icons.ramen_dining, size: 80, color: Color(0xFFE53935)),
                  ),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.85),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back_ios_new, size: 16, color: Color(0xFFE53935)),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ── Konten Detail ──
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // Nama & harga
                  Text(widget.nama,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Price: ${formatRupiah(hargaAngka)}',
                    style: const TextStyle(fontSize: 14, color: Colors.black87)),
                  const Divider(height: 24),

                  // Pilihan rasa
                  const Text('Choose your noodle flavor',
                    style: TextStyle(fontSize: 13, color: Colors.grey)),
                  const SizedBox(height: 10),
                  Row(
                    children: ['Sweet', 'Salty'].map((rasa) {
                      final dipilih = rasaDipilih == rasa;
                      return GestureDetector(
                        onTap: () => setState(() => rasaDipilih = rasa),
                        child: Container(
                          margin: const EdgeInsets.only(right: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: dipilih ? const Color(0xFFF5C518) : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: dipilih ? const Color(0xFFF5C518) : Colors.grey.shade300),
                          ),
                          child: Row(
                            children: [
                              Text(rasa,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: dipilih ? Colors.white : Colors.black87,
                                )),
                              const SizedBox(width: 6),
                              Icon(dipilih ? Icons.check : Icons.close,
                                size: 14,
                                color: dipilih ? Colors.white : Colors.grey.shade400),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 20),

                  // Quantity
                  Row(
                    children: [
                      const Text('Quantity:', style: TextStyle(fontSize: 13)),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () { if (jumlah > 1) setState(() => jumlah--); },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: const Icon(Icons.remove, size: 16),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text('$jumlah',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                      ),
                      GestureDetector(
                        onTap: () => setState(() => jumlah++),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: const Icon(Icons.add, size: 16),
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Total & tombol Add to cart
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total:',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                      Text('Rp. ${formatRupiah(hargaAngka * jumlah)}',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
                      label: const Text('Add to cart',
                        style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE53935),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}