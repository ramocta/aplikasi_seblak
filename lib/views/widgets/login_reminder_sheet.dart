import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginReminderSheet extends StatelessWidget {
  const LoginReminderSheet({super.key});

  // Fungsi statis untuk memicu bottom sheet dengan delay 1 detik
  static void showWithDelay(BuildContext context) {
    Future.delayed(const Duration(seconds: 1), () {
      if (!context.mounted) return;
      
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        isDismissible: false, // User dipaksa memilih salah satu tombol
        enableDrag: false,    // Menghindari sheet tertutup tanpa sengaja
        builder: (_) => const LoginReminderSheet(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar atas modal
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
        
          // Tombol Login (Utama)
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Tutup bottom sheet terlebih dahulu
                context.push('/login');      // Navigasi ke Halaman Login
              },
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFFDE3905),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                "Log in as admin",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Tombol Masuk sebagai Tamu (Sekunder)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cukup tutup sheet dan tetap di page saat ini
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFDE3905), width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                "Log in as a customer",
                style: TextStyle(
                  color: Color(0xFFDE3905),
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ),
           const SizedBox(height: 12),
        ],
      ),
    );
  }
}