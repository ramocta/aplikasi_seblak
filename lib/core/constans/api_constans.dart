import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  static String baseUrl = dotenv.env['BASE_URL'] ?? '';

  // ==================== AUTH ENDPOINTS ====================
  static const String login = '/admin/login';
  static const String register = '/admin/register';
  static const String logout = '/logout';

  // ==================== KATALOG ENDPOINTS (PELANGGAN) ====================
  static const String menu = '/menu';
  static const String topping = '/topping';
  static const String kategoriMenu = '/kategorimenu';
  static const String kategoriTopping = '/kategoritopping';

  // ==================== TRANSAKSI ENDPOINTS (PELANGGAN) ====================
  static const String checkout = '/checkout';

  static const String transactionDetailCustomer = '/transactions';

  // ==================== MANAGEMENT ENDPOINTS (ADMIN) ====================
  static const String adminMenu = '/admin/menu';
  static const String adminTopping = '/admin/topping';

  // Dashboard & Laporan Admin
  static const String stats = '/admin/stats';
  static const String history = '/admin/history';
  static const String printReceipt = '/admin/print';

  // ✅ KELOLA TRANSAKSI MASUK (ADMIN)
  // Menampilkan detail item & bukti bayar QRIS: BaseUrl + '/admin/transactions/$id'
  static const String transactionDetail = '/admin/transactions'; 
  
  // Menyetujui transaksi: BaseUrl + '/admin/transactions/$id/apply'
  static const String applyTransaction = '/admin/transactions'; 
  
  // Menolak transaksi: BaseUrl + '/admin/transactions/$id/reject'
  static const String rejectTransaction = '/admin/transactions'; 
}