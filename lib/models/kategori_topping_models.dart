class KategoriToppingModels {
  final int id;
  final String nama;

  KategoriToppingModels({
    required this.id,
    required this.nama,
  });

  factory KategoriToppingModels.fromJson(Map<String, dynamic> json) {
    return KategoriToppingModels(
      // Mengikuti pola perbaikan lo: cek ID spesifik database, lalu ID umum, lalu default 0
      id: json['id_kategori_topping'] ?? json['id'] ?? 0,
      
      // Memastikan nama diconvert ke String dan handle null
      nama: json['nama']?.toString() ?? '',
    );
  }

  // Untuk memudahkan debugging
  @override
  String toString() {
    return 'KategoriToppingModels(id: $id, nama: $nama)';
  }
}