import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/routes/app_router.dart';
// import '../../views/splash/splash_screen.dart';
// import '../../views/costomer/order_option_page.dart';
// import '../../views/costomer/table_number_screen.dart';
// import '../../views/costomer/menu_page2.dart';
// import '../../views/costomer/detail_pesanan_page2.dart';
// import '../../views/costomer/menu_page3.dart';
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