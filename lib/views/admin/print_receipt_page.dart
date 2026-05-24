import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../controllers/order_controller.dart';

class PrintReceiptPage extends StatefulWidget {
  final String orderId;

  const PrintReceiptPage({super.key, required this.orderId});

  @override
  State<PrintReceiptPage> createState() => _PrintReceiptPageState();
}

class _PrintReceiptPageState extends State<PrintReceiptPage> {
  final OrderController controller = Get.find<OrderController>();
  bool isGenerating = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await controller.fetchOrderDetail(widget.orderId);
      setState(() {
        isGenerating = false;
      });
    });
  }

  // =========================================================================
  // LOGIKA BACKEND PDF: BERJALAN DI BALIK LAYAR SAAT TOMBOL "CETAK PDF" DIKLIK
  // =========================================================================
  Future<pw.Document> _generateReceiptFile() async {
    final pdf = pw.Document();
    final items = controller.currentOrderItems;
    final subtotal = controller.subtotal;
    final grandTotal = controller.grandTotal;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80, // Ukuran kertas thermal struk kasir
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            color: PdfColors.white,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Center(
                  child: pw.Text("SAY CAFE", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
                ),
                pw.SizedBox(height: 2),
                pw.Center(
                  child: pw.Text("Stall #04 - Food Junction Central", style: pw.TextStyle(fontSize: 8)),
                ),
                pw.SizedBox(height: 8),
                pw.Divider(borderStyle: pw.BorderStyle.dashed, thickness: 0.5),
                
                pw.Text("Order ID: #SB-${widget.orderId.padLeft(4, '0')}", style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                pw.Text("Tanggal: ${DateTime.now().toString().substring(0, 16).replaceAll('-', '/')}", style: pw.TextStyle(fontSize: 8)),
                pw.Divider(borderStyle: pw.BorderStyle.dashed, thickness: 0.5),

                // Looping item di file cetak PDF
                ...items.map((item) {
                  if (item == null) return pw.SizedBox.shrink();
                  String namaMenu = item['nama_menu'] ?? item['menu']?['nama_menu'] ?? "Menu";
                  int qty = int.tryParse(item['qty']?.toString() ?? item['jumlah']?.toString() ?? "1") ?? 1;
                  double hargaSatuan = double.tryParse(item['harga_satuan']?.toString() ?? item['menu']?['harga']?.toString() ?? "0") ?? 0.0;
                  double totalHargaItem = hargaSatuan * qty;

                  return pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 3),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text("$qty" "x $namaMenu", style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                            pw.Text("Rp${totalHargaItem.toInt()}", style: pw.TextStyle(fontSize: 9)),
                          ],
                        ),
                        if (item['toppings'] != null || item['pesanan_toppings'] != null)
                          ...((item['toppings'] ?? item['pesanan_toppings'] ?? []) as List).map((t) {
                            String namaTopping = t['nama_topping'] ?? t['topping']?['nama_topping'] ?? "Topping";
                            return pw.Padding(
                              padding: const pw.EdgeInsets.only(left: 10),
                              child: pw.Text("+ $namaTopping", style: pw.TextStyle(fontSize: 7.5, color: PdfColors.grey700)),
                            );
                          }).toList(),
                      ],
                    ),
                  );
                }).toList(),

                pw.Divider(borderStyle: pw.BorderStyle.solid, thickness: 0.5),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text("Subtotal:", style: pw.TextStyle(fontSize: 9)),
                    pw.Text("Rp${subtotal.toInt()}", style: pw.TextStyle(fontSize: 9)),
                  ],
                ),
                pw.SizedBox(height: 2),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text("TOTAL BAYAR:", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
                    pw.Text("Rp${grandTotal.toInt()}", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
    return pdf;
  }

  @override
  Widget build(BuildContext context) {
    // Ambil data real-time untuk visualisasi UI di aplikasi agar singkron dengan order summary
    final items = controller.currentOrderItems;
    final subtotal = controller.subtotal;
    final grandTotal = controller.grandTotal;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Cetak Struk", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
      ),
      backgroundColor: Colors.white, // Menjamin full layar putih bersih polosan tanpa background abu-abu
      body: isGenerating
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE64A19)),
              ),
            )
          : Column(
              children: [
                // =========================================================================
                // VIEW PRATINJAU: MENGGUNAKAN FLUTTER WIDGET BIASA (RESPONSIF & PUTIH POLOS)
                // =========================================================================
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                    child: Container(
                      color: Colors.white,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Center(
                            child: Text(
                              "Say Cafe",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.black),
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Center(
                            child: Text("Stall #04 - Food Junction Central", style: TextStyle(fontSize: 12, color: Colors.black54)),
                          ),
                          const SizedBox(height: 15),
                          const Text("-------------------------------------------------------------------------", style: TextStyle(color: Colors.black12)),
                          
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Order ID: #SB-${widget.orderId.padLeft(4, '0')}", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                              Text(DateTime.now().toString().substring(0, 16).replaceAll('-', '/'), style: const TextStyle(fontSize: 12, color: Colors.black54)),
                            ],
                          ),
                          const Text("-------------------------------------------------------------------------", style: TextStyle(color: Colors.black12)),
                          const SizedBox(height: 8),

                          // Render Daftar Menu & Topping di UI Aplikasi
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: items.length,
                            itemBuilder: (context, index) {
                              final item = items[index];
                              if (item == null) return const SizedBox.shrink();

                              String namaMenu = item['nama_menu'] ?? item['menu']?['nama_menu'] ?? "Menu";
                              int qty = int.tryParse(item['qty']?.toString() ?? item['jumlah']?.toString() ?? "1") ?? 1;
                              double hargaSatuan = double.tryParse(item['harga_satuan']?.toString() ?? item['menu']?['harga']?.toString() ?? "0") ?? 0.0;
                              double totalHargaItem = hargaSatuan * qty;

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("$qty" "x $namaMenu", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                                        Text("Rp${totalHargaItem.toInt()}", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                                      ],
                                    ),
                                    // Render data topping pendukung secara dinamis di bawahnya
                                    if (item['toppings'] != null || item['pesanan_toppings'] != null)
                                      ...((item['toppings'] ?? item['pesanan_toppings'] ?? []) as List).map((t) {
                                        String namaTopping = t['nama_topping'] ?? t['topping']?['nama_topping'] ?? "Topping";
                                        return Padding(
                                          padding: const EdgeInsets.only(left: 14, top: 2),
                                          child: Text("+ $namaTopping", style: const TextStyle(fontSize: 12, color: Colors.black54, fontStyle: FontStyle.italic)),
                                        );
                                      }).toList(),
                                  ],
                                ),
                              );
                            },
                          ),

                          const Text("-------------------------------------------------------------------------", style: TextStyle(color: Colors.black12)),
                          const SizedBox(height: 6),

                          // Bagian Ringkasan Harga (SINKRON DENGAN DATA TOTAL HARGA CONTROLLER)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Subtotal", style: TextStyle(fontSize: 14, color: Colors.black54)),
                              Text("Rp${subtotal.toInt()}", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("TOTAL BAYAR", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black)),
                              Text("Rp${grandTotal.toInt()}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFD84315))),
                            ],
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // =========================================================================
                // LAYOUT TOMBOL AKSI STABIL DI BAGIAN BAWAH KERTAS
                // =========================================================================
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  color: Colors.white,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Tombol 1: CETAK PDF
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD84315), 
                          minimumSize: const Size.fromHeight(50),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 0,
                        ),
                        onPressed: () async {
                          final doc = await _generateReceiptFile();
                          await Printing.layoutPdf(onLayout: (format) async => doc.save());
                        },
                        icon: const Icon(Icons.print, color: Colors.white),
                        label: const Text("CETAK PDF", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                      ),
                      const SizedBox(height: 10),
                      
                      // Tombol 2: Back to Dashboard
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                          side: BorderSide.none, 
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          backgroundColor: const Color(0xFFE0E0E0), 
                        ),
                        // DIUBAH DISINI: Dari context.pop() menjadi context.go('/dashboard')
                        onPressed: () => context.go('/dashboard'),
                        child: const Text(
                          "Back to Dashboard", 
                          style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
    );
  }
}