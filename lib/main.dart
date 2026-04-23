import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/routes/app_router.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
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
    );
  }
}