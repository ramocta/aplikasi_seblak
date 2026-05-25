import 'package:flutter/material.dart';

class MenuRectangle extends StatelessWidget {
  final Widget child; // Menambahkan parameter child agar fleksibel

  const MenuRectangle({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, // Responsif memenuhi lebar layar
      constraints: const BoxConstraints(minHeight: 593),
      decoration: const ShapeDecoration(
        color: Color(0xFFFFFEFE),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
      ),
      child: child, // Menampilkan apapun yang dikirim dari MenuPage
    );
  }
}
