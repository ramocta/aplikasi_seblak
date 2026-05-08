import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  static String baseUrl =
      dotenv.env['BASE_URL'] ?? '';

  static const String login = '/admin/login';
  static const String register = '/admin/register';

  static const String menu = '/menu';
  static const String topping = '/topping';


}
