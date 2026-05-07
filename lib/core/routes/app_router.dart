<<<<<<< HEAD
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// IMPORT YANG SUDAH DIPERBAIKI
import 'package:seblak_say_cafe/views/admin/login_page.dart';
import 'package:seblak_say_cafe/views/admin/home_page.dart';
import 'package:seblak_say_cafe/views/admin/kelola_menu_mie.dart';
import 'package:seblak_say_cafe/views/admin/kelola_menu_minuman.dart';
import 'package:seblak_say_cafe/views/splash/splash_screen.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/login_page',
=======
import 'package:go_router/go_router.dart';
// import 'package:flutter/material.dart';
import '../../views/splash/splash_screen.dart';
import '../../views/costomer/order_option_page.dart';
// import file disini

class AppRouter {

  static final router = GoRouter(
    initialLocation: '/splash',
>>>>>>> c3be4c19ac696da81cdfe5757a7c9a30358faf54
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
<<<<<<< HEAD

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
=======
      
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      
>>>>>>> c3be4c19ac696da81cdfe5757a7c9a30358faf54
    ],
  );
}