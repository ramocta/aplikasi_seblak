import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// ======================================================
// CUSTOMER IMPORT
// ======================================================

import 'package:seblak_say_cafe/views/customer/cart_page.dart';
import 'package:seblak_say_cafe/views/customer/checkout_page.dart';
import 'package:seblak_say_cafe/views/customer/payment_qris_page.dart';
import 'package:seblak_say_cafe/views/customer/order_option_page.dart';
import 'package:seblak_say_cafe/views/customer/table_number_screen.dart';
import 'package:seblak_say_cafe/views/customer/katalog_menu.dart';
import 'package:seblak_say_cafe/views/customer/detail_menu.dart';
import 'package:seblak_say_cafe/views/customer/detail_menu_seblak.dart';
import 'package:seblak_say_cafe/views/customer/detail_transaction_page.dart';

// ======================================================
// ADMIN IMPORT
// ======================================================

import 'package:seblak_say_cafe/models/menu_models.dart';
import 'package:seblak_say_cafe/models/topping_models.dart';
import 'package:seblak_say_cafe/models/transaction_models.dart';

import 'package:seblak_say_cafe/views/admin/add_menu_page.dart';
import 'package:seblak_say_cafe/views/admin/add_topping_page.dart';
import 'package:seblak_say_cafe/views/admin/edit_menu_page.dart';
import 'package:seblak_say_cafe/views/admin/edit_topping_page.dart';
import 'package:seblak_say_cafe/views/admin/login_page.dart';
import 'package:seblak_say_cafe/views/admin/menu_page.dart';
import 'package:seblak_say_cafe/views/admin/notifications_page.dart';
import 'package:seblak_say_cafe/views/admin/order_detail_page.dart';
import 'package:seblak_say_cafe/views/admin/order_page.dart';
import 'package:seblak_say_cafe/views/admin/print_receipt_page.dart';
import 'package:seblak_say_cafe/views/admin/profile_page.dart';
import 'package:seblak_say_cafe/views/admin/reports_page.dart';
import 'package:seblak_say_cafe/views/admin/topping_page.dart';
import 'package:seblak_say_cafe/views/admin/dashboard_page.dart';

// ======================================================
// SPLASH
// ======================================================

import 'package:seblak_say_cafe/views/splash/splash_screen.dart';

class AppRouter {
  // ======================================================
  // NAVIGATOR KEY
  // ======================================================

  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  // ======================================================
  // ROUTER
  // ======================================================

  static final router = GoRouter(
    initialLocation: '/splash',
    navigatorKey: _rootNavigatorKey,

    routes: [
      // ======================================================
      // GLOBAL ROUTE
      // ======================================================

      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // ======================================================
      // CUSTOMER ROUTES
      // ======================================================

      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),

      GoRoute(
        path: '/table-number',
        builder: (context, state) => const TableNumberScreen(),
      ),

      GoRoute(
        path: '/menu',
        builder: (context, state) => const MenuPage(),
      ),

      GoRoute(
        path: '/detail-menu/:menuId',
        builder: (context, state) {
          final int menuId =
              int.tryParse(state.pathParameters['menuId'] ?? '0') ?? 0;

          return DetailMenuPage(id: menuId);
        },
      ),

      GoRoute(
        path: '/edit-detail-menu/:menuId',
        builder: (context, state) {
          final int menuId =
              int.tryParse(state.pathParameters['menuId'] ?? '0') ?? 0;

          return DetailMenuPage(id: menuId);
        },
      ),

      GoRoute(
        path: '/detail-seblak/:menuId',
        builder: (context, state) {
          final int menuId =
              int.tryParse(state.pathParameters['menuId'] ?? '0') ?? 0;

          return DetailMenuSeblakPage(id: menuId);
        },
      ),

      GoRoute(
        path: '/edit-detail-seblak/:menuId',
        builder: (context, state) {
          final int menuId =
              int.tryParse(state.pathParameters['menuId'] ?? '0') ?? 0;

          return DetailMenuSeblakPage(id: menuId);
        },
      ),

      GoRoute(
        path: '/cart',
        builder: (context, state) => const CartPage(),
      ),

      GoRoute(
        path: '/checkout',
        builder: (context, state) => const CheckoutPage(),
      ),

      GoRoute(
        path: '/pay-qris',
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>;

          return PaymentQrisPage(
            orderId: args['orderId'] as String,
            totalHarga: args['totalHarga'] as double,
          );
        },
      ),

      GoRoute(
        path: '/detail-transaction',
        builder: (context, state) {
          final transactionData = state.extra as TransactionModel;

          return DetailTransactionPage(
            transaction: transactionData,
          );
        },
      ),

      // ======================================================
      // ADMIN ROUTES
      // ======================================================

      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),

      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsPage(),
      ),

      // ======================================================
      // ADMIN SHELL ROUTE
      // ======================================================

      ShellRoute(
        navigatorKey: _shellNavigatorKey,

        builder: (context, state, child) {
          final userData = state.extra as Map<String, dynamic>?;

          return DashboardPage(
            userData: userData,
            child: child,
          );
        },

        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const HomeTab(),
          ),

          GoRoute(
            path: '/order',
            builder: (context, state) => const OrderPage(),
          ),

          GoRoute(
            path: '/menu_management',
            builder: (context, state) => const MenuPage(),
          ),

          GoRoute(
            path: '/topping_management',
            builder: (context, state) => const ToppingPage(),
          ),

          GoRoute(
            path: '/profil',
            builder: (context, state) => const ProfilePage(),
          ),
        ],
      ),

      // ======================================================
      // ADMIN FULLSCREEN ROUTES
      // ======================================================

      GoRoute(
        path: '/order_detail',
        builder: (context, state) {
          final order = state.extra as Map<String, dynamic>;

          return OrderDetailPage(
            orderData: order,
          );
        },
      ),

      GoRoute(
        path: '/print-receipt/:id',
        builder: (context, state) {
          final orderId = state.pathParameters['id'] ?? '0';

          return PrintReceiptPage(orderId: orderId);
        },
      ),

      GoRoute(
        path: '/add_menu',
        builder: (context, state) => const AddMenuPage(),
      ),

      GoRoute(
        path: '/edit_menu',
        name: 'edit_menu',
        builder: (context, state) {
          final menuData = state.extra;

          if (menuData != null && menuData is MenuModels) {
            return EditMenuPage(menu: menuData);
          }

          return const Scaffold(
            body: Center(
              child: Text(
                "Data menu kosong atau tidak valid.",
              ),
            ),
          );
        },
      ),

      GoRoute(
        path: '/add_topping',
        builder: (context, state) => const AddToppingPage(),
      ),

      GoRoute(
        path: '/edit_topping',
        name: 'edit_topping',
        builder: (context, state) {
          final toppingData = state.extra;

          if (toppingData != null &&
              toppingData is ToppingModels) {
            return EditToppingPage(
              topping: toppingData,
            );
          }

          return const Scaffold(
            body: Center(
              child: Text(
                "Data topping kosong atau tidak valid.",
              ),
            ),
          );
        },
      ),

      GoRoute(
        path: '/reports',
        builder: (context, state) => const ReportsPage(),
      ),
    ],
  );
}