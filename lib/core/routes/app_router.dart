// import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:seblak_say_cafe/views/costomer/checkout.dart';
// import 'package:flutter/material.dart';
import '../../views/splash/splash_screen.dart';
import '../../views/costomer/order_option_page.dart';
import '../../views/costomer/table_number_screen.dart';
import '../../views/costomer/menu_page2.dart';
import '../../views/costomer/detail_pesanan_page2.dart';
import '../../views/costomer/menu_page3.dart';
import "../../views/costomer/checkout.dart";
import '../../views/costomer/qris.dart';
import '../../views/costomer/bayar_dikasir.dart';
class AppRouter {

    static final router = GoRouter(
  initialLocation: '/menu-page2',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),

      GoRoute(
        path: '/table-number',
        builder: (context, state) => const TableNumberScreen(),
      ),

      GoRoute(
        path: '/menu',
        builder: (context, state) => const MenuPage2(),
      ),
      
      GoRoute(
        path: '/table-number',
        builder: (context, state) => DetailPesananPage2(
        nama: (state.extra as Map<String, String>)['nama']!,
        desc: (state.extra as Map<String, String>)['desc']!,
        harga: (state.extra as Map<String, String>)['harga']!,
        gambar: (state.extra as Map<String, String>)['gambar']!,
    ),
    ),  
      GoRoute(
        path: '/menu-drink',
        builder: (context, state) => const MenuPage3(),
      ),
      GoRoute(
        path: '/checkout',
        builder: (context, state) => const CheckoutPage(),
      ),
      GoRoute(
        path: '/qris',
        builder: (context, state) => const QrisPage(),

      ),
      GoRoute(
        path: '/bayar-dikasir',
        builder: (context, state) => const BayarDiKasirPage(),    
          ),
      GoRoute(
        path: '/menu-page2',
        builder: (context, state) => const MenuPage2(),
      )
    ],
  );
}