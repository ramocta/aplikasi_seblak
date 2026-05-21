import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../models/transaction_models.dart';
import '../../models/transaction_detail_models.dart';
import '../../services/transactions_services.dart';
import '../../core/constans/app_assets.dart';
import '../widgets/order_status_popup.dart';
import '../widgets/payment_instruction_sheet.dart';
import '../widgets/custom_button.dart'; // ✅ Pastikan CustomButton terimport dengan benar

class DetailTransactionPage extends StatefulWidget {
  final TransactionModel transaction;

  const DetailTransactionPage({super.key, required this.transaction});

  @override
  State<DetailTransactionPage> createState() =>
      _DetailTransactionPageState();
}

class _DetailTransactionPageState extends State<DetailTransactionPage> {
  final TransactionService _transactionService = TransactionService();

  TransactionDetailModel? _detail;
  bool _isLoading = true;
  String _errorMessage = '';
  String _lastStatus = 'pending';
  bool _popupShown = false;

  // ✅ Timer untuk polling setiap 5 detik
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _fetchDetail();
    _startPolling();
  }

  @override
  void dispose() {
    // ✅ Wajib cancel timer saat page ditutup
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchDetail() async {
    try {
      final detail = await _transactionService
          .getTransactionDetailCustomer(widget.transaction.idTransaksi!);

      if (!mounted) return;

      final String newStatus = detail.statusPesanan;

      // ✅ Cek apakah status berubah dari sebelumnya
      if (newStatus != _lastStatus && !_popupShown) {
        if (newStatus == 'done' || newStatus == 'reject') {
          _popupShown = true;
          // ✅ Stop polling saat status sudah final
          _pollingTimer?.cancel();

          // Tampilkan popup setelah setState selesai
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              OrderStatusPopup.show(
                context,
                isSuccess: newStatus == 'done',
              );
            }
          });
        }
      }

      setState(() {
        _detail = detail;
        _lastStatus = newStatus;
        _isLoading = false;
        _errorMessage = '';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceAll('Exception:', '').trim();
      });
    }
  }

  void _startPolling() {
    // ✅ Polling setiap 5 detik selama status masih pending
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (_lastStatus == 'pending') {
        _fetchDetail();
      } else {
        // Status sudah final, stop polling
        _pollingTimer?.cancel();
      }
    });
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'done':
        return Colors.green[700]!;
      case 'reject':
        return Colors.red[700]!;
      default:
        return const Color(0xFFE8A838);
    }
  }

  Color _statusBgColor(String status) {
    switch (status) {
      case 'done':
        return Colors.green.withOpacity(0.12);
      case 'reject':
        return Colors.red.withOpacity(0.1);
      default:
        return const Color(0xFFFFF3E0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tx = widget.transaction;
    final String orderId =
        'Order#${tx.idTransaksi?.toString().padLeft(3, '0') ?? '000'}';
    final bool isTunai = tx.paymentMethod == 'tunai';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FB),
      // ✅ Merapikan Header & AppBar sesuai mockup gambar
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Transparan agar menyatu dengan background body
        elevation: 0,
        toolbarHeight: 70, // Memberikan ruang vertikal yang pas bagi logo
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFDE3905)),
          onPressed: () => context.go('/menu'),
        ),
        title: Padding(
          padding: const EdgeInsets.only(top: 12.0),
          child: Image.asset(AppAssets.logo2, height: 48, fit: BoxFit.contain), // Ukuran logo yang proporsional
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFDE3905),
              ),
            )
          : _errorMessage.isNotEmpty
              ? _buildError()
              : _buildContent(orderId, isTunai),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _errorMessage = '';
                });
                _fetchDetail();
              },
              child: const Text("Coba Lagi",
                  style: TextStyle(color: Color(0xFFDE3905))),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(String orderId, bool isTunai) {
    final detail = _detail!;
    final String tanggal = detail.createdAt != null
        ? DateFormat('dd-MM-yyyy HH:mm').format(detail.createdAt!)
        : '-';
    final String modeDisplay =
        detail.opsiPemesanan == 'dine in' ? 'Dine In' : 'Take Away';

    // ✅ Deteksi status akhir untuk mengubah tombol instruksi jadi "Back to Homepage"
    final bool isStatusFinal = _lastStatus == 'done' || _lastStatus == 'reject';

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 30),
          child: ConstrainedBox(
            // ✅ Mengatur tinggi minimal agar Column dapat memakai sumbu vertikal penuh
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight - 42,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // ✅ Menggeser komponen utama ke tengah vertikal
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status Pesanan
                const Text(
                  "Status Transaksi",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: _statusBgColor(detail.statusPesanan),
                    borderRadius: BorderRadius.circular(20),
                    border: detail.statusPesanan == 'reject'
                        ? Border.all(color: Colors.red[700]!, width: 1.5)
                        : null,
                  ),
                  child: Text(
                    detail.statusPesanan,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _statusColor(detail.statusPesanan),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Info sedang diproses
                if (detail.statusPesanan == 'pending')
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      "Your order is being processed. Please wait",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),

                // Card detail transaksi
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow("ID", orderId),
                      const SizedBox(height: 6),
                      _buildInfoRow("Nama", detail.namaPemesan),
                      const SizedBox(height: 6),
                      _buildInfoRow("Date", tanggal),
                      if (detail.noMeja != null) ...[
                        const SizedBox(height: 6),
                        _buildInfoRow("No. Meja", detail.noMeja!),
                      ],
                      const SizedBox(height: 6),
                      _buildInfoRow("Mode", modeDisplay),
                      const SizedBox(height: 6),
                      _buildInfoRow("Payment", detail.paymentMethod.toCapitalized()),

                      const Divider(height: 24, color: Color(0xFFEEEEEE)),

                      // List item pesanan dari database
                      ...detail.items.map((item) => _buildItemRow(item)),

                      const Divider(height: 24, color: Color(0xFFEEEEEE)),

                      // Total
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Total",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "Rp. ${detail.hargaTotal.toStringAsFixed(0)}",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFDE3905),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // ✅ KONDISIONAL TOMBOL: Jika status BELUM Selesai/Batal, tampilkan cara bayar (bila tunai)
                if (!isStatusFinal && isTunai) ...[
                  const Text(
                    "Payment Instructions",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () => PaymentInstructionSheet.show(
                      context,
                      orderId: orderId,
                      totalHarga: detail.hargaTotal,
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDE3905),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "How to Make Payment",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Icon(Icons.keyboard_arrow_down,
                              color: Colors.white, size: 22),
                        ],
                      ),
                    ),
                  ),
                ],

                // ✅ KONDISIONAL TOMBOL: Jika status SUDAH Selesai ('done') atau Batal ('reject')
                if (isStatusFinal) ...[
                  CustomButton(
                    text: "Back to Homepage",
                    onPressed: () {
                      context.go('/welcome'); // Mengarahkan kembali ke halaman welcome kiosk
                    },
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildItemRow(PesananItemModel item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${item.menu.namaMenu} x ${item.qty}",
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Text(
                "Rp. ${item.hargaSatuan.toStringAsFixed(0)}",
                style: const TextStyle(
                    fontSize: 13, color: Colors.black54),
              ),
            ],
          ),

          if (item.toppings.isNotEmpty) ...[
            const SizedBox(height: 4),
            const Text(
              "Topping:",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
            ...item.toppings.map(
              (t) => Padding(
                padding: const EdgeInsets.only(left: 8, top: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${t.namaTopping} x ${t.qty}",
                      style: const TextStyle(
                          fontSize: 11, color: Colors.black45),
                    ),
                    Text(
                      "Rp. ${t.hargaSatuan.toStringAsFixed(0)}",
                      style: const TextStyle(
                          fontSize: 11, color: Colors.black45),
                    ),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              "Rp. ${item.subtotal.toStringAsFixed(0)}",
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFFDE3905),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, color: Colors.black54),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            ":",
            style: TextStyle(fontSize: 13, color: Colors.black54),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

extension CapitalizeString on String {
  String toCapitalized() => isNotEmpty 
      ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}' 
      : '';
}