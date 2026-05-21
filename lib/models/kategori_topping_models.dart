class KategoriToppingModels {
  final int id;
  final String nama;

  KategoriToppingModels({

    required this.id,
    required this.nama,

  });

  factory KategoriToppingModels.fromJson(
      Map<String, dynamic> json) {
    return KategoriToppingModels(
      id: json['id_kategori_topping']  ?? json['id'] ?? 0,
      nama: json['nama'] ?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_kategori_topping': id,
      'nama': nama,
    };
  }

  @override
  String toString() {
    return 'KategoriToppingModels(id: $id, nama: $nama)';
  }
}