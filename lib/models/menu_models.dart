import 'kategori_menu_models.dart';

class MenuModels {
  final int id;
  final String nama;
  final int harga;
  final int stok;
  final String gambarUrl;
  final String lastUpdate;
  final KategoriMenuModels kategorimenu;

  MenuModels({
    required this.id,
    required this.nama,
    required this.harga,
    required this.stok,
    required this.gambarUrl,
    required this.lastUpdate,
    required this.kategorimenu,
  });

  factory MenuModels.fromJson(Map<String, dynamic> json) {
    return MenuModels(
      // SINKRONKAN DENGAN FIELD MYSQL LARAVEL: id_menu & nama_menu atau id murni jika dari index
      id: json['id_menu'] ?? json['id'] ?? 0,
      nama: json['nama_menu']?.toString() ?? json['nama']?.toString() ?? '',
      harga: json['harga'] ?? 0,
      stok: json['stok'] ?? 0,
      gambarUrl: json['gambar_url']?.toString() ?? '', 
      lastUpdate: json['last_update']?.toString() ?? '-', 
      kategorimenu: KategoriMenuModels.fromJson(
        json['kategori'] ?? {},
      ),  
    );
  }

  MenuModels copyWith({
    int? id,
    String? nama,
    int? harga,
    int? stok,
    String? gambarUrl,
    String? lastUpdate,
    KategoriMenuModels? kategorimenu,
  }) {
    return MenuModels(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      harga: harga ?? this.harga,
      stok: stok ?? this.stok,
      gambarUrl: gambarUrl ?? this.gambarUrl,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      kategorimenu: kategorimenu ?? this.kategorimenu,
    );
  }
}