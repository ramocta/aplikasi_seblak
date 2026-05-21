import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart'; // ✅ Import GetStorage
import 'package:seblak_say_cafe/services/topping_services.dart';
import '../models/kategori_topping_models.dart';
import '../models/topping_models.dart';

class ToppingController extends GetxController {
  final ToppingService _toppingService = ToppingService();
  final GetStorage _localStorage = GetStorage(); // ✅ Instance storage lokal

  var listCategories = <KategoriToppingModels>[].obs;
  var listTopping = <ToppingModels>[].obs;

  var selectedCategoryId = 0.obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  final Map<int, List<ToppingModels>> _toppingCache = {};
  final Map<int, ToppingModels> _allToppingsFlat = {};
  final RxMap<int, int> _selectedQuantities = <int, int>{}.obs;

  @override
  void onInit() {
    super.onInit();
    // 🚀 Langsung mencuri start download di background saat halaman Order Option terbuka!
    initialLoad();
  }

  Future<void> initialLoad() async {
    try {
      errorMessage.value = '';

      // =======================================================================
      // 1. STRATEGI INSTAN: LOAD DATA OFFLINE DARI LOCAL STORAGE (0 Milidetik)
      // =======================================================================
      final List<dynamic>? cachedToppingCategories = _localStorage.read('topping_categories');
      final List<dynamic>? cachedAllToppingsFlat = _localStorage.read('all_toppings_flat');

      if (cachedToppingCategories != null && cachedAllToppingsFlat != null) {
        print("🚀 [Topping] Memuat data offline topping dari lokal storage (Instan)...");
        
        // Restore kategori topping
        listCategories.assignAll(cachedToppingCategories.map((e) => KategoriToppingModels.fromJson(e)).toList());
        selectedCategoryId.value = listCategories.first.id;

        // Restore flat toppings untuk kebutuhan hitung harga & kuantitas
        for (var item in cachedAllToppingsFlat) {
          final topping = ToppingModels.fromJson(item);
          _allToppingsFlat[topping.id] = topping;
        }

        // Rekonstruksi cache RAM berdasarkan data flat lokal
        _rebuildToppingCacheFromFlat();

        // Tampilkan kategori pertama di UI secara instan
        listTopping.assignAll(_toppingCache[selectedCategoryId.value] ?? []);
        
        isLoading(false);
      } else {
        // Jika aplikasi pertama diinstal dan cache kosong, aktifkan loading muter
        isLoading(true);
      }

      // =======================================================================
      // 2. STRATEGI BACKGROUND: AMBIL DATA FRESH DARI LARAVEL (PARALEL & CEPAT)
      // =======================================================================
      print("🌐 [Topping] Menyinkronkan data topping terbaru dari server Laravel...");
      final categories = await _toppingService.getAllCategories();

      if (categories.isEmpty) {
        if (listCategories.isEmpty) errorMessage.value = "Belum ada kategori topping.";
        return;
      }

      listCategories.assignAll(categories);
      selectedCategoryId.value = categories.first.id;
      _localStorage.write('topping_categories', categories.map((e) => e.toJson()).toList());

      // OPTIMALISASI BESAR: Ambil seluruh data topping per kategori secara PARALEL (Bersamaan)
      await _fetchAllCategoriesParallel(categories);

      // Sinkronisasi data ke UI utama secara halus setelah background fetch sukses
      listTopping.assignAll(_toppingCache[selectedCategoryId.value] ?? []);
      
      // Simpan backup seluruh data flat topping ke lokal storage HP
      final flatListJson = _allToppingsFlat.values.map((e) => e.toJson()).toList();
      _localStorage.write('all_toppings_flat', flatListJson);
      
      print("✅ [Topping] Semua data kategori & item topping sukses disinkronkan.");
    } catch (e) {
      print("❌ ERROR initialLoad Topping: $e");
      if (listTopping.isEmpty) {
        errorMessage.value = "Gagal terhubung ke server.";
      }
    } finally {
      isLoading(false);
    }
  }

  /// ✅ OPTIMALISASI: Menembak API Topping secara serentak (Paralel) menggunakan Future.wait
  Future<void> _fetchAllCategoriesParallel(List<KategoriToppingModels> categories) async {
    try {
      // Siapkan daftar tugas penembakan API
      final tasks = categories.map((category) => _toppingService.getToppingByCategory(category.id)).toList();
      
      // Jalankan seluruh tugas secara bersamaan di background
      final results = await Future.wait(tasks);

      // Masukkan hasil data paralel ke dalam cache RAM dan Flat Map
      for (int i = 0; i < categories.length; i++) {
        final categoryId = categories[i].id;
        final List<ToppingModels> toppings = results[i];

        for (var topping in toppings) {
          _allToppingsFlat[topping.id] = topping;
        }
        _toppingCache[categoryId] = List.from(toppings);
      }
    } catch (e) {
      print("❌ ERROR _fetchAllCategoriesParallel: $e");
    }
  }

  /// Membantu menyusun ulang serpihan data flat lokal ke dalam grup kategori di RAM
  void _rebuildToppingCacheFromFlat() {
    _toppingCache.clear();
    for (var topping in _allToppingsFlat.values) {
      // Gunakan field relasi ID kategori yang ada pada model topping Anda
      final catId = topping.idKategoriTopping; 
      if (!_toppingCache.containsKey(catId)) {
        _toppingCache[catId] = [];
      }
      _toppingCache[catId]!.add(topping);
    }
  }

  /// Dipanggil saat user berpindah tab kategori topping di dialog seblak
  Future<void> fetchToppingByCategory(int categoryId) async {
    if (_toppingCache.containsKey(categoryId)) {
      listTopping.assignAll(_toppingCache[categoryId]!);
      return;
    }

    try {
      isLoading(false); // ✅ PERBAIKAN LOGIKA: Set true saat loading aktif
      errorMessage.value = '';

      final result = await _toppingService.getToppingByCategory(categoryId);

      for (var topping in result) {
        _allToppingsFlat[topping.id] = topping;
      }

      listTopping.assignAll(result);
      _toppingCache[categoryId] = List.from(result);
    } catch (e) {
      errorMessage.value = "Gagal memuat topping.";
      listTopping.clear();
      print("❌ ERROR fetchToppingByCategory: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<void> changeCategory(int id) async {
    if (selectedCategoryId.value == id) return;
    selectedCategoryId.value = id;
    await fetchToppingByCategory(id);
  }

  void updateQuantity(int toppingId, int delta) {
    int current = _selectedQuantities[toppingId] ?? 0;
    int newValue = current + delta;
    if (newValue >= 0) {
      _selectedQuantities[toppingId] = newValue;
    }
  }

  int getQuantity(int toppingId) {
    return _selectedQuantities[toppingId] ?? 0;
  }

  void setQuantityById(int toppingId, int quantity) {
    if (quantity > 0) {
      _selectedQuantities[toppingId] = quantity;
    }
  }

  void restoreFromSaved(String nama, int quantity) {
    if (quantity <= 0) return;
    final match = _allToppingsFlat.values.where((t) => t.nama == nama).firstOrNull;
    if (match != null) {
      _selectedQuantities[match.id] = quantity;
    }
  }

  int get totalToppingPrice {
    if (_selectedQuantities.isEmpty) return 0;
    int total = 0;
    _selectedQuantities.forEach((id, qty) {
      final topping = _allToppingsFlat[id];
      if (topping != null) {
        total += topping.harga * qty;
      }
    });
    return total;
  }

  List<ToppingModels> getSelectedToppingsList() {
    List<ToppingModels> selected = [];
    _selectedQuantities.forEach((id, qty) {
      if (qty > 0) {
        final topping = _allToppingsFlat[id];
        if (topping != null) {
          topping.selectedQuantity = qty;
          selected.add(topping);
        }
      }
    });
    return selected;
  }

  void resetSelections() {
    _selectedQuantities.clear();
    _allToppingsFlat.forEach((key, value) => value.selectedQuantity = 0);
  }

  Future<void> refreshData() async {
    _toppingCache.clear();
    _allToppingsFlat.clear();
    _selectedQuantities.clear();
    await initialLoad();
  }
}