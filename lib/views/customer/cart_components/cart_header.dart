import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CartHeader extends StatelessWidget implements PreferredSizeWidget {
  const CartHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      // 💡 SOLUSI UTAMA: Menghentikan perubahan warna otomatis saat list di-scroll
      scrolledUnderElevation: 0, 
      leading: Padding(
        padding: const EdgeInsets.only(top: 12.0),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFDE3905)),
          onPressed: () => context.pop(),
        ),
      ),
      centerTitle: true,
      title: Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.shopping_cart_outlined,
              color: Color(0xFFDE3905),
              size: 26,
            ),
            SizedBox(width: 8),
            Text(
              "Your Cart",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 10);
}