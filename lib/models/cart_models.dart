// 1. Model untuk menampung detail topping
class ToppingItem {
  final int id;
  final String nama;
  final int harga;
  int quantity;

  ToppingItem({
    required this.id, 
    required this.nama, 
    required this.harga, 
    this.quantity = 0,
  });

  factory ToppingItem.fromJson(Map<String, dynamic> json) {
    return ToppingItem(
       id: json['id'] ?? 0,
      nama: json['nama'] ?? '',
      // Ambil harga dengan aman jika dari API bertipe double/string
      harga: json['harga'] is int 
          ? json['harga'] 
          : int.tryParse(json['harga']?.toString() ?? '0') ?? 0,
      quantity: json['quantity'] is int 
          ? json['quantity'] 
          : int.tryParse(json['quantity']?.toString() ?? '0') ?? 0,
    );
  }

  // Menambahkan properti toJson jika nanti data dikirim ke Backend Laravel
  Map<String, dynamic> toJson() {
    return {
      'id': id, 
      'nama': nama,
      'harga': harga,
      'quantity': quantity,
    };
  }
}

// 2. Update CartItem
class CartItem {
  final dynamic id;
  final int idKategoriMenu; // 🔴 PERBAIKAN: Ubah dari String ke int agar sinkron dengan UI
  final String nama;
  final int harga;
  final String gambarUrl;
  int quantity;
  final List<ToppingItem> selectedToppings; // Menggunakan List biasa (non-const default di constructor)

  CartItem({
    required this.id,
    required this.idKategoriMenu, // 🔴 Wajib int
    this.nama = '',
    this.harga = 0,
    this.gambarUrl = '',
    this.quantity = 1,
    required this.selectedToppings, // 🔴 Ubah menjadi required atau berikan list kosong yang aman
  });

  CartItem copyWith({
    dynamic id,
    int? idKategoriMenu, // 🔴 Ubah ke int?
    String? nama,
    int? harga,
    String? gambarUrl,
    int? quantity,
    List<ToppingItem>? selectedToppings,
  }) {
    return CartItem(
      id: id ?? this.id,
      idKategoriMenu: idKategoriMenu ?? this.idKategoriMenu,
      nama: nama ?? this.nama,
      harga: harga ?? this.harga,
      gambarUrl: gambarUrl ?? this.gambarUrl,
      quantity: quantity ?? this.quantity,
      selectedToppings: selectedToppings ?? this.selectedToppings,
    );
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    // 🔴 Perbaikan parsing selectedToppings dari JSON agar dinamis
    var toppingList = json['selected_toppings'] as List?;
    List<ToppingItem> parsedToppings = toppingList != null
        ? toppingList.map((t) => ToppingItem.fromJson(t)).toList()
        : [];

    return CartItem(
      id: json['id'] ?? '',
      // 🔴 Ambil id_kategori_menu dengan aman sebagai int
      idKategoriMenu: json['id_kategori_menu'] is int
          ? json['id_kategori_menu']
          : int.tryParse(json['id_kategori_menu']?.toString() ?? '0') ?? 0,
      nama: json['nama'] ?? '',
      harga: json['harga'] is int 
          ? json['harga'] 
          : int.tryParse(json['harga']?.toString() ?? '0') ?? 0,
      gambarUrl: json['gambar_url'] ?? '',
      quantity: json['quantity'] is int 
          ? json['quantity'] 
          : int.tryParse(json['quantity']?.toString() ?? '1') ?? 1,
      selectedToppings: parsedToppings, // ✅ Masukkan hasil parse topping
    );
  }

  // Menambahkan properti toJson jika struktur Cart di-save ke Local Storage / Shared Preferences
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_kategori_menu': idKategoriMenu,
      'nama': nama,
      'harga': harga,
      'gambar_url': gambarUrl,
      'quantity': quantity,
      'selected_toppings': selectedToppings.map((t) => t.toJson()).toList(),
    };
  }
}