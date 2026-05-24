import 'package:get/get.dart';
import 'package:seblak_say_cafe/services/topping_services.dart';
import '../models/topping_models.dart';
import '../models/kategori_topping_models.dart';

class ToppingController extends GetxController {
  final ToppingService _toppingService = ToppingService();

  var listCategories = <KategoriToppingModels>[].obs;
  var listTopping = <ToppingModels>[].obs;
  var selectedCategoryId = 0.obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    initialLoad();
  }

  Future<void> initialLoad() async {
    try {
      isLoading(true);
      errorMessage.value = '';
      final categories = await _toppingService.getAllToppingCategories();

      if (categories.isEmpty) {
        errorMessage.value = "Belum ada kategori topping.";
        return;
      }

      listCategories.assignAll(categories);
      
      if (selectedCategoryId.value == 0) {
        selectedCategoryId.value = categories[0].id;
      }
      
      await fetchToppingByCategory(selectedCategoryId.value);
    } catch (e) {
      errorMessage.value = "Error Kategori: $e";
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchToppingByCategory(int categoryId) async {
    try {
      isLoading(true);
      errorMessage.value = ''; 
      listTopping.clear(); 

      final result = await _toppingService.getToppingByCategory(categoryId);
      listTopping.assignAll(result);
      
    } catch (e) {
      errorMessage.value = "Gagal memuat topping: $e";
    } finally {
      isLoading(false);
    }
  }

  Future<void> changeCategory(int id) async {
    selectedCategoryId.value = id;
    await fetchToppingByCategory(id);
  }

  Future<void> refreshData() async {
    await initialLoad();
  }

  /// Fungsi Hapus Menu Topping Asinkronus
  Future<void> deleteTopping(int id) async {
    try {
      isLoading(true);
      final success = await _toppingService.deleteTopping(id);
      if (success) {
        // Tarik data terbaru setelah proses hapus di DB sukses
        await fetchToppingByCategory(selectedCategoryId.value);
      } else {
        throw "Gagal menghapus topping dari server.";
      }
    } catch (e) {
      print("Error pas deleteTopping di Controller: $e");
      rethrow; 
    } finally {
      isLoading(false);
    }
  }
}