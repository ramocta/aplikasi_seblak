import 'kategori_topping_models.dart';

class ToppingModels {
  final int id;
  final String nama;
  final int harga;
  final int stok;
  final String gambarUrl;
  final String lastUpdate;
  final KategoriToppingModels kategoritopping;
  int selectedQuantity;

  ToppingModels({
    required this.id,
    required this.nama,
    required this.harga,
    required this.stok,
    required this.gambarUrl,
    required this.lastUpdate,
    required this.kategoritopping,
    this.selectedQuantity = 0,
  });

  /// 🔴 SHORTCUT GETTER: Menyembuhkan error di ToppingController
  /// Mengambil ID kategori langsung dari objek relasi di bawahnya
  int get idKategoriTopping => kategoritopping.id;

  factory ToppingModels.fromJson(Map<String, dynamic> json) {
    return ToppingModels(
      id: json['id'] ?? 0,
      nama: json['nama'] ?? '',
      harga: json['harga'] ?? 0,
      stok: json['stok'] ?? 0,
      // Mengamankan pembacaan key snake_case dari Laravel maupun camelCase dari GetStorage lokal
      gambarUrl: json['gambar_url'] ?? json['gambarUrl'] ?? '',
      lastUpdate: json['last_update'] ?? json['lastUpdate'] ?? '-',
      selectedQuantity: json['selected_quantity'] ?? json['selectedQuantity'] ?? 0,
      
      // Mengamankan nested object kategori agar tidak crash jika salah satu bernilai null
      kategoritopping: KategoriToppingModels.fromJson(
        json['kategori'] ?? json['kategoritopping'] ?? {'id': 0, 'nama': ''},
      ),
    );
  }

  /// ✅ PERBAIKAN: Menyimpan objek utuh kategori agar saat dibaca ulang oleh GetStorage tidak null
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'harga': harga,
      'stok': stok,
      'gambarUrl': gambarUrl,
      'lastUpdate': lastUpdate,
      'selectedQuantity': selectedQuantity,
      'kategoritopping': kategoritopping.toJson(), // 🔴 WAJIB: Ikut disimpan dalam bentuk Map
    };
  }
}