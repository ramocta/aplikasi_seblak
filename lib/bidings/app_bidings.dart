import 'package:get/get.dart';
import '../controllers/menu_controller.dart'; // Sesuaikan path controller Anda
import '../controllers/topping_controller.dart'; // Jika ada ToppingController terpisah

class AppBinding extends Bindings {
  @override
  void dependencies() {
    // Menggunakan Get.put() dengan permanent true agar controller 
    // tidak terhapus saat berpindah halaman dari Order Option ke Katalog
    Get.put(MenuController(), permanent: true);
    
    // Jika Anda memiliki ToppingController terpisah, inisialisasi juga di sini:
    Get.put(ToppingController(), permanent: true);
  }
}