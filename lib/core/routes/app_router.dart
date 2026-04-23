import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
// import file disini

class AppRouter {

  static final router = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const Scaffold(body: Center(child: Text("Splash Screen"))),
      ),
    ],
  );
}