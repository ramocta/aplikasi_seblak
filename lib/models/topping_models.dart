import 'kategori_topping_models.dart';

class ToppingModels {
  final int id;
  final String nama;
  final int harga;
  final int stok;
  final String gambarUrl;
  final String lastUpdate;
  final KategoriToppingModels? kategoritopping; 

  ToppingModels({
    required this.id,
    required this.nama,
    required this.harga,
    required this.stok,
    required this.gambarUrl,
    required this.lastUpdate,
    this.kategoritopping,
  });

  factory ToppingModels.fromJson(Map<String, dynamic> json) {
    return ToppingModels(
      // SINKRONKAN DENGAN FIELD MYSQL LARAVEL: id_topping & nama_topping
      id: json['id_topping'] ?? json['id'] ?? 0,
      nama: json['nama_topping']?.toString() ?? json['nama']?.toString() ?? '', 
      harga: int.tryParse(json['harga'].toString()) ?? 0,
      stok: int.tryParse(json['stok'].toString()) ?? 0,
      gambarUrl: json['gambar_url']?.toString() ?? '', 
      lastUpdate: json['last_update']?.toString() ?? '',
      kategoritopping: json['kategori'] != null 
          ? KategoriToppingModels.fromJson(json['kategori']) 
          : null,
    );
  }

  ToppingModels copyWith({
    int? id,
    String? nama,
    int? harga,
    int? stok,
    String? gambarUrl,
    String? lastUpdate,
    KategoriToppingModels? kategoritopping,
  }) {
    return ToppingModels(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      harga: harga ?? this.harga,
      stok: stok ?? this.stok,
      gambarUrl: gambarUrl ?? this.gambarUrl,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      kategoritopping: kategoritopping ?? this.kategoritopping,
    );
  }
}