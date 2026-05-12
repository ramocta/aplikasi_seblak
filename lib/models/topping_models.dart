import 'kategori_topping_models.dart';

class ToppingModels {
  final int id;
  final String nama;
  final int harga;
  final int stok;
  final String gambarUrl;
  final String lastUpdate;
  final KategoriToppingModels kategoritopping;

  ToppingModels ({
    required this.id,
    required this.nama,
    required this.harga,
    required this.stok,
    required this.gambarUrl,
    required this.lastUpdate,
    required this.kategoritopping,
  });

  factory ToppingModels.fromJson(
      Map<String, dynamic> json) {
    return ToppingModels(
      id: json['id'],
      nama: json['nama'],
      harga: json['harga'],
      stok: json['stok'],
      gambarUrl: json['gambar_url'],
      lastUpdate: json['last_update'],

      kategoritopping: KategoriToppingModels.fromJson(
        json['kategori'],
      ),
    );
  }
}