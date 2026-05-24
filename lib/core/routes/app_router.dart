import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:seblak_say_cafe/models/menu_models.dart';
import 'package:seblak_say_cafe/models/topping_models.dart';
import 'package:seblak_say_cafe/views/admin/add_menu_page.dart';
import 'package:seblak_say_cafe/views/admin/add_topping_page.dart';
import 'package:seblak_say_cafe/views/admin/detail_mie_page.dart';
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
import 'package:seblak_say_cafe/views/admin/topping_selection_page.dart';
import 'package:seblak_say_cafe/views/costomer/order_option_page.dart';
import '../../views/splash/splash_screen.dart';
import '../../views/admin/dashboard_page.dart';

class AppRouter {
  // Navigator Keys global untuk memisahkan konteks shell dan root
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static final router = GoRouter(
    initialLocation: '/splash',
    navigatorKey: _rootNavigatorKey,
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
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),

      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsPage(),
      ),

      // =======================================================================
      // BUNGKUS NAVIGASI UTAMA DENGAN SHELLROUTE (BottomNavBar nempel terus disini)
      // =======================================================================
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          // Mengambil data user opsional dari extra login jika ada
          final userData = state.extra as Map<String, dynamic>?;
          return DashboardPage(
            userData: userData,
            child: child, // child ini adalah halaman sub-rute aktif di bawah
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
            builder: (context, state) {
              // Jika widget DashboardPage melempar userData, kita bisa teruskan ke ProfilePage
              return const ProfilePage();
            },
          ),
        ],
      ),
      // =======================================================================

      // Rute-rute di bawah ini berada di luar ShellRoute, jadi pas dibuka otomatis Full Screen (NavBar Hilang)

      GoRoute(
        path: '/order_detail',
        builder: (context, state) {
          final order = state.extra as Map<String, dynamic>;
          // SINKRONKAN PARAMETER MENJADI orderData UNTUK OrderDetailPage
          return OrderDetailPage(orderData: order); 
        },
      ),

      GoRoute(
        // ✅ Menggunakan :id agar GoRouter tahu bahwa bagian akhir URL adalah parameter dinamis
        path: '/print-receipt/:id', 
        builder: (context, state) {
          // Mengambil parameter 'id' yang dikirim dari URL
          final orderId = state.pathParameters['id'] ?? '0'; 
          
          // Ganti dengan nama class halaman cetak struk milikmu yang sebenarnya
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
            body: Center(child: Text("Data menu kosong atau tidak valid.")),
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
            // Kita terima object mentah-mentah tanpa paksaan as Map
            final toppingData = state.extra;

            if (toppingData != null && toppingData is ToppingModels) {
              return EditToppingPage(topping: toppingData);
            }

            return const Scaffold(
              body: Center(child: Text("Data topping kosong atau tidak valid.")),
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