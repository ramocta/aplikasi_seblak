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
      id: json['id'] ?? 0,
      nama: json['nama']?.toString() ?? '',
      harga: json['harga'] ?? 0,
      stok: json['stok'] ?? 0,
      gambarUrl: json['gambar_url']?.toString() ?? '',
      lastUpdate: json['last_update']?.toString() ?? '-',
      kategorimenu: KategoriMenuModels.fromJson(json['kategori'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
  return {
    'id': id,
    'nama': nama,
    'harga': harga,
    'stok': stok,
    'gambarUrl': gambarUrl,
    'idKategoriMenu': kategorimenu.id, // Pastikan ini sesuai dengan struktur JSON yang diharapkan
  };
}
}
