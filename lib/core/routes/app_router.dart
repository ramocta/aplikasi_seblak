import 'package:go_router/go_router.dart';
import 'package:seblak_say_cafe/views/costomer/deskripsi_menu_page1.dart';
// import 'package:flutter/material.dart';
import '../../views/splash/splash_screen.dart';
import '../../views/costomer/order_option_page.dart';
import '../../views/costomer/table_number_screen.dart';
import '../../views/costomer/menu_page1.dart';
import '../../views/costomer/deskripsi_menu_page1.dart';

// import file disini

class AppRouter {

  static final router = GoRouter(
    initialLocation: '/splash',
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
        builder: (context, state) => const MenuPage1(),
      ),

      GoRoute(
        path: '/deskripsi',
        builder: (context, state) => DeskripsiMenuSeblak(
        item: state.extra as MenuItem,
      ),
     ),
    ],
  );
}