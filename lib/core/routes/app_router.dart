import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:seblak_say_cafe/views/admin/login_page.dart';
import 'package:seblak_say_cafe/views/admin/home_page.dart';
import 'package:seblak_say_cafe/views/admin/kelola_menu_mie.dart';
import 'package:seblak_say_cafe/views/admin/kelola_menu_minuman.dart';

import '../../views/splash/splash_screen.dart';
import '../../views/costomer/order_option_page.dart';

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
        path: '/login_page',
        builder: (context, state) => LoginPage(),
      ),

      GoRoute(
        path: '/home_page',
        builder: (context, state) => Home(),
      ),

      GoRoute(
        path: '/kelola_menu_mie',
        builder: (context, state) => const KelolaMenuMie(),
      ),

      GoRoute(
        path: '/kelola_menu_minuman',
        builder: (context, state) => const KelolaMenuMinuman(),
      ),
    ],
  );
}