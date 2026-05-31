class TransactionModel {
  final int? idTransaksi;
  final int? idUser;
  final String namaPemesan;
  final String? noMeja;
  final String opsiPemesanan;
  final String paymentMethod;
  final String statusPesanan;
  final String? proofPayment;
  final double hargaTotal;
  final DateTime? createdAt;

  TransactionModel({
    this.idTransaksi,
    this.idUser,
    required this.namaPemesan,
    this.noMeja,
    required this.opsiPemesanan,
    required this.paymentMethod,
    this.statusPesanan = 'pending',
    this.proofPayment,
    required this.hargaTotal,
    this.createdAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      idTransaksi: json['id_transaksi'],
      idUser: json['id_user'],
      namaPemesan: json['nama_pemesan'] ?? '',
      noMeja: json['no_meja'],
      opsiPemesanan: json['opsi_pemesanan'] ?? '',
      paymentMethod: json['payment_method'] ?? '',
      statusPesanan: json['status_pesanan'] ?? 'pending',
      proofPayment: json['proof_payment'],
      hargaTotal: double.tryParse(json['harga_total'].toString()) ?? 0.0,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_transaksi': idTransaksi,
      'id_user': idUser,
      'nama_pemesan': namaPemesan,
      'no_meja': noMeja,
      'opsi_pemesanan': opsiPemesanan,
      'payment_method': paymentMethod,
      'status_pesanan': statusPesanan,
      'proof_payment': proofPayment,
      'harga_total': hargaTotal,
    };
  }
}