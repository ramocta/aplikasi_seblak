import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:seblak_say_cafe/services/menu_services.dart';
import '../models/menu_models.dart';
import '../models/kategori_menu_models.dart';

class MenuController extends GetxController {
  final MenuService _menuService = MenuService();
  final GetStorage _localStorage = GetStorage();

  var listCategories = <KategoriMenuModels>[].obs;
  var listMenu = <MenuModels>[].obs;
  var selectedCategoryId = 0.obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  // Cache Memory RAM untuk perpindahan antar kategori yang cepat
  final Map<int, List<MenuModels>> _menuCache = {};

  @override
  void onInit() {
    super.onInit();
    // 🚀 Langsung dieksekusi di background saat Order Option Page terbuka
    initialLoad(); 
  }

  Future<void> initialLoad() async {
    try {
      errorMessage.value = '';

      // =======================================================================
      // 1. STRATEGI INSTAN: MUAT DATA DARI STORAGE LOKAL (0 Milidetik)
      // =======================================================================
      final List<dynamic>? cachedCategories = _localStorage.read('categories');
      final List<dynamic>? cachedFirstMenu = _localStorage.read('first_menu');

      if (cachedCategories != null && cachedFirstMenu != null) {
        print("🚀 [Menu] Memuat data offline dari lokal storage (Instan)...");
        
        listCategories.assignAll(cachedCategories.map((e) => KategoriMenuModels.fromJson(e)).toList());
        selectedCategoryId.value = listCategories[0].id;
        
        final localMenus = cachedFirstMenu.map((e) => MenuModels.fromJson(e)).toList();
        listMenu.assignAll(localMenus);
        _menuCache[selectedCategoryId.value] = List.from(localMenus);
        
        // Matikan loading karena data lokal lama sudah siap dilihat oleh user
        isLoading(false);
      } else {
        // Jika cache benar-benar kosong (install baru), aktifkan loading indicator
        isLoading(true);
      }

      // =======================================================================
      // 2. STRATEGI LATAR BELAKANG: AMBIL DATA FRESH DARI LARAVEL (PARALEL)
      // =======================================================================
      print("🌐 [Menu] Menyinkronkan data kategori dari server Laravel...");
      final categories = await _menuService.getAllCategories();

      if (categories.isNotEmpty) {
        listCategories.assignAll(categories);
        selectedCategoryId.value = categories[0].id;
        
        // Simpan pembaruan daftar kategori ke lokal storage
        _localStorage.write('categories', categories.map((e) => e.toJson()).toList());

        // Ambil data menu fresh untuk kategori pertama secara silent sync
        final result = await _menuService.getMenuByCategory(categories[0].id);
        
        listMenu.assignAll(result);
        _menuCache[categories[0].id] = List.from(result);

        // Simpan pembaruan menu ke lokal storage
        _localStorage.write('first_menu', result.map((e) => e.toJson()).toList());
        print("✅ [Menu] Sinkronisasi background selesai. Data diperbarui.");
      }
    } catch (e) {
      print("❌ Error initialLoad Menu: $e");
      if (listMenu.isEmpty) {
        errorMessage.value = "Gagal terhubung ke server.";
      }
    } finally {
      isLoading(false);
    }
  }

  /// Ambil menu ketika user memilih atau berpindah kategori di katalog
  Future<void> fetchMenuByCategory(int categoryId) async {
    // Jika data kategori ini sudah pernah dibuka, ambil langsung dari RAM (0 ms)
    if (_menuCache.containsKey(categoryId)) {
      print("Mengambil dari cache internal untuk kategori $categoryId");
      listMenu.assignAll(_menuCache[categoryId]!);
      return;
    }

    try {
      isLoading(true);
      errorMessage.value = '';

      print("🌐 Fetching API untuk kategori baru: $categoryId");
      final result = await _menuService.getMenuByCategory(categoryId);
      
      listMenu.assignAll(result);
      _menuCache[categoryId] = List.from(result); // Amankan ke cache RAM
    } catch (e) {
      errorMessage.value = "Gagal memuat menu.";
      print("❌ Error fetchMenuByCategory: $e");
      listMenu.clear();
    } finally {
      isLoading(false);
    }
  }

  Future<void> changeCategory(int id) async {
    if (selectedCategoryId.value == id) return;
    selectedCategoryId.value = id;
    await fetchMenuByCategory(id);
  }

  Future<void> refreshData() async {
    _menuCache.clear();
    await initialLoad();
  }
}