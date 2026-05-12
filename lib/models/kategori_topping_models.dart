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
      id: json['id'],
      nama: json['nama'],
    );
  }
}