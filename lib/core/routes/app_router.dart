import 'package:go_router/go_router.dart';
import 'package:seblak_say_cafe/views/costomer/cart_page.dart';
import 'package:seblak_say_cafe/views/costomer/checkout_page.dart';
import 'package:seblak_say_cafe/views/costomer/payment_qris_page.dart';
import '../../views/splash/splash_screen.dart';
import '../../views/costomer/order_option_page.dart';
import '../../views/costomer/table_number_screen.dart';
import '../../views/costomer/katalog_menu.dart';
import '../../views/costomer/detail_menu.dart';
import '../../views/costomer/detail_menu_seblak.dart';
import '../../views/costomer/detail_transaction_page.dart';
import '../../models/transaction_models.dart';

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
        path: '/table-number',
        builder: (context, state) => const TableNumberScreen(),
      ),

      GoRoute(path: '/menu', builder: (context, state) => const MenuPage()),

      // ✅ Route dari MenuPage untuk menu biasa — tanpa extra
      GoRoute(
        path: '/detail-menu/:menuId',
        builder: (context, state) {
          final int menuId =
              int.tryParse(state.pathParameters['menuId'] ?? '0') ?? 0;
          return DetailMenuPage(id: menuId);
        },
      ),

      // ✅ Route dari CartPage mode edit untuk menu biasa
      // Semua data dibaca dari extra langsung di initState DetailMenuPage
      GoRoute(
        path: '/detail/:menuId',
        builder: (context, state) {
          final int menuId =
              int.tryParse(state.pathParameters['menuId'] ?? '0') ?? 0;
          return DetailMenuPage(id: menuId);
        },
      ),

      // ✅ Route dari MenuPage untuk seblak — tanpa extra, tidak duplikat
      GoRoute(
        path: '/detail-seblak/:menuId',
        builder: (context, state) {
          final int menuId =
              int.tryParse(state.pathParameters['menuId'] ?? '0') ?? 0;
          return DetailMenuSeblakPage(id: menuId);
        },
      ),

      GoRoute(path: '/cart', builder: (context, state) => const CartPage()),

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
          // 1. Ambil data model yang dikirimkan melalui parameter 'extra'
          // Cast datanya secara eksplisit sebagai TransactionModel
          final transactionData = state.extra as TransactionModel;

          // 2. Kirim data tersebut ke constructor DetailTransactionPage
          return DetailTransactionPage(transaction: transactionData);
        },
      ),
    ],
  );
}
