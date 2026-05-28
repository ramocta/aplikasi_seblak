import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../utils/currency_format.dart';

class ItemMenu extends StatelessWidget {
  final int id;
  final String namaMenu;
  final int harga;
  final String gambarUrl;
  final int idKategoriMenu; // 1. TAMBAHKAN INI

  const ItemMenu({
    super.key,
    required this.id,
    required this.namaMenu,
    required this.harga,
    required this.gambarUrl,
    required this.idKategoriMenu, // 2. TAMBAHKAN INI
  });

  @override
  Widget build(BuildContext context) {
    print('gambarUrl = $gambarUrl');
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.only(bottom: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFD9D9D9), width: 1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gambar Menu
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
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(13),
              child: Image.network(
                gambarUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.fastfood, color: Colors.white),
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),

          // Area Konten
          Expanded(
            child: SizedBox(
              height: 85,
              child: Stack(
                children: [
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
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          CurrencyFormat.convertToIdr(harga),
                          style: const TextStyle(
                            color: Color(0xFF121212),
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ==================== TOMBOL ADD (LOGIKA KATEGORI) ====================
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: GestureDetector(
                      onTap: () {
                        // Data yang akan dikirim ke halaman detail
                        final Map<String, dynamic> menuData = {
                          'id': id,
                          'namaMenu': namaMenu,
                          'harga': harga,
                          'gambarUrl': gambarUrl,
                        };

                        if (idKategoriMenu == 1) {
                          // Navigasi ke detail seblak jika kategori ID = 1
                          context.push('/detail-seblak/$id', extra: menuData);
                        } else {
                          // Navigasi ke detail menu biasa untuk kategori lainnya
                          context.push('/detail-menu/$id', extra: menuData);
                        }
                      },
                      child: _buildAddButton(),
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

  Widget _buildAddButton() {
    return SizedBox(
      width: 52,
      height: 32,
      child: Stack(
        children: [
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
                  style: TextStyle(color: Colors.black, fontSize: 11),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
