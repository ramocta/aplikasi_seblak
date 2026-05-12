import 'package:go_router/go_router.dart';
import 'package:seblak_say_cafe/views/admin/add_menu_page.dart';
import 'package:seblak_say_cafe/views/admin/add_order_page.dart';
import 'package:seblak_say_cafe/views/admin/add_topping_page.dart';
import 'package:seblak_say_cafe/views/admin/detail_mie_page.dart';
import 'package:seblak_say_cafe/views/admin/edit_menu_page.dart';
import 'package:seblak_say_cafe/views/admin/edit_topping_page.dart';
import 'package:seblak_say_cafe/views/admin/menu_page.dart';
import 'package:seblak_say_cafe/views/admin/notifications_page.dart';
import 'package:seblak_say_cafe/views/admin/order_cart_page.dart';
import 'package:seblak_say_cafe/views/admin/order_detail_page.dart';
import 'package:seblak_say_cafe/views/admin/order_page.dart';
import 'package:seblak_say_cafe/views/admin/print_receipt_page.dart';
import 'package:seblak_say_cafe/views/admin/topping_page.dart';
import 'package:seblak_say_cafe/views/admin/topping_selection_page.dart';
// import 'package:flutter/material.dart';
import '../../views/splash/splash_screen.dart';
import '../../views/customer/order_option_page.dart';
import '../../views/admin/dashboard_page.dart';
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
        path: '/dashboard',
        builder: (context, state) => const DashboardPage(),
      ),

      GoRoute(
        path: '/order',
        builder: (context, state) => const OrderPage(),
      ),
      
      GoRoute(
        path: '/add_order',
        builder: (context, state) => const AddOrderPage(),
      ),

      GoRoute(
        path: '/order_detail',
        builder: (context, state) => const OrderDetailPage(),
      ),

      GoRoute(
        path: '/print_receipt',
        builder: (context, state) => const PrintReceiptPage(),
      ),

      GoRoute(
        path: '/menu_management',
        builder: (context, state) => const MenuPage(),
      ),

      GoRoute(
        path: '/add_menu',
        builder: (context, state) => const AddMenuPage(),
      ),

      GoRoute(
        path: '/topping_management',
        builder: (context, state) => const ToppingPage(),
      ),

      GoRoute(
        path: '/detail_mie',
        builder: (context, state) => const DetailMiePage(),
      ),

      GoRoute(
        path: '/add_topping',
        builder: (context, state) => const AddToppingPage(),
      ),

      GoRoute(
        path: '/add_menu',
        builder: (context, state) => const AddMenuPage(),
      ),

      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsPage(),
      ),

      GoRoute(
        path: '/order_cart',
        builder: (context, state) => const OrderCartPage(),
      ),

      GoRoute(
        path: '/edit_topping',
        builder: (context, state) {
          // Mengambil data extra yang dikirim dari ToppingManagementPage
          final extra = state.extra as Map<String, dynamic>;
          
          return EditToppingPage(
            name: extra['name'] ?? '',
            price: extra['price'] ?? '',
            stock: extra['stock'] ?? '',
            category: extra['category'] ?? '',
          );
        },
      ),

      GoRoute(
        path: '/topping_selection',
        builder: (context, state) {
          // Mengambil data extra yang dikirim melalui GoRouter
          final extra = state.extra as Map<String, dynamic>;
          return ToppingSelectionPage(
            menuName: extra['menuName'] ?? '',
            basePrice: extra['basePrice'] ?? 0,
          );
        },
      ),

      GoRoute(
        path: '/edit_menu',
        builder: (context, state) {
          // Mengambil data extra yang dikirim dari halaman Menu
          final extra = state.extra as Map<String, dynamic>;
          
          return EditMenuPage(
            initialName: extra['name'] ?? '',
            initialCategory: extra['category'] ?? '',
            initialStock: extra['stock'] ?? 0,
            initialPrice: extra['price'] ?? 0,
            initialDescription: extra['description'] ?? '',
          );
        },
      ),

    ],
  );
}