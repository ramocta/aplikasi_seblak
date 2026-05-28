import 'package:intl/intl.dart';

class CurrencyFormat {
  static String convertToIdr(dynamic number) {
    if (number == null) return 'Rp 0';
    
    // Memastikan input adalah angka (int atau double)
    num value;
    if (number is String) {
      value = num.tryParse(number) ?? 0;
    } else if (number is num) {
      value = number;
    } else {
      value = 0;
    }

    // Menggunakan locale 'id' untuk format Indonesia (menggunakan titik sebagai pemisah ribuan)
    final numFormat = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0, // Menghilangkan ,00 di belakang angka
    );
    
    return numFormat.format(value);
  }
}