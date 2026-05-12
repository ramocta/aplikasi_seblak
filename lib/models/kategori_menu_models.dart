class KategoriMenuModels {
  final int id;
  final String nama;

  KategoriMenuModels({
    required this.id,
    required this.nama,
  });

  factory KategoriMenuModels.fromJson(Map<String, dynamic> json) {
    return KategoriMenuModels(
      // Perbaikan utama
      id: json['id_kategori_menu'] ?? json['id'] ?? 0,
      nama: json['nama']?.toString() ?? '',
    );
  }

  // Untuk memudahkan debugging
  @override
  String toString() {
    return 'KategoriMenuModels(id: $id, nama: $nama)';
  }
}