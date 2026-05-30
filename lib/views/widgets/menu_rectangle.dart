import 'package:flutter/material.dart';

class MenuRectangle extends StatelessWidget {
  final Widget child; 
  final double minHeight;
  final EdgeInsetsGeometry? margin; // Tambahkan properti margin

  const MenuRectangle({
    super.key, 
    required this.child, 
    this.minHeight = 593, 
    this.margin, // Masukkan ke constructor
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, 
      margin: margin, // Pasang margin di sini
      constraints: BoxConstraints(minHeight: minHeight), // Paksa height tetap senilai minHeight
      decoration: const ShapeDecoration(
        color: Color(0xFFFFFEFE),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
      ),
      child: child, 
    );
  }
}