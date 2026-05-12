import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  static String baseUrl =
      dotenv.env['BASE_URL'] ?? '';

  static const String login = '/admin/login';
  static const String register = '/admin/register';
  static const String logout = '/logout';

  static const String menu = '/menu';
  static const String topping = '/topping';
  static const String kategoriMenu = '/kategorimenu';
  static const String kategoriTopping = '/kategoritopping';


  static const String checkout ='/checkout';
  static const String payQris ='/checkout';

  static const String adminMenu ='/admin/menu';
  static const String adminTopping ='/admin/topping';

  static const String stats ='/admin/stats';
  static const String history ='/admin/history';
  static const String printReceipt ='/admin/print';

  static const String applyTransaction ='/admin/transactions';
}