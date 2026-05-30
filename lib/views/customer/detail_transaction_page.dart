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
import '../widgets/custom_button.dart';
import '../../utils/currency_format.dart';

class DetailTransactionPage extends StatefulWidget {
  final TransactionModel transaction;

  const DetailTransactionPage({super.key, required this.transaction});

  @override
  State<DetailTransactionPage> createState() => _DetailTransactionPageState();
}

class _DetailTransactionPageState extends State<DetailTransactionPage>
    with SingleTickerProviderStateMixin {
  final TransactionService _transactionService = TransactionService();

  TransactionDetailModel? _detail;
  bool _isLoading = true;
  String _errorMessage = '';
  String _lastStatus = 'pending';
  bool _popupShown = false;

  Timer? _pollingTimer;
  late AnimationController _blinkController;

  @override
  void initState() {
    super.initState();
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _fetchDetail();
    _startPolling();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _blinkController.dispose();
    super.dispose();
  }

  Future<void> _fetchDetail() async {
    try {
      final detail = await _transactionService
          .getTransactionDetailCustomer(widget.transaction.idTransaksi!);

      if (!mounted) return;

      final String newStatus = detail.statusPesanan;

      if (newStatus != _lastStatus && !_popupShown) {
        if (newStatus == 'done' || newStatus == 'reject') {
          _popupShown = true;
          _pollingTimer?.cancel();
          _blinkController.stop();

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
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (_lastStatus == 'pending') {
        _fetchDetail();
      } else {
        _pollingTimer?.cancel();
      }
    });
  }

  // 💡 Fungsi untuk menampilkan popup konfirmasi keluar / batalkan order
  Future<bool> _showDiscardDialog() async {
    // Jika status transaksi sudah sukses/reject, izinkan langsung keluar tanpa konfirmasi
    if (_lastStatus != 'pending') return true;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // Mengharuskan user memilih salah satu tombol
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            "Discard this order?",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.black87,
            ),
          ),
          content: const Text(
            "Please wait until the cashier verifies your order.",
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
              height: 1.4,
            ),
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            // Tombol Discard (Membatalkan & Menghapus transaksi)
            TextButton(
              onPressed: () async {
                // Tutup Dialog terlebih dahulu dengan membawa nilai true
                Navigator.of(context).pop(true);
              },
              child: const Text(
                "Discard",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Tombol Keep Waiting (Batal keluar, tetap di page)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text(
                "Keep Waiting",
                style: TextStyle(
                  color: Color(0xFFDE3905),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );

    // Jika user memilih Discard (result == true), jalankan proses hapus backend
    if (result == true) {
      try {
        // Tampilkan loading indikator sejenak saat menghapus
        setState(() => _isLoading = true);
        
        // 💡 Eksekusi hapus order dari service backend Anda
        await _transactionService.cancelOrDeleteTransaction(widget.transaction.idTransaksi!);
        
        return true; // Izinkan navigasi keluar (ke /menu)
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Gagal menghapus order: $e")),
          );
        }
        return false; // Gagal hapus, tahan user di page
      }
    }

    return false; // User memilih Keep Waiting
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

    // 💡 Bungkus Scaffold dengan PopScope untuk menangani tombol Back fisik/gesture HP
    return PopScope(
      canPop: false, // Kunci back otomatis agar dikendalikan oleh onPopInvokedWithResult
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        
        final shouldPop = await _showDiscardDialog();
        if (shouldPop && context.mounted) {
          context.go('/welcome');
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F6FB),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          toolbarHeight: 70,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFFDE3905)),
            onPressed: () async {
              // 💡 Panggil fungsi dialog yang sama saat icon panah kembali ditekan
              final shouldPop = await _showDiscardDialog();
              if (shouldPop && context.mounted) {
                context.go('/welcome');
              }
            },
          ),
          title: Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Image.asset(AppAssets.logo2, height: 100, fit: BoxFit.contain),
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
      ),
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

    final bool isStatusFinal = _lastStatus == 'done' || _lastStatus == 'reject';

    String statusInfoText = "Your order is being processed. Please wait";
    if (_lastStatus == 'done') {
      statusInfoText = "Your order is successful. Thank you for ordering";
    } else if (_lastStatus == 'reject') {
      statusInfoText = "Your order was rejected. Please contact the cashier";
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 30),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight - 46,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
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

                const SizedBox(height: 20),

                // Teks Informasi Dinamis & Animasi Berkedip
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: _lastStatus == 'pending'
                        ? FadeTransition(
                            opacity: _blinkController,
                            child: Text(
                              statusInfoText,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.black54,
                              ),
                            ),
                          )
                        : Text(
                            statusInfoText,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: _lastStatus == 'done'
                                  ? Colors.green[700]
                                  : Colors.red[700],
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 16),

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
                            CurrencyFormat.convertToIdr(detail.hargaTotal),
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

                // KONDISIONAL TOMBOL Cara Bayar
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

                // KONDISIONAL TOMBOL Selesai / Batal
                if (isStatusFinal) ...[
                  CustomButton(
                    text: "Back to Homepage",
                    onPressed: () {
                      context.go('/welcome');
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
  // 💡 Hitung total harga dari semua topping yang ada pada item ini
  // Formula: hargaSatuanTopping * qtyTopping
  int totalHargaTopping = item.toppings.fold<int>(
  0, 
  (sum, t) => sum + (t.hargaSatuan * t.qty).toInt(),
);

// 💡 Lakukan hal yang sama pada subtotal final untuk memastikan keamanan tipe data
int subtotalFinal = (item.hargaSatuan * item.qty).toInt() + totalHargaTopping;

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
              CurrencyFormat.convertToIdr(item.hargaSatuan),
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
                    CurrencyFormat.convertToIdr(t.hargaSatuan),
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
            // 💡 Menggunakan hasil perhitungan akumulasi subtotal final baru
            CurrencyFormat.convertToIdr(subtotalFinal),
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