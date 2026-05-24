import 'package:get/get.dart';
import 'package:seblak_say_cafe/services/menu_services.dart';
import '../models/menu_models.dart';
import '../models/kategori_menu_models.dart';

class MenuController extends GetxController {
  final MenuService _menuService = MenuService();

  var listCategories = <KategoriMenuModels>[].obs;
  var listMenu = <MenuModels>[].obs;
  var selectedCategoryId = 0.obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  // ==================== CACHE ====================
  final Map<int, List<MenuModels>> _menuCache = {};

  @override
  void onInit() {
    super.onInit();
    initialLoad();
  }

  Future<void> initialLoad() async {
    try {
      isLoading(true); 
      errorMessage.value = '';

      final categories = await _menuService.getAllCategories();

      if (categories.isEmpty) {
        errorMessage.value = "Belum ada kategori menu yang dibuat.";
        return;
      }

      listCategories.assignAll(categories);
      
      if (selectedCategoryId.value == 0) {
        selectedCategoryId.value = categories[0].id;
      }

      await fetchMenuByCategory(selectedCategoryId.value);
    } catch (e) {
      errorMessage.value = "Gagal terhubung ke server.";
      print("Error initialLoad: $e");
    } finally {
      isLoading(false);
    }
  }

  /// Fetch menu dengan caching
  Future<void> fetchMenuByCategory(int categoryId) async {
    // Cek cache dulu
    if (_menuCache.containsKey(categoryId)) {
      print("📦 Mengambil dari cache untuk kategori $categoryId");
      listMenu.assignAll(_menuCache[categoryId]!);
      return;
    }

    try {
      isLoading(true); 
      errorMessage.value = '';

      print("🌐 Fetching dari API untuk kategori $categoryId");

      final result = await _menuService.getMenuByCategory(categoryId);

      listMenu.assignAll(result);
      _menuCache[categoryId] = List.from(result); // Simpan ke cache

      print("✅ Berhasil memuat ${result.length} menu (kategori $categoryId)");
    } catch (e) {
      errorMessage.value = "Gagal memuat menu.";
      print("Error fetchMenuByCategory: $e");
      listMenu.clear();
    } finally {
      isLoading(false);
    }
  }

  Future<void> changeCategory(int id) async {
    if (selectedCategoryId.value == id) return;

    // 🔥 PENTING: Sebelum pindah kategori, amankan dulu perubahan stok list saat ini ke dalam cache!
    if (selectedCategoryId.value != 0 && listMenu.isNotEmpty) {
      _menuCache[selectedCategoryId.value] = List.from(listMenu);
    }

    selectedCategoryId.value = id;
    await fetchMenuByCategory(id);
  }

  // ==================== TAMBAHAN FUNGSI HAPUS MENU ====================
  Future<void> deleteMenu(int id) async {
    try {
      isLoading(true);
      
      final bool isSuccess = await _menuService.deleteMenu(id);
      
      if (isSuccess) {
        clearCache();
        await initialLoad();
      } else {
        throw "Gagal menghapus menu. Respon server tidak valid.";
      }
    } catch (e) {
      print("Error pas deleteMenu di Controller: $e");
      rethrow; 
    } finally {
      isLoading(false);
    }
  }

  // Clear cache jika perlu refresh data
  void clearCache() {
    _menuCache.clear();
    print("🧹 Cache menu berhasil dibersihkan");
  }

  Future<void> refreshData() async {
    clearCache();
    await initialLoad();
  }
}