

class TransactionDetailModel {
  final int idTransaksi;
  final String namaPemesan;
  final String? noMeja;
  final String opsiPemesanan;
  final String paymentMethod;
  final String statusPesanan;
  final double hargaTotal;
  final String? proofPaymentUrl;
  final DateTime? createdAt;
  final List<PesananItemModel> items;

  TransactionDetailModel({
    required this.idTransaksi,
    required this.namaPemesan,
    this.noMeja,
    required this.opsiPemesanan,
    required this.paymentMethod,
    required this.statusPesanan,
    required this.hargaTotal,
    this.proofPaymentUrl,
    this.createdAt,
    required this.items,
  });

  factory TransactionDetailModel.fromJson(Map<String, dynamic> json) {
    final list = json['items'] as List? ?? [];
    return TransactionDetailModel(
      idTransaksi: json['id_transaksi'] ?? 0,
      namaPemesan: json['nama_pemesan'] ?? '',
      noMeja: json['no_meja'],
      opsiPemesanan: json['opsi_pemesanan'] ?? '',
      paymentMethod: json['payment_method'] ?? '',
      statusPesanan: json['status_pesanan'] ?? 'pending',
      hargaTotal: double.tryParse(json['harga_total'].toString()) ?? 0.0,
      proofPaymentUrl: json['proof_payment_url'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      items: list.map((i) => PesananItemModel.fromJson(i)).toList(),
    );
  }
}

class PesananItemModel {
  final int idPesananMenu;
  final int qty;
  final double hargaSatuan;
  final double subtotal;
  final PesananMenuDetail menu;
  final List<PesananToppingItemModel> toppings;

  PesananItemModel({
    required this.idPesananMenu,
    required this.qty,
    required this.hargaSatuan,
    required this.subtotal,
    required this.menu,
    required this.toppings,
  });

  factory PesananItemModel.fromJson(Map<String, dynamic> json) {
    final subList = json['pesanan_toppings'] as List? ?? [];
    return PesananItemModel(
      idPesananMenu: json['id_pesanan_menu'] ?? 0,
      qty: json['qty'] ?? 0,
      hargaSatuan:
          double.tryParse(json['harga_satuan'].toString()) ?? 0.0,
      subtotal: double.tryParse(json['subtotal'].toString()) ?? 0.0,
      menu: PesananMenuDetail.fromJson(json['menu'] ?? {}),
      toppings: subList
          .map((t) => PesananToppingItemModel.fromJson(t))
          .toList(),
    );
  }
}

class PesananMenuDetail {
  final int idMenu;
  final int idKategoriMenu;
  final String namaMenu;
  final double harga;
  final String? gambar;

  PesananMenuDetail({
    required this.idMenu,
    required this.idKategoriMenu,
    required this.namaMenu,
    required this.harga,
    this.gambar,
  });

  factory PesananMenuDetail.fromJson(Map<String, dynamic> json) {
    return PesananMenuDetail(
      idMenu: json['id_menu'] ?? 0,
      idKategoriMenu: json['id_kategori_menu'] ?? 0,
      namaMenu: json['nama_menu'] ?? '',
      harga: double.tryParse(json['harga'].toString()) ?? 0.0,
      gambar: json['gambar'],
    );
  }
}

class PesananToppingItemModel {
  final int qty;
  final double hargaSatuan;
  final double subtotal;
  final String namaTopping;

  PesananToppingItemModel({
    required this.qty,
    required this.hargaSatuan,
    required this.subtotal,
    required this.namaTopping,
  });

  factory PesananToppingItemModel.fromJson(Map<String, dynamic> json) {
    return PesananToppingItemModel(
      qty: json['qty'] ?? 0,
      hargaSatuan:
          double.tryParse(json['harga_satuan'].toString()) ?? 0.0,
      subtotal: double.tryParse(json['subtotal'].toString()) ?? 0.0,
      namaTopping: json['topping'] != null
        ? (json['topping']['nama_topping'] ?? '')
        : '',
    );
  }
}