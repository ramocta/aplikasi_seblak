import 'package:flutter/material.dart';

class HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    // 1. Kurangi nilai ini agar garis samping lebih pendek (naik ke atas)
    double curveHeight = 120.0; 
    
    path.lineTo(0, size.height - curveHeight);
    
    // 2. Untuk membuat lebih bulat, titik kontrol (y) harus melebihi size.height
    path.quadraticBezierTo(
      size.width / 2, 
      size.height + 50, // Menambah nilai ini membuat elips lebih "gendut"/bulat
      size.width, 
      size.height - curveHeight
    );
    
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}