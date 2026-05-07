import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:get/get.dart';
import 'core/routes/app_router.dart';
import 'views/admin/login_page.dart';
=======
<<<<<<< HEAD
import 'views/costomer/menu_page2.dart';

=======
import 'package:get/get.dart';
import 'core/routes/app_router.dart';
>>>>>>> c93a1d96b38b99ecfe58506eb986e696fe2018cc
>>>>>>> c3be4c19ac696da81cdfe5757a7c9a30358faf54
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    return GetMaterialApp.router(
    // Menggunakan GetMaterialApp.router agar GetX dan GoRouter bekerja bersama
=======
<<<<<<< HEAD
    return MaterialApp(
      title: 'Seblak Say Cafe',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const MenuPage2(),
=======
    // Menggunakan GetMaterialApp.router agar GetX dan GoRouter bekerja bersama
    return GetMaterialApp.router(
>>>>>>> c3be4c19ac696da81cdfe5757a7c9a30358faf54
      debugShowCheckedModeBanner: false,
      title: 'Seblak Say Cafe',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      routeInformationParser: AppRouter.router.routeInformationParser,
      routerDelegate: AppRouter.router.routerDelegate,
      routeInformationProvider: AppRouter.router.routeInformationProvider,
<<<<<<< HEAD
=======
>>>>>>> c93a1d96b38b99ecfe58506eb986e696fe2018cc
>>>>>>> c3be4c19ac696da81cdfe5757a7c9a30358faf54
    );
  }
}