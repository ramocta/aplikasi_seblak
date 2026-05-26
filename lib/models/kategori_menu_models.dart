class KategoriMenuModels {
  final int id;
  final String nama;

  KategoriMenuModels({
    required this.id,
    required this.nama,
  });

    factory KategoriMenuModels.fromJson(Map<String, dynamic> json) {
    return KategoriMenuModels(
      // Tambahkan int.tryParse untuk memastikan tipe data selalu int
      id: int.tryParse(json['id_kategori_menu']?.toString() ?? json['id']?.toString() ?? '0') ?? 0,
      nama: json['nama']?.toString() ?? 'Kategori Tidak Dikenal',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_kategori_menu': id,
      'nama': nama,
    };
  }

  // Untuk memudahkan debugging
  @override
  String toString() {
    return 'KategoriMenuModels(id: $id, nama: $nama)';
  }
}