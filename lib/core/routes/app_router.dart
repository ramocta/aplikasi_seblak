import 'package:go_router/go_router.dart';
// import 'package:flutter/material.dart';
import '../../views/splash/splash_screen.dart';
import '../../views/costomer/order_option_page.dart';
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
      
    ],
  );
}