import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        // Mengikuti margin TableNumber agar sejajar presisi
        margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
        width: double.infinity, // Mengikuti lebar layar seperti TableNumber
        height: 45, // Disamakan tinggi 50 sesuai TableNumber
        child: Stack(
          children: [
            // Layer Bayangan/Aksen
            Positioned(
              left: 4,
              top: 4,
              right: 0, // Menggunakan right agar bayangan ikut melebar secara responsif
              child: Container(
                height: 46,
                decoration: ShapeDecoration(
                  color: const Color(0x7FDE3905),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13), // Radius 13 agar sama dengan TableNumber
                  ),
                ),
              ),
            ),
            // Main Button
            Container(
              width: double.infinity,
              height: 46,
              decoration: ShapeDecoration(
                color: const Color(0xFFDE3905),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13), // Radius disamakan 13
                ),
              ),
              child: Center(
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFFEFEAEA),
                    fontSize: 16, // Ukuran font disamakan 16 seperti TableNumber
                    fontFamily: 'Rubik',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}