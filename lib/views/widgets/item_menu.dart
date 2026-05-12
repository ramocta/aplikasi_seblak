import 'package:flutter/material.dart';

class ItemMenu extends StatelessWidget {
  final String namaMenu;
  final int harga;
  final String gambarUrl;

  const ItemMenu({
    super.key,
    required this.namaMenu,
    required this.harga,
    required this.gambarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.only(bottom: 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFD9D9D9), width: 1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gambar Menu dengan Efek Bayangan
          Container(
            width: 85,
            height: 85,
            decoration: ShapeDecoration(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(13),
              ),
              shadows: const [
                BoxShadow(
                  color: Color(0x3F000000),
                  blurRadius: 4,
                  offset: Offset(0, 4),
                  spreadRadius: 0,
                )
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(13),
              child: Image.network(
                gambarUrl,
                width: 85,
                height: 85,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.fastfood, color: Colors.white),
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),

          // Area Konten (Nama Menu & Harga + Tombol Add)
          Expanded(
            child: SizedBox(
              height: 85,
              child: Stack(
                children: [
                  // Nama & Harga (Alignment sesuai referensi)
                  Positioned(
                    left: 0,
                    top: 10,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          namaMenu,
                          style: const TextStyle(
                            color: Color(0xFF121212),
                            fontSize: 13,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12), // Jarak antara Nama dan Harga
                        Text(
                          'Rp $harga',
                          style: const TextStyle(
                            color: Color(0xFF121212),
                            fontSize: 14,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Tombol Add di Kanan Bawah
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: GestureDetector(
                      onTap: () {
                        print("Add $namaMenu to cart");
                      },
                      child: SizedBox(
                        width: 52,
                        height: 32,
                        child: Stack(
                          children: [
                            // Border Oranye Luar
                            Container(
                              width: 52,
                              height: 32,
                              decoration: ShapeDecoration(
                                color: const Color(0x7FDE3905),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                            // Konten Putih Dalam
                            Positioned(
                              left: 1,
                              top: 1,
                              child: Container(
                                width: 50,
                                height: 30,
                                decoration: ShapeDecoration(
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: const Center(
                                  child: Text(
                                    'Add',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 11,
                                      fontFamily: 'Roboto',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}