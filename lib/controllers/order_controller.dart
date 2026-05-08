import 'package:get/get.dart';

class OrderController extends GetxController {
  // Observables
  var selectedOrderType = "".obs; // "Dine In" atau "Take Away"
  var tableNumber = "".obs;

  // Cek apakah button Continue boleh aktif
  bool get isOrderTypeSelected => selectedOrderType.value.isNotEmpty;

  void selectType(String type) {
    selectedOrderType.value = type;
  }

  // Logika Navigasi
  String getNextRoute() {
    if (selectedOrderType.value == "Dine In") {
      return '/table-number';
    } else {
      return '/menu'; // Langsung ke katalog
    }
  }
}