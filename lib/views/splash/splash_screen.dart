import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:seblak_say_cafe/core/constans/app_assets.dart' show AppAssets;
import 'package:seblak_say_cafe/core/constans/app_color.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Logika untuk pindah ke halaman Welcome setelah 3 detik
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        context.go('/welcome'); 
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary, // Mengambil warna dari AppColors
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Foto di tengah
            Image.asset(
              AppAssets.logo1,
              width: 300, // Sesuaikan ukuran
              height: 300,
            ),
            const SizedBox(height: 20),
            // Opsional: Tambahkan Loading Indicator
            const CircularProgressIndicator(
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}