import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/routes/app_router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'controllers/cart_controller.dart';
import 'package:get_storage/get_storage.dart';
import 'bidings/app_bidings.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  Get.put(CartController());
  await GetStorage.init();
  WidgetsFlutterBinding.ensureInitialized();

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
      initialBinding: AppBinding(),
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
