import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'views/costomer/menu_page2.dart';

=======
import 'package:get/get.dart';
import 'core/routes/app_router.dart';
>>>>>>> c93a1d96b38b99ecfe58506eb986e696fe2018cc
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    return MaterialApp(
      title: 'Seblak Say Cafe',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const MenuPage2(),
=======
    // Menggunakan GetMaterialApp.router agar GetX dan GoRouter bekerja bersama
    return GetMaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Seblak Say Cafe',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      routeInformationParser: AppRouter.router.routeInformationParser,
      routerDelegate: AppRouter.router.routerDelegate,
      routeInformationProvider: AppRouter.router.routeInformationProvider,
>>>>>>> c93a1d96b38b99ecfe58506eb986e696fe2018cc
    );
  }
}