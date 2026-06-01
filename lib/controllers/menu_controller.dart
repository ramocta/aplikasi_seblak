import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:seblak_say_cafe/services/menu_services.dart';
import '../models/menu_models.dart';
import '../models/kategori_menu_models.dart';

class MenuController extends GetxController with GetTickerProviderStateMixin {
  final MenuService _menuService = MenuService();
  final GetStorage _localStorage = GetStorage();

  var listCategories = <KategoriMenuModels>[].obs;
  var listMenu = <MenuModels>[].obs;
  var selectedCategoryId = 0.obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  TabController? tabController;

  // Cache Memory RAM untuk perpindahan antar kategori yang cepat
  final Map<int, List<MenuModels>> _menuCache = {};

  @override
  void onInit() {
    super.onInit();
    // 🚀 Langsung dieksekusi di background saat Order Option Page terbuka
    initialLoad();
  }

  @override
  void onClose() {
    tabController?.dispose();
    super.onClose();
  }

void initTabController(int length) {
  if (length <= 0) return;

  tabController?.dispose();
  tabController = TabController(length: length, vsync: this);

  // ✅ Gunakan animation listener agar responsif saat swipe
  // addListener biasa tidak reliable saat swipe gesture
  tabController!.animation?.addListener(() {
    // Ambil index terdekat dari posisi animasi saat ini
    final int newIndex = tabController!.animation!.value.round();

    // Guard: pastikan index valid dan berbeda dari yang aktif
    if (newIndex < 0 || newIndex >= listCategories.length) return;
    if (newIndex == tabController!.index &&
        selectedCategoryId.value == listCategories[newIndex].id) return;

    final int activeCatId = listCategories[newIndex].id;

    // ✅ Update selectedCategoryId agar tab nav ikut highlight
    if (selectedCategoryId.value != activeCatId) {
      selectedCategoryId.value = activeCatId;
    }
  });

  // ✅ Tetap pakai addListener untuk fetch data saat swipe selesai
  // animation listener hanya update highlight, ini yang fetch data
  tabController!.addListener(() {
    if (tabController!.indexIsChanging) return;
    if (tabController!.index < 0 ||
        tabController!.index >= listCategories.length) return;

    final int activeCatId = listCategories[tabController!.index].id;
    if (selectedCategoryId.value != activeCatId) {
      changeCategory(activeCatId);
    }
  });
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

        listCategories.assignAll(
          cachedCategories.map((e) => KategoriMenuModels.fromJson(e)).toList(),
        );
        selectedCategoryId.value = listCategories[0].id;
        initTabController(listCategories.length);

        final localMenus = cachedFirstMenu
            .map((e) => MenuModels.fromJson(e))
            .toList();
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
        initTabController(listCategories.length);

        // Simpan pembaruan daftar kategori ke lokal storage
        _localStorage.write(
          'categories',
          categories.map((e) => e.toJson()).toList(),
        );

        // ✅ OPTIMASI PARALEL: Ambil data menu untuk SEMUA kategori secara bersamaan
        await _fetchAllCategoriesParallel(categories);

        // Tampilkan kategori pertama di UI dari cache
        listMenu.assignAll(_menuCache[categories[0].id] ?? []);

        print(
          "✅ [Menu] Sinkronisasi background selesai. Semua kategori di-cache.",
        );
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

  /// ✅ OPTIMASI: Menembak API Menu secara paralel menggunakan Future.wait
  Future<void> _fetchAllCategoriesParallel(
    List<KategoriMenuModels> categories,
  ) async {
    try {
      // Siapkan daftar tugas penembakan API untuk semua kategori
      final tasks = categories
          .map((category) => _menuService.getMenuByCategory(category.id))
          .toList();

      // Jalankan seluruh tugas secara bersamaan di background
      final results = await Future.wait(tasks);

      // Masukkan hasil data paralel ke dalam cache RAM
      for (int i = 0; i < categories.length; i++) {
        final categoryId = categories[i].id;
        final List<MenuModels> menus = results[i];
        _menuCache[categoryId] = List.from(menus);
      }

      // Simpan semua menu ke lokal storage sebagai backup
      final allMenusJson = <Map<String, dynamic>>[];
      for (var menu in _menuCache.values.expand((x) => x)) {
        allMenusJson.add(menu.toJson());
      }
      _localStorage.write('all_menus_backup', allMenusJson);
    } catch (e) {
      print("❌ ERROR _fetchAllCategoriesParallel: $e");
    }
  }

  Future<void> changeCategory(int id) async {
    if (selectedCategoryId.value == id) return;
    selectedCategoryId.value = id;

    final tabIndex = listCategories.indexWhere((category) => category.id == id);
    if (tabController != null &&
        tabIndex != -1 &&
        tabController!.index != tabIndex) {
      tabController!.animateTo(tabIndex);
    }

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
    _menuCache.clear();
    await initialLoad();
  }
  
  /// Getter untuk mengambil list menu dari cache berdasarkan kategori
  List<MenuModels> getMenusByCategory(int categoryId) {
    return _menuCache[categoryId] ?? [];
  }
}
