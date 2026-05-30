import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../utils/currency_format.dart';

class ItemMenu extends StatelessWidget {
  final int id;
  final String namaMenu;
  final int harga;
  final String gambarUrl;
  final int idKategoriMenu;
  final int stok;

  const ItemMenu({
    super.key,
    required this.id,
    required this.namaMenu,
    required this.harga,
    required this.gambarUrl,
    required this.idKategoriMenu,
    required this.stok,
  });

  @override
  Widget build(BuildContext context) {
    final bool isOutOfStock = stok <= 0;

    return GestureDetector(
      onTap: isOutOfStock
          ? null
          : () {
              final Map<String, dynamic> menuData = {
                'id': id,
                'namaMenu': namaMenu,
                'harga': harga,
                'gambarUrl': gambarUrl,
              };

              if (idKategoriMenu == 1) {
                context.push('/detail-seblak/$id', extra: menuData);
              } else {
                context.push('/detail-menu/$id', extra: menuData);
              }
            },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isOutOfStock
                  ? Colors.transparent
                  : const Color(0xFFD9D9D9),
              width: 1,
            ),
          ),
        ),
        child: _buildItemContent(isOutOfStock),
      ),
    );
  }

  Widget _buildItemContent(bool isOutOfStock) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ✅ ColorFiltered sudah dipindah ke dalam _buildMenuImage
        // tidak merambat ke elemen lain
        _buildMenuImage(isOutOfStock),

        const SizedBox(width: 20),

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

                Positioned(
                  right: 0,
                  bottom: 0,
                  child: _buildStockStatusButton(isOutOfStock),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuImage(bool isOutOfStock) {
    return Container(
      width: 85,
      height: 85,
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(13),
        ),
        shadows: isOutOfStock
            ? const []
            : const [
                BoxShadow(
                  color: Color(0x3F000000),
                  blurRadius: 4,
                  offset: Offset(0, 4),
                ),
              ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        // ✅ ColorFiltered hanya membungkus gambar saja
        // sehingga efek abu-abu tidak merambat ke elemen lain
        child: isOutOfStock
            ? ColorFiltered(
                colorFilter: const ColorFilter.mode(
                  Colors.grey,
                  BlendMode.saturation,
                ),
                child: Opacity(
                  opacity: 0.6,
                  child: CachedNetworkImage(
                    imageUrl: gambarUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[200],
                      child: const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFFDE3905),
                          ),
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.fastfood,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              )
            : CachedNetworkImage(
                imageUrl: gambarUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[200],
                  child: const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFFDE3905),
                      ),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[300],
                  child: const Icon(
                    Icons.fastfood,
                    color: Colors.white,
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildStockStatusButton(bool isOutOfStock) {
    if (isOutOfStock) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        child: Text(
          'Out of Stock',
          style: TextStyle(
            color: Color(0xFFE53935),
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

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