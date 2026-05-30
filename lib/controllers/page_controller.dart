import 'dart:async';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:seblak_say_cafe/core/constans/app_assets.dart';
class HomeBannerSlider extends StatefulWidget {
  const HomeBannerSlider({super.key});

  @override
  State<HomeBannerSlider> createState() => _HomeBannerSliderState();
}

class _HomeBannerSliderState extends State<HomeBannerSlider> {
  // 1. Definisikan PageController
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;
  Timer? _timer;

  // 2. Daftar gambar banner promo Seblak Say Cafe Anda
  final List<String> _banners = [
    AppAssets.bannerPromo, // Banner utama Anda
    AppAssets.bannerPromo2, // Ganti dengan asset banner 2 jika ada
    AppAssets.bannerPromo3, // Ganti dengan asset banner 3 jika ada
  ];

  @override
  void initState() {
    super.initState();
    // 3. Setup Auto-scroll setiap 3 detik
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (_currentPage < _banners.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeIn,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ✅ WIDGET BANNER PROMO SLIDER
        SizedBox(
          height: 150, // Sesuaikan dengan tinggi kontainer Anda sebelumnya
          child: PageView.builder(
            controller: _pageController,
            itemCount: _banners.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(13),
                  image: DecorationImage(
                    image: AssetImage(_banners[index]),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        ),
        
        const SizedBox(height: 8),

        // ✅ INDIKATOR TITIK-TITIK DI BAWAH SLIDER
        SmoothPageIndicator(
          controller: _pageController,
          count: _banners.length,
          effect: const ExpandingDotsEffect(
            dotHeight: 8,
            dotWidth: 8,
            activeDotColor: Color(0xFFDE3905), // Warna oranye khas Seblak Say Cafe
            dotColor: Colors.grey,
          ),
        ),
      ],
    );
  }
}